# 阶段三：Widget 层的事件与通知机制

> 前两个阶段关注的是触摸/手势这类「物理输入」事件。本阶段上升到 Widget 层，学习 Flutter 中**应用级别的事件传递模式**——通知、依赖传播、焦点管理。

---

## 1. Notification 通知机制

### 1.1 为什么需要 Notification？

冒泡机制（阶段二）有局限：
- 只能在**父子嵌套**的 Widget 树中逐层向上传递
- 无法**跨层**传递——中间层如果没挂 Listener，事件就断了
- 只传递 Pointer/手势事件，不能携带自定义业务数据

Notification 是 Flutter 提供的**自上而下监听、自下而上传递**的事件通道。

### 1.2 核心 API

```dart
// 定义通知
class ScrollEndNotification extends Notification { ... }

// 发送通知（子 Widget 调用）
notification.dispatch(context);  // 沿 Element 树向上传递

// 监听通知（祖先 Widget）
NotificationListener<ScrollEndNotification>(
  onNotification: (notification) {
    return true;  // true = 消费，停止继续冒泡
  },
  child: ...,
)
```

### 1.3 dispatch 的传递路径

```
子 Widget
  → notification.dispatch(context)
    → 从当前 Element 开始，沿 parent 链向上遍历
      → 每个 Element 检查是否注册了 NotificationListener
        → 匹配泛型类型 → 调用 onNotification
        → 返回 true → 停止冒泡
        → 返回 false → 继续向上
```

与 Pointer 事件冒泡的区别：
| 特性 | Pointer 冒泡 | Notification |
|------|-------------|--------------|
| 方向 | 向上 | 向上 |
| 载荷 | 固定的 PointerEvent | 任意自定义数据 |
| 匹配方式 | 逐层 Listener | 泛型类型匹配 |
| 跨层 | 不能跳过中间层 | 能跳过（只匹配注册了对应类型的） |

### 1.4 自定义 Notification

```dart
class MyNotification extends Notification {
  final String message;
  final int value;
  MyNotification(this.message, this.value);
}

// 子 Widget 发送
MyNotification('hello', 42).dispatch(context);

// 祖先监听
NotificationListener<MyNotification>(
  onNotification: (n) {
    print('${n.message}: ${n.value}');
    return true;
  },
  child: ...,
)
```

### 1.5 应用场景

- 滚动位置同步（ScrollNotification）
- 表单验证状态上报
- 子组件通知父组件刷新（替代 callback 传参）
- 跨层通信（中间层不需要知道）

---

## 2. InheritedWidget 依赖传播

### 2.1 核心概念

InheritedWidget 是 Flutter **依赖注入**的基础设施。它解决的问题是：

> 祖先持有数据 → 后代需要使用 → 不想一层层传参数

```dart
class MyData extends InheritedWidget {
  final int count;
  final String label;

  const MyData({
    required this.count,
    required this.label,
    required super.child,
  });

  // 关键方法：后代通过此方法获取数据
  static MyData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyData>();
  }

  // 决定是否通知依赖者重建
  @override
  bool updateShouldNotify(MyData oldWidget) {
    return count != oldWidget.count || label != oldWidget.label;
  }
}
```

### 2.2 dependOnInheritedWidgetOfExactType 的机制

```dart
context.dependOnInheritedWidgetOfExactType<MyData>()
```

做了两件事：
1. **获取**：沿 Element 树向上查找最近的 MyData Element
2. **注册依赖**：当前 Element 记录对 MyData 的依赖关系

当 MyData.updateShouldNotify 返回 true 时，所有依赖它的 Element 被标记为 dirty → 触发 rebuild。

### 2.3 依赖传播链路

```
MyData(count: 0)          ← InheritedWidget
  └─ Column
      ├─ Text(count)      ← dependOnInheritedWidget → 注册依赖
      └─ Button(+1)       ← 点击后 setState → 更新 MyData

点击 Button → setState → MyData 重建
  → updateShouldNotify 比较新旧
    → true → Text 被标记 dirty → rebuild → 显示新 count
```

### 2.4 与 Provider 的关系

Provider 本质上是对 InheritedWidget 的封装：

```dart
// Provider 做的事
class Provider<T> extends InheritedWidget {
  final T value;
  static T of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider<T>>()!.value;
  }
  @override
  bool updateShouldNotify(Provider<T> old) => value != old.value;
}
```

### 2.5 getInheritedWidgetOfExactType vs dependOnInheritedWidgetOfExactType

| 方法 | 注册依赖 | 用途 |
|------|---------|------|
| `dependOnInheritedWidgetOfExactType` | ✅ 会 | 需要响应数据变化 |
| `getInheritedWidgetOfExactType` | ❌ 不会 | 只需要一次性读取，不关心后续变化 |

---

## 3. Focus 与键盘事件传递

### 3.1 焦点系统概述

Flutter 的焦点系统管理「当前哪个 Widget 接收键盘输入」。

核心概念：
- **FocusNode**：焦点树中的节点，绑定到 Widget
- **FocusScopeNode**：管理一组 FocusNode，同一时刻只有一个获得焦点
- **FocusManager**：全局焦点管理器，维护焦点树

### 3.2 FocusNode 基础

```dart
class _MyState extends State<MyWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    print('hasFocus: ${_focusNode.hasFocus}');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(focusNode: _focusNode);
  }
}
```

### 3.3 键盘事件传递链路

```
物理键盘输入
  → Flutter Engine → KeyEvent message
    → ServicesBinding.handleKeyMessage
      → FocusManager.handleKeyMessage
        → 当前 FocusNode 的 onKeyEvent 回调
          → 返回 KeyEventResult.handled → 停止传递
          → 返回 KeyEventResult.ignored → 继续向 parent FocusNode 传递
```

与手势事件的对比：
| 特性 | 手势事件 | 键盘事件 |
|------|---------|---------|
| 来源 | 触摸屏 | 物理/虚拟键盘 |
| 路径 | Hit Test → 冒泡 | FocusNode 链 |
| 决定接收者 | 坐标命中测试 | 焦点持有者 |
| 向上遍历 | Widget 树 | Focus 树 |

### 3.4 Focus Widget

```dart
Focus(
  autofocus: true,                    // 自动获取焦点
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: node.hasFocus ? Colors.blue : Colors.grey,
      ),
    ),
    child: Text('按 Esc 退出'),
  ),
)
```

### 3.5 FocusTraversalGroup

控制 Tab 键的焦点切换顺序：

```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(order: NumericFocusOrder(1), child: TextField()),
      FocusTraversalOrder(order: NumericFocusOrder(2), child: TextField()),
      FocusTraversalOrder(order: NumericFocusOrder(3), child: TextField()),
    ],
  ),
)
```

---

## 4. 事件机制的调试

### 4.1 debugPrintHitTestResults

```dart
import 'package:flutter/rendering.dart';

// 打印命中测试结果
debugPrintHitTestResults = true;
```

### 4.2 debugPaintPointersEnabled

```dart
// 显示每个 Layer 接收的 pointer 事件数量
debugPaintPointersEnabled = true;
```

### 4.3 GestureArena 调试

```dart
// 开启手势竞技场的详细日志
debugPrintGestureArenaDiagnostics = true;
```

### 4.4 Focus 调试

```dart
// 打印焦点变化
debugFocusChanges = true;

// FocusManager 的焦点树转储
debugDumpFocusTree();
```

### 4.5 常用调试手段

```dart
// 1. 在 Listener 中打印原始 Pointer 事件
Listener(
  onPointerDown: (e) => print('DOWN: ${e.position}'),
  onPointerMove: (e) => print('MOVE: ${e.delta}'),
  onPointerUp: (e) => print('UP: ${e.position}'),
  child: ...,
)

// 2. 在 GestureDetector 中打印手势回调
GestureDetector(
  onTap: () => print('TAP'),
  onPanUpdate: (d) => print('PAN: ${d.delta}'),
  child: ...,
)

// 3. 用 NotificationListener 监听滚动通知
NotificationListener<ScrollNotification>(
  onNotification: (n) {
    print('Scroll: ${n.metrics.pixels}');
    return false;  // 不消费，继续传递
  },
  child: ListView.builder(...),
)

// 4. 用 Focus 监听键盘
Focus(
  onKeyEvent: (node, event) {
    print('Key: ${event.logicalKey} ${event.runtimeType}');
    return KeyEventResult.ignored;
  },
  child: ...,
)
```

---

## 知识图谱

```
应用层事件
├── Notification 通知机制
│   ├── dispatch → Element parent 链
│   ├── NotificationListener<T> 泛型匹配
│   └── 自定义 Notification 子类
├── InheritedWidget 依赖传播
│   ├── dependOnInheritedWidgetOfExactType
│   ├── updateShouldNotify → dirty → rebuild
│   └── Provider 的本质
├── Focus 焦点系统
│   ├── FocusNode → FocusScopeNode
│   ├── 键盘事件沿 FocusNode 链传递
│   └── FocusTraversalGroup 控制 Tab 顺序
└── 调试工具
    ├── debugPrintHitTestResults
    ├── debugPrintGestureArenaDiagnostics
    └── debugDumpFocusTree
```
