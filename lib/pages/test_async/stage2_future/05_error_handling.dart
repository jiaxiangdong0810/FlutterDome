import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 2.5 —— 错误处理最佳实践
///
/// 核心知识点：
/// 1. try-catch 在 async 函数中捕获 await 的错误
/// 2. .catchError() 在 .then() 链中捕获错误
/// 3. Future.timeout() 设置超时
/// 4. Future.whenComplete() 无论成功失败都执行（类似 finally）
/// 5. 未处理的异步错误会导致 Zone 错误
@RoutePage()
class FutureErrorHandlingPage extends StatefulWidget {
  const FutureErrorHandlingPage({super.key});

  @override
  State<FutureErrorHandlingPage> createState() => _FutureErrorHandlingPageState();
}

class _FutureErrorHandlingPageState extends State<FutureErrorHandlingPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.5 错误处理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '错误处理方式对比',
            content:
                '方式 1：try-catch（推荐用于 async/await）\n'
                '  try {\n'
                '    final result = await riskyOperation();\n'
                '  } catch (e) {\n'
                '    print(e);\n'
                '  }\n\n'
                '方式 2：.catchError()（用于 .then() 链）\n'
                '  riskyOperation()\n'
                '    .then((v) => process(v))\n'
                '    .catchError((e) => handle(e));\n\n'
                '方式 3：.onError()（.then 的 onError 参数）\n'
                '  riskyOperation()\n'
                '    .then((v) => v, onError: (e) => default);',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '超时处理',
            content:
                'Future.timeout() 可以设置超时：\n\n'
                '  await future.timeout(\n'
                '    Duration(seconds: 5),\n'
                '    onTimeout: () => defaultResult,\n'
                '  );\n\n'
                '超时后会抛出 TimeoutException，\n'
                '除非提供了 onTimeout 回调。',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：try-catch 捕获错误',
            color: Colors.blue,
            onPressed: _demoTryCatch,
          ),
          _actionButton(
            label: '演示：.catchError() 链式捕获',
            color: Colors.green,
            onPressed: _demoCatchError,
          ),
          _actionButton(
            label: '演示：timeout 超时处理',
            color: Colors.orange,
            onPressed: _demoTimeout,
          ),
          _actionButton(
            label: '演示：whenComplete 清理',
            color: Colors.purple,
            onPressed: _demoWhenComplete,
          ),
          _actionButton(
            label: '演示：重试机制',
            color: Colors.teal,
            onPressed: _demoRetry,
          ),
          _actionButton(
            label: '演示：未处理错误的后果',
            color: Colors.red,
            onPressed: _demoUnhandledError,
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

  // ==================== 演示 1：try-catch ====================
  Future<void> _demoTryCatch() async {
    _log('=== try-catch 捕获错误 ===');

    Future<String> riskyOperation() async {
      await Future.delayed(const Duration(milliseconds: 100));
      throw Exception('网络请求失败');
    }

    try {
      final result = await riskyOperation();
      _log('不会执行：$result');
    } catch (e) {
      _log('catch 捕获：$e');
    } finally {
      _log('finally 总是执行');
    }
  }

  // ==================== 演示 2：.catchError ====================
  void _demoCatchError() {
    _log('=== .catchError() 链式捕获 ===');

    Future.value(1)
        .then((v) {
          _log('步骤 1：$v');
          if (v == 1) throw Exception('步骤 1 出错');
          return v;
        })
        .then((v) {
          _log('步骤 2：不会执行');
          return v;
        })
        .catchError((e) {
          _log('catchError 捕获：$e');
          return 0; // 恢复值
        })
        .then((v) {
          _log('恢复后继续：$v');
        });
  }

  // ==================== 演示 3：timeout ====================
  Future<void> _demoTimeout() async {
    _log('=== timeout 超时处理 ===');

    // 模拟慢请求
    Future<String> slowRequest() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return '慢请求结果';
    }

    // 设置 200ms 超时
    try {
      _log('发起请求，设置 200ms 超时...');
      final result = await slowRequest().timeout(
        const Duration(milliseconds: 200),
        onTimeout: () => '超时默认值',
      );
      _log('结果：$result');
    } on TimeoutException catch (e) {
      _log('超时异常：$e');
    }

    // 不同方式：用 onTimeout 回调
    _log('--- 用 onTimeout 回调 ---');
    final result = await slowRequest().timeout(
      const Duration(milliseconds: 200),
      onTimeout: () => 'onTimeout 返回的默认值',
    );
    _log('结果：$result');
  }

  // ==================== 演示 4：whenComplete ====================
  Future<void> _demoWhenComplete() async {
    _log('=== whenComplete 清理 ===');

    Future<String> operation(bool shouldFail) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (shouldFail) throw Exception('操作失败');
      return '操作成功';
    }

    // 成功的情况
    _log('--- 成功情况 ---');
    await operation(false)
        .then((v) => _log('结果：$v'))
        .whenComplete(() => _log('whenComplete: 清理资源'));

    // 失败的情况
    _log('--- 失败情况 ---');
    await operation(true)
        .then((v) => _log('不会执行'))
        .catchError((e) => _log('错误：$e'))
        .whenComplete(() => _log('whenComplete: 同样清理资源'));

    _log('whenComplete 无论成功失败都会执行，类似 finally');
  }

  // ==================== 演示 5：重试机制 ====================
  Future<void> _demoRetry() async {
    _log('=== 重试机制 ===');

    var attempt = 0;

    Future<String> unreliableOperation() async {
      attempt++;
      await Future.delayed(const Duration(milliseconds: 100));
      if (attempt < 3) {
        throw Exception('第 $attempt 次尝试失败');
      }
      return '第 $attempt 次尝试成功！';
    }

    // 带重试的执行
    Future<T> withRetry<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
      for (var i = 0; i < maxRetries; i++) {
        try {
          return await operation();
        } catch (e) {
          _log('第 ${i + 1} 次失败：$e');
          if (i == maxRetries - 1) rethrow;
          _log('准备重试...');
        }
      }
      throw StateError('unreachable');
    }

    try {
      final result = await withRetry(unreliableOperation);
      _log('最终结果：$result');
    } catch (e) {
      _log('所有重试都失败：$e');
    }
  }

  // ==================== 演示 6：未处理错误 ====================
  Future<void> _demoUnhandledError() async {
    _log('=== 未处理错误 ===');

    // 没有 catchError 的 Future
    Future(() {
      throw Exception('未处理的错误');
    });

    _log('一个未处理错误的 Future 已创建');
    _log('它会被 Zone 的错误处理器捕获');
    _log('在 Flutter 中会显示在控制台');

    await Future.delayed(const Duration(milliseconds: 100));
    _log('程序不会崩溃，但错误会被记录');
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
