import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Stage 4.4 —— 背压处理策略
///
/// 核心知识点：
/// 1. 背压（Backpressure）：生产者速度 > 消费者速度时的问题
/// 2. 策略一：丢弃（drop）—— 丢掉来不及处理的数据
/// 3. 策略二：缓冲（buffer）—— 先存起来，批量处理
/// 4. 策略三：节流（throttle）—— 固定时间间隔只取一个
/// 5. 策略四：防抖（debounce）—— 等一段时间没有新数据才处理
@RoutePage()
class BackpressurePage extends StatefulWidget {
  const BackpressurePage({super.key});

  @override
  State<BackpressurePage> createState() => _BackpressurePageState();
}

class _BackpressurePageState extends State<BackpressurePage> {
  final List<String> _logs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4.4 背压处理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 知识卡片 ====================
          _knowledgeCard(
            title: '什么是背压？',
            content:
                '当数据产出速度 > 消费速度时，就会产生背压。\n\n'
                '例子：\n'
                '  • 搜索框输入：用户打字很快，但请求搜索 API 较慢\n'
                '  • 传感器数据：每秒 100 个读数，但 UI 只需要每秒更新 1 次\n'
                '  • 消息推送：突发大量消息，但处理每条需要时间\n\n'
                '不处理背压的后果：\n'
                '  • 内存溢出（数据堆积）\n'
                '  • UI 卡顿（处理积压数据）\n'
                '  • 重复请求（搜索场景）',
          ),
          const SizedBox(height: 12),
          _knowledgeCard(
            title: '四种策略',
            content:
                '1. 丢弃（Drop）\n'
                '   忙的时候直接丢掉新数据\n\n'
                '2. 缓冲（Buffer）\n'
                '   先存起来，等消费者空闲了批量处理\n\n'
                '3. 节流（Throttle）\n'
                '   固定时间间隔内只处理第一个\n\n'
                '4. 防抖（Debounce）\n'
                '   等一段时间没有新数据才处理最后一个',
          ),
          const SizedBox(height: 12),

          // ==================== 演示按钮 ====================
          _actionButton(
            label: '演示：问题场景 — 快生产慢消费',
            color: Colors.red,
            onPressed: _demoProblem,
          ),
          _actionButton(
            label: '演示：策略一 — 丢弃（Drop）',
            color: Colors.blue,
            onPressed: _demoDrop,
          ),
          _actionButton(
            label: '演示：策略二 — 缓冲（Buffer）',
            color: Colors.green,
            onPressed: _demoBuffer,
          ),
          _actionButton(
            label: '演示：策略三 — 节流（Throttle）',
            color: Colors.orange,
            onPressed: _demoThrottle,
          ),
          _actionButton(
            label: '演示：策略四 — 防抖（Debounce）',
            color: Colors.purple,
            onPressed: _demoDebounce,
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

  // ==================== 演示 1：问题场景 ====================
  void _demoProblem() {
    _log('=== 问题：快生产慢消费 ===');
    _log('生产者每 100ms 产出，消费者处理需要 500ms...');

    int processed = 0;
    Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
        .take(10)
        .listen(
      (data) async {
        _log('【收到】$data（等待处理...）');
        // 模拟慢消费者
        await Future.delayed(const Duration(milliseconds: 500));
        processed++;
        _log('【处理完成】$data（已处理 $processed 个）');
      },
      onDone: () => _log('【完成】共处理 $processed 个'),
    );
  }

  // ==================== 演示 2：丢弃策略 ====================
  void _demoDrop() {
    _log('=== 策略：丢弃（Drop） ===');
    _log('忙的时候直接跳过，只处理不忙时收到的数据');

    bool busy = false;
    int dropped = 0;
    int processed = 0;

    Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
        .take(10)
        .listen(
      (data) {
        if (busy) {
          dropped++;
          _log('【丢弃】$data（忙碌中，累计丢弃 $dropped 个）');
          return;
        }

        busy = true;
        processed++;
        _log('【处理】$data');
        Future.delayed(const Duration(milliseconds: 500), () {
          busy = false;
        });
      },
      onDone: () => _log('【完成】处理 $processed 个，丢弃 $dropped 个'),
    );
  }

  // ==================== 演示 3：缓冲策略 ====================
  void _demoBuffer() {
    _log('=== 策略：缓冲（Buffer） ===');
    _log('每 500ms 批量处理一次，把期间收到的数据打包');

    final buffer = <int>[];

    Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
        .take(10)
        .listen(
      (data) {
        buffer.add(data);
        _log('【缓冲】加入 $data（缓冲区：$buffer）');
      },
      onDone: () {
        _log('【处理】最终缓冲区：$buffer');
        _log('【完成】批量处理 ${buffer.length} 个数据');
      },
    );

    // 每 500ms 清空一次缓冲区
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (buffer.isNotEmpty) {
        _log('【批量处理】$buffer');
        buffer.clear();
      }
    });
  }

  // ==================== 演示 4：节流 ====================
  void _demoThrottle() {
    _log('=== 策略：节流（Throttle） ===');
    _log('固定 400ms 间隔内只处理第一个数据');

    DateTime lastTime = DateTime(2000); // 很久以前
    int processed = 0;

    Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
        .take(10)
        .listen(
      (data) {
        final now = DateTime.now();
        if (now.difference(lastTime).inMilliseconds >= 400) {
          lastTime = now;
          processed++;
          _log('【节流处理】$data');
        } else {
          _log('【节流跳过】$data');
        }
      },
      onDone: () => _log('【完成】节流处理 $processed 个'),
    );
  }

  // ==================== 演示 5：防抖 ====================
  void _demoDebounce() {
    _log('=== 策略：防抖（Debounce） ===');
    _log('300ms 内没有新数据才处理最后一个');

    Timer? debounceTimer;
    int? lastValue;
    int processed = 0;

    Stream.periodic(const Duration(milliseconds: 100), (i) => i + 1)
        .take(10)
        .listen(
      (data) {
        lastValue = data;
        debounceTimer?.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 300), () {
          processed++;
          _log('【防抖处理】$lastValue（300ms 无新数据）');
        });
      },
      onDone: () {
        // 等最后一个防抖完成
        Future.delayed(const Duration(milliseconds: 500), () {
          _log('【完成】防抖处理 $processed 次');
        });
      },
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
