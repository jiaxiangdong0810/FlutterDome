import 'package:flutter/material.dart';
import 'tokens.dart';

/// 将 Design Token 注入 Flutter ThemeData
///
/// 这是"翻译层"：把设计规范翻译成 Flutter 能理解的主题配置。
/// 只有这里引用 Token，业务代码不直接 import tokens.dart。
class AppTheme {
  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        brandPrimary: BrandColors.primary,
        brandSecondary: BrandColors.secondary,
        textPrimary: TextColors.primary,
        textSecondary: TextColors.secondary,
        textTertiary: TextColors.tertiary,
        textInverse: TextColors.inverse,
        surfacePage: SurfaceColors.page,
        surfaceCard: SurfaceColors.card,
        surfaceDivider: SurfaceColors.divider,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        brandPrimary: DarkBrandColors.primary,
        brandSecondary: DarkBrandColors.secondary,
        textPrimary: DarkTextColors.primary,
        textSecondary: DarkTextColors.secondary,
        textTertiary: DarkTextColors.tertiary,
        textInverse: DarkTextColors.inverse,
        surfacePage: DarkSurfaceColors.page,
        surfaceCard: DarkSurfaceColors.card,
        surfaceDivider: DarkSurfaceColors.divider,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color brandPrimary,
    required Color brandSecondary,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color textInverse,
    required Color surfacePage,
    required Color surfaceCard,
    required Color surfaceDivider,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // 颜色方案：Material 组件的默认颜色来源
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: brandPrimary,
        secondary: brandSecondary,
        error: SemanticColors.error,
        surface: surfaceCard,
        onPrimary: textInverse,
        onSecondary: textInverse,
        onError: textInverse,
        onSurface: textPrimary,
      ),

      // 页面背景
      scaffoldBackgroundColor: surfacePage,

      // 文字主题
      textTheme: TextTheme(
        headlineMedium: TypographyTokens.heading.copyWith(color: textPrimary),
        titleLarge: TypographyTokens.title.copyWith(color: textPrimary),
        bodyLarge: TypographyTokens.body.copyWith(color: textPrimary),
        bodyMedium: TypographyTokens.caption.copyWith(color: textSecondary),
        labelMedium: TypographyTokens.label.copyWith(color: textTertiary),
      ),

      // AppBar 样式
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceCard,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TypographyTokens.title.copyWith(color: textPrimary),
      ),

      // ElevatedButton 样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: textInverse,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          textStyle: TypographyTokens.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card 样式
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.lg),
        ),
        margin: EdgeInsets.zero,
      ),

      // 分割线
      dividerTheme: DividerThemeData(
        color: surfaceDivider,
        thickness: 1,
        space: Spacing.md,
      ),

      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePage,
        contentPadding: const EdgeInsets.all(Spacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          borderSide: BorderSide.none,
        ),
        hintStyle: TypographyTokens.body.copyWith(color: textTertiary),
      ),
    );
  }
}
