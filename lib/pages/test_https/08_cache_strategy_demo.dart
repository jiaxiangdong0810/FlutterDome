import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 08 - 缓存策略
///
/// 知识点：
/// - 内存缓存（Map）
/// - 缓存过期策略（TTL）
/// - ETag / Last-Modified 条件请求
/// - 拦截器实现缓存
@RoutePage()
class CacheStrategyDemoPage extends StatefulWidget {
  const CacheStrategyDemoPage({super.key});

  @override
  State<CacheStrategyDemoPage> createState() => _CacheStrategyDemoPageState();
}

class _CacheStrategyDemoPageState extends State<CacheStrategyDemoPage> {
  final List<String> _logs = [];
  late final Dio _dio;
  late final _CacheInterceptor _cacheInterceptor;

  @override
  void initState() {
    super.initState();
    _cacheInterceptor = _CacheInterceptor(onLog: _addLog);
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    _dio.interceptors.add(_cacheInterceptor);
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $log');
    });
  }

  /// 第一次请求：从网络获取，结果缓存
  Future<void> _demoFirstRequest() async {
    _addLog('--- 请求 /posts/1（首次） ---');
    try {
      final response = await _dio.get('/posts/1');
      _addLog('✅ 网络返回: ${(response.data as Map)["title"]}');
    } on DioException catch (e) {
      _addLog('❌ 失败: ${e.message}');
    }
  }

  /// 第二次请求：命中缓存，不走网络
  Future<void> _demoCachedRequest() async {
    _addLog('--- 请求 /posts/1（再次） ---');
    try {
      final response = await _dio.get('/posts/1');
      final hitCache = response.extra['fromCache'] == true;
      _addLog(hitCache ? '📦 命中缓存' : '🌐 网络返回');
      _addLog('数据: ${(response.data as Map)["title"]}');
    } on DioException catch (e) {
      _addLog('❌ 失败: ${e.message}');
    }
  }

  /// 强制刷新：跳过缓存
  Future<void> _demoForceRefresh() async {
    _addLog('--- 强制刷新 /posts/1 ---');
    try {
      final response = await _dio.get(
        '/posts/1',
        options: Options(extra: {'forceRefresh': true}),
      );
      _addLog('✅ 强制从网络获取: ${(response.data as Map)["title"]}');
    } on DioException catch (e) {
      _addLog('❌ 失败: ${e.message}');
    }
  }

  void _clearCache() {
    _cacheInterceptor.clearCache();
    _addLog('🗑️ 缓存已清空');
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
      appBar: AppBar(title: const Text('08 缓存策略')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '缓存策略要点：\n'
                  '• 内存缓存：Map<String, CacheEntry>\n'
                  '• TTL 过期：设置缓存有效期\n'
                  '• 拦截器实现：onResponse 缓存，onRequest 检查缓存\n'
                  '• forceRefresh：跳过缓存强制请求',
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
                  onPressed: _demoFirstRequest,
                  child: const Text('首次请求'),
                ),
                ElevatedButton(
                  onPressed: _demoCachedRequest,
                  child: const Text('再次请求'),
                ),
                ElevatedButton(
                  onPressed: _demoForceRefresh,
                  child: const Text('强制刷新'),
                ),
                OutlinedButton(
                  onPressed: _clearCache,
                  child: const Text('清空缓存'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空日志'),
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
                    ? const Center(child: Text('点击查看缓存行为'))
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

/// 缓存条目
class _CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration ttl;

  _CacheEntry({
    required this.data,
    required this.ttl,
  }) : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// 缓存拦截器
///
/// 知识点：通过拦截器实现透明的缓存层
///
/// 工作流程：
/// 1. onRequest: 检查缓存，如果有效则直接返回缓存（跳过网络）
/// 2. onResponse: 将网络响应存入缓存
/// 3. onError: 网络失败时尝试返回过期缓存（降级策略）
class _CacheInterceptor extends Interceptor {
  final Map<String, _CacheEntry> _cache = {};
  final void Function(String) onLog;

  _CacheInterceptor({required this.onLog});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = _cacheKey(options);
    final forceRefresh = options.extra['forceRefresh'] == true;

    if (forceRefresh) {
      onLog('⏭️ forceRefresh=true，跳过缓存');
      handler.next(options);
      return;
    }

    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      onLog('📦 缓存命中: $key（剩余 ${_remainingTtl(entry)}）');
      // 知识点：handler.resolve 直接返回响应，不走网络
      handler.resolve(Response(
        data: entry.data,
        statusCode: 200,
        requestOptions: options,
        extra: {'fromCache': true},
      ));
      return;
    }

    if (entry != null && entry.isExpired) {
      onLog('⏰ 缓存已过期: $key');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _cacheKey(response.requestOptions);

    // 缓存成功的 GET 请求响应
    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200) {
      _cache[key] = _CacheEntry(
        data: response.data,
        ttl: const Duration(seconds: 30), // 缓存 30 秒
      );
      onLog('💾 已缓存: $key（TTL 30s）');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _cacheKey(err.requestOptions);
    final entry = _cache[key];

    // 知识点：网络失败时返回过期缓存（降级策略）
    if (entry != null) {
      onLog('⚠️ 网络失败，降级使用过期缓存: $key');
      handler.resolve(Response(
        data: entry.data,
        statusCode: 200,
        requestOptions: err.requestOptions,
        extra: {'fromCache': true, 'stale': true},
      ));
      return;
    }

    handler.next(err);
  }

  String _cacheKey(RequestOptions options) {
    return '${options.method}:${options.uri}';
  }

  String _remainingTtl(_CacheEntry entry) {
    final remaining = entry.ttl - DateTime.now().difference(entry.createdAt);
    return '${remaining.inSeconds}s';
  }

  void clearCache() {
    _cache.clear();
  }
}
