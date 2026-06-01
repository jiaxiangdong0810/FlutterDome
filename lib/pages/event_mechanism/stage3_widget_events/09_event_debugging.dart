import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

// ==================== Demo 页面 ====================

@RoutePage()
class EventDebuggingDemoPage extends StatefulWidget {
  const EventDebuggingDemoPage({super.key});

  @override
  State<EventDebuggingDemoPage> createState() => _EventDebuggingDemoPageState();
}

class _EventDebuggingDemoPageState extends State<EventDebuggingDemoPage> {
  final List<String> _logs = [];
  int _tapCount = 0;
  int _pointerDownCount = 0;

  void _addLog(String tag, String msg) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} [$tag] $msg');
    });
    if (_logs.length > 50) _logs.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('事件机制的调试'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pointer 调试', icon: Icon(Icons.touch_app)),
              Tab(text: '手势调试', icon: Icon(Icons.gesture)),
              Tab(text: '调试工具', icon: Icon(Icons.bug_report)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPointerDebugTab(),
            _buildGestureDebugTab(),
            _buildToolsTab(),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 1: Pointer 调试 ====================

  Widget _buildPointerDebugTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(
                title: 'Listener 事件日志',
                icon: Icons.touch_app,
                color: Colors.blue,
                description: '在下方区域触摸，观察完整的 Pointer 事件序列',
                child: Listener(
                  onPointerDown: (e) {
                    _pointerDownCount++;
                    _addLog('Pointer', 'DOWN #$_pointerDownCount '
                        'id=${e.pointer} pos=${e.position.dx.toStringAsFixed(0)},${e.position.dy.toStringAsFixed(0)} '
                        'kind=${e.kind}');
                  },
                  onPointerMove: (e) {
                    _addLog('Pointer', 'MOVE id=${e.pointer} '
                        'delta=${e.delta.dx.toStringAsFixed(1)},${e.delta.dy.toStringAsFixed(1)}');
                  },
                  onPointerUp: (e) {
                    _addLog('Pointer', 'UP id=${e.pointer}');
                  },
                  onPointerCancel: (e) {
                    _addLog('Pointer', 'CANCEL id=${e.pointer}');
                  },
                  onPointerSignal: (e) {
                    _addLog('Pointer', 'SIGNAL ${e.runtimeType}');
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 32, color: Colors.blue.shade400),
                          const SizedBox(height: 8),
                          Text('触摸此区域',
                              style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold)),
                          Text('已触发 $_pointerDownCount 次 PointerDown',
                              style: TextStyle(fontSize: 11, color: Colors.blue.shade400)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                title: '事件序列说明',
                icon: Icons.info_outline,
                color: Colors.teal,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('单次点击的完整事件序列：', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('1. PointerDown → 手指按下'),
                    Text('2. PointerMove → 手指移动（可能多次）'),
                    Text('3. PointerUp → 手指抬起'),
                    SizedBox(height: 8),
                    Text('特殊情况：', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('• PointerCancel → 系统取消（如来电、手势被父组件拦截）'),
                    Text('• PointerSignal → 鼠标滚轮等信号事件'),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildLogPanel('Pointer 事件日志'),
      ],
    );
  }

  // ==================== Tab 2: 手势调试 ====================

  Widget _buildGestureDebugTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCard(
                title: '手势识别日志',
                icon: Icons.gesture,
                color: Colors.green,
                description: '同时注册多种手势，观察竞技场裁决过程',
                child: GestureDetector(
                  onTap: () {
                    _tapCount++;
                    _addLog('Gesture', 'TAP #$_tapCount');
                  },
                  onDoubleTap: () => _addLog('Gesture', 'DOUBLE_TAP'),
                  onLongPress: () => _addLog('Gesture', 'LONG_PRESS'),
                  onPanStart: (d) => _addLog('Gesture', 'PAN_START'),
                  onPanUpdate: (d) =>
                      _addLog('Gesture', 'PAN_UPDATE delta=${d.delta.dx.toStringAsFixed(1)},${d.delta.dy.toStringAsFixed(1)}'),
                  onPanEnd: (d) => _addLog('Gesture', 'PAN_END v=${d.velocity.pixelsPerSecond.dx.toStringAsFixed(0)}'),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gesture, size: 32, color: Colors.green.shade400),
                          const SizedBox(height: 8),
                          Text('尝试各种手势',
                              style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.bold)),
                          Text('点击 / 双击 / 长按 / 拖动',
                              style: TextStyle(fontSize: 11, color: Colors.green.shade400)),
                          Text('已触发 $_tapCount 次 Tap',
                              style: TextStyle(fontSize: 11, color: Colors.green.shade400)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildCard(
                title: 'Pointer vs 手势触发顺序',
                icon: Icons.compare_arrows,
                color: Colors.orange,
                description: '同时监听 Listener 和 GestureDetector，观察触发顺序',
                child: Listener(
                  onPointerDown: (e) => _addLog('Order', '① Listener.onPointerDown'),
                  child: GestureDetector(
                    onTap: () => _addLog('Order', '② GestureDetector.onTap'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.compare_arrows, size: 32, color: Colors.orange.shade400),
                            const SizedBox(height: 8),
                            Text('点击此区域',
                                style: TextStyle(color: Colors.orange.shade600, fontWeight: FontWeight.bold)),
                            Text('观察日志中的 ① 和 ② 顺序',
                                style: TextStyle(fontSize: 11, color: Colors.orange.shade400)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildLogPanel('手势事件日志'),
      ],
    );
  }

  // ==================== Tab 3: 调试工具 ====================

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(
          title: 'Flutter 事件调试开关',
          icon: Icons.bug_report,
          color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDebugFlag(
                'debugPrintHitTestResults',
                '打印命中测试的结果列表',
                '在 RenderBox.hitTest 中输出每次命中的对象',
              ),
              const Divider(),
              _buildDebugFlag(
                'debugPrintGestureArenaDiagnostics',
                '打印手势竞技场的详细日志',
                '显示 arena 的打开、成员添加、竞争、裁决全过程',
              ),
              const Divider(),
              _buildDebugFlag(
                'debugPaintPointersEnabled',
                '在画布上标记接收 pointer 事件的区域',
                '每个 Layer 显示一个计数器，表示接收到的事件数',
              ),
              const Divider(),
              _buildDebugFlag(
                'debugFocusChanges',
                '打印焦点变化日志',
                '每次焦点转移都会在 debug console 输出',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: '常用调试代码片段',
          icon: Icons.code,
          color: Colors.indigo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCodeSnippet(
                '监听所有 Pointer 事件',
                'Listener(\n'
                    '  onPointerDown: (e) => print("DOWN: \${e.pointer}"),\n'
                    '  onPointerMove: (e) => print("MOVE: \${e.pointer}"),\n'
                    '  onPointerUp: (e) => print("UP: \${e.pointer}"),\n'
                    '  child: yourWidget,\n'
                    ')',
              ),
              const SizedBox(height: 12),
              _buildCodeSnippet(
                '监听滚动通知',
                'NotificationListener<ScrollNotification>(\n'
                    '  onNotification: (n) {\n'
                    '    print("scroll: \${n.metrics.pixels}");\n'
                    '    return false;\n'
                    '  },\n'
                    '  child: ListView.builder(...),\n'
                    ')',
              ),
              const SizedBox(height: 12),
              _buildCodeSnippet(
                '监听键盘事件',
                'Focus(\n'
                    '  onKeyEvent: (node, event) {\n'
                    '    print("\${event.logicalKey} \${event.runtimeType}");\n'
                    '    return KeyEventResult.ignored;\n'
                    '  },\n'
                    '  child: yourWidget,\n'
                    ')',
              ),
              const SizedBox(height: 12),
              _buildCodeSnippet(
                '转储焦点树',
                'debugDumpFocusTree();',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: '调试技巧总结',
          icon: Icons.lightbulb_outline,
          color: Colors.amber,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TipItem(
                icon: Icons.looks_one,
                text: '先用 Listener 确认 Pointer 事件是否到达',
              ),
              _TipItem(
                icon: Icons.looks_two,
                text: '再用 GestureDetector 确认手势是否识别',
              ),
              _TipItem(
                icon: Icons.looks_3,
                text: '事件没到达？检查 IgnorePointer/AbsorbPointer/HitTestBehavior',
              ),
              _TipItem(
                icon: Icons.looks_4,
                text: '手势不触发？检查 GestureArena 竞争（可能被其他手势抢占）',
              ),
              _TipItem(
                icon: Icons.looks_5,
                text: '键盘不响应？检查 FocusNode 是否持有焦点',
              ),
              _TipItem(
                icon: Icons.looks_6,
                text: '用 debugPrintGestureArenaDiagnostics 追踪竞技场全过程',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== 通用组件 ====================

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    String? description,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(description, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDebugFlag(String name, String description, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13)),
          Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text(detail, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildCodeSnippet(String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.greenAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogPanel(String title) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _logs.clear()),
                  child: const Text('清空', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _logs.length,
              itemBuilder: (context, index) => Text(
                _logs[index],
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
