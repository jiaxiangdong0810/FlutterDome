import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 4.1 —— async* / yield / yield*
///
/// 核心知识点：
/// 1. async* 函数返回 Stream，用 yield 产出值
/// 2. yield 产出一个值，yield* 委托给另一个 Stream
/// 3. async* 函数是"惰性"的——没有监听者时不会执行
/// 4. 可以用 await for 遍历 Stream
@RoutePage()
class AsyncGeneratorPage extends StatefulWidget {
  const AsyncGeneratorPage({super.key});

  @override
  State<AsyncGeneratorPage> createState() => _AsyncGeneratorPageState();
}

class _AsyncGeneratorPageState extends State<AsyncGeneratorPage> {
  final List<String> _logs = [];
  StreamSubscription<String>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4.1 async* / yield / yield*')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'async* 函数',
            content:
                '普通函数  → 返回一个值\n'
                'async 函数 → 返回 Future<T>\n'
                'async* 函数 → 返回 Stream<T>\n\n'
                'async* 函数体内用 yield 产出值：\n\n'
                'Stream<int> countStream(int n) async* {\n'
                '  for (int i = 1; i <= n; i++) {\n'
                '    await Future.delayed(Duration(seconds: 1));\n'
                '    yield i;  // 产出一个值\n'
                '  }\n'
                '}\n\n'
                '每次 yield 后函数暂停，等下一次被请求时继续。',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: 'yield vs yield*',
            content:
                'yield value     → 产出单个值\n'
                'yield* stream   → 委托给另一个 Stream\n\n'
                'yield* 的用途：\n'
                '  • 组合多个 Stream\n'
                '  • 递归生成（如斐波那契）\n'
                '  • 复用已有的 Stream 逻辑\n\n'
                '类比：\n'
                '  yield   = 自己说一句话\n'
                '  yield*  = 把话筒交给别人',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：基本 async* 生成器',
            color: Colors.blue,
            onPressed: _demoBasicAsyncGen,
          ),
          _actionButton(
            label: '演示：带延迟的生成器',
            color: Colors.green,
            onPressed: _demoDelayedGenerator,
          ),
          _actionButton(
            label: '演示：yield* 委托',
            color: Colors.orange,
            onPressed: _demoYieldStar,
          ),
          _actionButton(
            label: '演示：await for 遍历',
            color: Colors.purple,
            onPressed: _demoAwaitFor,
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

  // ==================== 生成器函数 ====================

  /// 基本 async* 生成器：产出 1 到 n
  Stream<int> countStream(int n) async* {
    for (int i = 1; i <= n; i++) {
      yield i;
    }
  }

  /// 带延迟的生成器：每 500ms 产出一个值
  Stream<String> delayedGenerator() async* {
    final words = ['Hello', 'Flutter', 'Dart', 'Async', 'Stream'];
    for (final word in words) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield word;
    }
  }

  /// yield* 委托：组合两个 Stream
  Stream<int> combinedStream() async* {
    yield 1;
    yield 2;
    yield* Stream.fromIterable([3, 4, 5]); // 委托给另一个 Stream
    yield 6;
  }

  /// 递归 yield*：斐波那契数列
  Stream<int> fibonacci(int n) async* {
    yield* _fibHelper(0, 1, n);
  }

  Stream<int> _fibHelper(int a, int b, int count) async* {
    if (count <= 0) return;
    yield a;
    yield* _fibHelper(b, a + b, count - 1);
  }

  // ==================== 演示方法 ====================

  void _demoBasicAsyncGen() {
    _log('=== 基本 async* 生成器 ===');

    countStream(5).listen(
      (data) => _log('【收到】$data'),
      onDone: () => _log('【完成】'),
    );
  }

  void _demoDelayedGenerator() {
    _log('=== 带延迟的生成器 ===');
    _log('每 500ms 产出一个词...');

    _subscription?.cancel();
    _subscription = delayedGenerator().listen(
      (data) => _log('【收到】$data'),
      onDone: () => _log('【完成】'),
    );
  }

  void _demoYieldStar() {
    _log('=== yield* 委托 ===');

    combinedStream().listen(
      (data) => _log('【收到】$data'),
      onDone: () => _log('【完成】'),
    );
  }

  void _demoAwaitFor() {
    _log('=== await for 遍历 ===');
    _log('用 await for 逐个处理 Stream 中的值...');

    // 在 async 函数中用 await for 遍历
    _processStream();
  }

  Future<void> _processStream() async {
    await for (final value in countStream(5)) {
      _log('【await for】处理：$value');
    }
    _log('【await for】遍历结束');
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
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
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
