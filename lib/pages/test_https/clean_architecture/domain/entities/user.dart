/// 用户实体（领域层）
///
/// 知识点：
/// - 领域实体是纯业务对象，不依赖任何框架
/// - 只包含业务逻辑需要的字段
/// - 与 DTO（数据传输对象）分离
class User {
  final int id;
  final String name;
  final String email;
  final String phone;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  /// 业务逻辑示例：显示名称
  String get displayName => name.isNotEmpty ? name : '匿名用户';

  /// 业务逻辑示例：邮箱脱敏
  String get maskedEmail {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final masked = name.length > 2
        ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
        : name;
    return '$masked@${parts[1]}';
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
