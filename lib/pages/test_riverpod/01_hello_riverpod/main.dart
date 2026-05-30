import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod 入门示例 —— Hello Riverpod
///
/// 核心知识点：
/// 1. Provider 是 Riverpod 的核心，用于创建和管理状态
/// 2. StateProvider —— 管理简单的可变化状态（值类型）
/// 3. ConsumerWidget —— 替代 StatelessWidget，自动获取 WidgetRef
/// 4. WidgetRef —— 用于读取/监听/修改 Provider 状态，不需要 BuildContext
///
/// Riverpod vs Provider 核心区别：
/// ┌─────────────────┬──────────────────────────┬──────────────────────────┐
/// │     特性         │        Provider          │        Riverpod          │
/// ├─────────────────┼──────────────────────────┼──────────────────────────┤
/// │ 是否需要Context  │  ✅ 需要 BuildContext     │  ❌ 不需要，用 WidgetRef  │
/// │ 编译时安全       │  ❌ 运行时可能找不到       │  ✅ 编译时就能检查错误     │
/// │ 全局可访问       │  ❌ 依赖 Widget 树        │  ✅ Provider 全局定义      │
/// │ 代码生成支持     │  ❌ 不支持                │  ✅ 支持代码生成           │
/// └─────────────────┴──────────────────────────┴──────────────────────────┘

// ==================== Provider 定义（全局） ====================

/// StateProvider：管理一个 int 类型的状态
///
/// 与 Provider 的对比：
/// - Provider: ChangeNotifier + ChangeNotifierProvider 包裹在 Widget 树中
/// - Riverpod: 全局定义，不依赖 Widget 树，编译时就能确定依赖关系
///
/// Provider 写法（需要 BuildContext）：
/// ```dart
/// class Counter extends ChangeNotifier {
///   int _count = 0;
///   int get count => _count;
///   void increment() { _count++; notifyListeners(); }
/// }
/// // 在 Widget 树中包裹：
/// ChangeNotifierProvider(
///   create: (_) => Counter(),
///   child: const MyPage(),
/// )
/// // 在子 Widget 中读取：
/// final counter = context.watch<Counter>(); // 需要 BuildContext！
/// ```
///
/// Riverpod 写法（不需要 BuildContext）：
/// ```dart
/// final counterProvider = StateProvider<int>((ref) => 0);
/// // 在 ConsumerWidget 中读取：
/// final count = ref.watch(counterProvider); // 不需要 BuildContext！
/// ```
final counterProvider = StateProvider<int>((ref) => 0);

// ==================== 页面入口 ====================

@RoutePage()
class RiverpodHelloPage extends ConsumerWidget {
  const RiverpodHelloPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(counterProvider) —— 监听状态变化，状态更新时 Widget 重建
    // 等价于 Provider 的 context.watch<Counter>()
    // 关键区别：不需要 BuildContext！
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('01 Hello Riverpod'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 计数显示
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 减少按钮
                ElevatedButton(
                  onPressed: () {
                    // ref.read(counterProvider.notifier).state —— 读取 notifier 修改状态
                    // 等价于 Provider 的 context.read<Counter>().decrement()
                    // 关键区别：不需要 BuildContext！
                    ref.read(counterProvider.notifier).state--;
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                // 增加按钮
                ElevatedButton(
                  onPressed: () {
                    ref.read(counterProvider.notifier).state++;
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 核心优势说明
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    'Riverpod 核心优势',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '不需要 BuildContext，编译时安全',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Provider 全局定义，不依赖 Widget 树',
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
}
