import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 3.4 —— Stream 操作符
///
/// 核心知识点：
/// 1. Stream 支持链式操作符，类似 Iterable 的 map/where/take 等
/// 2. map —— 转换每个值
/// 3. where —— 过滤值
/// 4. take / skip —— 取前 N 个 / 跳过前 N 个
/// 5. transform —— 使用 StreamTransformer 做更复杂的转换
/// 6. 操作符返回新的 Stream，不修改原始 Stream
@RoutePage()
class StreamOperatorsPage extends StatefulWidget {
  const StreamOperatorsPage({super.key});

  @override
  State<StreamOperatorsPage> createState() => _StreamOperatorsPageState();
}

class _StreamOperatorsPageState extends State<StreamOperatorsPage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3.4 Stream 操作符')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: 'Stream 操作符 = 异步版 Iterable',
            content:
                '就像 List 有 map / where / take，Stream 也有：\n\n'
                'stream\n'
                '  .map((x) => x * 2)        // 转换\n'
                '  .where((x) => x > 5)       // 过滤\n'
                '  .take(3)                    // 只取前 3 个\n'
                '  .skip(1)                    // 跳过第 1 个\n'
                '  .listen((data) => print(data));\n\n'
                '每个操作符返回一个新的 Stream，形成管道（pipeline）。\n'
                '数据从上游流到下游，每一步都可以加工或过滤。',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '操作符链的执行模型',
            content:
                '重要：操作符是"惰性"的！\n\n'
                '  没有 listen 时，什么都不会发生。\n'
                '  listen 后，数据从源头"拉"出来，经过每一步处理。\n\n'
                '类比：\n'
                '  水管接好了但没开水龙头 → 没有水流\n'
                '  打开水龙头 → 水从源头流经每一节管道',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：map 转换',
            color: Colors.blue,
            onPressed: _demoMap,
          ),
          _actionButton(
            label: '演示：where 过滤',
            color: Colors.green,
            onPressed: _demoWhere,
          ),
          _actionButton(
            label: '演示：take / skip',
            color: Colors.orange,
            onPressed: _demoTakeSkip,
          ),
          _actionButton(
            label: '演示：操作符链组合',
            color: Colors.purple,
            onPressed: _demoChain,
          ),
          _actionButton(
            label: '演示：expand 展开',
            color: Colors.teal,
            onPressed: _demoExpand,
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

  // ==================== 演示 1：map ====================
  void _demoMap() {
    _log('=== map 转换 ===');

    Stream.fromIterable([1, 2, 3, 4, 5])
        .map((x) => x * 10) // 每个值乘以 10
        .listen(
          (data) => _log('【map】原始值 → $data'),
          onDone: () => _log('【完成】'),
        );
  }

  // ==================== 演示 2：where ====================
  void _demoWhere() {
    _log('=== where 过滤 ===');

    Stream.fromIterable([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        .where((x) => x % 2 == 0) // 只保留偶数
        .listen(
          (data) => _log('【where】偶数：$data'),
          onDone: () => _log('【完成】'),
        );
  }

  // ==================== 演示 3：take / skip ====================
  void _demoTakeSkip() {
    _log('=== take / skip ===');

    _log('--- take(3)：只取前 3 个 ---');
    Stream.fromIterable([10, 20, 30, 40, 50])
        .take(3)
        .listen(
          (data) => _log('【take(3)】$data'),
          onDone: () => _log('take 完成'),
        );

    _log('');
    _log('--- skip(2)：跳过前 2 个 ---');
    Stream.fromIterable([10, 20, 30, 40, 50])
        .skip(2)
        .listen(
          (data) => _log('【skip(2)】$data'),
          onDone: () => _log('skip 完成'),
        );
  }

  // ==================== 演示 4：操作符链 ====================
  void _demoChain() {
    _log('=== 操作符链组合 ===');
    _log('原始数据 1~20 → 取偶数 → 乘以 3 → 只取前 4 个');

    Stream.fromIterable(List.generate(20, (i) => i + 1))
        .where((x) => x % 2 == 0) // 1. 过滤偶数
        .map((x) => x * 3) // 2. 乘以 3
        .take(4) // 3. 只取前 4 个
        .listen(
          (data) => _log('【结果】$data'),
          onDone: () => _log('【完成】管道处理结束'),
        );
  }

  // ==================== 演示 5：expand ====================
  void _demoExpand() {
    _log('=== expand 展开 ===');
    _log('expand 把一个值展开成多个值（类似 Iterable.expand）');

    Stream.fromIterable(['hello', 'world'])
        .expand((word) => word.split('')) // 把每个单词拆成字母
        .listen(
          (data) => _log('【expand】$data'),
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
