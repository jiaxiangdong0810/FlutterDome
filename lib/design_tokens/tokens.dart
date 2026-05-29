/// Design Token 定义文件
///
/// 这是设计团队维护的规范，Flutter/iOS/Android/Web 共用同一套命名。
/// 设计师在 Figma 中修改 Token 值后，各端同步更新此文件。
///
/// 命名规则：{类别}-{属性}-{层级/状态}
/// 例如：color-text-primary、spacing-md、radius-lg

import 'package:flutter/material.dart';

// ============================================
// 颜色 Token —— 浅色主题（默认）
// ============================================

/// 品牌色
/// 用途：主按钮、关键操作、选中状态
class BrandColors {
  static const Color primary = Color(0xFF6B4EFF);
  static const Color primaryHover = Color(0xFF5A3EE8);
  static const Color primaryPressed = Color(0xFF4A2FD1);

  static const Color secondary = Color(0xFF00C853);
  static const Color secondaryHover = Color(0xFF00B34A);
}

/// 功能色
/// 用途：状态反馈
class SemanticColors {
  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2979FF);
}

/// 文本色
/// 用途：不同层级的文字
class TextColors {
  static const Color primary = Color(0xFF1A1A1A);    // 标题、正文
  static const Color secondary = Color(0xFF666666);  // 辅助说明
  static const Color tertiary = Color(0xFF999999);   // 占位符、禁用
  static const Color inverse = Color(0xFFFFFFFF);    // 深色背景上的文字
}

/// 背景/表面色
/// 用途：容器、卡片、页面背景
class SurfaceColors {
  static const Color page = Color(0xFFF5F5F5);
  static const Color card = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8E8E8);
}

// ============================================
// 颜色 Token —— 深色主题
// ============================================

class DarkBrandColors {
  static const Color primary = Color(0xFF8B7AFF);
  static const Color primaryHover = Color(0xFF9D8FFF);
  static const Color primaryPressed = Color(0xFF7A6AEE);

  static const Color secondary = Color(0xFF69F0AE);
  static const Color secondaryHover = Color(0xFF7FFFBF);
}

class DarkTextColors {
  static const Color primary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFB0B0B0);
  static const Color tertiary = Color(0xFF808080);
  static const Color inverse = Color(0xFF1A1A1A);
}

class DarkSurfaceColors {
  static const Color page = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFF2C2C2C);
}

// ============================================
// 间距 Token（主题无关）
// ============================================

/// 基础间距单位：4dp
/// 所有间距都是 4 的倍数，保持视觉节奏
class Spacing {
  static const double unit = 4;

  static const double xs = unit * 1;   // 4
  static const double sm = unit * 2;   // 8
  static const double md = unit * 4;   // 16
  static const double lg = unit * 6;   // 24
  static const double xl = unit * 8;   // 32
  static const double xxl = unit * 12; // 48
}

// ============================================
// 圆角 Token（主题无关）
// ============================================

class RadiusTokens {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 999; // 胶囊形、圆形
}

// ============================================
// 文字 Token（主题无关，颜色由调用方决定）
// ============================================

/// 字体规格
/// 设计稿中标注："标题/正文/辅助文字"，开发对应到这里的 Token
class TypographyTokens {
  /// 页面大标题
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 模块标题
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// 正文
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 辅助文字、说明
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 标签、小字
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}
