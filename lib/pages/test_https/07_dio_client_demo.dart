import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 07 - 网络层封装（DioClient 单例）
///
/// 知识点：
/// - 单例模式管理 Dio 实例
/// - 统一响应模型 ApiResponse<T>
/// - 统一错误处理
/// - 封装 GET / POST / PUT / DELETE 方法
@RoutePage()
class DioClientDemoPage extends StatefulWidget {
  const DioClientDemoPage({super.key});

  @override
  State<DioClientDemoPage> createState() => _DioClientDemoPageState();
}

class _DioClientDemoPageState extends State<DioClientDemoPage> {
  String _output = '点击按钮演示封装后的网络层';

  /// 使用封装后的 DioClient 发请求
  Future<void> _demoGetPost() async {
    final client = DioClient.instance;
    final result = await client.get<Map<String, dynamic>>('/posts/1');

    setState(() {
      _output = '【封装后的 GET 请求】\n\n'
          '成功: ${result.isSuccess}\n'
          '状态码: ${result.code}\n'
          '消息: ${result.message}\n'
          '数据: ${result.data}\n\n'
          '💡 调用方式：\n'
          '  final result = await DioClient.instance.get("/posts/1");\n'
          '  if (result.isSuccess) { use(result.data); }';
    });
  }

  Future<void> _demoPost() async {
    final client = DioClient.instance;
    final result = await client.post<Map<String, dynamic>>(
      '/posts',
      data: {
        'title': '网络层封装',
        'body': '统一的响应模型让代码更清晰',
        'userId': 1,
      },
    );

    setState(() {
      _output = '【封装后的 POST 请求】\n\n'
          '成功: ${result.isSuccess}\n'
          '状态码: ${result.code}\n'
          '消息: ${result.message}\n'
          '数据: ${result.data}';
    });
  }

  Future<void> _demoError() async {
    final client = DioClient.instance;
    // 请求一个不存在的资源
    final result = await client.get<Map<String, dynamic>>('/posts/99999');

    setState(() {
      _output = '【错误处理演示】\n\n'
          '成功: ${result.isSuccess}\n'
          '状态码: ${result.code}\n'
          '消息: ${result.message}\n'
          '数据: ${result.data}\n\n'
          '💡 统一错误处理：\n'
          '  • 业务错误：服务器返回 code != 0\n'
          '  • 网络错误：DioException → 映射为友好提示\n'
          '  • 未知错误：兜底 catch → "未知错误"';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('07 网络层封装')),
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
                  '封装要点：\n'
                  '• 单例 Dio → 全局共享同一个实例\n'
                  '• ApiResponse<T> → 统一的数据模型\n'
                  '• get/post/put/delete → 简洁的调用方式\n'
                  '• 统一拦截器 → token / 日志 / 错误处理',
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
                  onPressed: _demoGetPost,
                  child: const Text('GET 请求'),
                ),
                ElevatedButton(
                  onPressed: _demoPost,
                  child: const Text('POST 请求'),
                ),
                ElevatedButton(
                  onPressed: _demoError,
                  child: const Text('错误处理'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 350,
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

// ========== 以下是网络层封装的核心代码 ==========

/// 统一响应模型
///
/// 知识点：泛型类封装 API 响应，所有接口返回统一格式
class ApiResponse<T> {
  final bool isSuccess;
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.isSuccess,
    required this.code,
    required this.message,
    this.data,
  });

  /// 成功响应
  factory ApiResponse.success(T data, {int code = 0, String message = 'success'}) {
    return ApiResponse(isSuccess: true, code: code, message: message, data: data);
  }

  /// 失败响应
  factory ApiResponse.failure({required int code, required String message}) {
    return ApiResponse(isSuccess: false, code: code, message: message);
  }
}

/// DioClient 单例
///
/// 知识点：
/// 1. 私有构造函数 + 静态实例 = 单例
/// 2. 统一配置 BaseOptions
/// 3. 添加拦截器
/// 4. 封装 GET/POST/PUT/DELETE，返回 ApiResponse
class DioClient {
  // 单例
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late final Dio _dio;

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));

    // 添加拦截器
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LogInterceptor());
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.failure(code: -1, message: '未知错误: $e');
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.failure(code: -1, message: '未知错误: $e');
    }
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.failure(code: -1, message: '未知错误: $e');
    }
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(String path) async {
    try {
      final response = await _dio.delete(path);
      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.failure(code: -1, message: '未知错误: $e');
    }
  }

  /// 统一错误处理
  ApiResponse<T> _handleError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.failure(code: -2, message: '网络超时，请检查网络');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        return ApiResponse.failure(code: statusCode, message: '服务器错误: $statusCode');
      case DioExceptionType.cancel:
        return ApiResponse.failure(code: -3, message: '请求已取消');
      case DioExceptionType.connectionError:
        return ApiResponse.failure(code: -4, message: '网络连接失败');
      default:
        return ApiResponse.failure(code: -1, message: e.message ?? '未知错误');
    }
  }
}

/// 认证拦截器
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 实际项目中从本地存储读取 token
    options.headers['Authorization'] = 'Bearer demo_token';
    handler.next(options);
  }
}

/// 日志拦截器
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 [${options.method}] ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ [${response.statusCode}] ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ [${err.type}] ${err.requestOptions.uri}');
    handler.next(err);
  }
}
