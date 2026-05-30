import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Provider 依赖 —— 自动追踪依赖关系
///
/// 核心知识点：
/// 1. Provider 之间可以形成依赖链，一个 Provider 可以依赖其他 Provider
/// 2. ref.watch() 会自动建立依赖关系，当依赖变化时自动重建
/// 3. Riverpod 的依赖追踪是声明式的，不需要手动管理
///
/// Riverpod vs Provider 依赖对比：
/// ┌─────────────────┬──────────────────────────────┬──────────────────────────────┐
/// │     特性         │        Provider              │        Riverpod              │
/// ├─────────────────┼──────────────────────────────┼──────────────────────────────┤
/// │ 依赖声明方式     │  ChangeNotifierProxyProvider  │  在 Provider 内用 ref.watch   │
/// │ 依赖追踪         │  手动 create + update         │  自动追踪，自动重建            │
/// │ 多依赖支持       │  需要嵌套多个 ProxyProvider   │  直接多个 ref.watch           │
/// │ 代码复杂度       │  复杂，容易出错               │  简洁，声明式                  │
/// └─────────────────┴──────────────────────────────┴──────────────────────────────┘

// ==================== Provider 定义（依赖链） ====================

/// 基础价格 Provider —— 商品原价
///
/// StateProvider 适合管理简单的可变化状态（值类型）
final basePriceProvider = StateProvider<double>((ref) => 500);

/// 折扣率 Provider —— 折扣百分比（0.0 ~ 1.0）
///
/// 例如 0.2 表示 20% 折扣
final discountRateProvider = StateProvider<double>((ref) => 0.2);

/// 最终价格 Provider —— 依赖 basePriceProvider 和 discountRateProvider
///
/// 核心：使用 ref.watch() 监听依赖的 Provider
/// 当 basePriceProvider 或 discountRateProvider 变化时，
/// finalPriceProvider 会自动重新计算
///
/// Provider 的等价写法（极其繁琐）：
/// ```dart
/// ChangeNotifierProxyProvider2<PriceModel, DiscountModel, FinalPriceModel>(
///   create: (_) => FinalPriceModel(),
///   update: (_, price, discount, finalPrice) {
///     finalPrice.update(price.value, discount.value);
///     return finalPrice;
///   },
///   child: ...
/// )
/// ```
final finalPriceProvider = Provider<double>((ref) {
  // ref.watch 建立依赖关系：finalPriceProvider 依赖 basePriceProvider
  final basePrice = ref.watch(basePriceProvider);

  // ref.watch 建立依赖关系：finalPriceProvider 依赖 discountRateProvider
  final discountRate = ref.watch(discountRateProvider);

  // 自动计算最终价格
  return basePrice * (1 - discountRate);
});

// ==================== 页面入口 ====================

@RoutePage()
class RiverpodDependencyPage extends ConsumerWidget {
  const RiverpodDependencyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听最终价格（自动追踪两个上游依赖）
    final finalPrice = ref.watch(finalPriceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('07 Provider 依赖 - 自动追踪'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 依赖链说明
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '依赖链：basePrice → discountRate → finalPrice',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '修改任意上游 Provider，下游会自动重新计算',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: 基础价格滑块
            _buildPriceCard(context, ref),
            const SizedBox(height: 16),

            // Card 2: 折扣率滑块
            _buildDiscountCard(context, ref),
            const SizedBox(height: 16),

            // Card 3: 最终价格展示
            _buildFinalPriceCard(context, finalPrice),
            const SizedBox(height: 24),

            // 代码对比
            _buildComparisonSection(context),
          ],
        ),
      ),
    );
  }

  /// 基础价格卡片
  Widget _buildPriceCard(BuildContext context, WidgetRef ref) {
    final basePrice = ref.watch(basePriceProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  '基础价格',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '¥${basePrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: basePrice,
              min: 0,
              max: 1000,
              divisions: 100,
              label: basePrice.toStringAsFixed(0),
              onChanged: (value) {
                // 修改基础价格，finalPriceProvider 会自动重新计算
                ref.read(basePriceProvider.notifier).state = value;
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('¥0', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('¥1000', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 折扣率卡片
  Widget _buildDiscountCard(BuildContext context, WidgetRef ref) {
    final discountRate = ref.watch(discountRateProvider);
    final percent = (discountRate * 100).toStringAsFixed(0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.percent, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  '折扣率',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: discountRate,
              min: 0,
              max: 1,
              divisions: 20,
              label: '$percent%',
              onChanged: (value) {
                // 修改折扣率，finalPriceProvider 会自动重新计算
                ref.read(discountRateProvider.notifier).state = value;
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 最终价格卡片
  Widget _buildFinalPriceCard(BuildContext context, double finalPrice) {
    return Card(
      elevation: 4,
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.shade200, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '最终价格',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '¥${finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '自动计算 = 基础价格 × (1 - 折扣率)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Provider vs Riverpod 代码对比
  Widget _buildComparisonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '代码对比',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Provider 写法
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
                  Icon(Icons.close, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Provider 写法（繁琐）',
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
                'ChangeNotifierProxyProvider2<Price, Discount, Final>(\n'
                '  create: (_) => FinalModel(),\n'
                '  update: (_, price, discount, final) {\n'
                '    final.update(price.value, discount.value);\n'
                '    return final;\n'
                '  },\n'
                '  child: ...\n'
                ')',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Riverpod 写法
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
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
                  Icon(Icons.check, color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Riverpod 写法（简洁）',
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
                'final finalPriceProvider = Provider<double>((ref) {\n'
                '  final basePrice = ref.watch(basePriceProvider);\n'
                '  final discountRate = ref.watch(discountRateProvider);\n'
                '  return basePrice * (1 - discountRate);\n'
                '});',
                style: TextStyle(
                  fontSize: 12,
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
