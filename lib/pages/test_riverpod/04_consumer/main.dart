import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================
// 状态类：包含多个字段，用于演示 select 精准监听
// ============================================
class UserState {
  final String name;
  final int age;
  final int counter;

  const UserState({
    this.name = '张三',
    this.age = 25,
    this.counter = 0,
  });

  UserState copyWith({String? name, int? age, int? counter}) {
    return UserState(
      name: name ?? this.name,
      age: age ?? this.age,
      counter: counter ?? this.counter,
    );
  }
}

// ============================================
// StateNotifier：管理 UserState 状态
// ============================================
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void updateName(String name) => state = state.copyWith(name: name);
  void updateAge(int age) => state = state.copyWith(age: age);
  void incrementCounter() => state = state.copyWith(counter: state.counter + 1);
}

// ============================================
// Provider 定义
// ============================================
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

// ============================================
// 页面入口：ProviderScope 包裹，确保本页有独立的 Provider 容器
// ============================================
@RoutePage()
class RiverpodConsumerPage extends StatelessWidget {
  const RiverpodConsumerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('04 消费状态的 N 种方式'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 方式1：ConsumerWidget
            _Section1ConsumerWidget(),
            SizedBox(height: 16),

            // 方式2：ConsumerStatefulWidget + ConsumerState
            _Section2ConsumerStateful(),
            SizedBox(height: 16),

            // 方式3：Consumer（局部重建）
            _Section3ConsumerLocal(),
            SizedBox(height: 16),

            // 方式4：Consumer + child 优化
            _Section4ConsumerChild(),
            SizedBox(height: 16),

            // 方式5：ref.watch + select
            _Section5Select(),
          ],
        ),
      ),
      // 底部悬浮按钮：修改 counter，观察哪些区域会重建
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            onPressed: () => ref.read(userProvider.notifier).incrementCounter(),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

// ============================================
// 通用卡片组件：带彩色边框和重建计数显示
// ============================================
class _DemoCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color borderColor;
  final List<Widget> children;

  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.children,
  });

  @override
  State<_DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<_DemoCard> {
  int _rebuildCount = 0;

  @override
  void didUpdateWidget(covariant _DemoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildCount++;
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = _rebuildCount + 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: widget.borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: widget.borderColor.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.borderColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 重建计数徽章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.borderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '重建次数: $displayCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.borderColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 副标题说明
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const Divider(height: 20),
          // 内容区域
          ...widget.children,
        ],
      ),
    );
  }
}

// ============================================
// 方式1：ConsumerWidget
// 适用场景：简单的无状态页面，整个 widget 需要随 provider 变化重建
// 特点：继承 ConsumerWidget，build 方法中直接拿到 WidgetRef
// ============================================
class _Section1ConsumerWidget extends ConsumerWidget {
  const _Section1ConsumerWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听整个 userProvider，任何字段变化都会触发重建
    final user = ref.watch(userProvider);

    return _DemoCard(
      title: '1. ConsumerWidget',
      subtitle: '整个 widget 随 provider 变化重建，适合简单页面',
      borderColor: Colors.blue,
      children: [
        Text('姓名: ${user.name}'),
        const SizedBox(height: 8),
        _NameInput(
          initialValue: user.name,
          onChanged: (value) =>
              ref.read(userProvider.notifier).updateName(value),
        ),
      ],
    );
  }
}

// ============================================
// 方式2：ConsumerStatefulWidget + ConsumerState
// 适用场景：需要 initState、dispose、didUpdateWidget 等生命周期方法
// 特点：类似 StatefulWidget，但 state 类继承 ConsumerState，可直接使用 ref
// ============================================
class _Section2ConsumerStateful extends ConsumerStatefulWidget {
  const _Section2ConsumerStateful();

  @override
  ConsumerState<_Section2ConsumerStateful> createState() =>
      _Section2ConsumerStatefulState();
}

class _Section2ConsumerStatefulState
    extends ConsumerState<_Section2ConsumerStateful> {
  late final TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    // ConsumerState 中可以直接使用 ref，无需通过 widget 传递
    final initialAge = ref.read(userProvider).age;
    _ageController = TextEditingController(text: '$initialAge');
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听整个 provider，任何字段变化都会触发重建
    final user = ref.watch(userProvider);

    return _DemoCard(
      title: '2. ConsumerStatefulWidget + ConsumerState',
      subtitle: '需要 initState / dispose 时使用，可直接访问 ref',
      borderColor: Colors.green,
      children: [
        Text('年龄: ${user.age}'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '输入年龄',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final age = int.tryParse(_ageController.text) ?? 0;
                ref.read(userProvider.notifier).updateAge(age);
              },
              child: const Text('更新'),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================
// 方式3：Consumer（局部重建）
// 适用场景：页面大部分内容不需要重建，只有一小块需要监听 provider
// 特点：Consumer 的 builder 部分会重建，但包裹的外部 widget 不会
// ============================================
class _Section3ConsumerLocal extends StatelessWidget {
  const _Section3ConsumerLocal();

  @override
  Widget build(BuildContext context) {
    // 这个 build 方法不会因为 provider 变化而重建！
    return Consumer(
      builder: (context, ref, child) {
        // 只有这个 builder 内部会重建
        final counter = ref.watch(userProvider).counter;

        return _DemoCard(
          title: '3. Consumer（局部重建）',
          subtitle: '只重建 Consumer 的 builder 部分，外部 widget 不受影响',
          borderColor: Colors.orange,
          children: [
            Text(
              '计数器: $counter',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击右下角 + 按钮，只有本卡片会重建',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}

// ============================================
// 方式4：Consumer + child 优化
// 适用场景：builder 中有一大块不需要重建的 UI
// 特点：将不变化的 UI 放在 child 中，Flutter 会复用该子树，避免重建
// ============================================
class _Section4ConsumerChild extends StatelessWidget {
  const _Section4ConsumerChild();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      // child 中的 widget 只会创建一次，不会随 provider 变化重建
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          children: [
            Icon(Icons.info_outline, color: Colors.purple),
            SizedBox(height: 4),
            Text(
              '这段内容通过 child 传入，不会重建',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            Text(
              '适合放置复杂的静态 UI',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      builder: (context, ref, child) {
        final counter = ref.watch(userProvider).counter;

        return _DemoCard(
          title: '4. Consumer + child 优化',
          subtitle: '将不变化的 UI 放在 child 中，避免不必要的重建开销',
          borderColor: Colors.purple,
          children: [
            Text(
              '当前计数: $counter',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // 复用传入的 child，不会重建
            child!,
          ],
        );
      },
    );
  }
}

// ============================================
// 方式5：ref.watch + select（精准监听）
// 适用场景：状态对象有多个字段，只关心其中一个字段的变化
// 特点：只有当 select 的返回值变化时，才会触发重建
// ============================================
class _Section5Select extends StatelessWidget {
  const _Section5Select();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 卡片 A：只监听 name 字段
        Consumer(
          builder: (context, ref, child) {
            // select：只提取 name 字段，只有 name 变化时才重建
            final name = ref.watch(userProvider.select((s) => s.name));

            return _DemoCard(
              title: '5-A. select 监听 name',
              subtitle: '只监听 name 字段，age/counter 变化不会触发重建',
              borderColor: Colors.teal,
              children: [
                Text(
                  '姓名: $name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '点击右下角 + 按钮，本卡片不会重建（因为 counter 变了，name 没变）',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // 卡片 B：只监听 counter 字段
        Consumer(
          builder: (context, ref, child) {
            // select：只提取 counter 字段，只有 counter 变化时才重建
            final counter = ref.watch(userProvider.select((s) => s.counter));

            return _DemoCard(
              title: '5-B. select 监听 counter',
              subtitle: '只监听 counter 字段，name/age 变化不会触发重建',
              borderColor: Colors.red,
              children: [
                Text(
                  '计数: $counter',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '点击右下角 + 按钮，只有本卡片会重建（因为 counter 变了）',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}


// ============================================
// 辅助组件：姓名输入框
// ============================================
class _NameInput extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _NameInput({required this.initialValue, required this.onChanged});

  @override
  State<_NameInput> createState() => _NameInputState();
}

class _NameInputState extends State<_NameInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _NameInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只在值真正变化时更新 controller
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
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
            decoration: const InputDecoration(
              hintText: '输入姓名',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => widget.onChanged(_controller.text),
          child: const Text('更新'),
        ),
      ],
    );
  }
}

