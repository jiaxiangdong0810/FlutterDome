import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/app_router.gr.dart';

/// Flutter 异步编程学习路线 Hub
///
/// 核心知识点：
/// 1. 事件循环与微任务队列（地基）
/// 2. Future 与 async/await（核心）
/// 3. Stream 基础与进阶
/// 4. Isolate 与并发
/// 5. Flutter 异步 UI 集成
/// 6. 高级模式与实战陷阱
@RoutePage()
class AsyncHubPage extends StatelessWidget {
  const AsyncHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('异步编程')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== Stage 1: 事件循环 ====================
          _buildSectionHeader('一、事件循环与微任务队列', '理解 Dart 为什么这样设计', Colors.blue),
          _buildTile(
            context,
            title: '1.1 事件循环模型',
            subtitle: 'Event Loop | 单线程 | 为什么不是并行',
            icon: Icons.loop,
            color: Colors.blue,
            route: const EventLoopBasicsRoute(),
          ),
          _buildTile(
            context,
            title: '1.2 微任务队列',
            subtitle: 'Microtask Queue | 优先级 | scheduleMicrotask',
            icon: Icons.low_priority,
            color: Colors.blue,
            route: const MicrotaskQueueRoute(),
          ),
          _buildTile(
            context,
            title: '1.3 执行顺序综合实验',
            subtitle: '同步 vs 微任务 vs Future | 顺序预测',
            icon: Icons.reorder,
            color: Colors.blue,
            route: const ExecutionOrderRoute(),
          ),

          const SizedBox(height: 24),
          // ==================== Stage 2: Future ====================
          _buildSectionHeader('二、Future 与 async/await', '日常开发 80% 的异步场景', Colors.green),
          _buildTile(
            context,
            title: '2.1 Future 基础',
            subtitle: '三种状态 | 创建方式 | 状态转换',
            icon: Icons.hourglass_empty,
            color: Colors.green,
            route: const FutureBasicsRoute(),
          ),
          _buildTile(
            context,
            title: '2.2 async/await 详解',
            subtitle: '语法糖 | .then() 转换 | 同步写法异步执行',
            icon: Icons.code,
            color: Colors.green,
            route: const AsyncAwaitRoute(),
          ),
          _buildTile(
            context,
            title: '2.3 Future 链式调用',
            subtitle: '.then() 链 | async/await 对比 | 错误传播',
            icon: Icons.link,
            color: Colors.green,
            route: const FutureChainRoute(),
          ),
          _buildTile(
            context,
            title: '2.4 Future 组合器',
            subtitle: 'wait | any | forEach | 并行 vs 竞速 vs 串行',
            icon: Icons.merge_type,
            color: Colors.green,
            route: const FutureCombinatorsRoute(),
          ),
          _buildTile(
            context,
            title: '2.5 错误处理',
            subtitle: 'try-catch | catchError | timeout | whenComplete',
            icon: Icons.error_outline,
            color: Colors.green,
            route: const FutureErrorHandlingRoute(),
          ),

          const SizedBox(height: 24),
          // ==================== Stage 3: Stream 基础 ====================
          _buildSectionHeader('三、Stream 基础', '异步版的 Iterable', Colors.orange),
          _buildTile(
            context,
            title: '3.1 Stream 基础概念',
            subtitle: 'Future vs Stream | listen | 生命周期',
            icon: Icons.waves,
            color: Colors.orange,
            route: const StreamBasicsRoute(),
          ),
          _buildTile(
            context,
            title: '3.2 单订阅 vs 广播 Stream',
            subtitle: 'Single-subscription | Broadcast | asBroadcastStream',
            icon: Icons.broadcast_on_personal,
            color: Colors.orange,
            route: const StreamTypesRoute(),
          ),
          _buildTile(
            context,
            title: '3.3 StreamController',
            subtitle: '手动控制 | add / close | 生命周期回调',
            icon: Icons.gamepad,
            color: Colors.orange,
            route: const StreamControllerRoute(),
          ),
          _buildTile(
            context,
            title: '3.4 Stream 操作符',
            subtitle: 'map | where | take | skip | expand',
            icon: Icons.filter_list,
            color: Colors.orange,
            route: const StreamOperatorsRoute(),
          ),

          const SizedBox(height: 24),
          // ==================== Stage 4: Stream 进阶 ====================
          _buildSectionHeader('四、Stream 进阶', '自定义转换与背压', Colors.purple),
          _buildTile(
            context,
            title: '4.1 async* / yield / yield*',
            subtitle: 'async* 生成器 | yield | yield* 委托',
            icon: Icons.generating_tokens,
            color: Colors.purple,
            route: const AsyncGeneratorRoute(),
          ),
          _buildTile(
            context,
            title: '4.2 StreamTransformer',
            subtitle: '自定义转换 | fromHandlers | bind',
            icon: Icons.transform,
            color: Colors.purple,
            route: const StreamTransformerRoute(),
          ),
          _buildTile(
            context,
            title: '4.3 Stream 合并与分割',
            subtitle: 'Merge | Split | 链式级联',
            icon: Icons.call_split,
            color: Colors.purple,
            route: const StreamMergeSplitRoute(),
          ),
          _buildTile(
            context,
            title: '4.4 背压处理',
            subtitle: 'Drop | Buffer | Throttle | Debounce',
            icon: Icons.compress,
            color: Colors.purple,
            route: const BackpressureRoute(),
          ),

          const SizedBox(height: 24),
          // ==================== Stage 5: Isolate ====================
          _buildSectionHeader('五、Isolate 与并发', '真正的多线程', Colors.red),
          _buildComingSoon('5.1 Isolate 基础概念'),
          _buildComingSoon('5.2 Isolate.run'),
          _buildComingSoon('5.3 compute() 函数'),
          _buildComingSoon('5.4 消息传递与通信'),

          const SizedBox(height: 24),
          // ==================== Stage 6: Flutter 异步 UI ====================
          _buildSectionHeader('六、Flutter 异步 UI', 'FutureBuilder / StreamBuilder', Colors.teal),
          _buildComingSoon('6.1 FutureBuilder'),
          _buildComingSoon('6.2 StreamBuilder'),
          _buildComingSoon('6.3 AsyncSnapshot'),
          _buildComingSoon('6.4 取消与生命周期'),

          const SizedBox(height: 24),
          // ==================== Stage 7: 高级模式 ====================
          _buildSectionHeader('七、高级模式与实战陷阱', '生产级异步模式', Colors.indigo),
          _buildComingSoon('7.1 Completer'),
          _buildComingSoon('7.2 调度优先级'),
          _buildComingSoon('7.3 常见陷阱'),
          _buildComingSoon('7.4 实战模式'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required PageRouteInfo route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.router.push(route),
      ),
    );
  }

  Widget _buildComingSoon(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(Icons.lock_outline, color: Colors.grey.shade400),
        ),
        title: Text(title, style: TextStyle(color: Colors.grey.shade500)),
        subtitle: Text('待开发', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
      ),
    );
  }
}
