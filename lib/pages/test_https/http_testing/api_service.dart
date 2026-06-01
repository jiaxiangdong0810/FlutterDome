import 'package:dio/dio.dart';

/// API 服务类（被测代码）
///
/// 知识点：
/// - Dio 依赖注入（通过构造函数传入）→ 方便测试时注入 Mock
/// - 统一的响应处理
/// - 清晰的错误处理
class ApiService {
  final Dio _dio;

  /// 依赖注入：生产环境传真实 Dio，测试环境传 Mock Dio
  ApiService(this._dio);

  /// 获取帖子列表
  Future<List<Post>> getPosts({int page = 1, int limit = 10}) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );

    final data = response.data as List;
    return data.map((json) => Post.fromJson(json)).toList();
  }

  /// 获取单个帖子
  Future<Post> getPost(int id) async {
    final response = await _dio.get('/posts/$id');
    return Post.fromJson(response.data);
  }

  /// 创建帖子
  Future<Post> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    final response = await _dio.post(
      '/posts',
      data: {'title': title, 'body': body, 'userId': userId},
    );
    return Post.fromJson(response.data);
  }

  /// 删除帖子
  Future<void> deletePost(int id) async {
    await _dio.delete('/posts/$id');
  }
}

/// 帖子模型
///
/// 知识点：fromJson 工厂方法解析 JSON
class Post {
  final int id;
  final String title;
  final String body;
  final int userId;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'userId': userId,
      };

  @override
  String toString() => 'Post(id: $id, title: $title)';
}
