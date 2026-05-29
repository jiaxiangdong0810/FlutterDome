import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// InheritedWidget 演示页面 —— 方案 B：StatefulWidget 包装
///
/// 核心思路：
/// 1. AppStateWidget 内部持有状态（_AppState）和修改方法
/// 2. 通过 InheritedWidget 向下传递：状态 + 回调函数
/// 3. 子组件通过 AppStateWidget.of(context) 获取数据和操作
/// 4. 页面本身不直接管理状态，只负责包一层 AppStateWidget
///
/// 优点：状态逻辑封装在 AppStateWidget 内，页面间可复用
/// 缺点：回调函数需要通过 InheritedWidget 传递，略显冗余
@RoutePage()
class InheritedWidgetDemoPage extends StatelessWidget {
  const InheritedWidgetDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('InheritedWidget 演示（方案 B）'),
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
// 1. 状态类：Immutable 数据模型
// ============================================

class AppState {
  const AppState({
    this.counter = 0,
    this.userName = 'Flutter 开发者',
  });

  final int counter;
  final String userName;

  AppState copyWith({int? counter, String? userName}) {
    return AppState(
      counter: counter ?? this.counter,
      userName: userName ?? this.userName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.counter == counter &&
        other.userName == userName;
  }

  @override
  int get hashCode => Object.hash(counter, userName);
}

// ============================================
// 2. AppStateWidget：StatefulWidget 包装，内部管理状态
// ============================================

/// 状态管理 Widget
///
/// 内部持有 _AppState 和修改方法，通过 InheritedWidget 向下传递。
/// 子组件通过 AppStateWidget.of(context) 获取数据和回调。
class AppStateWidget extends StatefulWidget {
  const AppStateWidget({super.key, required this.child});

  final Widget child;

  /// 获取数据和操作回调
  static AppStateData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<_AppStateInherited>()!;
    return AppStateData(
      state: widget.state,
      increment: widget.increment,
      changeName: widget.changeName,
    );
  }

  @override
  State<AppStateWidget> createState() => _AppStateWidgetState();
}

class _AppStateWidgetState extends State<AppStateWidget> {
  AppState _state = const AppState();

  void _increment() {
    setState(() {
      _state = _state.copyWith(counter: _state.counter + 1);
    });
  }

  void _changeName() {
    final newName = _state.userName == 'Flutter 开发者' ? 'Dart 爱好者' : 'Flutter 开发者';
    setState(() {
      _state = _state.copyWith(userName: newName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AppStateInherited(
      state: _state,
      increment: _increment,
      changeName: _changeName,
      child: widget.child,
    );
  }
}

/// 数据 + 回调包装类
class AppStateData {
  const AppStateData({
    required this.state,
    required this.increment,
    required this.changeName,
  });

  final AppState state;
  final VoidCallback increment;
  final VoidCallback changeName;
}

/// 内部 InheritedWidget：传递状态 + 回调
class _AppStateInherited extends InheritedWidget {
  const _AppStateInherited({
    required this.state,
    required this.increment,
    required this.changeName,
    required super.child,
  });

  final AppState state;
  final VoidCallback increment;
  final VoidCallback changeName;

  @override
  bool updateShouldNotify(_AppStateInherited oldWidget) {
    return state != oldWidget.state;
  }
}

// ============================================
// 3. UI 组件
// ============================================

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final data = AppStateWidget.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'changeName',
          onPressed: data.changeName,
          child: const Icon(Icons.person),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'increment',
          onPressed: data.increment,
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
    final state = AppStateWidget.of(context).state;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前共享数据（方案 B）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _DataRow(label: '计数器', value: '${state.counter}'),
            const SizedBox(height: 8),
            _DataRow(label: '用户名', value: state.userName),
            const SizedBox(height: 8),
            Text(
              '（通过 AppStateWidget.of(context).state 读取）',
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
    final state = AppStateWidget.of(context).state;

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
