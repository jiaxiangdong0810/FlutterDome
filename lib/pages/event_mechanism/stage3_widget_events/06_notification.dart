import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// ==================== 自定义 Notification ====================

/// 自定义通知：携带消息和数值
class CountNotification extends Notification {
  final int count;
  CountNotification(this.count);
}

/// 自定义通知：表单验证状态
class FormStatusNotification extends Notification {
  final String field;
  final bool isValid;
  final String? errorMessage;
  FormStatusNotification(this.field, this.isValid, {this.errorMessage});
}

/// 自定义通知：跨层通信
class ActionNotification extends Notification {
  final String action;
  final Map<String, dynamic> data;
  ActionNotification(this.action, this.data);
}

// ==================== Demo 页面 ====================

@RoutePage()
class NotificationDemoPage extends StatefulWidget {
  const NotificationDemoPage({super.key});

  @override
  State<NotificationDemoPage> createState() => _NotificationDemoPageState();
}

class _NotificationDemoPageState extends State<NotificationDemoPage> {
  final List<String> _logs = [];

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
          title: const Text('Notification 通知机制'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '基础', icon: Icon(Icons.notifications)),
              Tab(text: '自定义', icon: Icon(Icons.edit_notifications)),
              Tab(text: '跨层', icon: Icon(Icons.layers)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBasicTab(),
            _buildCustomTab(),
            _buildCrossLayerTab(),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 1: 基础 Notification ====================

  Widget _buildBasicTab() {
    return Column(
      children: [
        // 滚动通知监听区
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _addLog('ScrollStart');
              } else if (notification is ScrollUpdateNotification) {
                _addLog('ScrollUpdate: ${notification.metrics.pixels.toStringAsFixed(0)}px');
              } else if (notification is ScrollEndNotification) {
                _addLog('ScrollEnd');
              }
              return false; // 不消费，继续传递
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 20,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('$index')),
                  title: Text('列表项 $index'),
                  subtitle: const Text('滚动查看 ScrollNotification'),
                ),
              ),
            ),
          ),
        ),
        // 日志面板
        _buildLogPanel('ScrollNotification 日志'),
      ],
    );
  }

  // ==================== Tab 2: 自定义 Notification ====================

  Widget _buildCustomTab() {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<CountNotification>(
            onNotification: (notification) {
              _addLog('CountNotification: count=${notification.count}');
              return true; // 消费，阻止继续冒泡
            },
            child: NotificationListener<FormStatusNotification>(
              onNotification: (notification) {
                _addLog('FormStatus: ${notification.field} '
                    '${notification.isValid ? "✓" : "✗"} '
                    '${notification.errorMessage ?? ""}');
                return false;
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCounterSection(),
                    const Divider(height: 32),
                    _buildFormSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildLogPanel('自定义 Notification 日志'),
      ],
    );
  }

  Widget _buildCounterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('子组件发送 CountNotification',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _CounterSender(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('子组件发送 FormStatusNotification',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _FormSender(),
          ],
        ),
      ),
    );
  }

  // ==================== Tab 3: 跨层通信 ====================

  Widget _buildCrossLayerTab() {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<ActionNotification>(
            onNotification: (notification) {
              _addLog('ActionNotification: action=${notification.action} '
                  'data=${notification.data}');
              return true;
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDeepNestedWidget(),
            ),
          ),
        ),
        _buildLogPanel('跨层 Notification 日志'),
      ],
    );
  }

  /// 模拟深层嵌套：A → B → C → D，D 直接发通知给 A，中间层不感知
  Widget _buildDeepNestedWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('深层嵌套跨层通信',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('层级：A(NotificationListener) → B → C → D(发送通知)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            // Layer A
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A 层 (NotificationListener<ActionNotification>)',
                      style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Layer B
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('B 层 (不感知通知)',
                            style: TextStyle(color: Colors.blue.shade700)),
                        const SizedBox(height: 8),
                        // Layer C
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('C 层 (不感知通知)',
                                  style: TextStyle(color: Colors.green.shade700)),
                              const SizedBox(height: 8),
                              // Layer D
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('D 层 (发送方)',
                                        style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => ActionNotification('refresh', {'page': 'home'}).dispatch(context),
                                          child: const Text('发送 refresh'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => ActionNotification('navigate', {'route': '/settings'}).dispatch(context),
                                          child: const Text('发送 navigate'),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 通用组件 ====================

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

// ==================== 子组件 ====================

/// 计数器发送方
class _CounterSender extends StatefulWidget {
  @override
  State<_CounterSender> createState() => _CounterSenderState();
}

class _CounterSenderState extends State<_CounterSender> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() => _count--);
            CountNotification(_count).dispatch(context);
          },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$_count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: () {
            setState(() => _count++);
            CountNotification(_count).dispatch(context);
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => CountNotification(_count).dispatch(context),
          child: const Text('发送通知'),
        ),
      ],
    );
  }
}

/// 表单发送方
class _FormSender extends StatefulWidget {
  @override
  State<_FormSender> createState() => _FormSenderState();
}

class _FormSenderState extends State<_FormSender> {
  final _controller = TextEditingController();
  bool _isValid = false;

  void _validate() {
    final text = _controller.text;
    _isValid = text.length >= 3;
    FormStatusNotification(
      'username',
      _isValid,
      errorMessage: _isValid ? null : '至少 3 个字符',
    ).dispatch(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: '用户名',
              border: const OutlineInputBorder(),
              isDense: true,
              errorText: _controller.text.isNotEmpty && !_isValid ? '至少 3 个字符' : null,
            ),
            onChanged: (_) => _validate(),
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          _controller.text.isEmpty
              ? Icons.help_outline
              : _isValid
                  ? Icons.check_circle
                  : Icons.error_outline,
          color: _controller.text.isEmpty
              ? Colors.grey
              : _isValid
                  ? Colors.green
                  : Colors.red,
        ),
      ],
    );
  }
}
