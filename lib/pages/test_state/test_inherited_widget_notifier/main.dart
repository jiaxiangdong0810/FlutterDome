import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// InheritedWidget 演示页面 —— 最优方案：ChangeNotifier + InheritedNotifier
///
/// 核心思路：
/// 1. AppState 继承 ChangeNotifier，自管理数据和方法
/// 2. 数据变化时调用 notifyListeners() 通知监听者
/// 3. AppInfo（InheritedNotifier）自动监听，触发依赖者重建
/// 4. 页面持有 AppState 实例，通过 AppInfo 包裹子树
///
/// 优点：
/// - 状态完全自管理，不依赖 Widget 层级
/// - 通知机制内置，无需手动 setState
/// - 可轻松提升状态到更高层级，多页面共享
/// - 与 Provider 底层原理一致
@RoutePage()
class InheritedWidgetNotifierPage extends StatefulWidget {
  const InheritedWidgetNotifierPage({super.key});

  @override
  State<InheritedWidgetNotifierPage> createState() => _InheritedWidgetNotifierPageState();
}

class _InheritedWidgetNotifierPageState extends State<InheritedWidgetNotifierPage> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInfo(
      notifier: _state,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('InheritedNotifier 演示（最优方案）'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DataDisplayCard(),
              SizedBox(height: 16),
              _DeepNestedWidget(),
            ],
          ),
        ),
        floatingActionButton: const _ActionButtons(),
      ),
    );
  }
}

// ============================================
// 1. AppState：ChangeNotifier 自管理状态
// ============================================

/// 应用状态类
///
/// 继承 ChangeNotifier，数据和方法都封装在这里。
/// 修改数据后调用 notifyListeners()，InheritedNotifier 会自动重建依赖者。
class AppState extends ChangeNotifier {
  AppState({
    this._counter = 0,
    this._userName = 'Flutter 开发者',
  });

  int _counter;
  String _userName;

  int get counter => _counter;
  String get userName => _userName;

  void increment() {
    _counter++;
    notifyListeners(); // 通知所有监听者重建
  }

  void changeUserName() {
    _userName = _userName == 'Flutter 开发者' ? 'Dart 爱好者' : 'Flutter 开发者';
    notifyListeners();
  }
}

// ============================================
// 2. AppInfo：InheritedNotifier 自动监听
// ============================================

/// InheritedNotifier 是 Flutter SDK 提供的组件
///
/// 它继承自 InheritedWidget，内部自动监听 notifier（ChangeNotifier）。
/// 当 notifier.notifyListeners() 被调用时，InheritedNotifier 会自动重建依赖者。
class AppInfo extends InheritedNotifier<AppState> {
  const AppInfo({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppInfo>()!;
    return widget.notifier!;
  }
}

// ============================================
// 3. UI 组件
// ============================================

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'changeName',
          onPressed: state.changeUserName,
          child: const Icon(Icons.person),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'increment',
          onPressed: state.increment,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _DataDisplayCard extends StatelessWidget {
  const _DataDisplayCard();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前共享数据（最优方案）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _DataRow(label: '计数器', value: '${state.counter}'),
            const SizedBox(height: 8),
            _DataRow(label: '用户名', value: state.userName),
            const SizedBox(height: 8),
            Text(
              '（通过 AppInfo.of(context) 读取，ChangeNotifier 自动通知）',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _DeepNestedWidget extends StatelessWidget {
  const _DeepNestedWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '深层嵌套组件',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('以下组件嵌套了多层，但数据依然可以直接获取：'),
            const SizedBox(height: 12),
            _Level1(),
          ],
        ),
      ),
    );
  }
}

class _Level1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Level 1', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _Level2(),
        ],
      ),
    );
  }
}

class _Level2 extends StatelessWidget {
  const _Level2();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Level 2', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _Level3(),
        ],
      ),
    );
  }
}

class _Level3 extends StatelessWidget {
  const _Level3();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Level 3（直接读取数据）',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('计数器: ${state.counter}'),
          Text('用户名: ${state.userName}'),
          const SizedBox(height: 4),
          Text(
            '✅ 无需通过构造函数层层传递！',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
