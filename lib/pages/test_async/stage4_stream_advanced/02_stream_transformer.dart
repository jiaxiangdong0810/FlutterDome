import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 4.2 —— StreamTransformer 自定义转换
///
/// 核心知识点：
/// 1. StreamTransformer 是 Stream 的"中间件"，可以对数据做任意转换
/// 2. 通过实现 StreamTransformer.bind() 或使用 StreamTransformer.fromHandlers()
/// 3. 可以用 .transform() 把 transformer 接入 Stream 管道
/// 4. 典型用途：JSON 解码、缓冲、去重、日志记录
@RoutePage()
class StreamTransformerPage extends StatefulWidget {
  const StreamTransformerPage({super.key});

  @override
  State<StreamTransformerPage> createState() => _StreamTransformerPageState();
}

class _StreamTransformerPageState extends State<StreamTransformerPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4.2 StreamTransformer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'StreamTransformer 是什么？',
            content:
                'StreamTransformer<S, T> 把 Stream<S> 转换成 Stream<T>。\n\n'
                '两种创建方式：\n\n'
                '1. StreamTransformer.fromHandlers()：\n'
                '   StreamTransformer.fromHandlers(\n'
                '     handleData: (data, sink) { ... },\n'
                '     handleError: (error, stack, sink) { ... },\n'
                '     handleDone: (sink) { ... },\n'
                '   );\n\n'
                '2. 实现 StreamTransformer.bind() 接口（更底层）\n\n'
                '使用：stream.transform(myTransformer)',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: 'Sink 是什么？',
            content:
                'EventSink<T> 是数据的"输出口"：\n\n'
                '  sink.add(value)     → 往下游输出一个值\n'
                '  sink.addError(e)    → 往下游输出一个错误\n'
                '  sink.close()        → 关闭输出\n\n'
                'Transformer 内部拿到上游数据后，\n'
                '通过 sink 决定往下游输出什么。',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：数值加倍 Transformer',
            color: Colors.blue,
            onPressed: _demoDoubleTransformer,
          ),
          _actionButton(
            label: '演示：JSON 解码 Transformer',
            color: Colors.green,
            onPressed: _demoJsonTransformer,
          ),
          _actionButton(
            label: '演示：日志记录 Transformer',
            color: Colors.orange,
            onPressed: _demoLogTransformer,
          ),
          _actionButton(
            label: '演示：去重 Transformer',
            color: Colors.purple,
            onPressed: _demoDistinctTransformer,
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

  // ==================== Transformer 定义 ====================

  /// 数值加倍 Transformer
  StreamTransformer<int, int> get doubleTransformer {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(data * 2); // 把值加倍后输出
      },
    );
  }

  /// JSON 解码 Transformer（模拟）
  StreamTransformer<String, Map<String, dynamic>> get jsonTransformer {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        try {
          // 模拟 JSON 解码
          final map = {'raw': data, 'length': data.length, 'decoded': true};
          sink.add(map);
        } catch (e) {
          sink.addError('JSON 解码失败: $e');
        }
      },
    );
  }

  /// 日志记录 Transformer（透传，但打印日志）
  StreamTransformer<T, T> logTransformer<T>(String tag) {
    return StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        _log('【$tag】通过数据: $data');
        sink.add(data); // 原样透传
      },
      handleDone: (sink) {
        _log('【$tag】Stream 完成');
        sink.close();
      },
    );
  }

  /// 去重 Transformer（连续相同值只保留第一个）
  StreamTransformer<T, T> distinctTransformer<T>() {
    T? lastValue;
    bool hasValue = false;
    return StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) {
        if (!hasValue || data != lastValue) {
          sink.add(data);
          lastValue = data;
          hasValue = true;
        }
      },
    );
  }

  // ==================== 演示方法 ====================

  void _demoDoubleTransformer() {
    _log('=== 数值加倍 Transformer ===');

    Stream.fromIterable([1, 2, 3, 4, 5])
        .transform(doubleTransformer)
        .listen(
          (data) => _log('【结果】$data'),
          onDone: () => _log('【完成】'),
        );
  }

  void _demoJsonTransformer() {
    _log('=== JSON 解码 Transformer ===');

    Stream.fromIterable(['{"name":"张三"}', '{"age":25}', 'hello'])
        .transform(jsonTransformer)
        .listen(
          (data) => _log('【解码结果】$data'),
          onError: (e) => _log('【错误】$e'),
          onDone: () => _log('【完成】'),
        );
  }

  void _demoLogTransformer() {
    _log('=== 日志记录 Transformer ===');
    _log('数据原样通过，但每一步都打印日志');

    Stream.fromIterable([10, 20, 30])
        .transform(logTransformer('阶段1'))
        .map((x) => x + 1)
        .transform(logTransformer('阶段2'))
        .listen(
          (data) => _log('【最终】$data'),
          onDone: () => _log('【完成】'),
        );
  }

  void _demoDistinctTransformer() {
    _log('=== 去重 Transformer ===');

    Stream.fromIterable([1, 1, 2, 2, 2, 3, 1, 1, 3])
        .transform<int>(distinctTransformer())
        .listen(
          (data) => _log('【去重后】$data'),
          onDone: () => _log('【完成】'),
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
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
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
