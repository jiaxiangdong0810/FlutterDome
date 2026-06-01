import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 3.3 —— StreamController 手动控制
///
/// 核心知识点：
/// 1. StreamController 是手动创建和控制 Stream 的核心工具
/// 2. 通过 controller.add() 添加数据，controller.addError() 添加错误
/// 3. 通过 controller.close() 关闭 Stream
/// 4. controller.stream 获取对应的 Stream 供外部监听
/// 5. onListen / onPause / onResume / onCancel 回调控制生命周期
@RoutePage()
class StreamControllerPage extends StatefulWidget {
  const StreamControllerPage({super.key});

  @override
  State<StreamControllerPage> createState() => _StreamControllerPageState();
}

class _StreamControllerPageState extends State<StreamControllerPage> {
  final List<String> _logs = [];
  late StreamController<int> _controller;
  StreamSubscription<int>? _subscription;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<int>(
      onListen: () => _log('【生命周期】onListen — 有人开始监听'),
      onPause: () => _log('【生命周期】onPause — 监听者暂停了'),
      onResume: () => _log('【生命周期】onResume — 监听者恢复了'),
      onCancel: () => _log('【生命周期】onCancel — 监听者取消了'),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3.3 StreamController')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'StreamController 是什么？',
            content:
                'StreamController 是 Stream 的"发射器"。\n\n'
                '它有两面：\n'
                '  • 生产者端：controller.add() / addError() / close()\n'
                '  • 消费者端：controller.stream → 拿到 Stream 去 listen\n\n'
                '类比：\n'
                '  StreamController = 电台发射塔\n'
                '  controller.stream = 收音机接收频道\n'
                '  add() = 发射信号\n'
                '  listen() = 调频收听',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '生命周期回调',
            content:
                'StreamController(\n'
                '  onListen:   () {},  // 第一个 listen 调用时\n'
                '  onPause:    () {},  // 监听者 pause 时\n'
                '  onResume:   () {},  // 监听者 resume 时\n'
                '  onCancel:   () {},  // 监听者 cancel 时\n'
                ');\n\n'
                '这些回调适合做资源初始化和清理。',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：手动 add 数据',
            color: Colors.blue,
            onPressed: _demoManualAdd,
          ),
          _actionButton(
            label: '演示：添加错误',
            color: Colors.red,
            onPressed: _demoAddError,
          ),
          _actionButton(
            label: '演示：模拟数据生产者',
            color: Colors.green,
            onPressed: _demoProducer,
          ),
          _actionButton(
            label: '演示：多事件类型',
            color: Colors.orange,
            onPressed: _demoMultipleEvents,
          ),
          _actionButton(
            label: '清空日志 & 重置',
            color: Colors.grey,
            onPressed: _reset,
          ),
          const SizedBox(height: 16),

          // ==================== 日志输出 ====================
          _logOutput(),
        ],
      ),
    );
  }

  // ==================== 演示 1：手动 add ====================
  void _demoManualAdd() {
    _log('=== 手动 add 数据 ===');

    _subscription?.cancel();
    _subscription = _controller.stream.listen(
      (data) => _log('【收到】$data'),
      onDone: () => _log('【完成】Stream 已关闭'),
    );

    // 手动添加数据
    _controller.add(100);
    _controller.add(200);
    _controller.add(300);

    _log('已发送 3 个值，Stream 仍然打开');
  }

  // ==================== 演示 2：添加错误 ====================
  void _demoAddError() {
    _log('=== 添加错误 ===');

    _subscription?.cancel();
    _subscription = _controller.stream.listen(
      (data) => _log('【收到】$data'),
      onError: (error) => _log('【错误】$error'),
      onDone: () => _log('【完成】'),
    );

    _controller.add(1);
    _controller.addError('这是一个错误！');
    _controller.add(2);
    _log('错误不会关闭 Stream，之后还能继续 add');
  }

  // ==================== 演示 3：模拟生产者 ====================
  void _demoProducer() {
    _log('=== 模拟数据生产者 ===');
    _log('每 500ms 生产一个数据，共 5 个...');

    _subscription?.cancel();
    _subscription = _controller.stream.listen(
      (data) => _log('【消费者】收到：$data'),
      onDone: () => _log('【消费者】生产者关闭了 Stream'),
    );

    // 模拟异步生产者
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      count++;
      _controller.add(count);
      _log('【生产者】产出：$count');

      if (count >= 5) {
        timer.cancel();
        _controller.close();
        _log('【生产者】关闭 Stream');
      }
    });
  }

  // ==================== 演示 4：多事件类型 ====================
  void _demoMultipleEvents() {
    _log('=== 多事件类型 ===');

    _subscription?.cancel();
    _subscription = _controller.stream.listen(
      (data) => _log('【数据】$data'),
      onError: (error) => _log('【错误】$error'),
      onDone: () => _log('【完成】Stream 结束'),
    );

    _controller.add(1);
    _controller.addError('错误 A');
    _controller.add(2);
    _controller.add(3);
    _controller.addError('错误 B');
    _controller.close();

    _log('数据和错误交替出现，close 后不能再 add');
  }

  // ==================== 重置 ====================
  void _reset() {
    _subscription?.cancel();
    _subscription = null;
    _controller.close();

    // 重新创建 controller
    _controller = StreamController<int>(
      onListen: () => _log('【生命周期】onListen'),
      onPause: () => _log('【生命周期】onPause'),
      onResume: () => _log('【生命周期】onResume'),
      onCancel: () => _log('【生命周期】onCancel'),
    );

    setState(() => _logs.clear());
    _log('已重置，StreamController 已重新创建');
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
