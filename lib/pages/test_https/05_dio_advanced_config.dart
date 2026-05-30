import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 05 - dio 高级配置
///
/// 知识点：
/// - BaseOptions 完整参数
/// - 请求/响应转换器
/// - 取消请求（CancelToken）
/// - 重试机制（手动实现）
@RoutePage()
class DioAdvancedConfigPage extends StatefulWidget {
  const DioAdvancedConfigPage({super.key});

  @override
  State<DioAdvancedConfigPage> createState() => _DioAdvancedConfigPageState();
}

class _DioAdvancedConfigPageState extends State<DioAdvancedConfigPage> {
  String _output = '点击按钮开始演示';
  bool _loading = false;

  late final Dio _dio;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _dio = _createConfiguredDio();
  }

  /// 知识点：BaseOptions 完整配置
  Dio _createConfiguredDio() {
    return Dio(BaseOptions(
      // 基础 URL，所有请求自动拼接
      baseUrl: 'https://jsonplaceholder.typicode.com',

      // 连接超时：建立连接的最大等待时间
      connectTimeout: const Duration(seconds: 10),

      // 接收超时：等待服务器响应数据的最大时间
      receiveTimeout: const Duration(seconds: 10),

      // 发送超时：发送请求数据的最大时间（上传大文件时需要调大）
      sendTimeout: const Duration(seconds: 10),

      // 默认请求头
      headers: {
        'Accept': 'application/json',
        'X-App-Version': '1.0.0',
      },

      // 默认 Content-Type
      contentType: 'application/json',

      // 响应类型：json 会自动 decode，plain 返回原始字符串
      responseType: ResponseType.json,

      // 验证状态码，返回 true 表示请求成功
      // 默认 200-299 为成功
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ));
  }

  /// 演示：查看完整配置
  void _showConfig() {
    final options = _dio.options;
    setState(() {
      _output = '【Dio BaseOptions 配置】\n\n'
          'baseUrl:        ${options.baseUrl}\n'
          'connectTimeout: ${options.connectTimeout}\n'
          'receiveTimeout: ${options.receiveTimeout}\n'
          'sendTimeout:    ${options.sendTimeout}\n'
          'contentType:    ${options.contentType}\n'
          'responseType:   ${options.responseType}\n'
          'headers:        ${options.headers}\n\n'
          '💡 可以在单个请求中覆盖这些配置：\n'
          '  dio.get("/path", options: Options(receiveTimeout: ...))';
    });
  }

  /// 演示：取消请求
  Future<void> _demoCancel() async {
    _cancelToken = CancelToken();
    _setLoading(true);
    setState(() => _output = '请求已发起，2秒后取消...');

    // 2 秒后取消请求
    Future.delayed(const Duration(seconds: 2), () {
      if (_cancelToken != null && !_cancelToken!.isCancelled) {
        _cancelToken!.cancel('用户主动取消');
      }
    });

    try {
      // 使用延迟 API 模拟慢请求
      final dio = Dio(BaseOptions(
        baseUrl: 'https://httpbin.org',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));
      await dio.get('/delay/5', cancelToken: _cancelToken);
      setState(() => _output = '请求完成（不应该走到这里）');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        setState(() {
          _output = '【请求被取消】\n\n'
              '类型: ${e.type}\n'
              '原因: ${e.message}\n\n'
              '💡 CancelToken 可以：\n'
              '  • 传给请求的 cancelToken 参数\n'
              '  • 调用 cancelToken.cancel() 取消\n'
              '  • 一个 CancelToken 可取消多个请求\n'
              '  • 常用于页面退出时取消未完成的请求';
        });
      } else {
        setState(() => _output = '其他错误: ${e.message}');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// 演示：手动重试
  Future<void> _demoRetry() async {
    _setLoading(true);
    const maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      setState(() => _output = '第 $attempt 次尝试...');
      try {
        final response = await _dio.get('/posts/1');
        setState(() {
          _output = '【重试机制演示】\n\n'
              '第 $attempt 次请求成功 ✅\n'
              '状态码: ${response.statusCode}\n\n'
              '💡 实际项目中可以用 dio 的 interceptor 实现自动重试：\n'
              '  onError 中检查条件 → handler.resolve(重试请求)';
        });
        break;
      } on DioException catch (e) {
        if (attempt == maxRetries) {
          setState(() {
            _output = '【重试机制演示】\n\n'
                '已重试 $maxRetries 次，全部失败 ❌\n'
                '最后错误: ${e.type}';
          });
        } else {
          // 指数退避：第 1 次等 1s，第 2 次等 2s
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('05 dio 高级配置')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '高级配置要点：\n'
                  '• BaseOptions 统一配置超时/headers/响应类型\n'
                  '• CancelToken 取消进行中的请求\n'
                  '• 手动实现重试 + 指数退避\n'
                  '• validateStatus 自定义成功判断',
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
                  onPressed: _loading ? null : _showConfig,
                  child: const Text('查看配置'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoCancel,
                  child: const Text('取消请求'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoRetry,
                  child: const Text('重试机制'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Container(
              height: 400,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
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
