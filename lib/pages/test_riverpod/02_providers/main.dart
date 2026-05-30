import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled1/utils/log.dart';

/// Riverpod 四种 Provider 类型对比演示
///
/// 核心知识点：
/// 1. Provider — 不可变值/纯计算，不会变化的数据
/// 2. StateProvider — 简单可变状态，适合基础类型（int、String、bool）
/// 3. FutureProvider — 异步一次性数据，如 HTTP 请求
/// 4. StreamProvider — 持续数据流，如 WebSocket、定时器
///
/// 使用场景总结：
/// - 只读配置 → Provider
/// - 简单状态（计数器、开关）→ StateProvider
/// - 异步请求（API 调用）→ FutureProvider
/// - 实时数据（推送、定时器）→ StreamProvider

// ==================== Provider 定义 ====================

/// 1. Provider — 用于不可变值或纯计算
///
/// 适用场景：应用配置、常量字符串、格式化函数、由其他状态派生的计算值
/// 特点：值不会变化，消费者只读取一次，不会触发重建
final greetingProvider = Provider<String>((ref) {
  return 'Hello, Riverpod!';
});

/// 2. StateProvider — 用于简单的可变状态
///
/// 适用场景：计数器、开关状态、当前选中的 Tab 索引、简单的表单输入
/// 特点：状态变化时自动通知所有监听者重建
/// 注意：只适合简单数据类型，复杂对象请用 StateNotifierProvider
final counterProvider = StateProvider<int>((ref) => 0);

/// 3. FutureProvider — 用于异步数据获取
///
/// 适用场景：HTTP 请求、数据库查询、文件读取等一次性异步操作
/// 特点：自动处理 loading / error / data 三种状态，内置刷新机制
final userInfoProvider = FutureProvider<String>((ref) async {
  // 模拟网络请求延迟
  await Future.delayed(const Duration(seconds: 2));

  // 模拟随机失败（用于展示 error 状态）
  // 有 20% 概率抛出异常
  if (DateTime.now().millisecond % 5 == 0) {
    throw Exception('网络请求失败，请重试');
  }

  return '用户：张三\n等级：Lv.8\n积分：1250';
});

/// 4. StreamProvider — 用于持续的数据流
///
/// 适用场景：定时器、WebSocket 消息、位置更新、蓝牙数据流
/// 特点：监听一个 Stream，每次有新数据都会触发重建
final timerProvider = StreamProvider<int>((ref) {
  // 每秒产生一个递增的数字，模拟实时数据流
  return Stream.periodic(
    const Duration(seconds: 1),
    (count) => count + 1,
  );
});

// ==================== 页面入口 ====================

@RoutePage()
class RiverpodProvidersPage extends StatelessWidget {
  const RiverpodProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riverpod 四种 Provider'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Provider 卡片
            ProviderCard(),
            SizedBox(height: 16),

            // 2. StateProvider 卡片
            StateProviderCard(),
            SizedBox(height: 16),

            // 3. FutureProvider 卡片
            FutureProviderCard(),
            SizedBox(height: 16),

            // 4. StreamProvider 卡片
            StreamProviderCard(),
          ],
        ),
      ),
    );
  }
}

// ==================== 1. Provider 卡片 ====================

/// Provider 演示卡片
///
/// 使用 ConsumerWidget 替代 StatelessWidget，可以直接获取 WidgetRef
/// 也可以继续使用 StatelessWidget + Consumer 组合
class ProviderCard extends ConsumerWidget {
  const ProviderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(provider) — 监听 Provider 的值，变化时重建 Widget
    // 对于 Provider（非 StateProvider），值不会变，所以只会读取一次
    final greeting = ref.watch(greetingProvider);

    return _buildCard(
      title: '1. Provider',
      subtitle: '不可变值 / 纯计算',
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            '说明：Provider 用于不会变化的数据，如配置项、常量、计算属性。'
            '消费者读取一次即可，不会触发重建。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ==================== 2. StateProvider 卡片 ====================

/// StateProvider 演示卡片
class StateProviderCard extends ConsumerWidget {
  const StateProviderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 StateProvider 的当前值
    final count = ref.watch(counterProvider);

    return _buildCard(
      title: '2. StateProvider',
      subtitle: '简单可变状态',
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 减少按钮
              IconButton(
                onPressed: () {
                  // ref.read(provider.notifier).state — 读取并修改状态
                  // 在回调中使用 read，不建立监听关系
                  ref.read(counterProvider.notifier).state--;
                },
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.green,
              ),
              // 当前计数
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              // 增加按钮
              IconButton(
                onPressed: () {
                  ref.read(counterProvider.notifier).state++;
                },
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '说明：StateProvider 适合基础类型的状态（int、String、bool）。'
            '通过 .notifier 获取 StateController 来修改状态。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ==================== 3. FutureProvider 卡片 ====================

/// FutureProvider 演示卡片
class FutureProviderCard extends ConsumerWidget {
  const FutureProviderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(futureProvider) 返回 AsyncValue<T>
    // AsyncValue 有三种状态：loading、error、data
    final asyncUserInfo = ref.watch(userInfoProvider);
    LogByCommon.d("异步数据 build");
    return _buildCard(
      title: '3. FutureProvider',
      subtitle: '异步数据（自动处理 loading/error/data）',
      color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AsyncValue 提供 when 方法，分别处理三种状态
          asyncUserInfo.when(
            // loading 状态：请求中
            loading: () => const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('加载中...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            // error 状态：请求失败
            error: (error, stackTrace) => Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '错误：$error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    // invalidate 可以刷新 Provider，重新执行异步操作
                    onPressed: () => ref.invalidate(userInfoProvider),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
            // data 状态：请求成功
            data: (info) => Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    info,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(userInfoProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新数据'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '说明：FutureProvider 自动管理异步状态。'
            '用 when() 分别处理 loading / error / data，代码清晰无嵌套。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ==================== 4. StreamProvider 卡片 ====================

/// StreamProvider 演示卡片
class StreamProviderCard extends ConsumerWidget {
  const StreamProviderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // StreamProvider 同样返回 AsyncValue
    // 但数据会随 Stream 的新事件不断更新
    final asyncTimer = ref.watch(timerProvider);

    return _buildCard(
      title: '4. StreamProvider',
      subtitle: '持续数据流（定时器 / WebSocket / 位置更新）',
      color: Colors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          asyncTimer.when(
            loading: () => const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('等待数据流...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            error: (error, stackTrace) => Center(
              child: Text('流错误：$error', style: const TextStyle(color: Colors.red)),
            ),
            data: (seconds) => Center(
              child: Column(
                children: [
                  // 动态变化的计时器显示
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: Colors.purple.shade400),
                        const SizedBox(width: 12),
                        Text(
                          '已运行 ${seconds}s',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '每秒自动更新（Stream 推送新数据）',
                    style: TextStyle(fontSize: 12, color: Colors.purple.shade300),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '说明：StreamProvider 监听一个 Stream，每次有新事件都会触发重建。'
            '适合实时数据：定时器、WebSocket、传感器数据等。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ==================== 公共组件 ====================

/// 统一的卡片样式
Widget _buildCard({
  required String title,
  required String subtitle,
  required Color color,
  required Widget child,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: color.withAlpha(180)),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          // 内容区域
          child,
        ],
      ),
    ),
  );
}
