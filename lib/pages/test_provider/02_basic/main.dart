import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Provider 基础示例
///
/// 核心知识点：
/// 1. ChangeNotifier — 通知监听者状态变化
/// 2. ChangeNotifierProvider — 在 Widget 树中提供状态
/// 3. 三种消费方式的区别：
///    - context.watch<T>() — 监听变化，会触发重建（在 build 中使用）
///    - context.read<T>() — 只读取一次，不监听（在回调中使用）
///    - Consumer<T> — 局部重建，控制更精细
/// 4. Selector — 选择部分字段，避免不必要的重建

// ==================== 状态类 ====================

class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }
}

class UserProfile extends ChangeNotifier {
  String _name = '张三';
  int _age = 25;

  String get name => _name;
  int get age => _age;

  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  void growOlder() {
    _age++;
    notifyListeners();
  }
}

// ==================== 页面入口 ====================

@RoutePage()
class ProviderBasicRoute extends StatelessWidget {
  const ProviderBasicRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider 可以同时提供多个状态
    // 这里为了演示简单，先用 ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (_) => Counter(),
      child: const ProviderBasicPage(),
    );
  }
}

class ProviderBasicPage extends StatelessWidget {
  const ProviderBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider 基础'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. context.watch() — 自动监听重建'),
            const WatchDemo(),
            const Divider(height: 32),

            _buildSectionTitle('2. context.read() — 只读不监听'),
            const ReadDemo(),
            const Divider(height: 32),

            _buildSectionTitle('3. Consumer — 局部重建'),
            const ConsumerDemo(),
            const Divider(height: 32),

            _buildSectionTitle('4. Selector — 精准字段监听'),
            // 这里需要多个字段，所以用 MultiProvider
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => UserProfile()),
              ],
              child: const SelectorDemo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}

// ==================== 1. watch() 示例 ====================

class WatchDemo extends StatelessWidget {
  const WatchDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // watch() 会在状态变化时触发整个 Widget 重建
    final count = context.watch<Counter>().count;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('当前计数: $count', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            ElevatedButton(
              // read() 在回调中使用，只读取不监听
              onPressed: () => context.read<Counter>().increment(),
              child: const Text('增加'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 2. read() 示例 ====================

class ReadDemo extends StatelessWidget {
  const ReadDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // 注意：这里没有用 watch()，所以这个 Widget 不会因为计数变化而重建
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '这个区域用 read() 获取计数',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // read() 只读取当前值，不建立监听关系
            Text(
              '当前值: ${context.read<Counter>().count}（不会自动更新）',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击增加后，上面的 watch 区域会更新，这个区域不会',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 3. Consumer 示例 ====================

class ConsumerDemo extends StatelessWidget {
  const ConsumerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Consumer 只重建它包裹的部分',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // Consumer 的 builder 只在状态变化时重建
            // 这个 Text 外面包裹的其他 Widget 不会重建
            Consumer<Counter>(
              builder: (context, counter, child) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Consumer 计数: ${counter.count}',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<Counter>().increment(),
              child: const Text('增加计数'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 4. Selector 示例 ====================

class SelectorDemo extends StatelessWidget {
  const SelectorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selector — 只监听特定字段的变化',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Selector 选择 name 字段，只有 name 变化时才重建
            Selector<UserProfile, String>(
              selector: (_, profile) => profile.name,
              builder: (context, name, child) {
                return _buildInfoRow('姓名', name, Colors.purple);
              },
            ),

            const SizedBox(height: 8),

            // Selector 选择 age 字段，只有 age 变化时才重建
            Selector<UserProfile, int>(
              selector: (_, profile) => profile.age,
              builder: (context, age, child) {
                return _buildInfoRow('年龄', '$age 岁', Colors.orange);
              },
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final profile = context.read<UserProfile>();
                      profile.updateName(profile.name == '张三' ? '李四' : '张三');
                    },
                    child: const Text('修改姓名'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<UserProfile>().growOlder(),
                    child: const Text('年龄+1'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '点击"修改姓名"只有姓名区域重建，点击"年龄+1"只有年龄区域重建',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
