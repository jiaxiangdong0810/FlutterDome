import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 11 - WebSocket 实时通信
///
/// 知识点：
/// - WebSocket 连接 / 发送 / 接收
/// - 心跳保活
/// - 自动重连
/// - 状态管理
@RoutePage()
class WebSocketDemoPage extends StatefulWidget {
  const WebSocketDemoPage({super.key});

  @override
  State<WebSocketDemoPage> createState() => _WebSocketDemoPageState();
}

class _WebSocketDemoPageState extends State<WebSocketDemoPage> {
  final List<String> _logs = [];
  final TextEditingController _msgController = TextEditingController();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  bool _connected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 10);

  /// 连接 WebSocket
  ///
  /// 知识点：WebSocketChannel.connect 建立连接
  void _connect() {
    _addLog('--- 建立 WebSocket 连接 ---');

    try {
      // 使用 echo 服务测试
      _channel = WebSocketChannel.connect(
        Uri.parse('wss://echo.websocket.org'),
      );

      // 知识点：监听服务端消息
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      setState(() => _connected = true);
      _reconnectAttempts = 0;
      _addLog('✅ 连接成功');

      // 启动心跳
      _startHeartbeat();
    } catch (e) {
      _addLog('❌ 连接失败: $e');
    }
  }

  /// 收到消息
  void _onMessage(dynamic data) {
    // 解析消息
    String message;
    try {
      final json = jsonDecode(data);
      message = json.toString();
    } catch (e) {
      message = data.toString();
    }
    _addLog('📩 收到: $message');
  }

  /// 连接错误
  void _onError(Object error) {
    _addLog('💥 错误: $error');
    _scheduleReconnect();
  }

  /// 连接关闭
  void _onDone() {
    _addLog('🔌 连接已关闭 (code: ${_channel?.closeCode})');
    setState(() => _connected = false);
    _stopHeartbeat();
    _scheduleReconnect();
  }

  /// 发送消息
  ///
  /// 知识点：channel.sink.add 发送数据
  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty || !_connected) return;

    // 构造 JSON 消息
    final message = jsonEncode({
      'type': 'message',
      'content': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    _channel!.sink.add(message);
    _addLog('📤 发送: $text');
    _msgController.clear();
  }

  /// 心跳保活
  ///
  /// 知识点：定期发送 ping 防止连接断开
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_connected) {
        _channel!.sink.add(jsonEncode({'type': 'ping'}));
        _addLog('💓 心跳 ping');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// 自动重连
  ///
  /// 知识点：指数退避重连策略
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _addLog('❌ 已达最大重连次数 ($_maxReconnectAttempts)，停止重连');
      return;
    }

    _reconnectAttempts++;
    // 指数退避：1s, 2s, 4s, 8s, 16s
    final delay = Duration(seconds: 1 << (_reconnectAttempts - 1));
    _addLog('⏳ ${delay.inSeconds}s 后第 $_reconnectAttempts 次重连...');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_connected) {
        _addLog('🔄 第 $_reconnectAttempts 次重连...');
        _connect();
      }
    });
  }

  /// 主动断开
  void _disconnect() {
    _stopHeartbeat();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    setState(() => _connected = false);
    _reconnectAttempts = _maxReconnectAttempts; // 阻止自动重连
    _addLog('👋 已主动断开');
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $log');
    });
  }

  void _clearLogs() {
    setState(() => _logs.clear());
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('11 WebSocket 实时通信')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- 连接状态 ----------
            Card(
              color: _connected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _connected ? Icons.sync : Icons.sync_disabled,
                      color: _connected ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _connected ? '已连接' : '未连接',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _connected ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    if (_reconnectAttempts > 0 && !_connected) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(重连 $_reconnectAttempts/$_maxReconnectAttempts)',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'WebSocket 要点：\n'
                  '• WebSocketChannel.connect 建立连接\n'
                  '• sink.add 发送、stream.listen 接收\n'
                  '• 心跳保活：定时发 ping 防断连\n'
                  '• 自动重连：指数退避策略',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _connected ? null : _connect,
                  child: const Text('连接'),
                ),
                ElevatedButton(
                  onPressed: _connected ? _disconnect : null,
                  child: const Text('断开'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ---------- 输入框 ----------
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _connected ? _sendMessage : null,
                  child: const Text('发送'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ---------- 日志 ----------
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击"连接"开始演示'))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[i],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
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
