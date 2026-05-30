import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 09 AsyncValue - 异步状态统一处理
///
/// 核心知识点：
/// 1. AsyncValue 是 Riverpod 提供的统一异步状态封装，替代 loading/error/data 的分散处理
/// 2. 相比 Provider 的 AsyncSnapshot，AsyncValue 提供了更丰富的 API 和函数式编程风格
/// 3. FutureProvider 自动将 Future 转换为 AsyncValue，无需手动管理状态
///
/// AsyncValue 三态模型：
/// ┌─────────────┬──────────────────────────────┐
/// │   状态       │           说明               │
/// ├─────────────┼──────────────────────────────┤
/// │ AsyncLoading │ 异步操作进行中，显示加载中     │
/// │ AsyncError   │ 异步操作失败，携带错误信息     │
/// │ AsyncData    │ 异步操作成功，携带数据         │
/// └─────────────┴──────────────────────────────┘

// ==================== 数据模型 ====================

/// 用户资料数据模型
class UserProfile {
  final String name;
  final int age;
  final String bio;

  const UserProfile({
    required this.name,
    required this.age,
    required this.bio,
  });
}

// ==================== Provider 定义 ====================

/// FutureProvider：管理异步数据获取
///
/// 核心优势：FutureProvider 自动将 Future 转换为 AsyncValue
/// 不需要手动维护 isLoading / hasError / data 等状态
///
/// 对比 Provider 的写法：
/// - Provider: 需要 ChangeNotifier + 手动管理 loading/error/data 状态
/// - Riverpod: FutureProvider 自动处理，直接得到 AsyncValue
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  // 模拟网络请求延迟
  await Future.delayed(const Duration(seconds: 2));
  // 30% 概率随机失败，用于演示错误状态处理
  if (Random().nextDouble() < 0.3) {
    throw Exception('网络请求失败');
  }
  return const UserProfile(
    name: '张三',
    age: 25,
    bio: 'Flutter 开发者',
  );
});

// ==================== 页面入口 ====================

@RoutePage()
class AsyncValuePage extends ConsumerWidget {
  const AsyncValuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(userProfileProvider) 返回 AsyncValue<UserProfile>
    // 自动处理 Future 的所有状态转换
    final asyncValue = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('09 AsyncValue - 异步状态统一处理'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== 1. .when() - 处理所有三种状态 ==========
            _buildSectionTitle('1. .when() - 处理所有三种状态'),
            _buildDescription(
              '最常用的方法，强制处理 loading / error / data 三种情况，'
              '避免遗漏任何状态。',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: asyncValue.when(
                  // 加载中状态
                  loading: () => const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('加载中...'),
                      ],
                    ),
                  ),
                  // 错误状态
                  error: (error, stackTrace) => Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '出错了: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  // 数据成功状态
                  data: (profile) => _buildProfileCard(profile),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== 2. .whenOrNull() - 只处理部分状态 ==========
            _buildSectionTitle('2. .whenOrNull() - 只处理部分状态'),
            _buildDescription(
              '只处理关心的状态，其他状态返回 null。'
              '适合只需要在特定状态下显示额外内容的场景。',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 只在 data 状态时显示内容，其他情况返回 null
                    Text(
                      '数据状态: ${asyncValue.whenOrNull(
                        data: (profile) => '姓名: ${profile.name}, 年龄: ${profile.age}岁',
                      ) ?? '（非 data 状态，返回 null）'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // 只在 error 状态时显示内容
                    Text(
                      '错误状态: ${asyncValue.whenOrNull(
                        error: (err, _) => '捕获错误: $err',
                      ) ?? '（非 error 状态，返回 null）'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== 3. .map() - 函数式风格映射 ==========
            _buildSectionTitle('3. .map() - 函数式风格映射'),
            _buildDescription(
              '与 .when() 类似，但返回类型更灵活，'
              '适合需要对不同状态返回不同类型 Widget 或做复杂转换的场景。',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: asyncValue.map(
                  loading: (_) => const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('map() - 加载中...'),
                    ],
                  ),
                  error: (errorState) => Text(
                    'map() - 错误: ${errorState.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (dataState) => Text(
                    'map() - 成功: ${dataState.value.name}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== 4. .valueOrNull - 获取值（如果可用） ==========
            _buildSectionTitle('4. .valueOrNull - 获取值（如果可用）'),
            _buildDescription(
              '如果当前是 data 状态则返回值，否则返回 null。'
              '适合在 UI 中安全地读取数据而不触发重建。',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'valueOrNull: ${asyncValue.valueOrNull ?? 'null（数据尚未加载或出错）'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    // 利用 valueOrNull 安全地访问数据属性
                    Text(
                      '安全访问姓名: ${asyncValue.valueOrNull?.name ?? '暂无数据'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: asyncValue.valueOrNull != null
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== 5. 布尔检查属性 ==========
            _buildSectionTitle('5. 布尔检查 - hasValue / hasError / isLoading'),
            _buildDescription(
              '快速检查当前状态，适合用于条件渲染或逻辑判断。',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusChip(
                      'hasValue',
                      asyncValue.hasValue,
                      Colors.green,
                    ),
                    _buildStatusChip(
                      'hasError',
                      asyncValue.hasError,
                      Colors.red,
                    ),
                    _buildStatusChip(
                      'isLoading',
                      asyncValue.isLoading,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== 刷新按钮 ==========
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // invalidate 会丢弃当前状态并重新执行 Provider
                  // 用于强制刷新异步数据
                  ref.invalidate(userProfileProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('刷新数据（30% 概率失败）'),
              ),
            ),
            const SizedBox(height: 24),

            // ========== 对比：FutureBuilder vs AsyncValue.when ==========
            _buildSectionTitle('对比：FutureBuilder vs AsyncValue.when'),
            const SizedBox(height: 8),
            _buildComparisonTable(),
            const SizedBox(height: 24),

            // ========== 代码对比示例 ==========
            _buildSectionTitle('代码对比示例'),
            const SizedBox(height: 8),
            _buildCodeComparison(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建小节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建说明文字
  Widget _buildDescription(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Colors.grey),
    );
  }

  /// 构建用户资料卡片
  Widget _buildProfileCard(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(Icons.person, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${profile.age} 岁',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.description, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profile.bio,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建状态指示 Chip
  Widget _buildStatusChip(String label, bool active, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: active ? Colors.white : Colors.grey,
        ),
      ),
      backgroundColor: active ? color : Colors.grey.shade200,
    );
  }

  /// 构建对比表格
  Widget _buildComparisonTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          border: TableBorder.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(3),
          },
          children: [
            _buildTableRow(
              '特性',
              'FutureBuilder (Provider)',
              'AsyncValue.when (Riverpod)',
              isHeader: true,
            ),
            _buildTableRow(
              '状态管理',
              '手动创建 Future',
              'FutureProvider 自动管理',
            ),
            _buildTableRow(
              '状态类型',
              'AsyncSnapshot',
              'AsyncValue（更丰富的 API）',
            ),
            _buildTableRow(
              '错误处理',
              'snapshot.hasError',
              '强制在 .when() 中处理',
            ),
            _buildTableRow(
              '代码量',
              '较多，需管理 Future',
              '极少，声明式',
            ),
            _buildTableRow(
              '刷新机制',
              'setState 重建 Future',
              'ref.invalidate() 一键刷新',
            ),
          ],
        ),
      ),
    );
  }

  /// 构建表格行
  TableRow _buildTableRow(
    String col1,
    String col2,
    String col3, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      fontSize: 12,
    );
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(col1, style: style),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(col2, style: style),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            col3,
            style: style.copyWith(
              color: isHeader ? null : Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建代码对比展示
  Widget _buildCodeComparison() {
    return Column(
      children: [
        // FutureBuilder 代码
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '// Provider + FutureBuilder 写法',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'FutureBuilder<UserProfile>(\n'
                '  future: _fetchUser(),\n'
                '  builder: (context, snapshot) {\n'
                '    if (snapshot.connectionState ==\n'
                '        ConnectionState.waiting) {\n'
                '      return CircularProgressIndicator();\n'
                '    } else if (snapshot.hasError) {\n'
                '      return Text("Error: \${snapshot.error}");\n'
                '    } else if (snapshot.hasData) {\n'
                '      return Text("Data: \${snapshot.data}");\n'
                '    }\n'
                '    return Container(); // 默认返回\n'
                '  },\n'
                ')',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Icon(Icons.arrow_downward, color: Colors.green),
        const Text(
          'Riverpod AsyncValue 更简洁',
          style: TextStyle(fontSize: 12, color: Colors.green),
        ),
        const SizedBox(height: 12),
        // AsyncValue.when 代码
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '// Riverpod AsyncValue.when 写法',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'final asyncValue = ref.watch(userProfileProvider);\n\n'
                'asyncValue.when(\n'
                '  loading: () => CircularProgressIndicator(),\n'
                '  error: (err, stack) => Text("Error: \$err"),\n'
                '  data: (profile) => Text("Data: \$profile"),\n'
                ')',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
