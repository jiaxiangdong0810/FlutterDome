import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class RiverpodHubPage extends StatelessWidget {
  const RiverpodHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod 状态管理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '基础入门',
            items: [
              _ItemTile(
                title: 'Hello Riverpod',
                subtitle: 'Riverpod 基础示例',
                route: '/test-riverpod/hello',
              ),
              _ItemTile(
                title: 'Provider 类型',
                subtitle: '不同 Provider 类型演示',
                route: '/test-riverpod/providers',
              ),
              _ItemTile(
                title: 'StateNotifier',
                subtitle: 'StateNotifier 使用示例',
                route: '/test-riverpod/state-notifier',
              ),
            ],
          ),
          _buildSection(
            context,
            title: '进阶用法',
            items: [
              _ItemTile(
                title: 'Consumer 使用',
                subtitle: 'Consumer Widget 用法',
                route: '/test-riverpod/consumer',
              ),
              _ItemTile(
                title: 'Family',
                subtitle: 'Family Provider 示例',
                route: '/test-riverpod/family',
              ),
              _ItemTile(
                title: 'AutoDispose',
                subtitle: '自动销毁 Provider',
                route: '/test-riverpod/auto-dispose',
              ),
            ],
          ),
          _buildSection(
            context,
            title: '高级特性',
            items: [
              _ItemTile(
                title: '依赖注入',
                subtitle: 'Provider 依赖关系',
                route: '/test-riverpod/dependency',
              ),
              _ItemTile(
                title: '性能优化',
                subtitle: 'select 优化重建',
                route: '/test-riverpod/optimization',
              ),
              _ItemTile(
                title: 'AsyncValue',
                subtitle: '异步状态处理',
                route: '/test-riverpod/async-value',
              ),
            ],
          ),
          _buildSection(
            context,
            title: '实战应用',
            items: [
              _ItemTile(
                title: 'Scoped Provider',
                subtitle: '作用域 Provider',
                route: '/test-riverpod/scoped',
              ),
              _ItemTile(
                title: '状态刷新',
                subtitle: 'Provider 刷新机制',
                route: '/test-riverpod/refresh',
              ),
              _ItemTile(
                title: 'Todo 应用',
                subtitle: 'Riverpod 实战 Todo',
                route: '/test-riverpod/todo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_ItemTile> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                items[i],
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String route;

  const _ItemTile({
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.router.pushNamed(route),
    );
  }
}
