import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 09 - 网络状态监听
///
/// 知识点：
/// - connectivity_plus 监听网络变化
/// - 断网时的降级策略
/// - 请求重试队列
/// - 网络状态驱动 UI
@RoutePage()
class NetworkStateDemoPage extends StatefulWidget {
  const NetworkStateDemoPage({super.key});

  @override
  State<NetworkStateDemoPage> createState() => _NetworkStateDemoPageState();
}

class _NetworkStateDemoPageState extends State<NetworkStateDemoPage> {
  final List<String> _logs = [];
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  final Connectivity _connectivity = Connectivity();

  // 重试队列：存储失败的请求，联网后自动重试
  final List<_PendingRequest> _retryQueue = [];
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    // 知识点：监听网络状态变化
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // 初始检查
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final result = await _connectivity.checkConnectivity();
    _onConnectivityChanged(result);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    setState(() {
      _connectionStatus = results;
    });

    final isOnline = results.any((r) => r != ConnectivityResult.none);
    _addLog('📡 网络变化: ${results.map((r) => r.name).join(", ")}');

    if (isOnline) {
      _addLog('✅ 已联网，处理重试队列 (${_retryQueue.length} 个待重试)');
      _processRetryQueue();
    } else {
      _addLog('❌ 断网，后续请求将加入重试队列');
    }
  }

  /// 处理重试队列
  Future<void> _processRetryQueue() async {
    if (_retryQueue.isEmpty) return;

    final queue = List<_PendingRequest>.from(_retryQueue);
    _retryQueue.clear();

    for (final request in queue) {
      _addLog('🔄 重试: ${request.method} ${request.path}');
      try {
        final response = await _dio.request(
          request.path,
          options: Options(method: request.method),
          data: request.data,
        );
        request.completer.complete(response);
        _addLog('✅ 重试成功: ${response.statusCode}');
      } catch (e) {
        request.completer.completeError(e);
        _addLog('❌ 重试失败: $e');
      }
    }
  }

  /// 演示：正常请求
  Future<void> _demoRequest() async {
    _addLog('--- 发起请求 ---');
    try {
      final response = await _dio.get('/posts/1');
      _addLog('✅ 成功: ${(response.data as Map)["title"]}');
    } on DioException catch (e) {
      _addLog('❌ 失败: ${e.type}');
    }
  }

  /// 演示：带降级的请求（断网时返回缓存或提示）
  Future<void> _demoWithFallback() async {
    _addLog('--- 发起带降级的请求 ---');

    final isOnline = _connectionStatus.any((r) => r != ConnectivityResult.none);

    if (!isOnline) {
      _addLog('⚠️ 当前离线，使用降级数据');
      _addLog('📦 降级数据: { "title": "离线缓存数据", "body": "..." }');
      return;
    }

    try {
      final response = await _dio.get('/posts/1');
      _addLog('✅ 在线获取: ${(response.data as Map)["title"]}');
    } on DioException catch (e) {
      _addLog('⚠️ 请求失败，降级处理: ${e.type}');
    }
  }

  /// 演示：请求加入重试队列
  Future<void> _demoRetryQueue() async {
    _addLog('--- 请求加入重试队列 ---');

    final isOnline = _connectionStatus.any((r) => r != ConnectivityResult.none);

    if (!isOnline) {
      _addLog('📡 离线中，请求加入重试队列');
      final pending = _PendingRequest(
        method: 'GET',
        path: '/posts/2',
      );
      _retryQueue.add(pending);

      // 等待重试完成
      try {
        final response = await pending.completer.future;
        _addLog('✅ 重试队列执行成功');
      } catch (e) {
        _addLog('❌ 重试队列执行失败');
      }
    } else {
      _addLog('📡 在线中，直接请求');
      try {
        final response = await _dio.get('/posts/2');
        _addLog('✅ 成功: ${(response.data as Map)["title"]}');
      } on DioException catch (e) {
        _addLog('❌ 失败: ${e.type}');
      }
    }
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
    _subscription.cancel();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _connectionStatus.any((r) => r != ConnectivityResult.none);

    return Scaffold(
      appBar: AppBar(title: const Text('09 网络状态监听')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- 网络状态指示 ----------
            Card(
              color: isOnline
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOnline
                          ? '在线: ${_connectionStatus.map((r) => r.name).join(", ")}'
                          : '离线',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const Spacer(),
                    if (_retryQueue.isNotEmpty)
                      Chip(
                        label: Text('重试队列: ${_retryQueue.length}'),
                        backgroundColor: Colors.orange.shade100,
                      ),
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
                  '网络状态要点：\n'
                  '• connectivity_plus 监听网络变化\n'
                  '• 断网时使用缓存/降级数据\n'
                  '• 重试队列：联网后自动重发失败请求\n'
                  '• 用 StreamSubscription 监听，dispose 取消',
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
                  onPressed: _demoRequest,
                  child: const Text('普通请求'),
                ),
                ElevatedButton(
                  onPressed: _demoWithFallback,
                  child: const Text('带降级'),
                ),
                ElevatedButton(
                  onPressed: _demoRetryQueue,
                  child: const Text('重试队列'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 断网测试：开启飞行模式后点击按钮查看降级行为',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击查看网络状态变化'))
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

/// 待重试的请求
class _PendingRequest {
  final String method;
  final String path;
  final dynamic data;
  final Completer<Response> completer = Completer();

  _PendingRequest({
    required this.method,
    required this.path,
    this.data,
  });
}
