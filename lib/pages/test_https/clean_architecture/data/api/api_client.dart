import 'package:dio/dio.dart';

/// API 客户端（数据层）
///
/// 知识点：
/// - 封装 Dio 实例，统一配置
/// - 所有 API 调用集中管理
/// - 便于切换 BaseUrl（测试/生产环境）
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET 请求
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get(path, queryParameters: queryParams);
  }

  /// POST 请求
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  /// PUT 请求
  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  /// DELETE 请求
  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
