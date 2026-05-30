import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 04 - dio 拦截器（Interceptor）
///
/// 知识点：
/// - Interceptor 的三个回调：onRequest / onResponse / onError
/// - 拦截器链的执行顺序
/// - 统一添加 token / 日志打印 / 错误处理
/// - QueuedInterceptor 的使用场景
@RoutePage()
class DioInterceptorDemoPage extends StatefulWidget {
  const DioInterceptorDemoPage({super.key});

  @override
  State<DioInterceptorDemoPage> createState() => _DioInterceptorDemoPageState();
}

class _DioInterceptorDemoPageState extends State<DioInterceptorDemoPage> {
  final List<String> _logs = [];
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // 知识点：拦截器的添加顺序 = 执行顺序
    // 请求时：先 Auth → 再 Log
    // 响应时：先 Log → 再 Auth（反过来）
    _dio.interceptors.add(_AuthInterceptor(_addLog));
    _dio.interceptors.add(_LogInterceptor(_addLog));
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $log');
    });
  }

  void _clearLogs() {
    setState(() => _logs.clear());
  }

  /// 演示拦截器链
  Future<void> _demoRequest() async {
    _addLog('--- 发起请求 ---');
    try {
      final response = await _dio.get('/posts/1');
      _addLog('✅ 最终拿到数据: ${(response.data as Map)["title"]}');
    } on DioException catch (e) {
      _addLog('❌ 请求失败: ${e.message}');
    }
  }

  /// 演示拦截器修改请求
  Future<void> _demoModifyRequest() async {
    _addLog('--- 发起带参数的请求 ---');
    try {
      // query 参数会被拦截器读取并添加 header
      final response = await _dio.get(
        '/posts/1',
        queryParameters: {'needAuth': true},
      );
      _addLog('✅ 完成');
    } on DioException catch (e) {
      _addLog('❌ 失败: ${e.message}');
    }
  }

  /// 演示拦截器处理错误
  Future<void> _demoError() async {
    _addLog('--- 发起一个会失败的请求 ---');
    try {
      // 请求一个不存在的资源
      await _dio.get('/posts/99999');
    } on DioException catch (e) {
      _addLog('❌ 最终异常: ${e.type}');
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('04 dio 拦截器')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- 知识点卡片 ----------
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '拦截器执行顺序：\n'
                  '请求 → onRequest → onRequest ...\n'
                  '响应 ← onResponse ← onResponse ...\n\n'
                  '每个拦截器可以：\n'
                  '• 修改请求（加 header / token）\n'
                  '• 修改响应（统一格式化）\n'
                  '• 拦截错误（重试 / 刷新 token）',
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
                  onPressed: _demoModifyRequest,
                  child: const Text('带 Auth'),
                ),
                ElevatedButton(
                  onPressed: _demoError,
                  child: const Text('触发错误'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ---------- 日志输出 ----------
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击按钮查看拦截器日志'))
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

// ========== 拦截器实现 ==========

/// 认证拦截器：统一添加 token
///
/// 知识点：onRequest 中修改 requestOptions.headers
class _AuthInterceptor extends Interceptor {
  final void Function(String) log;
  _AuthInterceptor(this.log);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('🔑 [Auth] onRequest: 添加 Authorization header');
    // 实际项目中从 SharedPreferences / SecureStorage 读取 token
    options.headers['Authorization'] = 'Bearer fake_token_12345';
    // 知识点：必须调用 handler.next() 传递给下一个拦截器
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('🔑 [Auth] onError: 检查是否 401 未认证');
    if (err.response?.statusCode == 401) {
      log('🔑 [Auth] 401 → 实际项目中此处刷新 token 并重试');
    }
    handler.next(err);
  }
}

/// 日志拦截器：打印请求和响应
///
/// 知识点：拦截请求/响应/错误的完整生命周期
class _LogInterceptor extends Interceptor {
  final void Function(String) log;
  _LogInterceptor(this.log);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('📤 [Log] ${options.method} ${options.uri}');
    if (options.headers.containsKey('Authorization')) {
      log('📤 [Log] Headers 含 Authorization ✅');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('📥 [Log] ${response.statusCode} ← ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('💥 [Log] ${err.type} ← ${err.requestOptions.uri}');
    handler.next(err);
  }
}
