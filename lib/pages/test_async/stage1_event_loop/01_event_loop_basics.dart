import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 1.1 —— 事件循环模型
///
/// 核心知识点：
/// 1. Dart 是单线程语言，依靠事件循环（Event Loop）实现异步
/// 2. 事件循环不断从"事件队列"（Event Queue）中取出任务执行
/// 3. 同步代码会一直执行到完成，不会被打断（run-to-completion）
/// 4. 异步任务（如 Future.delayed）完成后会被放入事件队列等待执行
@RoutePage()
class EventLoopBasicsPage extends StatefulWidget {
  const EventLoopBasicsPage({super.key});

  @override
  State<EventLoopBasicsPage> createState() => _EventLoopBasicsPageState();
}

class _EventLoopBasicsPageState extends State<EventLoopBasicsPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.1 事件循环模型')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '什么是事件循环？',
            content:
                'Dart 是单线程语言，但它能处理异步操作，靠的就是事件循环（Event Loop）。\n\n'
                '想象一个 while(true) 循环：\n'
                '  1. 检查微任务队列，有任务就执行完\n'
                '  2. 检查事件队列，取一个任务执行\n'
                '  3. 回到第 1 步\n\n'
                '这就是 Dart 程序运行的核心机制。',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '为什么选择单线程？',
            content:
                '单线程的好处：\n'
                '  • 没有锁竞争，不会有死锁\n'
                '  • 不需要线程同步，代码更简单\n'
                '  • UI 线程不会被阻塞（只要不写耗时同步代码）\n\n'
                '单线程的代价：\n'
                '  • CPU 密集任务会阻塞整个线程\n'
                '  • 需要用 Isolate 来做真正的并行计算',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：同步代码先于异步',
            color: Colors.blue,
            onPressed: _demoSyncFirst,
          ),
          _actionButton(
            label: '演示：run-to-completion',
            color: Colors.green,
            onPressed: _demoRunToCompletion,
          ),
          _actionButton(
            label: '演示：异步任务的执行时机',
            color: Colors.orange,
            onPressed: _demoAsyncTiming,
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

  // ==================== 演示 1：同步代码先于异步 ====================
  void _demoSyncFirst() {
    _log('=== 演示：同步代码先于异步 ===');
    _log('【同步】第 1 行');

    Future(() => _log('【异步 Future】事件队列中的任务'));

    _log('【同步】第 2 行');
    _log('【同步】第 3 行');
    _log('--- 结论：同步代码全部执行完，才轮到 Future ---');
  }

  // ==================== 演示 2：run-to-completion ====================
  void _demoRunToCompletion() {
    _log('=== 演示：run-to-completion ===');
    _log('【同步】开始一段耗时同步操作...');

    // 模拟耗时同步操作 - 阻塞 2 秒
    final stopwatch = Stopwatch()..start();
    var sum = 0;
    while (stopwatch.elapsedMilliseconds < 2000) {
      sum++;
    }
    stopwatch.stop();
    _log('【同步】耗时操作完成，阻塞了 ${stopwatch.elapsedMilliseconds}ms，sum = $sum');

    Future(() => _log('【异步】我只能等同步代码全部执行完才能运行'));

    _log('【同步】最后一行');
    _log('--- 结论：同步代码不会被打断，这就是 run-to-completion ---');
  }

  // ==================== 演示 3：异步任务的执行时机 ====================
  void _demoAsyncTiming() {
    _log('=== 演示：异步任务的执行时机 ===');

    // 立即返回的 Future
    Future(() => _log('【Future】延迟 0ms（实际是下一个事件循环）'));

    // 延迟 0ms 的 Future
    Future.delayed(Duration.zero, () => _log('【Future.delayed(0)】也是下一个事件循环'));

    // 延迟 100ms 的 Future
    Future.delayed(const Duration(milliseconds: 100), () {
      _log('【Future.delayed(100ms)】100ms 后执行');
    });

    // 延迟 50ms 的 Future
    Future.delayed(const Duration(milliseconds: 50), () {
      _log('【Future.delayed(50ms)】50ms 后执行');
    });

    _log('【同步】主函数继续执行');
    _log('--- 结论：延迟短的先执行，延迟长的后执行 ---');
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
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
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
