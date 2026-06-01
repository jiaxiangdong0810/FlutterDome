# 第二阶段：事件传递的完整链路

## 一、命中测试（Hit Testing）

### 1.1 什么是命中测试

当用户触摸屏幕上的某个点时，Flutter 需要找出「哪个 Widget 被触摸到了」。这个过程叫**命中测试**，是事件传递的第一步。

核心问题：屏幕上 Widget 层层叠放，一个触摸点可能同时落在多个 Widget 上，如何确定事件该发给谁？

### 1.2 命中测试的流程

```
RenderView.hitTest(position)
  └─ RenderBox.hitTest(result, position)      // 根节点
       ├─ hitTestChildren(result, position)   // 先测试子节点
       │    ├─ child3.hitTest(...)            // 从后向前（后添加的在上层）
       │    ├─ child2.hitTest(...)
       │    └─ child1.hitTest(...)
       └─ hitTestSelf(result, position)       // 再测试自己
```

**关键规则**：
- 从**渲染树根节点**开始，**递归向下**测试
- 子节点按**从后到前**的顺序测试（后添加的 Widget 在视觉上层，优先命中）
- 每个节点先调用 `hitTestChildren()` 测试子节点，再调用 `hitTestSelf()` 测试自身
- 命中的节点会被记录到 `HitTestResult` 中

### 1.3 hitTestSelf 与 hitTestChildren

这两个方法共同决定一个 RenderBox 是否被命中：

```dart
@override
bool hitTest(BoxHitTestResult result, {required Offset position}) {
  // 边界检查：触摸点是否在自己的范围内
  if (!size.contains(position)) return false;

  // 先测试子节点（从后往前）
  if (hitTestChildren(result, position: position)) {
    return true;  // 子节点被命中了
  }

  // 再测试自己
  if (hitTestSelf(result, position: position)) {
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  return false;
}
```

- `hitTestChildren()`：默认递归测试所有子节点
- `hitTestSelf()`：默认返回 `false`（大多数 RenderBox 不直接响应触摸）
- 子类可以重写这两个方法来自定义命中逻辑

### 1.4 HitTestBehavior 三模式

`HitTestBehavior` 决定一个 Widget 如何参与命中测试：

| 模式 | hitTestSelf | hitTestChildren | 效果 |
|------|-------------|-----------------|------|
| `deferToChild` | 不调用 | 调用 | 只有子 Widget 被命中时才算命中。默认行为 |
| `opaque` | 返回 true | 调用 | 自己算命中，阻止事件穿透到下层 |
| `translucent` | 返回 true | 调用 | 自己算命中，但**不阻止**事件继续传递 |

`opaque` 和 `translucent` 的区别：
- `opaque`：像一堵墙，事件被自己消费，下层 Widget 收不到
- `translucent`：像一块玻璃，自己能收到事件，下层 Widget 也能收到

### 1.5 IgnorePointer 与 AbsorbPointer

这两个 Widget 用于屏蔽事件：

| Widget | 效果 |
|--------|------|
| `IgnorePointer` | 子树完全不参与命中测试，事件穿透到下层 |
| `AbsorbPointer` | 子树不参与命中测试，但**阻止事件穿透**（相当于 opaque 空白区域） |

典型用法：
- 动画进行中用 `IgnorePointer` 禁用按钮
- 弹窗遮罩用 `AbsorbPointer` 阻止下层交互

---

## 二、事件分发链路

### 2.1 完整链路

```
1. 操作系统捕获触摸 → Flutter 引擎接收
2. PlatformDispatcher.onPointerDataPacket
3. PointerDataPacket → 解析为多个 PointerData
4. 转换为 PointerEvent（坐标转换、重采样）
5. GestureBinding.handlePointerEvent
6. RendererBinding.dispatchEvent
7. RenderView.hitTest → 递归命中测试
8. 命中路径记录到 HitTestResult
9. 事件沿命中路径反向传递（从叶子到根）
10. 每个命中节点的 handleEvent() 被调用
11. 如果有 GestureRecognizer，进入手势竞技场
```

### 2.2 向下命中、向上冒泡

事件传递是**双向**的：

**向下（命中测试阶段）**：
```
RenderView → RenderBox → RenderBox → ... → 叶子节点
```
找出所有被触摸到的节点，记录到 HitTestResult 中。

**向上（事件分发阶段）**：
```
叶子节点.handleEvent() → 父节点.handleEvent() → ... → RenderView.handleEvent()
```
沿着命中路径**反向**传递事件，每个节点都有机会处理。

这就是为什么 `Listener` 能收到事件：它在命中测试阶段被记录，在事件分发阶段被通知。

### 2.3 PointerRoute 机制

`PointerRoute` 是一个回调函数，可以被注册到 `GestureBinding` 中直接接收原始 Pointer 事件，绕过渲染树的命中测试。这是一种**全局事件监听**机制。

```dart
// 注册全局 Pointer 事件路由
GestureBinding.instance.pointerRouter.addRoute(myPointer, myCallback);
```

日常开发很少直接使用，但它是理解事件系统全局架构的重要一环。

### 2.4 事件队列批处理

Pointer 事件不是逐个处理的，而是**批量处理**：

```
一批 PointerDataPacket（可能包含多个 PointerData）
  → 转换为 PointerEvent
  → 放入事件队列
  → _flushPointerEventQueue() 批量处理
```

这样做是为了：
- 保证同一帧内的多个事件按顺序处理
- 避免中间状态导致的视觉闪烁
- 与帧调度协调，保证事件处理在渲染之前完成

---

## 三、Pointer 事件与手势的桥接

### 3.1 GestureBinding 的角色

`GestureBinding` 是 Flutter 框架中连接 Pointer 事件和手势识别器的桥梁。它做了两件关键的事：

1. **将 Pointer 事件分发给 GestureRecognizer**
2. **管理手势竞技场的生命周期**

### 3.2 手指按下 → 加入竞技场

当 `PointerDownEvent` 到达时：

```
GestureBinding._handlePointerEventImmediately(PointerDownEvent)
  → 遍历所有 GestureRecognizer
  → recognizer.addPointer(downEvent)
  → recognizer 通过 GestureArenaManager.add() 加入竞技场
```

每个 `GestureRecognizer` 在 `addPointer()` 中决定是否参与竞争。

### 3.3 手指移动/抬起 → 竞技场裁决

```
PointerMoveEvent 到达
  → recognizer.handleEvent(moveEvent)
  → 识别器判断是否能识别
  → 可能 accept() 或继续等待

PointerUpEvent 到达
  → recognizer.handleEvent(upEvent)
  → 最终裁决：accept() 或 reject()
  → 竞技场关闭，胜出者获得事件处理权
```

### 3.4 多指触控的 pointer ID

每根手指有独立的 `pointer` ID，从 0 开始递增：

- 手指1按下 → pointer=0，加入竞技场
- 手指2按下 → pointer=1，独立加入竞技场
- 两个手指的事件完全独立，互不干扰

手势识别器通过 `_PointerState` 追踪每个指针的状态（位置、时间戳等）。

### 3.5 _flushPointerEventQueue

事件队列的处理时机：

```dart
void _flushPointerEventQueue() {
  // 在每一帧开始前，批量处理队列中的所有事件
  while (_pendingPointerEvents.isNotEmpty) {
    _handlePointerEventImmediately(_pendingPointerEvents.removeFirst());
  }
}
```

这保证了：
- 事件处理是**同步**的，不等待帧渲染
- 同一批事件按到达顺序处理
- 事件处理完成后才进入帧渲染流程
