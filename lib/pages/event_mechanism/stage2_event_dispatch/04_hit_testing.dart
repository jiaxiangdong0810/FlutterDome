import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HitTestingPage extends StatefulWidget {
  const HitTestingPage({super.key});

  @override
  State<HitTestingPage> createState() => _HitTestingPageState();
}

class _HitTestingPageState extends State<HitTestingPage> {
  final List<String> _logs = [];

  void _log(String msg) {
    setState(() {
      _logs.insert(0, msg);
      if (_logs.length > 30) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2.1 命中测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== 场景1：HitTestBehavior 对比 ======
          const _Title('HitTestBehavior 三模式对比'),
          const _Explain(
            '每列结构相同：底层按钮 + 上层透明遮罩(Listener)。\n'
            '遮罩用不同的 HitTestBehavior，点击遮罩区域观察日志：\n'
            '• deferToChild: 自己不处理，事件穿透到下层 → 只有按钮响应\n'
            '• opaque: 自己处理，且阻止穿透 → 只有遮罩响应\n'
            '• translucent: 自己处理，但不阻止穿透 → 遮罩和按钮都响应',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // --- deferToChild ---
              Expanded(
                child: Column(
                  children: [
                    const Text('deferToChild',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 90,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => _log('🔵 底层按钮被点击'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                child: const Text('按钮', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ),
                          // Listener 不参与手势竞技场，事件可以自然穿透
                          Positioned.fill(
                            child: Listener(
                              behavior: HitTestBehavior.deferToChild,
                              onPointerDown: (_) => _log('🔵 遮罩收到事件'),
                              child: Container(
                                color: Colors.blue.withValues(alpha: 0.15),
                                alignment: Alignment.center,
                                child: const Text('自己不处理\n穿透到按钮', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // --- opaque ---
              Expanded(
                child: Column(
                  children: [
                    const Text('opaque',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 90,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => _log('🟢 底层按钮被点击'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text('按钮', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: (_) => _log('🟢 遮罩收到事件（阻止穿透）'),
                              child: Container(
                                color: Colors.green.withValues(alpha: 0.15),
                                alignment: Alignment.center,
                                child: const Text('自己处理\n阻止穿透', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // --- translucent ---
              Expanded(
                child: Column(
                  children: [
                    const Text('translucent',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 90,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => _log('🟠 底层按钮被点击'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                child: const Text('按钮', style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Listener(
                              behavior: HitTestBehavior.translucent,
                              onPointerDown: (_) => _log('🟠 遮罩收到事件（不阻止穿透）'),
                              child: Container(
                                color: Colors.orange.withValues(alpha: 0.15),
                                alignment: Alignment.center,
                                child: const Text('自己处理\n不阻止穿透', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Text(
              '💡 点击每一列的色块区域，看日志：\n'
              '   • deferToChild → 只有按钮响应，遮罩没反应\n'
              '   • opaque → 只有遮罩响应，按钮没反应\n'
              '   • translucent → 遮罩和按钮都响应！',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
          ),

          const Divider(height: 32),

          // ====== 场景2：IgnorePointer vs AbsorbPointer ======
          const _Title('IgnorePointer vs AbsorbPointer'),
          const _Explain(
            '两个色块叠放，底层按钮 + 上层遮罩：\n'
            '• IgnorePointer: 上层不参与命中测试，事件穿透到下层按钮\n'
            '• AbsorbPointer: 上层不参与命中测试，但阻止事件穿透，按钮收不到',
          ),
          Row(
            children: [
              // IgnorePointer 示例
              Expanded(
                child: Column(
                  children: [
                    const Text('IgnorePointer', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 100,
                      child: Stack(
                        children: [
                          // 底层按钮
                          Positioned.fill(
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => _log('✅ 底层按钮被点击（IgnorePointer 场景）'),
                                child: const Text('点我'),
                              ),
                            ),
                          ),
                          // 上层 IgnorePointer 遮罩
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                color: Colors.red.withValues(alpha: 0.3),
                                alignment: Alignment.center,
                                child: const Text(
                                  'IgnorePointer\n事件穿透',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // AbsorbPointer 示例
              Expanded(
                child: Column(
                  children: [
                    const Text('AbsorbPointer', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 100,
                      child: Stack(
                        children: [
                          // 底层按钮
                          Positioned.fill(
                            child: Center(
                              child: ElevatedButton(
                                onPressed: () => _log('✅ 底层按钮被点击（AbsorbPointer 场景）'),
                                child: const Text('点我'),
                              ),
                            ),
                          ),
                          // 上层 AbsorbPointer 遮罩
                          Positioned.fill(
                            child: AbsorbPointer(
                              child: Container(
                                color: Colors.red.withValues(alpha: 0.3),
                                alignment: Alignment.center,
                                child: const Text(
                                  'AbsorbPointer\n事件被吸收',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          // ====== 场景3：嵌套 Listener 的命中顺序 ======
          const _Title('嵌套 Listener 的命中顺序'),
          const _Explain(
            '命中测试从根向下递归，事件分发从叶子向上传递。\n'
            '嵌套 Listener 时，内层和外层都会收到事件，顺序是内层先处理。',
          ),
          Listener(
            onPointerDown: (_) => _log('🔵 外层 Listener: onPointerDown'),

            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Listener(
                onPointerDown: (_) => _log('🟢 内层 Listener: onPointerDown'),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text('点击此区域\n内外层 Listener 都会收到事件'),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 日志
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _logs.isEmpty
                ? const Center(child: Text('等待操作...', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (_, i) => Text(
                      _logs[i],
                      style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _Explain extends StatelessWidget {
  final String text;
  const _Explain(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.5)),
    );
  }
}
