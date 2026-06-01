import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 10 - 认证与安全
///
/// 知识点：
/// - Token 自动刷新（拦截器 + 重试队列）
/// - 请求签名
/// - HTTPS 证书锁定（概念演示）
@RoutePage()
class AuthSecurityDemoPage extends StatefulWidget {
  const AuthSecurityDemoPage({super.key});

  @override
  State<AuthSecurityDemoPage> createState() => _AuthSecurityDemoPageState();
}

class _AuthSecurityDemoPageState extends State<AuthSecurityDemoPage> {
  final List<String> _logs = [];
  late final Dio _dio;

  // 模拟 token 状态
  String _accessToken = 'access_token_expired'; // 初始为过期 token
  String _refreshToken = 'refresh_token_valid';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(
      baseUrl: 'https://httpbin.org',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(_AuthInterceptor(
      getAccessToken: () => _accessToken,
      refreshToken: _doRefreshToken,
      onRefreshStart: () => _addLog('🔄 开始刷新 token...'),
      onRefreshEnd: () => _addLog('✅ token 刷新完成'),
      onLog: _addLog,
    ));
  }

  /// 模拟刷新 token 的 API 调用
  Future<String> _doRefreshToken() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));
    _accessToken = 'access_token_${DateTime.now().millisecondsSinceEpoch}';
    _addLog('🔑 新 token: $_accessToken');
    return _accessToken;
  }

  /// 演示：正常请求（token 自动附加）
  Future<void> _demoNormalRequest() async {
    _addLog('--- 发起请求（token 自动附加） ---');
    try {
      final response = await _dio.get('/get');
      _addLog('✅ 成功: ${response.statusCode}');
    } on DioException catch (e) {
      _addLog('❌ 失败: ${e.type}');
    }
  }

  /// 演示：token 过期 → 自动刷新 → 重试
  Future<void> _demoTokenRefresh() async {
    // 先把 token 设为过期
    _accessToken = 'access_token_expired';
    _addLog('--- token 已设为过期，发起请求 ---');
    _addLog('当前 token: $_accessToken');

    try {
      // 请求 /status/401 会返回 401，触发拦截器刷新 token
      final response = await _dio.get('/status/401');
      _addLog('✅ 重试成功: ${response.statusCode}');
    } on DioException catch (e) {
      _addLog('❌ 最终失败: ${e.type}');
    }
  }

  /// 演示：并发请求时只刷新一次 token
  Future<void> _demoConcurrentRefresh() async {
    _accessToken = 'access_token_expired';
    _addLog('--- 并发 3 个请求，token 过期 ---');
    _addLog('预期：只刷新 1 次 token，3 个请求都重试');

    // 并发发起 3 个请求
    final futures = [
      _dio.get('/status/401'),
      _dio.get('/status/401'),
      _dio.get('/status/401'),
    ];

    final results = await Future.wait(futures, eagerError: false);
    for (int i = 0; i < results.length; i++) {
      _addLog('请求 ${i + 1}: ${results[i].statusCode}');
    }
  }

  /// 演示：请求签名
  void _demoSigning() {
    _addLog('--- 请求签名演示 ---');

    // 模拟签名过程
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonce = 'abc123';
    final method = 'GET';
    final path = '/api/data';

    // 实际项目中：sign = HMAC-SHA256(secret, "$method$path$timestamp$nonce")
    final signSource = '$method$path$timestamp$nonce';
    final sign = 'hmac_sha256($signSource)';

    _addLog('请求参数:');
    _addLog('  timestamp: $timestamp');
    _addLog('  nonce: $nonce');
    _addLog('  sign: $sign');
    _addLog('');
    _addLog('签名流程:');
    _addLog('  1. 收集参数: method + path + timestamp + nonce');
    _addLog('  2. 用密钥计算 HMAC-SHA256');
    _addLog('  3. 将 sign/timestamp/nonce 放入 header');
    _addLog('  4. 服务端用相同方式验证签名');
    _addLog('');
    _addLog('💡 防重放攻击: timestamp + nonce 确保请求唯一');
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
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('10 认证与安全')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- token 状态 ----------
            Card(
              color: _accessToken.contains('expired')
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _accessToken.contains('expired')
                          ? Icons.lock_open
                          : Icons.lock,
                      color: _accessToken.contains('expired')
                          ? Colors.red
                          : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Token: ${_accessToken.substring(0, _accessToken.length > 30 ? 30 : _accessToken.length)}...',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
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
                  '认证安全要点：\n'
                  '• 拦截器自动附加 Authorization header\n'
                  '• 401 时自动刷新 token + 重试原请求\n'
                  '• 并发请求只刷新一次（排队等待）\n'
                  '• 请求签名防篡改、timestamp+nonce 防重放',
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
                  onPressed: _demoNormalRequest,
                  child: const Text('普通请求'),
                ),
                ElevatedButton(
                  onPressed: _demoTokenRefresh,
                  child: const Text('Token 刷新'),
                ),
                ElevatedButton(
                  onPressed: _demoConcurrentRefresh,
                  child: const Text('并发刷新'),
                ),
                OutlinedButton(
                  onPressed: _demoSigning,
                  child: const Text('请求签名'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击查看认证流程'))
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

/// 认证拦截器 - Token 自动刷新
///
/// 知识点：
/// 1. onRequest 中附加 token
/// 2. onError 中检测 401
/// 3. 401 时刷新 token，然后重试原请求
/// 4. 并发 401 只触发一次刷新（_isRefreshing 标记）
class _AuthInterceptor extends Interceptor {
  final String Function() getAccessToken;
  final Future<String> Function() refreshToken;
  final VoidCallback onRefreshStart;
  final VoidCallback onRefreshEnd;
  final void Function(String) onLog;

  bool _isRefreshing = false;
  // 等待 token 刷新的请求队列
  final List<_PendingRetry> _pendingRetries = [];

  _AuthInterceptor({
    required this.getAccessToken,
    required this.refreshToken,
    required this.onRefreshStart,
    required this.onRefreshEnd,
    required this.onLog,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 附加 token
    final token = getAccessToken();
    options.headers['Authorization'] = 'Bearer $token';
    onLog('🔑 [Auth] 附加 token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 只处理 401
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    onLog('🔒 [Auth] 检测到 401，准备刷新 token');

    // 如果正在刷新，把当前请求加入等待队列
    if (_isRefreshing) {
      onLog('⏳ [Auth] token 正在刷新中，加入等待队列');
      final completer = Completer<Response>();
      _pendingRetries.add(_PendingRetry(
        requestOptions: err.requestOptions,
        handler: handler,
      ));
      return;
    }

    _isRefreshing = true;
    onRefreshStart();

    try {
      // 刷新 token
      final newToken = await refreshToken();
      onRefreshEnd();

      // 重试当前请求
      onLog('🔄 [Auth] 用新 token 重试原请求');
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newToken';

      final response = await Dio().fetch(options);
      handler.resolve(response);

      // 处理等待队列中的请求
      for (final pending in _pendingRetries) {
        pending.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final retryResponse = await Dio().fetch(pending.requestOptions);
          pending.handler.resolve(retryResponse);
        } catch (e) {
          pending.handler.next(err);
        }
      }
      _pendingRetries.clear();
    } catch (refreshError) {
      onLog('❌ [Auth] token 刷新失败');
      // 刷新失败，清除等待队列
      for (final pending in _pendingRetries) {
        pending.handler.next(err);
      }
      _pendingRetries.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

class _PendingRetry {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _PendingRetry({
    required this.requestOptions,
    required this.handler,
  });
}
