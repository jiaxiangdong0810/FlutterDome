import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 4.3 —— Stream 合并与分割
///
/// 核心知识点：
/// 1. 合并：多个 Stream → 一个 Stream（StreamGroup.merge / 自定义）
/// 2. 分割：一个 Stream → 多个监听者（广播 Stream / StreamController 转发）
/// 3. 链接：Stream 的输出作为另一个 Stream 的输入
/// 4. 实际场景：合并多个数据源、分发事件到不同处理器
@RoutePage()
class StreamMergeSplitPage extends StatefulWidget {
  const StreamMergeSplitPage({super.key});

  @override
  State<StreamMergeSplitPage> createState() => _StreamMergeSplitPageState();
}

class _StreamMergeSplitPageState extends State<StreamMergeSplitPage> {
  final List<String> _logs = [];
  final List<StreamSubscription> _subscriptions = [];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4.3 Stream 合并与分割')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '合并（Merge）',
            content:
                '多个 Stream 合成一个：\n\n'
                '方式 1：手动用 StreamController 转发\n'
                '  controller1.stream.listen((d) => merged.add(d));\n'
                '  controller2.stream.listen((d) => merged.add(d));\n\n'
                '方式 2：async* 生成器\n'
                '  Stream<T> merge(s1, s2) async* {\n'
                '    yield* s1;\n'
                '    yield* s2;\n'
                '  }\n\n'
                '方式 3：使用 StreamGroup（来自 async 包）',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '分割（Split / 多路分发）',
            content:
                '一个 Stream 分发给多个消费者：\n\n'
                '方式 1：广播 Stream\n'
                '  final broadcast = stream.asBroadcastStream();\n'
                '  broadcast.listen(consumerA);\n'
                '  broadcast.listen(consumerB);\n\n'
                '方式 2：StreamController 转发\n'
                '  source.listen((data) {\n'
                '    controllerA.add(data);\n'
                '    controllerB.add(data);\n'
                '  });',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：手动合并两个 Stream',
            color: Colors.blue,
            onPressed: _demoManualMerge,
          ),
          _actionButton(
            label: '演示：async* 合并',
            color: Colors.green,
            onPressed: _demoAsyncMerge,
          ),
          _actionButton(
            label: '演示：广播分割',
            color: Colors.orange,
            onPressed: _demoBroadcastSplit,
          ),
          _actionButton(
            label: '演示：Stream 链接（级联）',
            color: Colors.purple,
            onPressed: _demoChaining,
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

  // ==================== 演示 1：手动合并 ====================
  void _demoManualMerge() {
    _log('=== 手动合并两个 Stream ===');

    final mergedController = StreamController<String>();

    // Stream A：每 300ms 产出
    Stream.periodic(const Duration(milliseconds: 300), (i) => 'A${i + 1}')
        .take(3)
        .listen(
          (data) => mergedController.add(data),
          onDone: () => _log('Stream A 完成'),
        );

    // Stream B：每 500ms 产出
    Stream.periodic(const Duration(milliseconds: 500), (i) => 'B${i + 1}')
        .take(2)
        .listen(
          (data) => mergedController.add(data),
          onDone: () => _log('Stream B 完成'),
        );

    // 监听合并后的 Stream
    mergedController.stream.listen(
      (data) => _log('【合并输出】$data'),
      onDone: () => _log('【完成】'),
    );

    // 延迟关闭（等所有源完成）
    Future.delayed(const Duration(seconds: 2), () {
      mergedController.close();
    });
  }

  // ==================== 演示 2：async* 合并 ====================
  void _demoAsyncMerge() {
    _log('=== async* 合并 ===');

    final s1 = Stream.fromIterable([1, 2, 3]);
    final s2 = Stream.fromIterable([10, 20, 30]);

    mergeStreams(s1, s2).listen(
      (data) => _log('【合并输出】$data'),
      onDone: () => _log('【完成】'),
    );
  }

  /// 用 async* 合并两个 Stream（顺序执行，先完一个再下一个）
  Stream<T> mergeStreams<T>(Stream<T> s1, Stream<T> s2) async* {
    yield* s1;
    yield* s2;
  }

  // ==================== 演示 3：广播分割 ====================
  void _demoBroadcastSplit() {
    _log('=== 广播分割 ===');

    final source = Stream.fromIterable([100, 200, 300]);
    final broadcast = source.asBroadcastStream();

    // 消费者 A：平方
    broadcast
        .map((x) => x * x)
        .listen((data) => _log('【消费者 A（平方）】$data'));

    // 消费者 B：转字符串
    broadcast
        .map((x) => '值=$x')
        .listen((data) => _log('【消费者 B（字符串）】$data'));

    _log('同一个数据被分发给两个不同的处理器');
  }

  // ==================== 演示 4：Stream 链接 ====================
  void _demoChaining() {
    _log('=== Stream 链接（级联） ===');
    _log('Stream A 的输出 → 作为 Stream B 的输入');

    final source = Stream.fromIterable([1, 2, 3, 4, 5]);

    // 第一级：过滤偶数
    final evenStream = source.where((x) => x % 2 == 0);

    // 第二级：把偶数的值作为延迟毫秒数，用 async* 生成新 Stream
    delayedByValue(evenStream).listen(
      (data) => _log('【链式输出】$data'),
      onDone: () => _log('【完成】'),
    );
  }

  /// 根据输入值决定延迟时间
  Stream<String> delayedByValue(Stream<int> source) async* {
    await for (final value in source) {
      await Future.delayed(Duration(milliseconds: value * 100));
      yield '延迟${value * 100}ms后的值=$value';
    }
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
