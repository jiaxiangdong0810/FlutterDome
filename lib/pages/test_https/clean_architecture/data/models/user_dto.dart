import '../../domain/entities/user.dart';

/// 用户 DTO（数据传输对象）
///
/// 知识点：
/// - DTO 负责 API 数据与领域实体之间的转换
/// - 包含 fromJson / toJson 方法
/// - 可以包含 API 特有的字段（如 avatar_url）
/// - 通过 toEntity() 转换为领域实体
class UserDto {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;

  const UserDto({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
  });

  /// 从 JSON 构造
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'website': website,
      };

  /// 转换为领域实体
  ///
  /// 知识点：DTO → Entity 的转换在这里完成
  /// 过滤掉 API 特有字段，只保留业务需要的数据
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      phone: phone,
    );
  }

  /// 从领域实体构造 DTO（用于发送请求）
  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      name: user.name,
      username: '',
      email: user.email,
      phone: user.phone,
      website: '',
    );
  }
}
