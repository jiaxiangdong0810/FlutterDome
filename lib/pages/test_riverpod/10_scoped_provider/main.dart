import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod ProviderScope —— 局部状态覆盖
///
/// 核心知识点：
/// 1. ProviderScope 可以在 Widget 树的任意位置覆盖 Provider 的值
/// 2. 被覆盖的值只影响 ProviderScope 子树中的 Consumer
/// 3. ProviderScope 外部的 Consumer 仍然读取原始值
///
/// Provider vs Riverpod 对比：
/// ┌─────────────────┬──────────────────────────┬──────────────────────────┐
/// │     特性         │        Provider          │        Riverpod          │
/// ├─────────────────┼──────────────────────────┼──────────────────────────┤
/// │ 局部覆盖值       │  ❌ 无法实现              │  ✅ ProviderScope         │
/// │ 动态替换         │  ❌ 需创建不同实例        │  ✅ overrideWithValue    │
/// │ 作用范围控制     │  ❌ 全局或按树层级        │  ✅ 精确到子树            │
/// └─────────────────┴──────────────────────────┴──────────────────────────┘

// ==================== Provider 定义（全局） ====================

/// 全局默认的问候语 Provider
///
/// 在 Provider 包中，一个 Provider 实例一旦创建，其值就固定了，
/// 无法在 Widget 树的局部动态替换。
/// Riverpod 通过 ProviderScope.overrides 轻松解决这个问题。
final greetingProvider = Provider<String>((ref) => '你好，世界！');

// ==================== 页面入口 ====================

@RoutePage()
class RiverpodScopedPage extends ConsumerWidget {
  const RiverpodScopedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 顶层读取默认的 greetingProvider 值
    final defaultGreeting = ref.watch(greetingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('10 ProviderScope - 局部状态覆盖'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== 顶部区域：默认问候语 ==========
            _GreetingCard(
              title: '默认问候语（全局）',
              greeting: defaultGreeting,
              backgroundColor: Colors.blue.shade50,
              borderColor: Colors.blue.shade200,
              icon: Icons.public,
            ),
            const SizedBox(height: 16),

            // ========== 中部区域：ProviderScope 覆盖 ==========
            // ProviderScope.overrides 只在子树中生效
            // 子树内的 Consumer 会读取到覆盖后的值
            ProviderScope(
              overrides: [
                greetingProvider.overrideWithValue('Hello, Riverpod!'),
              ],
              child: _GreetingCard(
                title: '局部覆盖（英语）',
                // 这里不传入 greeting，由内部的 Consumer 读取
                backgroundColor: Colors.orange.shade50,
                borderColor: Colors.orange.shade200,
                icon: Icons.language,
                useConsumer: true,
              ),
            ),
            const SizedBox(height: 16),

            // ========== 底部区域：另一个 ProviderScope 覆盖 ==========
            ProviderScope(
              overrides: [
                greetingProvider.overrideWithValue('Bonjour, Riverpod!'),
              ],
              child: _GreetingCard(
                title: '局部覆盖（法语）',
                backgroundColor: Colors.purple.shade50,
                borderColor: Colors.purple.shade200,
                icon: Icons.translate,
                useConsumer: true,
              ),
            ),
            const SizedBox(height: 24),

            // ========== 核心对比说明 ==========
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '核心对比',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Provider 无法动态替换值，Riverpod ProviderScope 轻松实现',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '常见使用场景：',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('• Theme 覆盖：局部区域使用不同的主题配置'),
                  Text('• Feature Flags：为特定功能模块开关特性'),
                  Text('• A/B 测试：不同用户群体看到不同内容'),
                  Text('• 测试环境：在 Widget 测试中注入 mock 数据'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 子组件 ====================

/// 问候语展示卡片
///
/// 当 useConsumer 为 true 时，内部使用 Consumer 读取 Provider 值，
/// 这样可以感知 ProviderScope 的覆盖；
/// 当 useConsumer 为 false 时，直接使用外部传入的 greeting。
class _GreetingCard extends StatelessWidget {
  final String title;
  final String? greeting;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final bool useConsumer;

  const _GreetingCard({
    required this.title,
    this.greeting,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    this.useConsumer = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(icon, size: 20, color: borderColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 问候语内容
          if (useConsumer)
            // 使用 Consumer 读取 Provider，能感知 ProviderScope 覆盖
            Consumer(
              builder: (context, ref, child) {
                final scopedGreeting = ref.watch(greetingProvider);
                return Text(
                  scopedGreeting,
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            )
          else
            // 直接使用外部传入的值
            Text(
              greeting!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
        ],
      ),
    );
  }
}
