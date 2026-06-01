import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 2.2 —— async/await 详解
///
/// 核心知识点：
/// 1. async/await 是 Future 的语法糖，让异步代码看起来像同步代码
/// 2. async 函数返回 Future<T>，函数体内的 return 值会包装成 Future
/// 3. await 暂停当前 async 函数的执行，等待 Future 完成后继续
/// 4. await 只能在 async 函数中使用
/// 5. await 不会阻塞线程，只是暂停当前函数
@RoutePage()
class AsyncAwaitPage extends StatefulWidget {
  const AsyncAwaitPage({super.key});

  @override
  State<AsyncAwaitPage> createState() => _AsyncAwaitPageState();
}

class _AsyncAwaitPageState extends State<AsyncAwaitPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2.2 async/await 详解')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'async/await 本质',
            content:
                'async/await 是语法糖，编译器会把 async 函数转换成 .then() 链。\n\n'
                '以下两种写法等价：\n\n'
                '写法 1（async/await）：\n'
                '  Future<String> getData() async {\n'
                '    final data = await fetchFromNetwork();\n'
                '    return "result: \$data";\n'
                '  }\n\n'
                '写法 2（.then() 链）：\n'
                '  Future<String> getData() {\n'
                '    return fetchFromNetwork()\n'
                '      .then((data) => "result: \$data");\n'
                '  }',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: 'await 的含义',
            content:
                'await 并不是"阻塞线程"，而是：\n'
                '  1. 暂停当前 async 函数的执行\n'
                '  2. 把控制权交还给事件循环\n'
                '  3. 当 Future 完成时，恢复函数执行\n\n'
                '这期间事件循环可以处理其他任务（如 UI 更新、其他事件）。',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：async/await 基本用法',
            color: Colors.blue,
            onPressed: _demoBasicAsyncAwait,
          ),
          _actionButton(
            label: '演示：await 不阻塞线程',
            color: Colors.green,
            onPressed: _demoAwaitNonBlocking,
          ),
          _actionButton(
            label: '演示：async 函数的返回值',
            color: Colors.orange,
            onPressed: _demoAsyncReturn,
          ),
          _actionButton(
            label: '演示：async/await vs .then() 对比',
            color: Colors.purple,
            onPressed: _demoComparison,
          ),
          _actionButton(
            label: '演示：串行 await',
            color: Colors.teal,
            onPressed: _demoSerialAwait,
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

  // ==================== 演示 1：基本用法 ====================
  Future<void> _demoBasicAsyncAwait() async {
    _log('=== async/await 基本用法 ===');

    _log('【同步】开始');

    // 模拟一个异步操作
    final result = await Future(() {
      _log('【Future 回调】执行中...');
      return 'Hello from async';
    });

    _log('【await 之后】拿到结果：$result');
    _log('【同步】这段代码在 Future 完成后才执行');
  }

  // ==================== 演示 2：await 不阻塞 ====================
  Future<void> _demoAwaitNonBlocking() async {
    _log('=== await 不阻塞线程 ===');
    _log('【同步】按钮点击处理开始');

    // 启动一个不 await 的 Future（让它自己跑）
    Future.delayed(const Duration(milliseconds: 50), () {
      _log('【独立 Future】我在后台跑完了');
    });

    _log('【同步】按钮点击处理结束');
    _log('注意：独立 Future 会在按钮处理完成后执行');

    // 这里的 await 不影响上面的独立 Future
    await Future.delayed(const Duration(milliseconds: 100));
    _log('【await 完成】100ms 后');
  }

  // ==================== 演示 3：返回值 ====================
  Future<void> _demoAsyncReturn() async {
    _log('=== async 函数的返回值 ===');

    // async 函数返回 Future
    Future<int> computeValue() async {
      await Future.delayed(const Duration(milliseconds: 50));
      return 42; // 这个值会被包装成 Future<int>
    }

    _log('调用 async 函数...');
    final value = await computeValue();
    _log('返回值：$value（类型：${value.runtimeType}）');

    // async 函数返回 null 也是 Future<void>
    Future<void> doNothing() async {
      await Future.delayed(const Duration(milliseconds: 50));
      // 不 return 或 return null
    }

    await doNothing();
    _log('async void 函数执行完毕');
  }

  // ==================== 演示 4：对比 ====================
  Future<void> _demoComparison() async {
    _log('=== async/await vs .then() 对比 ===');

    Future<String> fetchUser() async {
      await Future.delayed(const Duration(milliseconds: 50));
      return 'Alice';
    }

    Future<String> fetchEmail(String user) async {
      await Future.delayed(const Duration(milliseconds: 50));
      return '$user@example.com';
    }

    // .then() 写法
    _log('--- .then() 写法 ---');
    fetchUser().then((user) {
      _log('用户：$user');
      return fetchEmail(user);
    }).then((email) {
      _log('邮箱：$email');
    });

    // async/await 写法
    _log('--- async/await 写法 ---');
    final user = await fetchUser();
    _log('用户：$user');
    final email = await fetchEmail(user);
    _log('邮箱：$email');

    _log('两种写法结果相同，但 async/await 更易读');
  }

  // ==================== 演示 5：串行 await ====================
  Future<void> _demoSerialAwait() async {
    _log('=== 串行 await ===');
    _log('每个 await 都会等待，总时间 = 各步骤时间之和');

    final sw = Stopwatch()..start();

    await Future.delayed(const Duration(milliseconds: 200));
    _log('[${sw.elapsedMilliseconds}ms] 第 1 步完成');

    await Future.delayed(const Duration(milliseconds: 200));
    _log('[${sw.elapsedMilliseconds}ms] 第 2 步完成');

    await Future.delayed(const Duration(milliseconds: 200));
    _log('[${sw.elapsedMilliseconds}ms] 第 3 步完成');

    _log('总耗时：${sw.elapsedMilliseconds}ms（约 600ms）');
    _log('如果用 Future.wait()，总耗时只有 200ms');
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
