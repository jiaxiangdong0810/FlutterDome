import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Provider 重建优化示例
///
/// 核心知识点：
/// 1. 对比不同消费方式的重建范围
/// 2. context.watch() vs Consumer vs Selector 的重建差异
/// 3. 如何最小化重建范围提升性能
///
/// 场景：一个页面包含三个独立区域（用户信息、计数器、主题色），
/// 修改其中一个时，观察其他区域是否被重建。

// ==================== 状态类 ====================

class OptimizationState extends ChangeNotifier {
  String _username = '用户A';
  int _counter = 0;
  Color _themeColor = Colors.blue;

  String get username => _username;
  int get counter => _counter;
  Color get themeColor => _themeColor;

  void updateUsername(String name) {
    _username = name;
    notifyListeners();
  }

  void increment() {
    _counter++;
    notifyListeners();
  }

  void changeThemeColor() {
    final colors = <Color>[Colors.blue, Colors.red, Colors.green, Colors.purple, Colors.orange];
    final currentIndex = colors.indexOf(_themeColor);
    _themeColor = colors[(currentIndex + 1) % colors.length];
    notifyListeners();
  }
}

// ==================== 页面入口 ====================

@RoutePage()
class ProviderOptimizationRoute extends StatelessWidget {
  const ProviderOptimizationRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OptimizationState(),
      child: const ProviderOptimizationPage(),
    );
  }
}

class ProviderOptimizationPage extends StatelessWidget {
  const ProviderOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 整个页面用 watch 监听，任何变化都会重建整个页面
    // 实际项目中应避免这样做
    final state = context.watch<OptimizationState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('重建优化对比'),
        backgroundColor: state.themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('方式1: 整页 watch() — 任何变化都重建整个页面'),
            const Text(
              '⚠️ 上面的 AppBar 颜色会随主题变化，但整个页面也一起重建了',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('方式2: Consumer — 只重建包裹的部分'),
            const ConsumerOptimized(),
            const Divider(height: 32),

            _buildSectionTitle('方式3: Selector — 只监听特定字段'),
            const SelectorOptimized(),
            const Divider(height: 32),

            _buildSectionTitle('操作区'),
            const OperationPanel(),
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
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}

// ==================== Consumer 优化示例 ====================

class ConsumerOptimized extends StatelessWidget {
  const ConsumerOptimized({super.key});

  @override
  Widget build(BuildContext context) {
    // 这个 Widget 本身不会因为 OptimizationState 变化而重建
    // 只有 Consumer 的 builder 内部会重建
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consumer 包裹区域 — 只重建内部',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),

            // 只有 counter 变化时，这个 builder 才会执行
            Consumer<OptimizationState>(
              builder: (context, state, child) {
                // 用 log 输出观察重建时机
                log('【Consumer】counter builder 重建: count=${state.counter}');

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '计数: ${state.counter}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            const Text(
              '修改用户名或主题色时，上面的计数区域不会重建',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Selector 优化示例 ====================

class SelectorOptimized extends StatelessWidget {
  const SelectorOptimized({super.key});

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
              'Selector 包裹区域 — 更精准的字段级监听',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Selector 只监听 username 字段
            Selector<OptimizationState, String>(
              selector: (_, state) => state.username,
              builder: (context, username, child) {
                log('【Selector】username builder 重建: $username');

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        '用户名: $username',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            const Text(
              '只有 username 变化时才重建，counter 和 themeColor 变化不影响',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 操作面板 ====================

class OperationPanel extends StatelessWidget {
  const OperationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    log('【OperationPanel 重建:');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final state = context.read<OptimizationState>();
                      state.updateUsername(
                        state.username == '用户A' ? '用户B' : '用户A',
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('切换用户'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<OptimizationState>().increment(),
                    icon: const Icon(Icons.add),
                    label: const Text('计数+1'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.read<OptimizationState>().changeThemeColor(),
                icon: const Icon(Icons.color_lens),
                label: const Text('切换主题色'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '打开控制台查看 log，观察不同操作触发哪些区域的重建',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
