import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@RoutePage()
class EventDispatchPage extends StatefulWidget {
  const EventDispatchPage({super.key});

  @override
  State<EventDispatchPage> createState() => _EventDispatchPageState();
}

class _EventDispatchPageState extends State<EventDispatchPage> {
  final List<String> _logs = [];
  // 记录事件分发的完整链路
  final List<_DispatchStep> _steps = [];

  void _log(String msg) {
    setState(() {
      _logs.insert(0, msg);
      if (_logs.length > 40) _logs.removeLast();
    });
  }

  void _addStep(String layer, String action, Color color) {
    setState(() {
      _steps.add(_DispatchStep(layer, action, color));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2.2 事件分发链路'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() {
              _logs.clear();
              _steps.clear();
            }),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== 知识说明 ======
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            child: const Text(
              '💡 事件传递是双向的：\n'
              '   向下：Hit Test 从根节点递归向下，找出所有被命中的节点\n'
              '   向上：事件沿命中路径反向传递，从叶子到根逐层处理\n\n'
              '   点击下方嵌套结构，观察事件分发的完整顺序。',
              style: TextStyle(fontSize: 13),
            ),
          ),

          const SizedBox(height: 16),

          // ====== 场景1：三层嵌套 Listener ======
          const _Title('三层嵌套 Listener — 事件冒泡顺序'),
          const _Explain(
            '嵌套三层 Listener，点击最内层观察事件如何从内向外传递。\n'
            '每个 Listener 都会收到事件，顺序是：内层 → 中层 → 外层。',
          ),
          _NestedListenerDemo(
            onOuter: () {
              _log('🔵 外层 Listener: onPointerDown');
              _addStep('外层', '收到事件', Colors.blue);
            },
            onMiddle: () {
              _log('🟢 中层 Listener: onPointerDown');
              _addStep('中层', '收到事件', Colors.green);
            },
            onInner: () {
              _log('🟠 内层 Listener: onPointerDown');
              _addStep('内层', '收到事件', Colors.orange);
            },
            onTap: () {
              _log('👆 GestureDetector: onTap（在事件冒泡之后触发）');
              _addStep('手势层', 'onTap 触发', Colors.red);
            },
          ),

          const SizedBox(height: 8),

          // 分发步骤可视化
          if (_steps.isNotEmpty) ...[
            const Text('事件分发顺序:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ..._steps.asMap().entries.map((e) {
              final step = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(
                      '${e.key + 1}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: step.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: step.color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        step.layer,
                        style: TextStyle(fontSize: 12, color: step.color, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(step.action, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }),
          ],

          const Divider(height: 32),

          // ====== 场景2：事件在渲染树中的路径 ======
          const _Title('事件在渲染树中的路径'),
          const _Explain(
            '按下按钮时，事件经过的完整路径：\n'
            '1. Hit Test：RenderView → Scaffold → ListView → Column → Button\n'
            '2. 事件分发：Button.handleEvent → Column → ListView → Scaffold → RenderView\n'
            '3. 手势识别：GestureDetector 在 handleEvent 中接收事件',
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _log('═══ 新事件 ═══');
                _log('1️⃣ Hit Test: RenderView → ... → ElevatedButton');
                _log('2️⃣ 事件分发: ElevatedButton → Column → ListView → Scaffold');
                _log('3️⃣ 手势识别: TapGestureRecognizer 胜出竞技场');
                _log('4️⃣ 回调触发: onPressed() 执行');
                _addStep('Hit Test', '向下递归找命中目标', Colors.cyan);
                _addStep('事件分发', '沿命中路径向上冒泡', Colors.blue);
                _addStep('竞技场', 'Tap 识别器 accept()', Colors.amber);
                _addStep('回调', 'onPressed() 执行', Colors.red);
              },
              child: const Text('点击追踪事件路径'),
            ),
          ),

          const Divider(height: 32),

          // ====== 场景3：Pointer 事件 vs 手势事件 ======
          const _Title('Pointer 事件 vs 手势事件的触发顺序'),
          const _Explain(
            '同时用 Listener（Pointer 层）和 GestureDetector（手势层）监听同一区域：\n'
            'Listener 的 onPointerDown 先于 GestureDetector 的 onTap 触发。\n'
            '因为 Pointer 事件在命中测试阶段就已分发，手势裁决在之后。',
          ),
          Listener(
            onPointerDown: (_) => _log('1️⃣ Listener: onPointerDown（Pointer 层，最先）'),
            onPointerUp: (_) => _log('3️⃣ Listener: onPointerUp（Pointer 层）'),
            child: GestureDetector(
              onTap: () => _log('4️⃣ GestureDetector: onTap（手势层，最后）'),
              onTapDown: (_) => _log('2️⃣ GestureDetector: onTapDown（手势层）'),
              child: Container(
                height: 80,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '同时监听 Pointer 和手势\n观察触发顺序',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ====== 场景4：双识别器竞技场竞争 ======
          const _Title('双识别器竞技场竞争'),
          const _Explain(
            '两个自定义识别器同时监听同一区域，通过按钮手动决定谁胜出：\n'
            '• 识别器A（红色）vs 识别器B（蓝色）\n'
            '• 触摸后两个识别器同时进入竞技场\n'
            '• 点击按钮选择 accept 哪个、reject 哪个\n'
            '• 观察最终只有一个识别器胜出',
          ),
          _DualRecognizerDemo(onLog: _log),

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

class _NestedListenerDemo extends StatelessWidget {
  final VoidCallback onOuter;
  final VoidCallback onMiddle;
  final VoidCallback onInner;
  final VoidCallback onTap;

  const _NestedListenerDemo({
    required this.onOuter,
    required this.onMiddle,
    required this.onInner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onOuter(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('外层 Listener', style: TextStyle(color: Colors.blue, fontSize: 12)),
            Listener(
              onPointerDown: (_) => onMiddle(),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('中层 Listener', style: TextStyle(color: Colors.green, fontSize: 12)),
                    GestureDetector(
                      onTap: onTap,
                      child: Listener(
                        onPointerDown: (_) => onInner(),
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '内层 Listener + GestureDetector\n点击这里',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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

/// 双识别器竞技场演示
/// 两个自定义识别器同时进入竞技场，手动决定谁胜出
class _DualRecognizerDemo extends StatefulWidget {
  final void Function(String) onLog;

  const _DualRecognizerDemo({required this.onLog});

  @override
  State<_DualRecognizerDemo> createState() => _DualRecognizerDemoState();
}

class _DualRecognizerDemoState extends State<_DualRecognizerDemo> {
  _ArenaEntry? _entryA;
  _ArenaEntry? _entryB;
  String _status = '等待触摸...';

  void _checkResolve() {
    // 两个都做出裁决后，清空状态
    if (_entryA == null && _entryB == null) {
      setState(() => _status = '裁决完成！再次触摸重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RawGestureDetector(
          gestures: {
            _RecognizerA: GestureRecognizerFactoryWithHandlers<_RecognizerA>(
              () => _RecognizerA(
                onArenaEnter: (entry) {
                  _entryA = entry;
                  widget.onLog('🔴 识别器A 进入竞技场');
                  setState(() => _status = '两个识别器已进入竞技场，点击按钮裁决');
                },
              ),
              (instance) {},
            ),
            _RecognizerB: GestureRecognizerFactoryWithHandlers<_RecognizerB>(
              () => _RecognizerB(
                onArenaEnter: (entry) {
                  _entryB = entry;
                  widget.onLog('🔵 识别器B 进入竞技场');
                  setState(() => _status = '两个识别器已进入竞技场，点击按钮裁决');
                },
              ),
              (instance) {},
            ),
          },
          child: Container(
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.blue.shade50],
              ),
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_status, style: const TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _entryA == null
                    ? null
                    : () {
                        _entryA!.accept();
                        widget.onLog('✅ 识别器A accept() — A 胜出！');
                        _entryA = null;
                        // B 自动被 reject
                        if (_entryB != null) {
                          _entryB!.reject();
                          widget.onLog('❌ 识别器B 被自动 reject');
                          _entryB = null;
                        }
                        setState(() {});
                      },
                icon: const Icon(Icons.check, color: Colors.red),
                label: const Text('A 胜出'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _entryB == null
                    ? null
                    : () {
                        _entryB!.accept();
                        widget.onLog('✅ 识别器B accept() — B 胜出！');
                        _entryB = null;
                        // A 自动被 reject
                        if (_entryA != null) {
                          _entryA!.reject();
                          widget.onLog('❌ 识别器A 被自动 reject');
                          _entryA = null;
                        }
                        setState(() {});
                      },
                icon: const Icon(Icons.check, color: Colors.blue),
                label: const Text('B 胜出'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (_entryA == null && _entryB == null)
                ? null
                : () {
                    if (_entryA != null) {
                      _entryA!.reject();
                      widget.onLog('❌ 识别器A reject()');
                      _entryA = null;
                    }
                    if (_entryB != null) {
                      _entryB!.reject();
                      widget.onLog('❌ 识别器B reject()');
                      _entryB = null;
                    }
                    widget.onLog('💥 两个都被淘汰！5秒超时后也会自动淘汰');
                    setState(() {});
                  },
            icon: const Icon(Icons.close, color: Colors.grey),
            label: const Text('两个都 Reject'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
        ),
      ],
    );
  }
}

class _ArenaEntry {
  final GestureArenaEntry entry;
  _ArenaEntry(this.entry);
  void accept() => entry.resolve(GestureDisposition.accepted);
  void reject() => entry.resolve(GestureDisposition.rejected);
}

/// 自定义识别器A（红色）
class _RecognizerA extends OneSequenceGestureRecognizer {
  final void Function(_ArenaEntry entry)? onArenaEnter;

  _RecognizerA({this.onArenaEnter});

  @override
  void addPointer(PointerDownEvent event) {
    final entry = GestureBinding.instance.gestureArena.add(event.pointer, this);
    onArenaEnter?.call(_ArenaEntry(entry));
  }

  @override
  String get debugDescription => 'RecognizerA';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {}

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {}
}

/// 自定义识别器B（蓝色）
class _RecognizerB extends OneSequenceGestureRecognizer {
  final void Function(_ArenaEntry entry)? onArenaEnter;

  _RecognizerB({this.onArenaEnter});

  @override
  void addPointer(PointerDownEvent event) {
    final entry = GestureBinding.instance.gestureArena.add(event.pointer, this);
    onArenaEnter?.call(_ArenaEntry(entry));
  }

  @override
  String get debugDescription => 'RecognizerB';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {}

  @override
  void acceptGesture(int pointer) {}

  @override
  void rejectGesture(int pointer) {}
}

class _DispatchStep {
  final String layer;
  final String action;
  final Color color;

  _DispatchStep(this.layer, this.action, this.color);
}
