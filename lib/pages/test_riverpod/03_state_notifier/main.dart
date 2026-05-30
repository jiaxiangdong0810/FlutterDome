import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ============================================================
/// 03 StateNotifier / AsyncNotifier 演示
/// ============================================================
///
/// 本页展示 Riverpod 中管理复杂状态的三种方式：
///
/// 1. StateNotifier + StateNotifierProvider（经典方式）
///    - 适合同步状态管理
///    - 状态不可变（immutable），每次更新都是新对象
///
/// 2. AsyncNotifier + AsyncNotifierProvider（异步操作推荐）
///    - 内置对异步操作的支持（loading / error / data）
///    - 自动处理 AsyncValue 的三种状态
///
/// 3. @riverpod 代码生成（现代推荐方式）
///    - 通过 build_runner 自动生成 Provider
///    - 类型更安全，IDE 提示更友好
///    - 本文件不展示生成代码，仅作注释说明
///
/// -----------------------------------------------------------
/// 为什么 StateNotifier 优于 ChangeNotifier？
/// -----------------------------------------------------------
/// - ChangeNotifier: 状态可变，需要手动调用 notifyListeners()
///   容易出现"修改了状态但忘记通知"的 bug
/// - StateNotifier: 状态不可变，通过 state = newState 自动通知
///   强制使用不可变数据，避免意外修改，更易测试和调试
/// ============================================================

// ------------------------------
// 数据模型：Todo
// ------------------------------

/// Todo 数据类，使用 @immutable 语义（实际通过 copy 更新）
class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  const Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  /// copyWith 用于创建新的不可变实例
  Todo copyWith({String? id, String? title, bool? isCompleted}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ============================================================
// 方式一：StateNotifier + StateNotifierProvider（经典方式）
// ============================================================

/// TodoNotifier 继承 StateNotifier，管理 `List<Todo>` 状态
///
/// `StateNotifier<T>` 的核心规则：
/// - state 属性是只读的（外部只能读取）
/// - 内部通过 this.state = newState 更新，自动触发通知
/// - 新 state 必须与旧 state 不同（!=）才会通知监听者
class TodoNotifier extends StateNotifier<List<Todo>> {
  /// 初始状态为空列表
  TodoNotifier() : super(const []);

  /// 添加 Todo
  /// 注意：必须创建新列表，不能直接 add 到原列表
  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    // 创建新列表，StateNotifier 才能检测到变化
    state = [...state, newTodo];
  }

  /// 切换完成状态
  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
  }

  /// 删除 Todo
  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

/// StateNotifierProvider：将 TodoNotifier 暴露给 UI
///
/// 泛型参数：`<Notifier类型, State类型>`
/// autoDispose: 当没有任何监听者时自动销毁，防止内存泄漏
final todoNotifierProvider =
    StateNotifierProvider.autoDispose<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

// ============================================================
// 方式二：AsyncNotifier + AsyncNotifierProvider（异步操作）
// ============================================================

/// AsyncTodoNotifier 继承 AsyncNotifier，适合异步场景
///
/// AsyncNotifier 的优势：
/// - 内置 AsyncValue<T> 包装，自动处理 loading / error / data
/// - 不需要手动维护 isLoading / errorMessage 等状态
/// - UI 可以通过 .when() 简洁地处理三种状态
class AsyncTodoNotifier extends AsyncNotifier<List<Todo>> {
  /// build() 是 AsyncNotifier 的抽象方法，返回初始状态
  /// 这里模拟从"服务器"加载初始数据
  @override
  Future<List<Todo>> build() async {
    // 模拟网络延迟加载初始数据
    await Future.delayed(const Duration(milliseconds: 800));
    return const [
      Todo(id: '1', title: '从服务器加载的 Todo 1'),
      Todo(id: '2', title: '从服务器加载的 Todo 2', isCompleted: true),
    ];
  }

  /// 异步添加 Todo（模拟网络请求）
  Future<void> addTodo(String title) async {
    // 先进入 loading 状态，保留旧数据
    state = const AsyncValue.loading();

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 600));

    // 获取当前数据（或空列表）
    final currentList = state.valueOrNull ?? [];
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );

    // 更新为 data 状态
    state = AsyncValue.data([...currentList, newTodo]);
  }

  /// 异步切换完成状态
  Future<void> toggleTodo(String id) async {
    final currentList = state.valueOrNull ?? [];
    if (currentList.isEmpty) return;

    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 400));

    state = AsyncValue.data([
      for (final todo in currentList)
        if (todo.id == id)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ]);
  }

  /// 异步删除 Todo
  Future<void> removeTodo(String id) async {
    final currentList = state.valueOrNull ?? [];

    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 400));

    state = AsyncValue.data(
      currentList.where((todo) => todo.id != id).toList(),
    );
  }
}

/// AsyncNotifierProvider：暴露 AsyncTodoNotifier
///
/// 使用 `AsyncNotifierProvider`，当页面离开且无监听者时自动销毁
/// State 的类型是 `AsyncValue<List<Todo>>`，由框架自动包装
final asyncTodoNotifierProvider =
    AsyncNotifierProvider<AsyncTodoNotifier, List<Todo>>(
  () => AsyncTodoNotifier(),
);

// ============================================================
// 方式三：@riverpod 代码生成（注释说明）
// ============================================================
//
// 现代 Riverpod 推荐使用代码生成方式，步骤如下：
//
// 1. 在 dart 文件顶部添加：import 'package:riverpod_annotation/riverpod_annotation.dart';
// 2. 定义带 @riverpod 注解的函数或类：
//
//    @riverpod
//    class GeneratedTodoNotifier extends _$GeneratedTodoNotifier {
//      @override
//      List<Todo> build() => [];
//
//      void addTodo(String title) { ... }
//      void toggleTodo(String id) { ... }
//      void removeTodo(String id) { ... }
//    }
//
// 3. 运行代码生成：flutter pub run build_runner build
// 4. 生成的 Provider 名称自动为：generatedTodoNotifierProvider
//
// 代码生成的优点：
// - 无需手动声明 Provider，减少样板代码
// - 类型推导更精确，IDE 自动补全更好
// - 支持更复杂的依赖注入场景
//
// 本文件为了教育目的，展示手动声明 Provider 的方式，
// 帮助理解底层原理。实际项目中推荐用代码生成。
// ============================================================

// ------------------------------
// UI 页面
// ------------------------------

@RoutePage()
class RiverpodStateNotifierPage extends ConsumerWidget {
  const RiverpodStateNotifierPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('03 StateNotifier / AsyncNotifier'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sync), text: '同步'),
              Tab(icon: Icon(Icons.cloud_sync), text: '异步'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            /// Tab 1: StateNotifier（同步）
            _SyncTodoTab(),

            /// Tab 2: AsyncNotifier（异步）
            _AsyncTodoTab(),
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// Tab 1: StateNotifier 同步版本
// ------------------------------

class _SyncTodoTab extends ConsumerWidget {
  const _SyncTodoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 通过 ref.watch 监听 StateNotifierProvider
    /// 返回的是 List<Todo>（StateNotifier 的 state 类型）
    final todos = ref.watch(todoNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// 说明卡片
          _InfoCard(
            title: 'StateNotifierProvider',
            subtitle: '状态类型: List<Todo> | 同步更新，无 loading',
          ),
          const SizedBox(height: 16),

          /// 输入框
          _TodoInput(
            onSubmit: (title) {
              /// 通过 ref.read 获取 Notifier 实例，调用方法
              /// 注意：操作状态用 read，监听状态用 watch
              ref.read(todoNotifierProvider.notifier).addTodo(title);
            },
          ),
          const SizedBox(height: 16),

          /// Todo 列表
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('暂无 Todo，请添加'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return _TodoItem(
                        todo: todo,
                        onToggle: () {
                          ref
                              .read(todoNotifierProvider.notifier)
                              .toggleTodo(todo.id);
                        },
                        onDelete: () {
                          ref
                              .read(todoNotifierProvider.notifier)
                              .removeTodo(todo.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------
// Tab 2: AsyncNotifier 异步版本
// ------------------------------

class _AsyncTodoTab extends ConsumerWidget {
  const _AsyncTodoTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 通过 ref.watch 监听 AsyncNotifierProvider
    /// 返回的是 AsyncValue<List<Todo>>，包含 loading / error / data 三种状态
    final asyncTodos = ref.watch(asyncTodoNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// 说明卡片
          _InfoCard(
            title: 'AsyncNotifierProvider',
            subtitle: '状态类型: AsyncValue<List<Todo>> | 带 loading 状态',
          ),
          const SizedBox(height: 16),

          /// 输入框
          _TodoInput(
            /// 当异步操作进行中时禁用输入
            enabled: !asyncTodos.isLoading,
            onSubmit: (title) {
              ref.read(asyncTodoNotifierProvider.notifier).addTodo(title);
            },
          ),
          const SizedBox(height: 16),

          /// Todo 列表 - 使用 AsyncValue.when 处理三种状态
          Expanded(
            child: asyncTodos.when(
              /// 数据状态：展示列表
              data: (todos) {
                if (todos.isEmpty) {
                  return const Center(child: Text('暂无 Todo，请添加'));
                }
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _TodoItem(
                      todo: todo,
                      /// 加载中禁用操作
                      enabled: !asyncTodos.isLoading,
                      onToggle: () {
                        ref
                            .read(asyncTodoNotifierProvider.notifier)
                            .toggleTodo(todo.id);
                      },
                      onDelete: () {
                        ref
                            .read(asyncTodoNotifierProvider.notifier)
                            .removeTodo(todo.id);
                      },
                    );
                  },
                );
              },

              /// 加载状态：展示进度指示器
              /// 由于列表上方空间有限，这里用覆盖层方式展示
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('加载中...'),
                  ],
                ),
              ),

              /// 错误状态：展示错误信息
              error: (error, stack) => Center(
                child: Text('出错了: $error'),
              ),
            ),
          ),

          /// 底部 loading 指示器（当列表已显示但操作进行中）
          if (asyncTodos.isLoading && asyncTodos.hasValue)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// ------------------------------
// 公共组件
// ------------------------------

/// 信息说明卡片
class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Todo 输入框
class _TodoInput extends StatefulWidget {
  final void Function(String) onSubmit;
  final bool enabled;

  const _TodoInput({required this.onSubmit, this.enabled = true});

  @override
  State<_TodoInput> createState() => _TodoInputState();
}

class _TodoInputState extends State<_TodoInput> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: '输入新 Todo...',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              suffixIcon: widget.enabled
                  ? null
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: widget.enabled ? _submit : null,
          child: const Text('添加'),
        ),
      ],
    );
  }
}

/// Todo 列表项
class _TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool enabled;

  const _TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: enabled ? (_) => onToggle() : null,
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration:
                  todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: enabled ? onDelete : null,
          ),
        ),
      ),
    );
  }
}
