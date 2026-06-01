import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 2.3 —— Future 链式调用 vs async/await
///
/// 核心知识点：
/// 1. .then() 返回一个新的 Future，可以链式调用
/// 2. .then() 中返回非 Future 值，会包装成 Future
/// 3. .then() 中返回 Future，会自动"展平"（不会出现 Future<Future<T>>）
/// 4. async/await 是 .then() 链的语法糖
/// 5. 错误传播：.then() 链中的错误会跳过后续 .then()，直到被 catchError 捕获
@RoutePage()
class FutureChainPage extends StatefulWidget {
  const FutureChainPage({super.key});

  @override
  State<FutureChainPage> createState() => _FutureChainPageState();
}

class _FutureChainPageState extends State<FutureChainPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.3 Future 链式调用')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '.then() 链的规则',
            content:
                '规则 1：.then() 返回新 Future，值是回调的返回值\n'
                '规则 2：回调返回普通值 → 包装成 Future<值类型>\n'
                '规则 3：回调返回 Future → 自动展平（不会嵌套）\n'
                '规则 4：回调抛出异常 → Future 变成 error 状态\n'
                '规则 5：error 状态会跳过后续 .then()，直到 catchError',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：基础链式调用',
            color: Colors.blue,
            onPressed: _demoBasicChain,
          ),
          _actionButton(
            label: '演示：链中返回 Future',
            color: Colors.green,
            onPressed: _demoChainWithFuture,
          ),
          _actionButton(
            label: '演示：错误传播',
            color: Colors.red,
            onPressed: _demoErrorPropagation,
          ),
          _actionButton(
            label: '演示：catchError 捕获错误',
            color: Colors.orange,
            onPressed: _demoCatchError,
          ),
          _actionButton(
            label: '演示：async/await 等价写法',
            color: Colors.purple,
            onPressed: _demoEquivalent,
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

  // ==================== 演示 1：基础链式调用 ====================
  void _demoBasicChain() {
    _log('=== 基础链式调用 ===');

    Future.value(1)
        .then((v) {
          _log('【第 1 链】收到 $v，返回 ${v + 10}');
          return v + 10;
        })
        .then((v) {
          _log('【第 2 链】收到 $v，返回 ${v * 2}');
          return v * 2;
        })
        .then((v) {
          _log('【第 3 链】收到 $v');
        });

    _log('【同步】链已注册');
  }

  // ==================== 演示 2：链中返回 Future ====================
  void _demoChainWithFuture() {
    _log('=== 链中返回 Future ===');

    Future.value('start')
        .then((v) {
          _log('【第 1 链】$v → 返回一个 Future');
          // 返回 Future，会自动展平
          return Future(() {
            _log('【内部 Future】执行');
            return 'resolved';
          });
        })
        .then((v) {
          _log('【第 2 链】收到展平后的值：$v');
          _log('注意：不是 Future<Future<String>>，而是 String');
        });
  }

  // ==================== 演示 3：错误传播 ====================
  void _demoErrorPropagation() {
    _log('=== 错误传播 ===');

    Future.value(1)
        .then((v) {
          _log('【第 1 链】正常：$v');
          return v + 1;
        })
        .then((v) {
          _log('【第 2 链】即将抛出异常！');
          throw Exception('出错了！');
        })
        .then((v) {
          _log('【第 3 链】不会执行，因为上一链出错了');
        })
        .then((v) {
          _log('【第 4 链】也不会执行');
        })
        .catchError((error) {
          _log('【catchError】捕获到：$error');
          return '恢复的值'; // catchError 返回值会继续传递
        })
        .then((v) {
          _log('【恢复链】收到：$v');
        });
  }

  // ==================== 演示 4：catchError ====================
  void _demoCatchError() {
    _log('=== catchError 捕获错误 ===');

    Future.value('data')
        .then((v) {
          _log('处理：$v');
          throw FormatException('数据格式错误');
        })
        .catchError((error) {
          if (error is FormatException) {
            _log('【catchError】格式错误：${error.message}');
            return 'default data'; // 恢复
          }
          _log('【catchError】其他错误：$error');
          throw error; // 继续传播
        })
        .then((v) {
          _log('后续处理：$v');
        });
  }

  // ==================== 演示 5：等价写法 ====================
  Future<void> _demoEquivalent() async {
    _log('=== async/await 等价写法 ===');

    Future<int> step1() async {
      await Future.delayed(const Duration(milliseconds: 50));
      return 10;
    }

    Future<int> step2(int v) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return v * 2;
    }

    // .then() 写法
    _log('--- .then() 写法 ---');
    step1().then((v) {
      _log('step1 结果：$v');
      return step2(v);
    }).then((v) {
      _log('step2 结果：$v');
    });

    // async/await 写法
    _log('--- async/await 写法 ---');
    final v1 = await step1();
    _log('step1 结果：$v1');
    final v2 = await step2(v1);
    _log('step2 结果：$v2');

    _log('两种写法完全等价');
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
