import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Refresh / Invalidate —— 刷新异步数据
///
/// 核心知识点：
/// 1. ref.refresh(provider) —— 立即重新执行 Provider，返回新的 Future
/// 2. ref.invalidate(provider) —— 标记 Provider 为失效，下次读取时自动刷新
/// 3. RefreshIndicator —— 下拉刷新，与 FutureProvider 天然配合
///
/// 与 Provider 的对比：
/// - Provider 的 FutureProvider 没有内置刷新机制，需要手动修改 key 或管理状态
/// - Riverpod 一行代码即可刷新：ref.refresh(provider)

// ==================== Provider 定义 ====================

/// 模拟 API 请求：获取随机论语名句
///
/// 知识点：FutureProvider 会自动管理异步状态（loading / data / error）
/// 不需要手动维护 isLoading、hasError 等状态
final quoteProvider = FutureProvider<String>((ref) async {
  // 模拟网络延迟
  await Future.delayed(const Duration(seconds: 1));
  final quotes = [
    '学而时习之，不亦说乎',
    '知之为知之，不知为不知',
    '温故而知新，可以为师矣',
    '三人行，必有我师焉',
  ];
  return quotes[Random().nextInt(quotes.length)];
});

/// 记录数据获取时间戳，用于展示刷新效果
final fetchTimeProvider = StateProvider<DateTime?>((ref) => null);

// ==================== 页面入口 ====================

@RoutePage()
class RefreshDemoPage extends ConsumerWidget {
  const RefreshDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 quoteProvider 的异步状态
    final quoteAsync = ref.watch(quoteProvider);
    final fetchTime = ref.watch(fetchTimeProvider);

    // 数据加载成功时更新时间戳
    quoteAsync.whenData((_) {
      // 使用 Future.microtask 避免在 build 中直接修改状态
      Future.microtask(() {
        ref.read(fetchTimeProvider.notifier).state = DateTime.now();
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('11 Refresh / Invalidate - 刷新数据'),
      ),
      body: RefreshIndicator(
        // 下拉刷新：使用 ref.refresh 立即刷新数据
        onRefresh: () async {
          // refresh() 返回新的 Future，await 它确保刷新指示器在加载完成后消失
          // ignore: unused_result
          await ref.refresh(quoteProvider.future);
        },
        child: SingleChildScrollView(
          // 确保内容可滚动，RefreshIndicator 才能生效
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 名言展示卡片
                _buildQuoteCard(context, quoteAsync, fetchTime),
                const SizedBox(height: 24),

                // 刷新按钮区域
                _buildRefreshButtons(ref),
                const SizedBox(height: 24),

                // 对比说明区域
                _buildComparisonSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 名言展示卡片
  Widget _buildQuoteCard(
    BuildContext context,
    AsyncValue<String> quoteAsync,
    DateTime? fetchTime,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: quoteAsync.when(
          // 数据加载中
          loading: () => const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('加载中...', style: TextStyle(color: Colors.grey)),
            ],
          ),
          // 数据加载成功
          data: (quote) => Column(
            children: [
              const Icon(
                Icons.format_quote,
                size: 40,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                quote,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // 时间戳展示
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '获取时间: ${_formatTime(fetchTime)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 数据加载失败
          error: (error, stack) => Column(
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
            ],
          ),
        ),
      ),
    );
  }

  /// 刷新按钮区域
  Widget _buildRefreshButtons(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '刷新方式',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // refresh() 按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // refresh() —— 立即重新执行 Provider 的创建函数
              // 返回新的 Future，UI 会立即进入 loading 状态
              // ignore: unused_result
              ref.refresh(quoteProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('refresh() - 立即刷新'),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            '立即重新执行 Provider，UI 同步进入 loading 状态',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // invalidate() 按钮
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // invalidate() —— 标记 Provider 为失效状态
              // 不会立即刷新，下次被读取（watch/read）时自动重新执行
              ref.invalidate(quoteProvider);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('invalidate() - 标记失效'),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            '标记为失效，下次读取时自动刷新（适合延迟刷新场景）',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),

        // 下拉刷新提示
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.swipe_down, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '下拉页面也可触发刷新（RefreshIndicator）',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Provider vs Riverpod 对比说明
  Widget _buildComparisonSection(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provider vs Riverpod 刷新对比',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Provider 的麻烦写法
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.close, color: Colors.red.shade400, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        'Provider 需要手动管理',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FutureProvider 没有刷新机制，需要：',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. 修改 key 强制重建 Widget\n'
                    '2. 或手动管理 Future 状态\n'
                    '3. 或使用 ChangeNotifier + 手动 notify',
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Riverpod 的简洁写法
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check, color: Colors.green.shade400, size: 18),
                      const SizedBox(width: 4),
                      const Text(
                        'Riverpod 一行代码搞定',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ref.refresh(quoteProvider)',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '自动管理 loading / data / error 状态',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化时间显示
  String _formatTime(DateTime? time) {
    if (time == null) return '--:--:--';
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
