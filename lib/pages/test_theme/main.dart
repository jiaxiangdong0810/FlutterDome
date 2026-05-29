import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../design_tokens/tokens.dart';

/// 换肤演示页面
///
/// 全局主题切换的演示入口。点击按钮切换浅色/深色主题，
/// 观察 Material 组件和自定义组件如何响应主题变化。
@RoutePage()
class ThemeDemoPage extends StatelessWidget {
  const ThemeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('换肤演示'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Text(
            '当前模式: ${isDark ? '深色' : '浅色'}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Spacing.lg),

          // Material 组件自动响应 ThemeData
          ElevatedButton(
            onPressed: () {},
            child: const Text('ElevatedButton（自动响应主题）'),
          ),
          const SizedBox(height: Spacing.md),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card 标题', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: Spacing.sm),
                  Text('Card 内容 —— 背景色、文字色自动随主题切换',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),

          const TextField(
            decoration: InputDecoration(
              hintText: '输入框 —— 背景色、提示文字色也随主题切换',
            ),
          ),
          const SizedBox(height: Spacing.md),

          const Divider(),
          const SizedBox(height: Spacing.md),

          // 自定义组件用 Theme 读取当前颜色
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(RadiusTokens.md),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '自定义组件',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '通过 Theme.of(context) 读取当前主题色',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.lg),
          Text(
            '提示：在首页 AppBar 右上角点击图标切换全局主题',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
