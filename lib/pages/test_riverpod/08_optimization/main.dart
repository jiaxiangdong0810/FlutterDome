import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 重建优化 —— select 精准监听
///
/// 核心知识点：
/// 1. select 的作用：只监听状态对象中的特定字段，字段变化时才重建
/// 2. 与 Provider 的 Selector 对比：
///    - Provider: 使用 Selector Widget 包裹，通过 selector 函数提取字段
///    - Riverpod: 使用 ref.watch(provider.select((s) => s.field))，不需要额外 Widget
/// 3. 性能优势：避免整个页面/Widget 因一个字段变化而全部重建
///
/// 本示例：
/// - 一个 UserProfile 状态类包含 4 个字段（name, age, counter, favoriteColor）
/// - 4 个独立区域分别用 select 监听不同字段
/// - 每个区域显示自己的重建次数
/// - 4 个按钮分别更新不同字段
/// - 观察：更新某个字段时，只有对应区域重建

// ==================== 状态类 ====================

/// 用户资料状态类，包含 4 个独立字段
///
/// 使用不可变对象（immutable）：每次更新都创建新实例
/// 这是 Riverpod StateNotifier 的最佳实践
class UserProfile {
  final String name;
  final int age;
  final int counter;
  final Color favoriteColor;

  const UserProfile({
    required this.name,
    required this.age,
    required this.counter,
    required this.favoriteColor,
  });

  /// copyWith：创建新实例，只修改指定字段，其他字段保持不变
  /// 这是不可变状态模式的标准写法
  UserProfile copyWith({
    String? name,
    int? age,
    int? counter,
    Color? favoriteColor,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      counter: counter ?? this.counter,
      favoriteColor: favoriteColor ?? this.favoriteColor,
    );
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, age: $age, counter: $counter, color: $favoriteColor)';
  }
}

// ==================== Provider 定义 ====================

/// StateNotifier：管理 UserProfile 状态
///
/// 与 StateProvider 的区别：
/// - StateProvider：适合简单值类型（int, String, bool）
/// - StateNotifier：适合复杂对象，需要封装业务逻辑时
///
/// 这里用 StateNotifier 是因为 UserProfile 是复杂对象，
/// 需要封装多个更新方法
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(const UserProfile(
          name: '张三',
          age: 25,
          counter: 0,
          favoriteColor: Colors.blue,
        ));

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void incrementAge() {
    state = state.copyWith(age: state.age + 1);
  }

  void incrementCounter() {
    state = state.copyWith(counter: state.counter + 1);
  }

  void changeColor() {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final currentIndex = colors.indexOf(state.favoriteColor);
    final nextColor = colors[(currentIndex + 1) % colors.length];
    state = state.copyWith(favoriteColor: nextColor);
  }
}

/// StateNotifierProvider：创建并管理 UserProfileNotifier
///
/// 语法：StateNotifierProvider<NotifierClass, StateClass>((ref) => NotifierClass())
/// 使用 .notifier 获取 notifier 实例来调用方法
/// 直接 watch provider 获取当前状态值
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

/// 重建日志 Provider：用于记录哪个 Widget 发生了重建
///
/// 使用 StateProvider 管理一个字符串列表
final rebuildLogProvider = StateProvider<List<String>>((ref) => []);

// ==================== 页面入口 ====================

@RoutePage()
class RiverpodOptimizationPage extends ConsumerWidget {
  const RiverpodOptimizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('08 重建优化 - Select'),
        actions: [
          // 清空日志按钮
          IconButton(
            onPressed: () {
              ref.read(rebuildLogProvider.notifier).state = [];
            },
            icon: const Icon(Icons.clear_all),
            tooltip: '清空日志',
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文字
            _DescriptionSection(),
            SizedBox(height: 16),

            // 4 个监听区域
            _NameCard(),
            SizedBox(height: 12),
            _AgeCard(),
            SizedBox(height: 12),
            _CounterCard(),
            SizedBox(height: 12),
            _ColorCard(),
            SizedBox(height: 16),

            // 操作按钮
            _OperationButtons(),
            SizedBox(height: 16),

            // 重建日志
            _RebuildLog(),
            SizedBox(height: 16),

            // Provider vs Riverpod 对比
            _ComparisonSection(),
          ],
        ),
      ),
    );
  }
}

// ==================== 说明区域 ====================

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '核心概念：select 精准监听',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '下方 4 个卡片分别用 select 监听 UserProfile 的不同字段。'
            '点击按钮更新某个字段时，只有对应的卡片会重建。',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ==================== 4 个独立监听区域 ====================

/// 名称卡片 —— 用 select 监听 name 字段
///
/// select 语法：ref.watch(provider.select((s) => s.name))
/// 只有当 name 的值发生变化时，这个 Widget 才会重建
class _NameCard extends ConsumerWidget {
  const _NameCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select：只监听 name 字段
    // 等价于 Provider 的 Selector<..., String>(selector: (_, s) => s.name, ...)
    final name = ref.watch(userProfileProvider.select((s) => s.name));

    // 记录重建次数，使用静态变量在每次重建时递增
    return _RebuildTracker(
      label: 'name',
      title: '姓名',
      value: name,
      icon: Icons.person,
      color: Colors.blue,
    );
  }
}

/// 年龄卡片 —— 用 select 监听 age 字段
class _AgeCard extends ConsumerWidget {
  const _AgeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final age = ref.watch(userProfileProvider.select((s) => s.age));

    return _RebuildTracker(
      label: 'age',
      title: '年龄',
      value: '$age 岁',
      icon: Icons.cake,
      color: Colors.green,
    );
  }
}

/// 计数器卡片 —— 用 select 监听 counter 字段
class _CounterCard extends ConsumerWidget {
  const _CounterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(userProfileProvider.select((s) => s.counter));

    return _RebuildTracker(
      label: 'counter',
      title: '计数器',
      value: '$counter',
      icon: Icons.plus_one,
      color: Colors.orange,
    );
  }
}

/// 颜色卡片 —— 用 select 监听 favoriteColor 字段
class _ColorCard extends ConsumerWidget {
  const _ColorCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(
      userProfileProvider.select((s) => s.favoriteColor),
    );

    return _RebuildTracker(
      label: 'color',
      title: '喜欢颜色',
      value: '#${color.value.toRadixString(16).toUpperCase().substring(2)}',
      icon: Icons.color_lens,
      color: color,
    );
  }
}

// ==================== 重建计数组件 ====================

/// 通用的重建追踪卡片
///
/// 使用 StatefulWidget 来维护每个卡片的独立重建计数
/// 每次父 Widget 重建时，didUpdateWidget 被调用，计数 +1
class _RebuildTracker extends StatefulWidget {
  final String label;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _RebuildTracker({
    required this.label,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<_RebuildTracker> createState() => _RebuildTrackerState();
}

class _RebuildTrackerState extends State<_RebuildTracker> {
  int _rebuildCount = 0;

  @override
  void didUpdateWidget(covariant _RebuildTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 父 Widget 重建时触发，计数 +1
    _rebuildCount++;
  }

  @override
  Widget build(BuildContext context) {
    // 首次构建时计数为 0，didUpdateWidget 后才会递增
    // 所以显示时要 +1 来表示总构建次数
    final displayCount = _rebuildCount + 1;

    return Card(
      color: widget.color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: widget.color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '重建: $displayCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 操作按钮 ====================

class _OperationButtons extends ConsumerWidget {
  const _OperationButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(userProfileProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '操作区（点击更新对应字段）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final currentName = ref.read(userProfileProvider).name;
                    notifier.updateName(
                      currentName == '张三' ? '李四' : '张三',
                    );
                    _addLog(ref, '更新 name');
                  },
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('切换姓名'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.incrementAge();
                    _addLog(ref, '更新 age');
                  },
                  icon: const Icon(Icons.cake, size: 18),
                  label: const Text('年龄 +1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.incrementCounter();
                    _addLog(ref, '更新 counter');
                  },
                  icon: const Icon(Icons.plus_one, size: 18),
                  label: const Text('计数 +1'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade100,
                    foregroundColor: Colors.orange.shade800,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.changeColor();
                    _addLog(ref, '更新 favoriteColor');
                  },
                  icon: const Icon(Icons.color_lens, size: 18),
                  label: const Text('切换颜色'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade100,
                    foregroundColor: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 添加日志记录
  void _addLog(WidgetRef ref, String action) {
    final currentLog = ref.read(rebuildLogProvider);
    final newLog = [
      '${DateTime.now().toString().substring(11, 19)} $action',
      ...currentLog,
    ];
    // 只保留最近 10 条
    ref.read(rebuildLogProvider.notifier).state =
        newLog.take(10).toList();
  }
}

// ==================== 重建日志区域 ====================

class _RebuildLog extends ConsumerWidget {
  const _RebuildLog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(rebuildLogProvider);

    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  '操作日志',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${logs.length} 条',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            if (logs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '暂无操作记录\n点击上方按钮更新字段',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              )
            else
              ...logs.map((log) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      log,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// ==================== Provider vs Riverpod 对比 ====================

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider Selector vs Riverpod select',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                  ),
                  children: const [
                    _TableHeaderCell('对比项'),
                    _TableHeaderCell('Provider'),
                    _TableHeaderCell('Riverpod'),
                  ],
                ),
                const TableRow(
                  children: [
                    _TableCell('使用方式'),
                    _CodeCell('Selector<T, R>(\n  selector: (_, s) => s.field,\n  builder: ...\n)'),
                    _CodeCell('ref.watch(\n  provider.select(\n    (s) => s.field\n  )\n)'),
                  ],
                ),
                const TableRow(
                  children: [
                    _TableCell('是否需要\n额外 Widget'),
                    _TableCell('是，需要 Selector Widget 包裹'),
                    _TableCell('否，直接在 ref.watch 中使用 select'),
                  ],
                ),
                const TableRow(
                  children: [
                    _TableCell('代码层级'),
                    _TableCell('多一层嵌套'),
                    _TableCell('更扁平，无额外嵌套'),
                  ],
                ),
                const TableRow(
                  children: [
                    _TableCell('监听粒度'),
                    _TableCell('字段级'),
                    _TableCell('字段级（支持任意表达式）'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riverpod select 的优势：',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. select 可以监听任意表达式，不只是字段\n'
                    '   例：ref.watch(provider.select((s) => s.age > 18))',
                    style: TextStyle(fontSize: 11),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '2. 不需要额外的 Widget 包裹，代码更简洁\n'
                    '3. 可以在任意地方使用（包括非 Widget 代码）',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 表格辅助组件 ====================

class _TableHeaderCell extends StatelessWidget {
  final String text;

  const _TableHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;

  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _CodeCell extends StatelessWidget {
  final String text;

  const _CodeCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'monospace',
          color: Colors.blue.shade800,
          height: 1.4,
        ),
      ),
    );
  }
}
