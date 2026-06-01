# 第一阶段：触摸事件与手势识别

## 一、事件分层模型

Flutter 的触摸事件处理分为两层：

```
┌─────────────────────────────────────────────┐
│            手势层 (Gesture Layer)             │
│  GestureDetector / GestureRecognizer         │
│  将原始事件语义化为 tap / drag / scale 等     │
├─────────────────────────────────────────────┤
│           原始指针层 (Pointer Layer)          │
│  Listener / PointerEvent                     │
│  最底层的触摸事件，包含坐标、压力、设备类型     │
└─────────────────────────────────────────────┘
```

日常开发主要使用手势层，但理解底层指针层对解决手势冲突、自定义交互至关重要。

---

## 二、Pointer 原始事件

### 2.1 什么是 Pointer 事件

当用户触摸屏幕时，操作系统将触摸信息传递给 Flutter 引擎，引擎将其封装为 `PointerEvent` 对象。这是**最底层的事件**，不经过任何语义化处理。

一个完整的触摸序列：
```
PointerDownEvent  → 手指接触屏幕（一次触摸的起点）
PointerMoveEvent  → 手指在屏幕上移动（可能触发多次）
PointerUpEvent    → 手指离开屏幕（一次触摸的终点）
PointerCancelEvent → 事件被系统取消（如来电打断）
```

### 2.2 PointerEvent 的关键属性

| 属性 | 类型 | 含义 |
|------|------|------|
| `pointer` | `int` | 指针唯一 ID，多指触控时每个手指不同 |
| `position` | `Offset` | 相对于屏幕左上角的全局坐标 |
| `localPosition` | `Offset` | 相对于监听 Widget 左上角的局部坐标 |
| `delta` | `Offset` | 相对于上一次事件的移动增量（仅 Move 有意义） |
| `pressure` | `double` | 按压力度（0.0~1.0，需要硬件支持） |
| `kind` | `PointerDeviceKind` | 设备类型：touch / mouse / trackpad / stylus |

### 2.3 多指触控

每根手指有独立的 `pointer` ID，Flutter 通过这个 ID 区分不同手指：

```
手指1: pointer=0  Down → Move → Move → Up
手指2: pointer=1  Down → Move → Up          （两指同时触摸）
手指3: pointer=2  Down → Move → Cancel       （被系统中断）
```

用 `Listener` 可以同时追踪多个手指的位置。

### 2.4 Listener 的 HitTestBehavior

`Listener` 的 `behavior` 属性决定它如何参与命中测试：

| 值 | 行为 |
|----|------|
| `deferToChild` | 默认。只有子 Widget 被命中时，Listener 才会收到事件 |
| `opaque` | 自身参与命中测试，阻止事件穿透到下层，但不显示任何内容 |
| `translucent` | 自身参与命中测试，**不阻止**事件继续传递给下层 Widget |

---

## 三、手势识别器（GestureRecognizer）

### 3.1 手势层的意义

原始 Pointer 事件太底层了——你关心的不是「手指从 (100,200) 移动到 (150,200)」，而是「用户在水平滑动」。手势识别器就是把低层事件**语义化**为用户意图。

### 3.2 内置手势识别器

| 手势 | 回调 | 识别器类 |
|------|------|----------|
| 单击 | `onTap` | `TapGestureRecognizer` |
| 双击 | `onDoubleTap` | `DoubleTapGestureRecognizer` |
| 长按 | `onLongPress` | `LongPressGestureRecognizer` |
| 自由拖拽 | `onPanStart/Update/End` | `PanGestureRecognizer` |
| 水平拖拽 | `onHorizontalDragStart/Update/End` | `HorizontalDragGestureRecognizer` |
| 垂直拖拽 | `onVerticalDragStart/Update/End` | `VerticalDragGestureRecognizer` |
| 缩放旋转 | `onScaleStart/Update/End` | `ScaleGestureRecognizer` |

### 3.3 GestureDetector 的组合机制

`GestureDetector` 内部管理多个 `GestureRecognizer`。当你传入 `onTap` 和 `onLongPress` 时，它会同时创建 `TapGestureRecognizer` 和 `LongPressGestureRecognizer`。

**重要限制**：部分手势互斥，不能同时使用：
- `onPan*` 和 `onScale*` 冲突（都消费拖拽移动）
- `onHorizontalDrag*` 和 `onVerticalDrag*` 冲突
- `onTap` 和 `onDoubleTap` 需要特殊处理（GestureDetector 内部已处理）

### 3.4 RawGestureDetector

`GestureDetector` 是高层封装，`RawGestureDetector` 是其底层 API：

```dart
RawGestureDetector(
  gestures: <Type, GestureRecognizerFactory>{
    TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => TapGestureRecognizer(),
      (instance) {
        instance.onTap = () => print('tapped');
      },
    ),
  },
  child: myWidget,
)
```

`RawGestureDetector` 的意义：
- 可以精确指定使用哪种识别器
- 可以传入自定义的 `GestureRecognizer` 子类
- 不会像 `GestureDetector` 那样自动创建多个识别器

---

## 四、手势竞技场（Gesture Arena）

### 4.1 为什么需要竞技场

当多个手势识别器同时存在时（比如同时有 Tap 和 HorizontalDrag），一次触摸到底算「点击」还是「拖拽」？竞技场就是为了解决这个**消歧**问题。

### 4.2 竞技场工作流程

```
1. 手指按下 (PointerDownEvent)
   ↓
2. 所有识别器通过 addPointer() 加入竞技场
   ↓
3. 手指移动 (PointerMoveEvent)
   ↓
4. 各识别器判断：
   - 能识别 → accept() 胜出
   - 明确不是自己的 → reject() 淘汰
   - 不确定 → 继续等待
   ↓
5. 裁决结果：
   a. 一个识别器 accept → 它胜出，其余全部 reject
   b. 多个都不确定 → 超时（5秒）后全部 reject
   c. 最后一个未 reject 的自动胜出
```

### 4.3 accept 和 reject

- **accept (胜出)**：识别器确认自己能处理这个手势。一旦 accept，竞技场关闭，其他识别器被 reject。
- **reject (淘汰)**：识别器确认这不是自己能处理的手势。
- **延迟裁决**：识别器可以等待更多信息再做决定（比如 Tap 需要等手指抬起才能确认）。

### 4.4 典型竞争场景

**Tap vs HorizontalDrag**：
- 手指按下 → 两个识别器都进入竞技场
- 手指小幅移动 → Tap 判断「移动距离超过阈值，不是点击」→ reject 自己 → HorizontalDrag 胜出
- 手指不动直接抬起 → HorizontalDrag 判断「没有移动，不是拖拽」→ reject 自己 → Tap 胜出

**Tap vs LongPress**：
- 手指按下 → 两个识别器都进入竞技场
- 快速抬起 → Tap 胜出
- 持续按住 500ms → LongPress 胜出，Tap 被 reject

### 4.5 竞技场超时

如果所有识别器都不主动裁决（既不 accept 也不 reject），竞技场会在 **5 秒**后强制关闭，所有识别器被 reject。这是一种安全机制，防止手势系统卡死。

---

## 五、事件完整链路概览

```
用户触摸屏幕
  → 操作系统捕获触摸
  → Flutter 引擎接收 (PlatformDispatcher.onPointerDataPacket)
  → PointerEvent 分发到渲染树
  → Hit Test：从根节点向下递归，找出被触摸到的 Widget
  → Pointer 事件沿命中路径传递
  → GestureArena：多个 GestureRecognizer 竞争
  → 最终一个识别器胜出，触发对应的语义回调 (onTap / onDrag / ...)
```

下一阶段将深入 Hit Test 和事件分发的具体源码实现。
