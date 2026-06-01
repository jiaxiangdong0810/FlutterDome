import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PointerEventsPage extends StatefulWidget {
  const PointerEventsPage({super.key});

  @override
  State<PointerEventsPage> createState() => _PointerEventsPageState();
}

class _PointerEventsPageState extends State<PointerEventsPage> {
  // 记录事件日志
  final List<String> _logs = [];
  // 当前触摸点信息
  final Map<int, _PointerInfo> _pointers = {};

  void _addLog(String log) {
    setState(() {
      _logs.insert(0, log);
      if (_logs.length > 30) _logs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1.1 Pointer 原始事件'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空日志',
            onPressed: () => setState(() => _logs.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // 知识点说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: const Text(
              '💡 Listener Widget 直接监听底层 Pointer 事件，不经过手势识别器。\n'
              '   支持 onPointerDown / onPointerMove / onPointerUp / onPointerCancel 等回调。\n'
              '   多指触控时，每个手指有独立的 pointer ID。',
              style: TextStyle(fontSize: 13),
            ),
          ),

          // 触摸区域
          Expanded(
            flex: 2,
            child: Listener(
              // onPointerDown: 手指按下
              onPointerDown: (PointerDownEvent event) {
                _pointers[event.pointer] = _PointerInfo(
                  start: event.position,
                  current: event.position,
                );
                _addLog(
                  '⬇️ DOWN  pointer=${event.pointer}  '
                  'pos=${event.position.dx.toStringAsFixed(1)},${event.position.dy.toStringAsFixed(1)}  '
                  'kind=${event.kind.name}',
                );
              },
              // onPointerMove: 手指移动
              onPointerMove: (PointerMoveEvent event) {
                final info = _pointers[event.pointer];
                if (info != null) {
                  info.current = event.position;
                  final dx = (event.position.dx - info.start.dx).toStringAsFixed(1);
                  final dy = (event.position.dy - info.start.dy).toStringAsFixed(1);
                  _addLog(
                    '↔️ MOVE  pointer=${event.pointer}  '
                    'delta=${event.delta.dx.toStringAsFixed(1)},${event.delta.dy.toStringAsFixed(1)}  '
                    '总偏移=$dx,$dy',
                  );
                }
              },
              // onPointerUp: 手指抬起
              onPointerUp: (PointerUpEvent event) {
                final info = _pointers.remove(event.pointer);
                if (info != null) {
                  final dx = (event.position.dx - info.start.dx).toStringAsFixed(1);
                  final dy = (event.position.dy - info.start.dy).toStringAsFixed(1);
                  _addLog(
                    '⬆️ UP    pointer=${event.pointer}  '
                    'pos=${event.position.dx.toStringAsFixed(1)},${event.position.dy.toStringAsFixed(1)}  '
                    '总偏移=$dx,$dy',
                  );
                }
              },
              // onPointerCancel: 事件被取消（如手势被系统接管）
              onPointerCancel: (PointerCancelEvent event) {
                _pointers.remove(event.pointer);
                _addLog('❌ CANCEL pointer=${event.pointer}');
              },
              // behavior: 控制命中测试行为
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                color: Colors.blue.shade100,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 48,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '在此区域触摸/拖拽\n'
                        '当前活跃指针: ${_pointers.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 关键属性说明
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.grey.shade100,
            child: const Text(
              '📋 PointerEvent 关键属性: pointer(唯一ID) | position(全局坐标) | localPosition(局部坐标) | delta(移动增量) | kind(touch/mouse/stylus)',
              style: TextStyle(fontSize: 11),
            ),
          ),

          // 事件日志
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade900,
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        '等待事件...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) => Text(
                        _logs[index],
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 追踪单个指针的起始和当前位置
class _PointerInfo {
  final Offset start;
  Offset current;

  _PointerInfo({required this.start, required this.current});
}
