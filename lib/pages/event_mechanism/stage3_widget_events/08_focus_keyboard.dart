import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ==================== Demo 页面 ====================

@RoutePage()
class FocusKeyboardDemoPage extends StatefulWidget {
  const FocusKeyboardDemoPage({super.key});

  @override
  State<FocusKeyboardDemoPage> createState() => _FocusKeyboardDemoPageState();
}

class _FocusKeyboardDemoPageState extends State<FocusKeyboardDemoPage> {
  final List<String> _logs = [];
  final _focusNodeA = FocusNode(debugLabel: 'FieldA');
  final _focusNodeB = FocusNode(debugLabel: 'FieldB');
  final _focusNodeC = FocusNode(debugLabel: 'FieldC');
  final _focusNodeKeyHandler = FocusNode(debugLabel: 'KeyHandler');

  @override
  void initState() {
    super.initState();
    _focusNodeA.addListener(() => _addLog('FieldA focus: ${_focusNodeA.hasFocus}'));
    _focusNodeB.addListener(() => _addLog('FieldB focus: ${_focusNodeB.hasFocus}'));
    _focusNodeC.addListener(() => _addLog('FieldC focus: ${_focusNodeC.hasFocus}'));
    _focusNodeKeyHandler.addListener(() => _addLog('KeyHandler focus: ${_focusNodeKeyHandler.hasFocus}'));
  }

  @override
  void dispose() {
    _focusNodeA.dispose();
    _focusNodeB.dispose();
    _focusNodeC.dispose();
    _focusNodeKeyHandler.dispose();
    super.dispose();
  }

  void _addLog(String log) {
    setState(() => _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} $log'));
    if (_logs.length > 30) _logs.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Focus 与键盘事件'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '焦点基础', icon: Icon(Icons.center_focus_strong)),
              Tab(text: '键盘事件', icon: Icon(Icons.keyboard)),
              Tab(text: '焦点遍历', icon: Icon(Icons.tab)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFocusBasicTab(),
            _buildKeyboardTab(),
            _buildTraversalTab(),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 1: 焦点基础 ====================

  Widget _buildFocusBasicTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildExplanationCard(),
              const SizedBox(height: 12),
              _buildFocusDemo(),
              const SizedBox(height: 12),
              _buildFocusScopeDemo(),
            ],
          ),
        ),
        _buildLogPanel('焦点变化日志'),
      ],
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.indigo.shade700),
                const SizedBox(width: 8),
                Text('焦点系统核心概念',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• FocusNode：焦点树节点，绑定到 Widget\n'
              '• FocusScopeNode：管理一组 FocusNode，同组内只有一个获焦\n'
              '• hasFocus：当前节点是否持有焦点\n'
              '• hasPrimaryFocus：是否为全局主焦点\n'
              '• Focus 便捷 Widget：自动管理 FocusNode 生命周期',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('手动管理 FocusNode', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('点击输入框获取焦点，观察日志中的 focus 变化',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              focusNode: _focusNodeA,
              decoration: InputDecoration(
                labelText: '字段 A',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _focusNodeA.unfocus(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              focusNode: _focusNodeB,
              decoration: InputDecoration(
                labelText: '字段 B',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _focusNodeB.unfocus(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _focusNodeA.requestFocus(),
                  child: const Text('聚焦 A'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _focusNodeB.requestFocus(),
                  child: const Text('聚焦 B'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => FocusScope.of(context).unfocus(),
                  child: const Text('取消焦点'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusScopeDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Focus Widget（自动管理生命周期）',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Focus Widget 自动创建/销毁 FocusNode，无需手动 dispose',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Focus(
              autofocus: true,
              onFocusChange: (hasFocus) =>
                  _addLog('Focus Widget: hasFocus=$hasFocus'),
              child: Builder(
                builder: (context) {
                  final focusNode = Focus.of(context);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: focusNode.hasFocus
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: focusNode.hasFocus ? Colors.blue : Colors.grey.shade300,
                        width: focusNode.hasFocus ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          focusNode.hasFocus ? '🎯 已获焦' : '未获焦',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: focusNode.hasFocus ? Colors.blue : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('点击此区域获取焦点', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 2: 键盘事件 ====================

  Widget _buildKeyboardTab() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKeyboardExplanation(),
              const SizedBox(height: 12),
              _buildKeyHandlerDemo(),
              const SizedBox(height: 12),
              _buildShortcutsDemo(),
            ],
          ),
        ),
        _buildLogPanel('键盘事件日志'),
      ],
    );
  }

  Widget _buildKeyboardExplanation() {
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.keyboard, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                Text('键盘事件传递链路',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '键盘输入 → Engine → ServicesBinding\n'
              '  → FocusManager.handleKeyMessage\n'
              '    → 当前 FocusNode.onKeyEvent\n'
              '      → handled：停止传递\n'
              '      → ignored：向 parent FocusNode 传递\n'
              '        → 逐层向上传递直到被处理或到达根节点',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyHandlerDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('onKeyEvent 回调', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('在此区域按下键盘按键，观察事件传递',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Focus(
              focusNode: _focusNodeKeyHandler,
              autofocus: true,
              onKeyEvent: (node, event) {
                _addLog('onKeyEvent: ${event.runtimeType} '
                    'key=${event.logicalKey.debugName} '
                    'physical=${event.physicalKey.debugName}');

                // 拦截 Escape 键
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  _addLog('→ Escape 被拦截 (KeyEventResult.handled)');
                  return KeyEventResult.handled;
                }

                // 拦截 Enter 键
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  _addLog('→ Enter 被拦截 (KeyEventResult.handled)');
                  return KeyEventResult.handled;
                }

                _addLog('→ 未处理 (KeyEventResult.ignored)');
                return KeyEventResult.ignored;
              },
              child: Builder(
                builder: (context) {
                  final focusNode = Focus.of(context);
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: focusNode.hasFocus
                          ? Colors.teal.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: focusNode.hasFocus ? Colors.teal : Colors.grey.shade300,
                        width: focusNode.hasFocus ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.keyboard,
                          size: 32,
                          color: focusNode.hasFocus ? Colors.teal : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          focusNode.hasFocus
                              ? '已获焦 — 请按键盘'
                              : '点击此区域获取焦点',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: focusNode.hasFocus ? Colors.teal : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Escape 和 Enter 会被拦截',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutsDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shortcuts + Actions（声明式快捷键）',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Flutter 推荐的快捷键处理方式，比 onKeyEvent 更高层',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Shortcuts(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                    const _SaveIntent(),
                LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
                    const _UndoIntent(),
              },
              child: Actions(
                actions: {
                  _SaveIntent: CallbackAction<_SaveIntent>(
                    onInvoke: (intent) {
                      _addLog('快捷键触发: Ctrl+S (Save)');
                      return null;
                    },
                  ),
                  _UndoIntent: CallbackAction<_UndoIntent>(
                    onInvoke: (intent) {
                      _addLog('快捷键触发: Ctrl+Z (Undo)');
                      return null;
                    },
                  ),
                },
                child: Focus(
                  autofocus: true,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Column(
                      children: [
                        Text('快捷键监听区域', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Ctrl+S → Save', style: TextStyle(fontSize: 12)),
                        Text('Ctrl+Z → Undo', style: TextStyle(fontSize: 12)),
                      ],
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

  // ==================== Tab 3: 焦点遍历 ====================

  Widget _buildTraversalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTraversalExplanation(),
        const SizedBox(height: 12),
        _buildTraversalDemo(),
      ],
    );
  }

  Widget _buildTraversalExplanation() {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tab, color: Colors.deepPurple.shade700),
                const SizedBox(width: 8),
                Text('焦点遍历（Tab 键切换）',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• FocusTraversalGroup：定义遍历组\n'
              '• FocusTraversalOrder：指定遍历顺序\n'
              '• 按 Tab 正向遍历，Shift+Tab 反向遍历\n'
              '• 内置策略：ReadingOrderTraversalPolicy（默认）\n'
              '  OrderedTraversalPolicy、DirectionalTraversalPolicy',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraversalDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('自定义 Tab 顺序', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('按 Tab 键在三个输入框之间切换，顺序为 A → B → C',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: TextField(
                      focusNode: _focusNodeC,
                      decoration: const InputDecoration(
                        labelText: '字段 C (顺序 1)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '字段 A (顺序 2)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: '字段 B (顺序 3)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 焦点遍历顺序由 FocusTraversalOrder 决定，'
                '与 Widget 的物理位置无关。即使 C 排在最上面，'
                '按 Tab 也会先到 C（顺序 1）。',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 日志面板 ====================

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

// ==================== Intent 类 ====================

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}
