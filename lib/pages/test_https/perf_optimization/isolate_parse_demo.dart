import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Isolate JSON 解析演示
///
/// 知识点：
/// - Isolate：Dart 的并发单元，独立的内存空间
/// - compute()：在后台 Isolate 执行函数
/// - 大型 JSON 解析不阻塞 UI 线程
/// - 适用场景：解析大型 API 响应、批量数据处理
@RoutePage()
class IsolateParseDemoPage extends StatefulWidget {
  const IsolateParseDemoPage({super.key});

  @override
  State<IsolateParseDemoPage> createState() => _IsolateParseDemoPageState();
}

class _IsolateParseDemoPageState extends State<IsolateParseDemoPage> {
  String _output = '点击按钮查看 Isolate 解析效果';
  bool _loading = false;

  /// 生成大型 JSON 字符串
  String _generateLargeJson(int itemCount) {
    final list = List.generate(itemCount, (i) => {
      'id': i,
      'name': 'User_$i',
      'email': 'user$i@example.com',
      'age': 20 + (i % 50),
      'address': {
        'city': 'City_${i % 100}',
        'street': 'Street_${i % 200}',
        'zip': '${10000 + i}',
      },
      'tags': List.generate(5, (j) => 'tag_${i}_$j'),
      'scores': List.generate(10, (j) => (i * j) % 100),
    });

    return jsonEncode({'users': list, 'total': itemCount});
  }

  /// 主线程解析（会阻塞 UI）
  Future<void> _parseOnMainThread() async {
    setState(() => _loading = true);
    final jsonStr = _generateLargeJson(5000);

    final stopwatch = Stopwatch()..start();

    // 知识点：在主线程解析，UI 会被阻塞
    final result = jsonDecode(jsonStr);
    stopwatch.stop();

    setState(() {
      _loading = false;
      _output = '【主线程解析】\n\n'
          '数据量: ${(jsonStr.length / 1024).toStringAsFixed(1)} KB\n'
          '用户数: ${(result["users"] as List).length}\n'
          '耗时: ${stopwatch.elapsedMilliseconds} ms\n\n'
          '⚠️ 注意：解析期间 UI 被阻塞\n'
          '   进度条/动画会卡住\n'
          '   大数据量时体验很差';
    });
  }

  /// Isolate 解析（不阻塞 UI）
  Future<void> _parseOnIsolate() async {
    setState(() => _loading = true);
    final jsonStr = _generateLargeJson(5000);

    final stopwatch = Stopwatch()..start();

    // 知识点：compute() 在后台 Isolate 执行函数
    // UI 线程不会被阻塞
    final result = await compute(_decodeJson, jsonStr);
    stopwatch.stop();

    setState(() {
      _loading = false;
      _output = '【Isolate 解析】\n\n'
          '数据量: ${(jsonStr.length / 1024).toStringAsFixed(1)} KB\n'
          '用户数: ${(result["users"] as List).length}\n'
          '耗时: ${stopwatch.elapsedMilliseconds} ms\n\n'
          '✅ UI 不会被阻塞\n'
          '   进度条/动画保持流畅\n'
          '   适合处理大型数据';
    });
  }

  /// 对比测试：两种方式各执行多次
  Future<void> _comparePerformance() async {
    setState(() => _loading = true);
    final jsonStr = _generateLargeJson(10000);

    // 主线程测试
    final mainWatch = Stopwatch()..start();
    for (int i = 0; i < 3; i++) {
      jsonDecode(jsonStr);
    }
    mainWatch.stop();

    // Isolate 测试
    final isolateWatch = Stopwatch()..start();
    for (int i = 0; i < 3; i++) {
      await compute(_decodeJson, jsonStr);
    }
    isolateWatch.stop();

    setState(() {
      _loading = false;
      _output = '【性能对比】（解析 10000 条数据 × 3 次）\n\n'
          '主线程解析: ${mainWatch.elapsedMilliseconds} ms\n'
          'Isolate 解析: ${isolateWatch.elapsedMilliseconds} ms\n\n'
          '💡 Isolate 的开销：\n'
          '  • 创建 Isolate 有固定开销\n'
          '  • 数据需要序列化/反序列化传递\n'
          '  • 小数据量：主线程更快（无开销）\n'
          '  • 大数据量：Isolate 更优（不阻塞 UI）\n\n'
          '结论：数据量 > 100KB 时建议用 Isolate';
    });
  }

  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Isolate JSON 解析')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Isolate 要点：\n'
                  '• Dart 是单线程模型，Isolate 是独立的执行单元\n'
                  '• compute() 在后台 Isolate 执行函数\n'
                  '• 参数和返回值必须是可序列化的\n'
                  '• 大型 JSON 解析应使用 Isolate 避免卡顿',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Center(child: Text('解析中... UI 应该保持流畅', style: TextStyle(fontSize: 12))),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _parseOnMainThread,
                  child: const Text('主线程解析'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _parseOnIsolate,
                  child: const Text('Isolate 解析'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _comparePerformance,
                  child: const Text('性能对比'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 400,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 顶层函数：在 Isolate 中执行的 JSON 解析
///
/// 知识点：compute() 要求函数是顶层函数或静态方法
/// 不能访问主 Isolate 的变量
Map<String, dynamic> _decodeJson(String jsonStr) {
  return jsonDecode(jsonStr) as Map<String, dynamic>;
}
