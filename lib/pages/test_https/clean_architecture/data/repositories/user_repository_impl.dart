import 'package:dio/dio.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../api/api_client.dart';
import '../models/user_dto.dart';

/// 用户仓库实现（数据层）
///
/// 知识点：
/// - 实现领域层定义的接口
/// - 使用 ApiClient 调用 API
/// - 将 DTO 转换为领域实体
/// - 统一的错误处理
class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl(this._apiClient);

  @override
  Future<List<User>> getUsers({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/users',
        queryParams: {'_page': page, '_limit': limit},
      );

      final data = response.data as List;
      // DTO → Entity 转换
      return data
          .map((json) => UserDto.fromJson(json).toEntity())
          .toList();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> getUser(int id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      return UserDto.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> createUser({
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      final dto = UserDto(
        id: 0,
        name: name,
        username: '',
        email: email,
        phone: phone,
        website: '',
      );

      final response = await _apiClient.post(
        '/users',
        data: dto.toJson(),
      );

      return UserDto.fromJson(response.data).toEntity();
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _apiClient.delete('/users/$id');
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  /// 统一异常映射
  Exception _mapException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('网络超时，请检查网络');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 404) return NotFoundException('资源不存在');
        if (code == 401) return AuthException('未认证');
        return ServerException('服务器错误: $code');
      case DioExceptionType.connectionError:
        return NetworkException('网络连接失败');
      default:
        return NetworkException(e.message ?? '未知错误');
    }
  }
}

/// 自定义异常类型（便于上层区分处理）
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => 'ServerException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}
