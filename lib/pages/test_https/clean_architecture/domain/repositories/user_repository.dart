import '../entities/user.dart';

/// 用户仓库接口（领域层）
///
/// 知识点：
/// - 定义在领域层，不依赖具体实现
/// - 数据层（RepositoryImpl）实现这个接口
/// - 便于测试时注入 Mock 实现
/// - 返回领域实体，不返回 DTO
abstract class UserRepository {
  /// 获取用户列表
  Future<List<User>> getUsers({int page = 1, int limit = 10});

  /// 获取单个用户
  Future<User> getUser(int id);

  /// 创建用户
  Future<User> createUser({
    required String name,
    required String email,
    required String phone,
  });

  /// 删除用户
  Future<void> deleteUser(int id);
}
