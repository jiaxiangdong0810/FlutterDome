import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Family 修饰符 —— 参数化 Provider
///
/// 核心知识点：
/// 1. family 是 Riverpod 独有的修饰符，Provider 包没有等价功能
/// 2. family 让 Provider 可以接受参数，根据参数创建不同的实例
/// 3. 每个不同的参数值对应一个独立的 Provider 实例，自动缓存
/// 4. 常用于：根据 ID 获取详情、分页查询、搜索等场景
///
/// Provider 要实现这个功能需要 ProxyProvider + 手动管理，Riverpod family 一行搞定

// ==================== 模拟用户数据 ====================

final Map<int, Map<String, String>> users = {
  1: {'name': '张三', 'email': 'zhangsan@example.com'},
  2: {'name': '李四', 'email': 'lisi@example.com'},
  3: {'name': '王五', 'email': 'wangwu@example.com'},
  4: {'name': '赵六', 'email': 'zhaoliu@example.com'},
  5: {'name': '孙七', 'email': 'sunqi@example.com'},
};

// ==================== Family Provider 定义 ====================

/// family 修饰符：创建参数化的 Provider
///
/// 语法：Provider.family<返回值类型, 参数类型>((ref, 参数) => ...)
///
/// 核心特性：
/// - 传入不同参数，自动创建不同的 Provider 实例
/// - 相同参数复用已有实例（自动缓存）
/// - 参数必须实现 == 和 hashCode（用于区分实例）
///
/// Provider 要实现这个功能需要 ProxyProvider + 手动管理，Riverpod family 一行搞定
final userDetailProvider = Provider.family<Map<String, String>?, int>((ref, userId) {
  // 模拟根据 userId 查询用户详情
  // 实际项目中这里可以是网络请求、数据库查询等
  return users[userId];
});

// ==================== 页面入口 ====================

@RoutePage()
class FamilyDemoPage extends ConsumerStatefulWidget {
  const FamilyDemoPage({super.key});

  @override
  ConsumerState<FamilyDemoPage> createState() => _FamilyDemoPageState();
}

class _FamilyDemoPageState extends ConsumerState<FamilyDemoPage> {
  // 当前选中的用户 ID
  int _selectedUserId = 1;

  @override
  Widget build(BuildContext context) {
    // 使用 family provider，传入当前选中的 userId
    // 每次 userId 变化时，自动获取对应用户的 Provider 实例
    final userDetail = ref.watch(userDetailProvider(_selectedUserId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('05 Family - 参数化 Provider'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户 ID 选择按钮
            const Text(
              '选择用户 ID：',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5].map((id) {
                final isSelected = id == _selectedUserId;
                return ChoiceChip(
                  label: Text('用户 $id'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedUserId = id;
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 用户详情卡片
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // 头像占位
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            userDetail?['name']?.substring(0, 1) ?? '?',
                            style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID: $_selectedUserId',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userDetail?['name'] ?? '未知用户',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userDetail?['email'] ?? '无邮箱',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 核心概念说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '核心概念',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'family 让 Provider 可以接受参数，每个不同的参数值对应一个独立的 Provider 实例。',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '当你调用 ref.watch(userDetailProvider(1)) 和 ref.watch(userDetailProvider(2)) 时，'
                    'Riverpod 会自动创建并缓存两个独立的实例，互不干扰。',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Provider vs Riverpod 对比
            const Text(
              'Provider vs Riverpod 对比',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Provider 方式（复杂）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Provider 方式（复杂，需手动管理）',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '// 需要 ProxyProvider + 手动 Map 管理实例',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'class UserDetailProvider extends ChangeNotifier {\n'
                      '  final Map<int, User> _cache = {};\n'
                      '  User? getUser(int id) {\n'
                      '    if (!_cache.containsKey(id)) {\n'
                      '      _cache[id] = fetchUser(id);\n'
                      '    }\n'
                      '    return _cache[id];\n'
                      '  }\n'
                      '}\n'
                      '\n'
                      '// Widget 树中需要额外包裹 ProxyProvider\n'
                      'ProxyProvider<...>(...)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Riverpod 方式（简单）
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Riverpod 方式（一行搞定）',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '// Provider 要实现这个功能需要 ProxyProvider + 手动管理，Riverpod family 一行搞定',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'final userDetailProvider = Provider.family<User, int>(\n'
                      '  (ref, userId) => fetchUser(userId),\n'
                      ');\n'
                      '\n'
                      '// 使用时直接传参\n'
                      'ref.watch(userDetailProvider(1));\n'
                      'ref.watch(userDetailProvider(2));',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
