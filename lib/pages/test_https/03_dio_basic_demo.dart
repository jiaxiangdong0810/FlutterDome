import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 03 - dio 包入门演示
///
/// 知识点：
/// - Dio 实例创建与 BaseOptions 配置
/// - GET / POST / PUT / DELETE 请求
/// - DioException 错误处理
/// - 与 http 包的对比优势
///
/// 使用公开测试 API：https://jsonplaceholder.typicode.com
@RoutePage()
class DioBasicDemoPage extends StatefulWidget {
  const DioBasicDemoPage({super.key});

  @override
  State<DioBasicDemoPage> createState() => _DioBasicDemoPageState();
}

class _DioBasicDemoPageState extends State<DioBasicDemoPage> {
  String _output = '点击按钮发送请求';
  bool _loading = false;

  // 知识点：通过 BaseOptions 统一配置 Dio 实例
  // baseUrl 会自动拼接到所有请求路径前面
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  /// GET 请求
  Future<void> _demoGet() async {
    _setLoading(true);
    try {
      // 知识点：dio.get 自动拼接 baseUrl
      // 响应数据已经被自动 decode 成 Map，不需要手动 jsonDecode
      final response = await _dio.get('/posts/1');
      setState(() {
        _output = '【dio GET 请求】\n\n'
            '状态码: ${response.statusCode}\n'
            '数据类型: ${response.data.runtimeType}\n\n'
            '标题: ${response.data["title"]}\n'
            '内容: ${response.data["body"]}\n\n'
            '💡 与 http 包的区别:\n'
            '  http 包: response.body 是 String，需 jsonDecode\n'
            '  dio:     response.data 已经是 Map，直接使用';
      });
    } on DioException catch (e) {
      // 知识点：DioException 是 dio 的专用异常类型
      _handleDioError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// GET 列表 + query 参数
  Future<void> _demoGetWithQuery() async {
    _setLoading(true);
    try {
      // 知识点：queryParameters 会拼接到 URL 后面
      // 等价于 /posts?_limit=3&_page=1
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          '_limit': 3,
          '_page': 1,
        },
      );

      final List<dynamic> posts = response.data;
      final buffer = StringBuffer();
      buffer.writeln('【dio GET + queryParameters】');
      buffer.writeln('URL: /posts?_limit=3&_page=1');
      buffer.writeln('返回 ${posts.length} 条\n');
      for (final post in posts) {
        buffer.writeln('[${post["id"]}] ${post["title"]}');
      }
      setState(() => _output = buffer.toString());
    } on DioException catch (e) {
      _handleDioError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// POST 请求
  Future<void> _demoPost() async {
    _setLoading(true);
    try {
      // 知识点：dio.post 的 data 参数直接传 Map
      // dio 会自动序列化为 JSON，并设置 Content-Type
      final response = await _dio.post(
        '/posts',
        data: {
          'title': 'dio 学习笔记',
          'body': 'dio 比 http 包更强大',
          'userId': 1,
        },
      );
      setState(() {
        _output = '【dio POST 请求】\n\n'
            '状态码: ${response.statusCode}\n\n'
            '💡 与 http 包的区别:\n'
            '  http 包: body 需要手动 jsonEncode + 设置 Content-Type\n'
            '  dio:     data 直接传 Map，自动序列化\n\n'
            '返回数据:\n${response.data}';
      });
    } on DioException catch (e) {
      _handleDioError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// PUT 请求
  Future<void> _demoPut() async {
    _setLoading(true);
    try {
      // 知识点：PUT 用于全量更新资源
      final response = await _dio.put(
        '/posts/1',
        data: {
          'id': 1,
          'title': '更新后的标题',
          'body': '更新后的内容',
          'userId': 1,
        },
      );
      setState(() {
        _output = '【dio PUT 请求】\n\n'
            '状态码: ${response.statusCode}\n'
            '更新后的数据:\n${response.data}';
      });
    } on DioException catch (e) {
      _handleDioError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// DELETE 请求
  Future<void> _demoDelete() async {
    _setLoading(true);
    try {
      final response = await _dio.delete('/posts/1');
      setState(() {
        _output = '【dio DELETE 请求】\n\n'
            '状态码: ${response.statusCode}\n'
            '响应数据: ${response.data}\n\n'
            '💡 DELETE 成功通常返回 200 或 204';
      });
    } on DioException catch (e) {
      _handleDioError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// 统一错误处理
  void _handleDioError(DioException e) {
    String errorMsg;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMsg = '连接超时';
        break;
      case DioExceptionType.sendTimeout:
        errorMsg = '发送超时';
        break;
      case DioExceptionType.receiveTimeout:
        errorMsg = '接收超时';
        break;
      case DioExceptionType.badResponse:
        errorMsg = '服务器错误: ${e.response?.statusCode}';
        break;
      case DioExceptionType.cancel:
        errorMsg = '请求被取消';
        break;
      case DioExceptionType.connectionError:
        errorMsg = '连接失败，请检查网络';
        break;
      default:
        errorMsg = '未知错误: ${e.message}';
    }
    setState(() {
      _output = '【请求失败】\n\n'
          '类型: ${e.type}\n'
          '原因: $errorMsg\n\n'
          '💡 DioException 包含丰富的错误信息:\n'
          '  e.type       → 错误类型枚举\n'
          '  e.response   → 服务器响应（如果有）\n'
          '  e.message    → 错误描述';
    });
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('03 dio 包入门')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- 知识点提示 ----------
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'dio 核心优势：\n'
                  '• 自动 JSON 序列化/反序列化\n'
                  '• 统一的 baseUrl + 请求拦截\n'
                  '• DioException 丰富的错误类型\n'
                  '• 内置超时、取消、文件上传下载',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ---------- 操作按钮 ----------
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _demoGet,
                  child: const Text('GET'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoGetWithQuery,
                  child: const Text('GET + Query'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoPost,
                  child: const Text('POST'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoPut,
                  child: const Text('PUT'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoDelete,
                  child: const Text('DELETE'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            // ---------- 输出区域 ----------
            Container(
              height: 300,
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
