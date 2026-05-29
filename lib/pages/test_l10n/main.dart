import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../generated/app_localizations.dart';

/// gen-l10n 国际化演示页面
///
/// 核心知识点：
/// 1. ARB 文件放在 lib/l10n/ 目录下，是 JSON 格式的翻译文件
/// 2. 运行 `flutter gen-l10n` 生成类型安全的 Dart 代码到 lib/generated/
/// 3. 在 MaterialApp 中配置 localizationsDelegates 和 supportedLocales
/// 4. 通过 AppLocalizations.of(context)! 访问翻译文本
/// 5. 占位符参数直接在方法调用时传入，编译期类型检查
@RoutePage()
class L10nDemoPage extends StatefulWidget {
  const L10nDemoPage({super.key});

  @override
  State<L10nDemoPage> createState() => _L10nDemoPageState();
}

class _L10nDemoPageState extends State<L10nDemoPage> {
  Locale _locale = const Locale('zh');

  void _switchLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用独立的 MaterialApp 来演示 locale 切换
    // 实际项目中通常在根 MaterialApp 配置 localizationsDelegates
    return Localizations.override(
      context: context,
      locale: _locale,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.pageTitle),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 当前语言显示
                  Text(
                    l10n.currentLocale(_locale.languageCode),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),

                  // 带占位符的问候语
                  Text(
                    l10n.greeting('Flutter'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // 带数字占位符的示例
                  Text(
                    l10n.itemCount(5),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  // 语言切换按钮
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _switchLocale(const Locale('zh')),
                        child: Text(l10n.switchToZh),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _switchLocale(const Locale('en')),
                        child: Text(l10n.switchToEn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 说明文本
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.demoDescription,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 代码提示
                  Text(
                    '生成的代码路径：lib/generated/app_localizations.dart',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '生成命令：flutter gen-l10n',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
