import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 3.1 —— Stream 基础概念
///
/// 核心知识点：
/// 1. Stream 是"异步版的 Iterable"，可以产出多个异步值
/// 2. Future 只能返回一个值，Stream 可以返回多个值
/// 3. 通过 listen() 监听 Stream，接收 onData / onError / onDone 回调
/// 4. Stream 的生命周期：产出数据 → 可能出错 → 最终完成
@RoutePage()
class StreamBasicsPage extends StatefulWidget {
  const StreamBasicsPage({super.key});

  @override
  State<StreamBasicsPage> createState() => _StreamBasicsPageState();
}

class _StreamBasicsPageState extends State<StreamBasicsPage> {
  final List<String> _logs = [];
  StreamSubscription<int>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel(); // 记得取消订阅，防止内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3.1 Stream 基础概念')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'Stream 是什么？',
            content:
                'Stream<T> 代表一个"会产出多个 T 类型值"的异步数据流。\n\n'
                '对比理解：\n'
                '  Future<String> → 一个异步值（如一次网络请求）\n'
                '  Stream<String> → 多个异步值（如 WebSocket 消息流）\n\n'
                '生活类比：\n'
                '  Future = 外卖订单（等一次，送到就结束）\n'
                '  Stream = 水龙头（打开后持续出水，直到关掉）',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: 'Stream 的监听方式',
            content:
                'stream.listen(\n'
                '  (data)  {},  // 每次产出一个值时调用\n'
                '  onError: (error) {},  // 出错时调用\n'
                '  onDone:  () {},  // Stream 关闭时调用\n'
                ');\n\n'
                '返回 StreamSubscription，可以暂停/恢复/取消。',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：创建并监听 Stream',
            color: Colors.blue,
            onPressed: _demoBasicListen,
          ),
          _actionButton(
            label: '演示：Stream.fromIterable',
            color: Colors.green,
            onPressed: _demoFromIterable,
          ),
          _actionButton(
            label: '演示：Stream.periodic 周期产生',
            color: Colors.orange,
            onPressed: _demoPeriodic,
          ),
          _actionButton(
            label: '演示：暂停与恢复',
            color: Colors.purple,
            onPressed: _demoPauseResume,
          ),
          _actionButton(
            label: '演示：取消订阅',
            color: Colors.red,
            onPressed: _demoCancel,
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

  // ==================== 演示 1：基本监听 ====================
  void _demoBasicListen() {
    _log('=== 创建并监听 Stream ===');

    // Stream.fromFuture 只会产出一个值，然后就完成
    final stream = Stream.fromFuture(Future.value('Hello Stream!'));

    stream.listen(
      (data) => _log('【onData】收到：$data'),
      onDone: () => _log('【onDone】Stream 完成'),
    );

    _log('【同步】listen 是非阻塞的，继续执行');
  }

  // ==================== 演示 2：fromIterable ====================
  void _demoFromIterable() {
    _log('=== Stream.fromIterable ===');

    // 从一个 List 创建 Stream，逐个产出
    final stream = Stream.fromIterable([1, 2, 3, 4, 5]);

    stream.listen(
      (data) => _log('【onData】收到：$data'),
      onDone: () => _log('【onDone】所有数据产出完毕'),
    );

    _log('【同步】fromIterable 会同步产出所有数据（在当前微任务中）');
  }

  // ==================== 演示 3：periodic ====================
  void _demoPeriodic() {
    _log('=== Stream.periodic ===');
    _log('每 500ms 产出一个值，共 5 个...');

    int count = 0;
    final stream = Stream.periodic(
      const Duration(milliseconds: 500),
      (i) => i + 1, // 产出 1, 2, 3, ...
    ).take(5); // take(5) 限制只取 5 个，之后自动完成

    stream.listen(
      (data) {
        count++;
        _log('【onData #$count】收到：$data');
      },
      onDone: () => _log('【onDone】周期 Stream 完成，共收到 $count 个值'),
    );
  }

  // ==================== 演示 4：暂停与恢复 ====================
  void _demoPauseResume() {
    _log('=== 暂停与恢复 ===');
    _log('每 300ms 产出一个值，第 3 个后暂停，1s 后恢复...');

    int count = 0;
    final stream = Stream.periodic(
      const Duration(milliseconds: 300),
      (i) => i + 1,
    ).take(10);

    _subscription = stream.listen(
      (data) {
        count++;
        _log('【onData #$count】收到：$data');

        if (count == 3) {
          _log('>>> 暂停订阅！');
          _subscription?.pause();

          // 1 秒后恢复
          Future.delayed(const Duration(seconds: 1), () {
            _log('>>> 恢复订阅！');
            _subscription?.resume();
          });
        }
      },
      onDone: () => _log('【onDone】完成，共收到 $count 个值'),
    );
  }

  // ==================== 演示 5：取消订阅 ====================
  void _demoCancel() {
    _log('=== 取消订阅 ===');
    _log('每 300ms 产出一个值，第 3 个后取消...');

    int count = 0;
    final stream = Stream.periodic(
      const Duration(milliseconds: 300),
      (i) => i + 1,
    ).take(10);

    _subscription = stream.listen(
      (data) {
        count++;
        _log('【onData #$count】收到：$data');

        if (count == 3) {
          _log('>>> 取消订阅！后续数据不再接收');
          _subscription?.cancel();
          _subscription = null;
        }
      },
      onDone: () => _log('【onDone】这个不会再触发了'),
    );
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
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
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
