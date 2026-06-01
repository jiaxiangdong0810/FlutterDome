import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@RoutePage()
class GestureArenaPage extends StatefulWidget {
  const GestureArenaPage({super.key});

  @override
  State<GestureArenaPage> createState() => _GestureArenaPageState();
}

class _GestureArenaPageState extends State<GestureArenaPage> {
  final List<String> _arenaLogs = [];
  String _result = '等待操作...';

  void _log(String msg) {
    setState(() {
      _arenaLogs.insert(0, msg);
      if (_arenaLogs.length > 40) _arenaLogs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1.3 手势竞技场'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空日志',
            onPressed: () => setState(() => _arenaLogs.clear()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 知识点说明
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.amber.shade50,
              child: const Text(
                '🏟️ Gesture Arena（手势竞技场）机制：\n'
                    '1. 手指按下 → 多个 GestureRecognizer 同时进入竞技场\n'
                    '2. 移动/抬起过程中，各识别器判断自己是否能识别\n'
                    '3. 识别器通过 accept() 胜出，或 reject() 淘汰\n'
                    '4. 若多个识别器都不主动裁决，5 秒超时后全部淘汰\n'
                    '5. 最终只有一个识别器胜出，获得事件处理权',
                style: TextStyle(fontSize: 13),
              ),
            ),

            // 场景1：Tap vs HorizontalDrag 竞争
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '场景：Tap vs HorizontalDrag 竞争',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '短按 → Tap 胜出（HorizontalDrag 未达到最小移动距离）\n'
                        '水平滑动 → HorizontalDrag 胜出（Tap 在 move 时被取消）',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _log('🏆 Tap 胜出！accept() 被调用');
                      setState(() => _result = 'Tap 胜出');
                    },
                    onHorizontalDragStart: (d) {
                      _log('🏆 HorizontalDrag 胜出！accept() 被调用');
                      setState(() => _result = 'HorizontalDrag 胜出');
                    },
                    onHorizontalDragUpdate: (d) {
                      // 持续拖拽中
                    },
                    onHorizontalDragEnd: (d) {},
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        border: Border.all(color: Colors.amber.shade700, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👇 短按 或 水平滑动', style: TextStyle(fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            '结果: $_result',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 场景2：手动竞技场演示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '手动竞技场：两个识别器竞争',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '使用 RawGestureDetector 注册两个自定义识别器\n'
                        '触摸后两者同时进入竞技场，手动选择谁 accept、谁 reject',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  _ManualArenaDemo(
                    onLog: _log,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 日志区域
            SizedBox(
              height: 300,
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade900,
                child: _arenaLogs.isEmpty
                    ? const Center(
                  child: Text('等待操作...', style: TextStyle(color: Colors.grey)),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _arenaLogs.length,
                  itemBuilder: (context, index) => Text(
                    _arenaLogs[index],
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
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

/// 手动竞技场演示
/// 创建两个自定义识别器，通过按钮手动决定谁胜出
class _ManualArenaDemo extends StatefulWidget {
  final void Function(String) onLog;

  const _ManualArenaDemo({required this.onLog});

  @override
  State<_ManualArenaDemo> createState() => _ManualArenaDemoState();
}

class _ManualArenaDemoState extends State<_ManualArenaDemo> {
  _ArenaEntry? _entryA;
  _ArenaEntry? _entryB;
  String _status = '等待触摸...';

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
                        if (_entryB != null) {
                          _entryB!.reject();
                          widget.onLog('❌ 识别器B 被自动 reject');
                          _entryB = null;
                        }
                        setState(() => _status = 'A 胜出！再次触摸重试');
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
                        if (_entryA != null) {
                          _entryA!.reject();
                          widget.onLog('❌ 识别器A 被自动 reject');
                          _entryA = null;
                        }
                        setState(() => _status = 'B 胜出！再次触摸重试');
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
                    _entryA?.reject();
                    _entryB?.reject();
                    widget.onLog('❌ 两个都 reject() — 全部淘汰！');
                    _entryA = null;
                    _entryB = null;
                    setState(() => _status = '全部淘汰！再次触摸重试');
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
/// 进入竞技场后不自动裁决，等待外部手动 accept/reject
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
/// 进入竞技场后不自动裁决，等待外部手动 accept/reject
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
