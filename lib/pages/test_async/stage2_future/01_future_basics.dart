import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 2.1 —— Future 基础
///
/// 核心知识点：
/// 1. Future 代表一个"将来会有结果"的值
/// 2. Future 有三种状态：未完成（uncompleted）、已完成有值、已完成有错误
/// 3. 创建 Future 的方式：Future()、Future.value()、Future.error()、Future.delayed()
/// 4. Future 一旦完成就不可变（immutable），状态不会再改变
/// 5. 可以通过 .then() 和 .catchError() 注册回调
@RoutePage()
class FutureBasicsPage extends StatefulWidget {
  const FutureBasicsPage({super.key});

  @override
  State<FutureBasicsPage> createState() => _FutureBasicsPageState();
}

class _FutureBasicsPageState extends State<FutureBasicsPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.1 Future 基础')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'Future 是什么？',
            content:
                'Future<T> 代表一个"将来会产生 T 类型结果"的异步操作。\n\n'
                '三种状态：\n'
                '  ┌─────────────┐\n'
                '  │  uncompleted │ ← 刚创建，等待结果\n'
                '  └──────┬──────┘\n'
                '         │\n'
                '    ┌────┴────┐\n'
                '    ↓         ↓\n'
                '  有值      有错误\n'
                '  (value)  (error)\n\n'
                '状态转换只能发生一次，不可逆转。',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '创建 Future 的方式',
            content:
                'Future(() => value)         ← 事件队列中执行\n'
                'Future.value(value)         ← 立即完成（微任务）\n'
                'Future.error(error)         ← 立即出错\n'
                'Future.delayed(duration, fn) ← 延迟后执行\n'
                'Future.sync(() => value)    ← 同步执行，结果进微任务\n'
                'Future(() async => value)   ← async 函数返回 Future',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：Future() 基本创建',
            color: Colors.blue,
            onPressed: _demoBasicFuture,
          ),
          _actionButton(
            label: '演示：Future.value() 立即完成',
            color: Colors.green,
            onPressed: _demoFutureValue,
          ),
          _actionButton(
            label: '演示：Future.error() 立即出错',
            color: Colors.red,
            onPressed: _demoFutureError,
          ),
          _actionButton(
            label: '演示：Future.delayed() 延迟',
            color: Colors.orange,
            onPressed: _demoFutureDelayed,
          ),
          _actionButton(
            label: '演示：.then() 注册回调',
            color: Colors.purple,
            onPressed: _demoThenCallback,
          ),
          _actionButton(
            label: '演示：多次 .then()',
            color: Colors.teal,
            onPressed: _demoMultipleThen,
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

  // ==================== 演示 1：基本 Future ====================
  void _demoBasicFuture() {
    _log('=== Future() 基本创建 ===');

    final future = Future(() {
      _log('【Future 回调】我在事件队列中执行');
      return 42;
    });

    _log('Future 已创建，状态：未完成');
    _log('类型：${future.runtimeType}');

    future.then((value) {
      _log('【.then()】收到结果：$value');
    });

    _log('【同步】继续执行');
  }

  // ==================== 演示 2：Future.value ====================
  void _demoFutureValue() {
    _log('=== Future.value() 立即完成 ===');

    final future = Future.value('Hello');

    _log('Future.value 已创建，它立即就是完成状态');

    future.then((value) {
      _log('【.then()】收到：$value');
      _log('注意：.then() 是微任务，不在当前同步代码中执行');
    });

    _log('【同步】.then() 还没执行，因为它在微任务队列');
  }

  // ==================== 演示 3：Future.error ====================
  void _demoFutureError() {
    _log('=== Future.error() 立即出错 ===');

    final future = Future.error('出错了！');

    future.then(
      (value) => _log('【.then()】不会执行'),
      onError: (error) => _log('【onError】捕获到错误：$error'),
    );

    _log('【同步】继续');
  }

  // ==================== 演示 4：Future.delayed ====================
  void _demoFutureDelayed() {
    _log('=== Future.delayed() ===');

    _log('创建 500ms 延迟的 Future...');

    Future.delayed(const Duration(milliseconds: 500), () {
      _log('【500ms 后】延迟完成！');
      return 'delayed result';
    }).then((value) => _log('【.then()】收到：$value'));

    _log('【同步】Future 已创建，但还没完成');
  }

  // ==================== 演示 5：.then() 回调 ====================
  void _demoThenCallback() {
    _log('=== .then() 注册回调 ===');

    Future(() => 'Dart')
        .then((lang) {
          _log('【.then()】语言：$lang');
          return 'Flutter is built with $lang';
        })
        .then((desc) {
          _log('【.then()】描述：$desc');
        });

    _log('【同步】.then() 链已注册，等待执行');
  }

  // ==================== 演示 6：多次 .then() ====================
  void _demoMultipleThen() {
    _log('=== 多次 .then() ===');

    final future = Future.value(100);

    // 同一个 Future 注册多个 .then()
    future.then((v) => _log('【.then() #1】$v'));
    future.then((v) => _log('【.then() #2】$v'));
    future.then((v) => _log('【.then() #3】$v'));

    _log('【同步】同一个 Future 的多个 .then() 都会执行');
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
