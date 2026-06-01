import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data/api/api_client.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/entities/user.dart';
import 'domain/repositories/user_repository.dart';

/// Clean Architecture 演示页面
///
/// 知识点：
/// - 依赖倒置：通过接口注入 Repository
/// - 分层架构：UI → Domain → Data
/// - 可测试性：替换实现即可 Mock
@RoutePage()
class ArchDemoPage extends StatefulWidget {
  const ArchDemoPage({super.key});

  @override
  State<ArchDemoPage> createState() => _ArchDemoPageState();
}

class _ArchDemoPageState extends State<ArchDemoPage> {
  final List<String> _logs = [];
  List<User> _users = [];
  bool _loading = false;

  // 知识点：依赖注入
  // 生产环境：真实的 Dio + ApiClient + RepositoryImpl
  late final UserRepository _repository;

  @override
  void initState() {
    super.initState();
    final dio = Dio(BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    final apiClient = ApiClient(dio);
    _repository = UserRepositoryImpl(apiClient);
  }

  /// 获取用户列表
  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    _addLog('--- 获取用户列表 ---');
    _addLog('调用: _repository.getUsers(page: 1, limit: 5)');

    try {
      // 知识点：UI 层只调用 Repository 接口
      // 不关心数据是从 API 还是缓存获取的
      final users = await _repository.getUsers(page: 1, limit: 5);
      setState(() => _users = users);

      _addLog('✅ 获取到 ${users.length} 个用户');
      for (final user in users) {
        _addLog('  ${user.displayName} - ${user.maskedEmail}');
      }
    } on NetworkException catch (e) {
      _addLog('🌐 网络错误: $e');
    } on ServerException catch (e) {
      _addLog('🖥️ 服务器错误: $e');
    } on NotFoundException catch (e) {
      _addLog('🔍 未找到: $e');
    } catch (e) {
      _addLog('❌ 未知错误: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 创建用户
  Future<void> _createUser() async {
    setState(() => _loading = true);
    _addLog('--- 创建用户 ---');

    try {
      final user = await _repository.createUser(
        name: '新用户',
        email: 'new@example.com',
        phone: '13800138000',
      );
      _addLog('✅ 创建成功: ${user}');
    } catch (e) {
      _addLog('❌ 创建失败: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  /// 演示架构层次
  void _showArchitecture() {
    _addLog('--- Clean Architecture 分层 ---');
    _addLog('');
    _addLog('📱 UI 层 (Flutter Widget)');
    _addLog('   ↓ 调用');
    _addLog('🏢 Domain 层');
    _addLog('   ├─ Entity (User) — 业务实体');
    _addLog('   └─ Repository 接口 — 定义契约');
    _addLog('   ↓ 实现');
    _addLog('💾 Data 层');
    _addLog('   ├─ ApiClient — Dio 封装');
    _addLog('   ├─ DTO (UserDto) — 数据转换');
    _addLog('   └─ RepositoryImpl — 接口实现');
    _addLog('');
    _addLog('✅ 优势：');
    _addLog('  • UI 不依赖具体 API 实现');
    _addLog('  • 替换 API 只需改 Data 层');
    _addLog('  • 测试时注入 Mock Repository');
    _addLog('  • DTO 和 Entity 解耦');
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $log');
    });
  }

  void _clearLogs() {
    setState(() => _logs.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clean Architecture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '架构要点：\n'
                  '• Domain 层定义接口，Data 层实现（依赖倒置）\n'
                  '• DTO → Entity 转换隔离 API 细节\n'
                  '• 自定义异常类型便于上层区分处理\n'
                  '• 依赖注入：构造函数传入 Repository',
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
                  onPressed: _loading ? null : _fetchUsers,
                  child: const Text('获取用户'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _createUser,
                  child: const Text('创建用户'),
                ),
                OutlinedButton(
                  onPressed: _showArchitecture,
                  child: const Text('架构说明'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            // 用户列表
            if (_users.isNotEmpty) ...[
              Text('用户列表', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              ...(_users.map((u) => Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(child: Text('${u.id}')),
                      title: Text(u.displayName),
                      subtitle: Text(u.maskedEmail),
                    ),
                  ))),
              const SizedBox(height: 8),
            ],
            // 日志
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击查看架构演示'))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[i],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
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
