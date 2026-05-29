import 'package:flutter/material.dart';

import 'app_theme.dart';

/// 全局主题状态管理
///
/// 放在 MaterialApp 上方，控制整个 App 的主题切换。
/// 使用 InheritedWidget 机制，任何子组件都能通过 ThemeProvider.of() 获取当前主题模式。
class ThemeProvider extends InheritedWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const ThemeProvider({
    super.key,
    required this.isDark,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'ThemeProvider not found in context');
    return provider!;
  }

  ThemeData get theme => isDark ? AppTheme.dark : AppTheme.light;

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) =>
      oldWidget.isDark != isDark;
}
