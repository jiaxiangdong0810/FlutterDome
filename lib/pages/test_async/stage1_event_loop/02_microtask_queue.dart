import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 1.2 —— 微任务队列 vs 事件队列
///
/// 核心知识点：
/// 1. Dart 有两个队列：微任务队列（Microtask Queue）和事件队列（Event Queue）
/// 2. 微任务队列优先级高于事件队列
/// 3. 事件循环每一轮会先清空微任务队列，再去事件队列取一个任务
/// 4. scheduleMicrotask() 将任务放入微任务队列
/// 5. Future() 将任务放入事件队列
@RoutePage()
class MicrotaskQueuePage extends StatefulWidget {
  const MicrotaskQueuePage({super.key});

  @override
  State<MicrotaskQueuePage> createState() => _MicrotaskQueuePageState();
}

class _MicrotaskQueuePageState extends State<MicrotaskQueuePage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.2 微任务队列')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '两个队列的优先级',
            content:
                'Dart 事件循环的每一轮：\n'
                '  1. 先检查微任务队列，如果有任务，逐个执行直到清空\n'
                '  2. 再从事件队列取一个任务执行\n'
                '  3. 回到第 1 步\n\n'
                '优先级：微任务 > 事件\n\n'
                '常用微任务来源：\n'
                '  • scheduleMicrotask()\n'
                '  • Future.value() / Future.sync() 的 .then() 回调\n'
                '  • Stream 的某些内部操作\n\n'
                '常用事件队列来源：\n'
                '  • Future(() => ...) 的回调\n'
                '  • Future.delayed() 的回调\n'
                '  • I/O 事件、用户交互事件',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '类比理解',
            content:
                '把事件循环想象成一个服务员：\n\n'
                '  微任务队列 = 老板的紧急指示（必须马上处理）\n'
                '  事件队列 = 顾客的点单（按顺序处理）\n\n'
                '服务员每次处理完一个顾客点单后，\n'
                '会先看看有没有老板的紧急指示，\n'
                '有就全部处理完，再去服务下一个顾客。',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：微任务优先于事件',
            color: Colors.blue,
            onPressed: _demoMicrotaskFirst,
          ),
          _actionButton(
            label: '演示：多个微任务全部先执行',
            color: Colors.green,
            onPressed: _demoMultipleMicrotasks,
          ),
          _actionButton(
            label: '演示：微任务中的微任务',
            color: Colors.orange,
            onPressed: _demoMicrotaskInMicrotask,
          ),
          _actionButton(
            label: '演示：微任务 vs 事件队列',
            color: Colors.purple,
            onPressed: _demoMicrotaskVsEvent,
          ),
          _actionButton(
            label: '演示：递归 3 级调用栈与事件循环',
            color: Colors.teal,
            onPressed: () => _demoRecursion(3),
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

  // ==================== 演示 1：微任务优先于事件 ====================
  void _demoMicrotaskFirst() {
    _log('=== 演示：微任务优先于事件 ===');

    // 先注册一个事件队列任务
    Future(() => _log('【事件队列】Future 任务'));

    // 再注册一个微任务队列任务
    scheduleMicrotask(() => _log('【微任务队列】scheduleMicrotask 任务'));


    _log('【同步】主函数');
    _log('--- 结论：虽然 Future 先注册，但微任务先执行 ---');
  }

  // ==================== 演示 2：多个微任务全部先执行 ====================
  void _demoMultipleMicrotasks() {
    _log('=== 演示：多个微任务全部先执行 ===');

    Future(() => _log('【事件队列】第 1 个事件任务'));

    scheduleMicrotask(() => _log('【微任务队列】第 1 个微任务'));
    scheduleMicrotask(() => _log('【微任务队列】第 2 个微任务'));
    scheduleMicrotask(() => _log('【微任务队列】第 3 个微任务'));

    Future(() => _log('【事件队列】第 2 个事件任务'));

    _log('【同步】主函数');
    _log('--- 结论：3 个微任务全部执行完，才轮到事件队列 ---');
  }

  // ==================== 演示 3：微任务中的微任务 ====================
  void _demoMicrotaskInMicrotask() {
    _log('=== 演示：微任务中的微任务 ===');

    scheduleMicrotask(() {
      _log('【微任务 1】开始');
      // 在微任务中再注册一个微任务
      scheduleMicrotask(() => _log('【微任务 1 中注册的微任务 2】'));
      _log('【微任务 1】结束');
    });

    Future(() => _log('【事件队列】我还是要等所有微任务清空'));

    _log('【同步】主函数');
    _log('--- 结论：微任务中注册的微任务也会在同一轮清空 ---');
  }

  // ==================== 演示 4：微任务 vs 事件队列 ====================
  void _demoMicrotaskVsEvent() {
    _log('=== 演示：微任务 vs 事件队列 ===');

    // scheduleMicrotask → 微任务队列
    scheduleMicrotask(() => _log('【微任务队列】scheduleMicrotask'));

    // Future.value().then() → .then() 回调进微任务队列
    Future.value('value').then((v) => _log('【微任务队列】Future.value().then(): $v'));

    // Future() → 事件队列
    Future(() => _log('【事件队列】Future() 任务'));

    _log('【同步】主函数');
    _log('--- 结论：微任务队列全部执行完，才轮到事件队列 ---');
    _log('--- 注意：Future.value().then() 和 scheduleMicrotask 都是微任务 ---');
  }

  // ==================== 演示 5：递归调用栈与事件循环 ====================
  // 核心：递归就是在调用栈上不断压栈，loop 只有在调用栈清空后才能介入
  void _demoRecursion(int n) {
    _log('=== 演示：递归 $n 级调用栈 ===');

    _recurse(n);

    _log('--- 调用栈清空，loop 介入 ---');
    _log('--- 先清空微任务队列，再逐个执行事件队列 ---');
  }

  void _recurse(int n) {
    if (n == 0) {
      _log('递归到底，return');
      return;
    }

    // 只是入队，不会立即执行
    scheduleMicrotask(() => _log('  【微任务 $n】'));
    Future(() => _log('  【事件 $n】'));

    // 同步代码，立即执行
    _log('【同步 $n】开始');
    _recurse(n - 1); // 继续递归，还在同步阶段
    _log('【同步 $n】结束');
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
