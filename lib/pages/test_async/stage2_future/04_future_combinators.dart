import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 2.4 —— Future 组合器
///
/// 核心知识点：
/// 1. Future.wait() —— 并行执行多个 Future，全部完成后返回结果列表
/// 2. Future.any() —— 竞速，第一个完成的 Future 的结果作为最终结果
/// 3. Future.forEach() —— 串行遍历，逐个执行
/// 4. Future.doWhile() —— 条件循环执行异步操作
/// 5. 选择合适的组合器可以显著提升性能
@RoutePage()
class FutureCombinatorsPage extends StatefulWidget {
  const FutureCombinatorsPage({super.key});

  @override
  State<FutureCombinatorsPage> createState() => _FutureCombinatorsPageState();
}

class _FutureCombinatorsPageState extends State<FutureCombinatorsPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.4 Future 组合器')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '三种组合模式',
            content:
                '┌──────────────┬────────────┬────────────────────────┐\n'
                '│ 组合器        │ 执行方式    │ 适用场景                │\n'
                '├──────────────┼────────────┼────────────────────────┤\n'
                '│ Future.wait  │ 并行        │ 多个独立请求同时发出     │\n'
                '│ Future.any   │ 竞速        │ 多个源取最快的一个       │\n'
                '│ Future.forEach│ 串行       │ 有先后依赖的顺序执行     │\n'
                '└──────────────┴────────────┴────────────────────────┘',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：Future.wait() 并行',
            color: Colors.blue,
            onPressed: _demoFutureWait,
          ),
          _actionButton(
            label: '演示：Future.wait() 部分失败',
            color: Colors.red,
            onPressed: _demoFutureWaitError,
          ),
          _actionButton(
            label: '演示：Future.any() 竞速',
            color: Colors.green,
            onPressed: _demoFutureAny,
          ),
          _actionButton(
            label: '演示：Future.forEach() 串行',
            color: Colors.orange,
            onPressed: _demoFutureForEach,
          ),
          _actionButton(
            label: '演示：串行 vs 并行性能对比',
            color: Colors.purple,
            onPressed: _demoPerformanceComparison,
          ),
          _actionButton(
            label: '清空日志',
            color: Colors.grey,
            onPressed: () => setState(() => _logs.clear()),
          ),
          const SizedBox(height: 16),

          // ==================== 日志输出 ====================
          _logOutput(),
        ],
      ),
    );
  }

  // ==================== 演示 1：Future.wait ====================
  Future<void> _demoFutureWait() async {
    _log('=== Future.wait() 并行执行 ===');
    final sw = Stopwatch()..start();

    Future<String> fetchUser() async {
      await Future.delayed(const Duration(milliseconds: 300));
      return 'Alice';
    }

    Future<String> fetchEmail() async {
      await Future.delayed(const Duration(milliseconds: 200));
      return 'alice@example.com';
    }

    Future<int> fetchScore() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return 95;
    }

    _log('同时发起 3 个请求...');

    // 并行执行，总耗时 = 最慢的那个
    final results = await Future.wait([fetchUser(), fetchEmail(), fetchScore()]);

    _log('[${sw.elapsedMilliseconds}ms] 全部完成');
    _log('用户：${results[0]}');
    _log('邮箱：${results[1]}');
    _log('分数：${results[2]}');
    _log('总耗时约 400ms（最慢的），而不是 900ms（串行之和）');
  }

  // ==================== 演示 2：wait 部分失败 ====================
  Future<void> _demoFutureWaitError() async {
    _log('=== Future.wait() 部分失败 ===');

    Future<String> success1() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return '成功 1';
    }

    Future<String> fail() async {
      await Future.delayed(const Duration(milliseconds: 200));
      throw Exception('请求失败！');
    }

    Future<String> success2() async {
      await Future.delayed(const Duration(milliseconds: 300));
      return '成功 2';
    }

    try {
      await Future.wait([success1(), fail(), success2()]);
    } catch (e) {
      _log('catch 捕获到：$e');
      _log('注意：wait 会等所有 Future 都完成（或失败）后才抛出第一个错误');
    }
  }

  // ==================== 演示 3：Future.any ====================
  Future<void> _demoFutureAny() async {
    _log('=== Future.any() 竞速 ===');

    Future<String> source1() async {
      await Future.delayed(const Duration(milliseconds: 300));
      return '源 1（300ms）';
    }

    Future<String> source2() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return '源 2（100ms）';
    }

    Future<String> source3() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return '源 3（500ms）';
    }

    _log('3 个源同时开始，取最快的结果...');

    final result = await Future.any([source1(), source2(), source3()]);

    _log('获胜者：$result');
    _log('其他 Future 仍在执行，但结果被忽略');
  }

  // ==================== 演示 4：Future.forEach ====================
  Future<void> _demoFutureForEach() async {
    _log('=== Future.forEach() 串行执行 ===');

    final items = ['A', 'B', 'C', 'D'];
    var index = 0;

    await Future.forEach(items, (item) async {
      await Future.delayed(const Duration(milliseconds: 150));
      index++;
      _log('[$index] 处理 $item 完成');
    });

    _log('全部串行处理完毕');
  }

  // ==================== 演示 5：性能对比 ====================
  Future<void> _demoPerformanceComparison() async {
    _log('=== 串行 vs 并行性能对比 ===');

    Future<int> task(int id) async {
      await Future.delayed(const Duration(milliseconds: 200));
      return id * 10;
    }

    // 串行
    final sw1 = Stopwatch()..start();
    final r1 = await task(1);
    final r2 = await task(2);
    final r3 = await task(3);
    sw1.stop();
    _log('串行：[$r1, $r2, $r3] 耗时 ${sw1.elapsedMilliseconds}ms');

    // 并行
    final sw2 = Stopwatch()..start();
    final results = await Future.wait([task(1), task(2), task(3)]);
    sw2.stop();
    _log('并行：$results 耗时 ${sw2.elapsedMilliseconds}ms');

    _log('并行比串行快约 ${sw1.elapsedMilliseconds - sw2.elapsedMilliseconds}ms');
  }

  // ==================== 辅助方法 ====================
  void _log(String message) {
    setState(() {
      _logs.add(message);
    });
  }

  Widget _knowledgeCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _actionButton({required String label, required Color color, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: color),
        child: Text(label),
      ),
    );
  }

  Widget _logOutput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _logs.isEmpty
          ? const Text('点击上方按钮查看输出', style: TextStyle(color: Colors.grey))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _logs
                  .map((log) => Text(
                        log,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
