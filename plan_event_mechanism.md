# Flutter 事件传递机制 — 学习计划

> 状态标记: ⬜ 未开始 | 🔄 进行中 | ✅ 已完成

---

## 一、基础篇：触摸事件与手势识别

### 1.1 Pointer 原始事件 ✅
- [x] `Listener` Widget 监听原始指针事件
- [x] `PointerDownEvent` / `PointerMoveEvent` / `PointerUpEvent` / `PointerCancelEvent`
- [x] `PointerEvent` 关键属性：`position`、`delta`、`pointer`、`kind`、`pressure`
- [x] `PointerDeviceKind`：touch / mouse / trackpad / stylus 区别

### 1.2 手势识别器（GestureRecognizer）✅
- [x] `TapGestureRecognizer` — 单击/双击/长按
- [x] `DragGestureRecognizer` — 水平/垂直/自由拖拽
- [x] `ScaleGestureRecognizer` — 缩放与旋转
- [x] `LongPressGestureRecognizer` / `ForcePressGestureRecognizer`
- [x] `GestureDetector` 如何同时管理多个识别器
- [x] `RawGestureDetector` — 直接指定识别器类型映射

### 1.3 手势竞技场（Gesture Arena）✅
- [x] `GestureArenaManager` 核心原理
- [x] `close()` / `accept()` / `reject()` 三板斧
- [x] 竞争、延迟裁决、超时消歧（默认 5 秒）
- [x] `GestureBinding` 桥接 Pointer 事件到手势识别

---

## 二、进阶篇：事件传递的完整链路

### 2.1 渲染树中的命中测试（Hit Testing）✅
- [x] `RenderBox.hitTest()` 递归逻辑
- [x] `hitTestSelf()` / `hitTestChildren()` 的分工
- [x] `HitTestResult` / `HitTestEntry` / `HitTestTarget`
- [x] `HitTestBehavior` 三模式：`deferToChild` / `opaque` / `translucent`
- [x] `IgnorePointer` / `AbsorbPointer` 的实现原理

### 2.2 事件分发链路源码 ✅
- [x] 「向下命中、向上冒泡」的双向流程
- [x] `PointerRoute` 机制
- [x] 事件队列批处理：`_flushPointerEventQueue()`

### 2.3 Pointer 事件与手势的桥接 ⬜
- [ ] `GestureBinding._handlePointerEventImmediately()`
- [ ] Pointer down → 加入竞技场 → move/up → 竞技场裁决
- [ ] 多指触控的 pointer ID 分配与跟踪

---

## 三、高级篇：Widget 层的事件与通知机制

### 3.1 Notification 通知机制（向上冒泡）✅
- [x] `NotificationListener<T>` 监听子树通知
- [x] `Notification.dispatch(context)` 沿 Element 树向上传播
- [x] `NotificationListener` 返回 `true` 拦截冒泡
- [x] 自定义 `Notification` 子类实战

### 3.2 InheritedWidget 依赖传播 ✅
- [x] `dependOnInheritedWidgetOfExactType<T>()` 注册依赖
- [x] `updateShouldNotify()` → 触发 `didChangeDependencies()`
- [x] `InheritedNotifier` / `InheritedModel`

### 3.3 Focus 与键盘事件传递 ✅
- [x] `FocusNode` / `FocusScopeNode` 焦点树
- [x] 键盘事件传递：`KeyEvent` → `FocusNode` → `Shortcuts`
- [x] `FocusTraversalPolicy` 焦点转移策略

### 3.4 事件机制的调试 ✅
- [x] `debugPrintHitTestResults()` 命中测试日志
- [x] `debugPrintGestureArenaDiagnostics` 竞技场日志
- [x] Flutter DevTools 事件时间线分析

---

## 页面目录

```
lib/pages/event_mechanism/
├── event_hub.dart                          # 入口导航页
├── stage1_pointer_and_gesture/             # 第一阶段：触摸事件与手势识别
│   ├── README.md                           # 技术文档（代码是文档的实现）
│   ├── 01_pointer_events.dart              # 1.1 Pointer 原始事件
│   ├── 02_gesture_recognizers.dart         # 1.2 手势识别器
│   └── 03_gesture_arena.dart               # 1.3 手势竞技场
├── stage2_event_dispatch/                  # 第二阶段：事件传递的完整链路
│   ├── README.md
│   ├── 04_hit_testing.dart
│   └── 05_event_dispatch.dart
└── stage3_widget_events/                   # 第三阶段：Widget 层的事件与通知
    ├── README.md
    ├── 06_notification.dart
    ├── 07_inherited_widget.dart
    ├── 08_focus_keyboard.dart
    └── 09_event_debugging.dart
```
