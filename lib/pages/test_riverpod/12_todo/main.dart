import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 12 Todo 实战 —— 综合运用所有 Riverpod 特性
///
/// 本示例综合使用了以下 Riverpod 核心特性：
/// 1. StateNotifier —— 管理复杂的 Todo 列表状态
/// 2. Provider 依赖 —— filteredTodosProvider 依赖 todoListProvider + filterProvider
/// 3. Family —— 按 id 获取单个 Todo，避免整个列表重建
/// 4. AsyncValue —— 模拟异步保存到服务器
/// 5. autoDispose —— 临时搜索关键词 Provider，离开页面自动释放
/// 6. select —— 仅监听完成数量变化，优化重建性能
///
/// ┌─────────────────────────────────────────────────────────────────┐
/// │                         Provider 关系图                          │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                 │
/// │   todoListProvider (StateNotifierProvider)                      │
/// │        │                                                        │
/// │        ├────► filteredTodosProvider (Provider) ◄──── filterProvider
/// │        │              │                                         │
/// │        │              └────► UI 显示过滤后的列表                  │
/// │        │                                                        │
/// │        ├────► todoItemProvider.family (Provider.family)         │
/// │        │              │                                         │
/// │        │              └────► 单个 Todo 编辑项（避免整列表重建）    │
/// │        │                                                        │
/// │        ├────► todoSaveProvider (FutureProvider.autoDispose)     │
/// │        │              │                                         │
/// │        │              └────► 异步保存，显示 loading 状态          │
/// │        │                                                        │
/// │        └────► 使用 select 监听 completedCount 变化               │
/// │                   │                                             │
/// │                   └────► 底部统计栏（仅数字变化时重建）            │
/// │                                                                 │
/// │   searchKeywordProvider (StateProvider.autoDispose)             │
/// │        │                                                        │
/// │        └────► 临时搜索，页面离开自动释放                          │
/// │                                                                 │
/// └─────────────────────────────────────────────────────────────────┘

// ==================== 数据模型 ====================

/// Todo 数据模型
class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// copyWith：不可变数据更新，Riverpod 推荐的做法
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 过滤条件枚举
enum TodoFilter { all, active, completed }

// ==================== StateNotifier：管理 Todo 列表状态 ====================

/// TodoList：使用 StateNotifier 管理列表状态
///
/// StateNotifier 的优势：
/// - 状态变更必须通过定义好的方法，避免随意修改
/// - 自动去重通知（相同状态不会触发重建）
/// - 适合管理复杂的状态逻辑
class TodoList extends StateNotifier<List<Todo>> {
  TodoList() : super([]);

  /// 添加 Todo
  void add(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    state = [...state, newTodo];
  }

  /// 切换完成状态
  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
  }

  /// 删除 Todo
  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  /// 获取已完成数量（供 select 使用）
  int get completedCount => state.where((t) => t.isCompleted).length;

  /// 获取总数（供 select 使用）
  int get totalCount => state.length;
}

// ==================== Provider 定义 ====================

/// todoListProvider：StateNotifierProvider，管理 Todo 列表
///
/// 使用 StateNotifierProvider 而不是 StateProvider，因为：
/// - 状态是复杂的 `List<Todo>`，需要封装增删改查方法
/// - 状态变更逻辑集中管理，避免分散在 UI 中
final todoListProvider = StateNotifierProvider<TodoList, List<Todo>>((ref) {
  return TodoList();
});

/// filterProvider：StateProvider，管理当前过滤条件
///
/// StateProvider 适合管理简单的值类型状态（枚举、bool、int 等）
final filterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

/// filteredTodosProvider：Provider 依赖示例
///
/// 这个 Provider 同时依赖 todoListProvider 和 filterProvider
/// 当任一依赖变化时，它会自动重新计算
/// 这是 Riverpod 的依赖注入机制，编译时就能确定依赖关系
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(filterProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((todo) => !todo.isCompleted).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.isCompleted).toList();
    case TodoFilter.all:
      return todos;
  }
});

/// todoItemProvider.family：按 id 获取单个 Todo
///
/// Family 的作用：
/// - 根据参数创建不同的 Provider 实例
/// - 每个 Todo 项可以独立监听，避免整个列表重建
/// - 适合列表中每个 item 需要独立更新的场景
///
/// 注意：参数必须是可哈希的（String、int 等）
final todoItemProvider = Provider.family<Todo?, String>((ref, id) {
  final todos = ref.watch(todoListProvider);
  try {
    return todos.firstWhere((todo) => todo.id == id);
  } catch (_) {
    return null;
  }
});

/// todoSaveProvider：FutureProvider.autoDispose，模拟异步保存
///
/// AsyncValue 的作用：
/// - 统一处理异步状态的三种情况：loading / data / error
/// - 不需要手动管理 isLoading、hasError 等状态
/// - UI 可以用 when() 方法简洁地处理不同状态
///
/// autoDispose 的作用：
/// - 当没有 Widget 监听时自动释放
/// - 适合临时操作（如保存、搜索），避免内存泄漏
final todoSaveProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, operation) async {
    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 模拟随机失败（10% 概率）
    if (Random().nextDouble() < 0.1) {
      throw Exception('保存失败：网络连接超时');
    }

    // 保存成功
    return;
  },
);

/// searchKeywordProvider：StateProvider.autoDispose
///
/// autoDispose 示例：搜索关键词只在当前页面有效
/// 离开页面后自动释放，不需要手动清理
final searchKeywordProvider = StateProvider.autoDispose<String>((ref) => '');

// ==================== 页面入口 ====================

@RoutePage()
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('12 Todo 实战 - 综合运用'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Column(
        children: [
          // 过滤条件选择
          _FilterChips(),

          // 添加 Todo 输入框
          _AddTodoField(),

          // 搜索框（autoDispose 演示）
          _SearchField(),

          // Todo 列表
          Expanded(child: _TodoList()),

          // 底部统计
          _TodoStats(),

          // 特性说明
          _FeatureNote(),
        ],
      ),
    );
  }
}

// ==================== 子组件 ====================

/// 过滤条件选择 Chips
///
/// 使用 Consumer 局部监听 filterProvider，避免整个页面重建
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip(context, ref, TodoFilter.all, '全部'),
          const SizedBox(width: 8),
          _buildFilterChip(context, ref, TodoFilter.active, '未完成'),
          const SizedBox(width: 8),
          _buildFilterChip(context, ref, TodoFilter.completed, '已完成'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    TodoFilter value,
    String label,
  ) {
    final isSelected = ref.watch(filterProvider) == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        // 修改过滤条件
        ref.read(filterProvider.notifier).state = value;
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

/// 添加 Todo 输入框
///
/// 使用 StatefulWidget 管理输入框的本地状态
/// 只有输入框内容变化时重建，不影响其他部分
class _AddTodoField extends ConsumerStatefulWidget {
  const _AddTodoField();

  @override
  ConsumerState<_AddTodoField> createState() => _AddTodoFieldState();
}

class _AddTodoFieldState extends ConsumerState<_AddTodoField> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    // 先添加到列表
    ref.read(todoListProvider.notifier).add(title);
    _controller.clear();

    // 模拟异步保存
    setState(() => _isSaving = true);

    // 触发 FutureProvider 执行保存
    final saveFuture = ref.read(todoSaveProvider('add:$title').future);

    try {
      await saveFuture;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: '输入待办事项...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          const SizedBox(width: 8),
          _isSaving
              ? const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton.filled(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                ),
        ],
      ),
    );
  }
}

/// 搜索框 —— autoDispose 演示
///
/// 搜索关键词使用 autoDispose Provider
/// 页面离开后会自动释放，不需要手动清理
class _SearchField extends ConsumerWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyword = ref.watch(searchKeywordProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: '搜索待办事项...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: keyword.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(searchKeywordProvider.notifier).state = '';
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (value) {
          ref.read(searchKeywordProvider.notifier).state = value;
        },
      ),
    );
  }
}

/// Todo 列表
///
/// 使用 Consumer 局部监听 filteredTodosProvider
/// 只有列表数据变化时才重建列表部分
class _TodoList extends ConsumerWidget {
  const _TodoList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final keyword = ref.watch(searchKeywordProvider);

    // 根据搜索关键词进一步过滤
    final displayTodos = keyword.isEmpty
        ? todos
        : todos
            .where((todo) => todo.title.toLowerCase().contains(keyword.toLowerCase()))
            .toList();

    if (displayTodos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无待办事项', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: displayTodos.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final todo = displayTodos[index];
        // 使用 todo.id 作为 key，让每个 item 独立监听
        return _TodoItem(todoId: todo.id);
      },
    );
  }
}

/// 单个 Todo 项
///
/// 使用 ConsumerWidget + todoItemProvider.family
/// 每个 item 只监听自己的数据变化，不会导致整个列表重建
///
/// 这是 Riverpod Family 的核心优势：
/// - 列表中修改一个 item，只有那个 item 重建
/// - 其他 item 不受影响
class _TodoItem extends ConsumerWidget {
  final String todoId;

  const _TodoItem({required this.todoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 family 按 id 获取单个 Todo
    // 只有这个 Todo 的数据变化时，才会重建这个 Widget
    final todo = ref.watch(todoItemProvider(todoId));

    if (todo == null) return const SizedBox.shrink();

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(todoListProvider.notifier).remove(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除'), duration: Duration(seconds: 1)),
        );
      },
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              ref.read(todoListProvider.notifier).toggle(todo.id);
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Text(
            '${todo.createdAt.month}月${todo.createdAt.day}日 ${todo.createdAt.hour}:${todo.createdAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              ref.read(todoListProvider.notifier).remove(todo.id);
            },
          ),
        ),
      ),
    );
  }
}

/// 底部统计栏
///
/// 使用 select 优化：只监听 completedCount 和 totalCount
/// 只有这两个数值变化时才会重建，列表增删不影响统计栏
///
/// select 的作用：
/// - 从复杂状态中提取部分数据监听
/// - 避免不必要的 Widget 重建
/// - 性能优化的重要手段
class _TodoStats extends ConsumerWidget {
  const _TodoStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 select 只监听总数变化
    // 只有 totalCount 变化时才重建，列表项内容变化不影响
    final totalCount = ref.watch(
      todoListProvider.select((list) => list.length),
    );

    // 使用 select 只监听已完成数量变化
    final completedCount = ref.watch(
      todoListProvider.select((list) => list.where((t) => t.isCompleted).length),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '共 $totalCount 项',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '已完成 $completedCount 项',
            style: TextStyle(
              fontSize: 14,
              color: completedCount == totalCount && totalCount > 0
                  ? Colors.green
                  : null,
              fontWeight: completedCount == totalCount && totalCount > 0
                  ? FontWeight.bold
                  : null,
            ),
          ),
          // 进度指示器
          if (totalCount > 0)
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: totalCount > 0 ? completedCount / totalCount : 0,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  completedCount == totalCount ? Colors.green : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 特性说明
class _FeatureNote extends StatelessWidget {
  const _FeatureNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本示例综合使用了：',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 4),
          Text(
            'StateNotifier（状态管理）| Provider依赖（过滤计算）| '
            'Family（单项监听）| AsyncValue（异步保存）| '
            'autoDispose（自动释放）| select（重建优化）',
            style: TextStyle(fontSize: 11, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
