import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled1/router/app_router.dart';
import 'package:untitled1/router/app_router.gr.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appRouter = AppRouter();
  runApp(
    ProviderScope(
      child: MyApp(appRouter: appRouter),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(),
    );
  }
}

@RoutePage()
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 知识点'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==================== 异步编程 ====================
          _ModuleCard(
            title: '⚡ 异步编程',
            child: _NavButton(
              label: '进入学习',
              onTap: () => context.router.push(const AsyncHubRoute()),
            ),
          ),
          const SizedBox(height: 12),

          // ==================== 事件分发机制 ====================
          _ModuleCard(
            title: '📡 事件分发机制',
            child: _NavButton(
              label: '进入学习',
              onTap: () => context.router.push(const EventHubRoute()),
            ),
          ),
          const SizedBox(height: 12),

          // ==================== 网络请求 ====================
          _ModuleCard(
            title: '🌐 网络请求',
            child: _NavButton(
              label: '进入学习',
              onTap: () => context.router.push(const TestHttpsRoute()),
            ),
          ),
          const SizedBox(height: 12),

          // ==================== Riverpod 状态管理 ====================
          _ModuleCard(
            title: '🧪 Riverpod 状态管理',
            child: _NavButton(
              label: '进入学习',
              onTap: () => context.router.push(const RiverpodHubRoute()),
            ),
          ),
          const SizedBox(height: 12),

          // ==================== Provider 状态管理 ====================
          _ModuleCard(
            title: '📦 Provider 状态管理',
            child: Column(
              children: [
                _NavButton(
                  label: 'Provider 基础',
                  onTap: () =>
                      context.router.push(const ProviderBasicRoute()),
                ),
                const Divider(height: 1),
                _NavButton(
                  label: '多 Provider',
                  onTap: () =>
                      context.router.push(const ProviderMultiRoute()),
                ),
                const Divider(height: 1),
                _NavButton(
                  label: '异步 Provider',
                  onTap: () =>
                      context.router.push(const ProviderAsyncRoute()),
                ),
                const Divider(height: 1),
                _NavButton(
                  label: '性能优化',
                  onTap: () => context.router
                      .push(const ProviderOptimizationRoute()),
                ),
                const Divider(height: 1),
                _NavButton(
                  label: '购物车示例',
                  onTap: () =>
                      context.router.push(const ProviderCartRoute()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== BLoC 架构 ====================
          _ModuleCard(
            title: '🏗️ BLoC 架构',
            child: Column(
              children: [
                _NavButton(
                  label: 'BLoC 基础',
                  onTap: () =>
                      context.router.push(const BlocBasicsRoute()),
                ),
                const Divider(height: 1),
                _NavButton(
                  label: 'BLoC 列表示例',
                  onTap: () =>
                      context.router.push(const BlocListRoute()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== 状态管理基础 ====================
          _ModuleCard(
            title: '🔄 状态管理基础',
            child: Column(
              children: [
                _NavButton(
                  label: '多监听器 MultiListener',
                  onTap: () =>
                      context.router.push(const MultiListenerRoute()),
                ),
                const Divider(height: 1),
                _NavButton(
                  label: '重建演示 RebuildDemo',
                  onTap: () =>
                      context.router.push(const RebuildDemoRoute()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== InheritedWidget 相关 ====================
          _ModuleCard(
            title: '🧬 InheritedWidget 相关',
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    label: 'InheritedWidget',
                    onTap: () => context.router
                        .push(const InheritedWidgetDemoRoute()),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _NavButton(
                    label: '+ ChangeNotifier',
                    onTap: () => context.router
                        .push(const InheritedWidgetNotifierRoute()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== AutoRoute 路由 ====================
          _ModuleCard(
            title: '🛣️ AutoRoute 路由',
            child: _NavButton(
              label: '进入学习',
              onTap: () =>
                  context.router.push(const AutoRouteHomeRoute()),
            ),
          ),
          const SizedBox(height: 12),

          // ==================== 主题与国际化 ====================
          _ModuleCard(
            title: '🎨 主题与国际化',
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    label: '主题 Theme',
                    onTap: () =>
                        context.router.push(const ThemeDemoRoute()),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _NavButton(
                    label: '多语言 L10n',
                    onTap: () =>
                        context.router.push(const L10nDemoRoute()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== 测试相关 ====================
          _ModuleCard(
            title: '🧪 测试相关',
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    label: 'Widget 测试',
                    onTap: () => context.router
                        .push(const WidgetTestDemoRoute()),
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _NavButton(
                    label: '集成测试',
                    onTap: () => context.router
                        .push(const IntegrationTestDemoRoute()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ==================== Flavor 多环境 ====================
          _ModuleCard(
            title: '🍎 Flavor 多环境',
            child: _NavButton(
              label: '进入学习',
              onTap: () => context.router.push(const FlavorsDemoRoute()),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// 模块卡片 - 带标题和分隔效果
class _ModuleCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ModuleCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

/// 导航按钮 - 较小尺寸
class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
