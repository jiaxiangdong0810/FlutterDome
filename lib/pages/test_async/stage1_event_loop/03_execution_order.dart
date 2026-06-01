import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 1.3 —— 执行顺序综合实验
///
/// 核心知识点：
/// 1. 同步代码 > 微任务 > 事件（Future）
/// 2. Future.value() 的 .then() 是微任务
/// 3. Future() 的回调是事件队列任务
/// 4. 嵌套的微任务会在当前轮次全部清空
/// 5. 嵌套的事件任务会排到队列末尾
@RoutePage()
class ExecutionOrderPage extends StatefulWidget {
  const ExecutionOrderPage({super.key});

  @override
  State<ExecutionOrderPage> createState() => _ExecutionOrderPageState();
}

class _ExecutionOrderPageState extends State<ExecutionOrderPage> {
  final List<String> _logs = [];
  final List<String> _expected = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('1.3 执行顺序综合实验')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '执行顺序规则总结',
            content:
                '规则 1：同步代码立即执行，不会被打断\n'
                '规则 2：微任务优先于事件队列\n'
                '规则 3：微任务队列会在当前轮次全部清空\n'
                '规则 4：事件队列每轮只取一个任务\n'
                '规则 5：Future.value().then() 是微任务\n'
                '规则 6：Future() 回调是事件队列任务\n\n'
                '记忆口诀：同步 > 微任务 > 事件',
          ),
          const SizedBox(height: 12),

          // ==================== 综合实验 ====================
          _actionButton(
            label: '实验 1：经典面试题',
            color: Colors.blue,
            onPressed: _experiment1,
          ),
          _actionButton(
            label: '实验 2：嵌套微任务',
            color: Colors.green,
            onPressed: _experiment2,
          ),
          _actionButton(
            label: '实验 3：混合场景',
            color: Colors.orange,
            onPressed: _experiment3,
          ),
          _actionButton(
            label: '挑战：你来预测顺序',
            color: Colors.red,
            onPressed: _challenge,
          ),
          _actionButton(
            label: '清空日志',
            color: Colors.grey,
            onPressed: () => setState(() {
              _logs.clear();
              _expected.clear();
            }),
          ),
          const SizedBox(height: 16),

          // ==================== 预期顺序 ====================
          if (_expected.isNotEmpty) ...[
            _sectionTitle('预期顺序（先思考再看答案）'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _expected
                    .map((e) => Text(e, style: const TextStyle(fontSize: 13, height: 1.4)))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ==================== 实际输出 ====================
          _sectionTitle('实际输出'),
          _logOutput(),
        ],
      ),
    );
  }

  // ==================== 实验 1：经典面试题 ====================
  void _experiment1() {
    _expected.clear();
    _expected.addAll([
      '1.【同步】1',
      '2.【同步】3',
      '3.【同步】4',
      '4.【事件】2',
    ]);

    _log('=== 实验 1：经典面试题 ===');
    _log('代码：print(1); Future(() => print(2)); print(3); print(4);');
    _log('---');

    _log('【同步】1');
    Future(() => _log('【事件】2'));
    _log('【同步】3');
    _log('【同步】4');
    _log('--- 实验 1 结束 ---');
  }

  // ==================== 实验 2：嵌套微任务 ====================
  void _experiment2() {
    _expected.clear();
    _expected.addAll([
      '1.【同步】start',
      '2.【微任务】micro-1',
      '3.【微任务】micro-2（嵌套在 micro-1 中）',
      '4.【微任务】micro-3（嵌套在 micro-2 中）',
      '5.【事件】event-1',
    ]);

    _log('=== 实验 2：嵌套微任务 ===');

    _log('【同步】start');

    scheduleMicrotask(() {
      _log('【微任务】micro-1');
      scheduleMicrotask(() {
        _log('【微任务】micro-2（嵌套在 micro-1 中）');
        scheduleMicrotask(() {
          _log('【微任务】micro-3（嵌套在 micro-2 中）');
        });
      });
    });

    Future(() => _log('【事件】event-1'));

    _log('--- 实验 2 结束 ---');
  }

  // ==================== 实验 3：混合场景 ====================
  void _experiment3() {
    _expected.clear();
    _expected.addAll([
      '1.【同步】A',
      '2.【微任务】B（Future.value.then）',
      '3.【微任务】C（scheduleMicrotask）',
      '4.【事件】D（Future）',
      '5.【事件】E（Future.delayed(0)）',
    ]);

    _log('=== 实验 3：混合场景 ===');

    _log('【同步】A');

    Future.value('value').then((_) => _log('【微任务】B（Future.value.then）'));

    scheduleMicrotask(() => _log('【微任务】C（scheduleMicrotask）'));

    Future(() => _log('【事件】D（Future）'));

    Future.delayed(Duration.zero, () => _log('【事件】E（Future.delayed(0)）'));

    _log('--- 实验 3 结束 ---');
  }

  // ==================== 挑战：你来预测顺序 ====================
  void _challenge() {
    _expected.clear();
    _expected.addAll([
      '1.【同步】main-1',
      '2.【微任务】mt-1',
      '3.【微任务】mt-2',
      '4.【微任务】mt-3（在 mt-2 中注册）',
      '5.【事件】ev-1',
      '6.【微任务】ev-1-then',
      '7.【事件】ev-2',
    ]);

    _log('=== 挑战：你来预测顺序 ===');
    _log('试试不看答案，先预测！');

    _log('【同步】main-1');

    scheduleMicrotask(() => _log('【微任务】mt-1'));

    scheduleMicrotask(() {
      _log('【微任务】mt-2');
      scheduleMicrotask(() => _log('【微任务】mt-3（在 mt-2 中注册）'));
    });

    Future(() {
      _log('【事件】ev-1');
      // ev-1 的 .then()
    }).then((_) => _log('【微任务】ev-1-then'));

    Future(() => _log('【事件】ev-2'));

    _log('--- 挑战结束 ---');
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                        style: TextStyle(
                          color: log.startsWith('---') ? Colors.yellow : Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
