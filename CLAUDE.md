# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 提供操作本代码仓库的指引。

## 项目概述

这是一个用于学习和理解 Flutter 知识点的演示项目。它是一个面向 Android 的最小化 Flutter 应用。

- **Flutter**: 3.44.0 (stable)
- **Dart**: 3.12.0
- **SDK 约束**: `^3.12.0`
- **目标平台**: Android（无 iOS、macOS、Windows、Linux 或 Web 目录）

## 常用命令

构建 APK（发布版）：
```bash
flutter build apk
```

构建 APK（调试版）：
```bash
flutter build apk --debug
```

获取依赖：
```bash
flutter pub get
```

## 项目结构

```
lib/
├── main.dart          # 应用入口，仅配置路由
└── pages/             # 知识点测试页面
    ├── topic_a/       # 每个知识点一个独立文件夹
    │   ├── main.dart  # 该知识点的入口页面
    │   └── ...        # 相关组件（仅在需要时拆分）
    ├── topic_b/
    │   └── main.dart
    └── ...
```

## 编码规范

### 知识点页面开发原则

1. **最小实现**：代码以能运行、能展示效果为首要目标，不添加不必要的抽象层
2. **结构清晰**：每个知识点在 `pages/` 下创建独立文件夹，入口文件统一命名为 `main.dart`
3. **逻辑清晰**：变量、函数命名直观，避免过度封装，注释说明核心知识点
4. **不过度设计**：
   - 不提前抽取公共组件，除非同一知识点内有明显重复
   - 不添加未使用的依赖
5. **路由注册**：每新增一个知识点页面，在 `lib/main.dart` 中添加对应路由