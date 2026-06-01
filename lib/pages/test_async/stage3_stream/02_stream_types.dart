import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 3.2 —— 单订阅 vs 广播 Stream
///
/// 核心知识点：
/// 1. 单订阅 Stream（Single-subscription）：只能 listen 一次，第二次会报错
/// 2. 广播 Stream（Broadcast）：可以多次 listen，新订阅者只能收到订阅之后的数据
/// 3. StreamController() 默认创建单订阅，StreamController.broadcast() 创建广播
/// 4. 单订阅 Stream 支持暂停/恢复，广播 Stream 不支持
@RoutePage()
class StreamTypesPage extends StatefulWidget {
  const StreamTypesPage({super.key});

  @override
  State<StreamTypesPage> createState() => _StreamTypesPageState();
}

class _StreamTypesPageState extends State<StreamTypesPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3.2 单订阅 vs 广播 Stream')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '单订阅 Stream',
            content:
                '特点：\n'
                '  • 只能有一个监听者（listen 一次）\n'
                '  • 数据会缓存，监听者不会错过任何值\n'
                '  • 支持 pause() / resume()\n'
                '  • Stream.fromIterable / Stream.periodic 默认是单订阅\n\n'
                '类比：录音机——录好后只能放给一个人听',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '广播 Stream',
            content:
                '特点：\n'
                '  • 可以有多个监听者\n'
                '  • 新订阅者只能收到订阅之后的数据（错过就是错过了）\n'
                '  • 不支持 pause() / resume()\n'
                '  • StreamController.broadcast() 创建\n\n'
                '类比：电台广播——你打开收音机时，只能听到之后的内容',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：单订阅 Stream 只能 listen 一次',
            color: Colors.blue,
            onPressed: _demoSingleSubscription,
          ),
          _actionButton(
            label: '演示：广播 Stream 多次 listen',
            color: Colors.green,
            onPressed: _demoBroadcast,
          ),
          _actionButton(
            label: '演示：广播 Stream 错过数据',
            color: Colors.orange,
            onPressed: _demoBroadcastMissed,
          ),
          _actionButton(
            label: '演示：asBroadcastStream 转换',
            color: Colors.purple,
            onPressed: _demoAsBroadcast,
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

  // ==================== 演示 1：单订阅限制 ====================
  void _demoSingleSubscription() {
    _log('=== 单订阅 Stream ===');

    final controller = StreamController<int>();

    // 第一次 listen 成功
    controller.stream.listen(
      (data) => _log('【监听者 A】收到：$data'),
      onDone: () => _log('【监听者 A】完成'),
    );

    // 第二次 listen 会抛异常
    try {
      controller.stream.listen((data) => _log('【监听者 B】收到：$data'));
    } catch (e) {
      _log('【错误】第二次 listen 失败：$e');
    }

    controller.add(1);
    controller.add(2);
    controller.close();
  }

  // ==================== 演示 2：广播 Stream ====================
  void _demoBroadcast() {
    _log('=== 广播 Stream ===');

    final controller = StreamController<int>.broadcast();

    // 监听者 A 先订阅
    controller.stream.listen(
      (data) => _log('【监听者 A】收到：$data'),
    );

    // 监听者 B 后订阅
    controller.stream.listen(
      (data) => _log('【监听者 B】收到：$data'),
    );

    // 发送数据，两个监听者都能收到
    controller.add(1);
    controller.add(2);
    controller.add(3);

    _log('两个监听者都收到了所有数据');
    controller.close();
  }

  // ==================== 演示 3：广播错过数据 ====================
  void _demoBroadcastMissed() {
    _log('=== 广播 Stream 错过数据 ===');

    final controller = StreamController<int>.broadcast();

    // 先发送一些数据（此时还没有监听者）
    controller.add(1);
    controller.add(2);
    _log('已发送 1, 2（此时没有监听者）');

    // 监听者 A 这才订阅
    controller.stream.listen(
      (data) => _log('【监听者 A】收到：$data'),
    );

    // 再发送数据
    controller.add(3);
    controller.add(4);
    _log('已发送 3, 4');

    _log('监听者 A 只收到了 3, 4，错过了 1, 2');
    controller.close();
  }

  // ==================== 演示 4：asBroadcastStream ====================
  void _demoAsBroadcast() {
    _log('=== asBroadcastStream 转换 ===');

    // 一个普通的单订阅 Stream
    final singleStream = Stream.fromIterable([10, 20, 30]);

    // 转换为广播 Stream
    final broadcastStream = singleStream.asBroadcastStream();

    // 现在可以多次 listen 了
    broadcastStream.listen(
      (data) => _log('【监听者 A】收到：$data'),
    );

    broadcastStream.listen(
      (data) => _log('【监听者 B】收到：$data'),
    );

    _log('单订阅 Stream 通过 .asBroadcastStream() 转为广播');
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
