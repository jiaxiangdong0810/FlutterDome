# ChangeNotifier + InheritedNotifier 深度解析

> 本文档从基础概念出发，逐步深入到源码级别，帮助你彻底掌握 Flutter 中最经典的状态管理组合。
>
> 配套代码：`lib/pages/test_inherited_widget_notifier/main.dart`

---

## 目录

1. [为什么要学这个？](#1-为什么要学这个)
2. [三个核心概念](#2-三个核心概念)
   - 2.1 [ChangeNotifier —— 数据的"广播站"](#21-changenotifier--数据的广播站)
   - 2.2 [InheritedWidget —— 数据的"高速公路"](#22-inheritedwidget--数据的高速公路)
   - 2.3 [InheritedNotifier —— 两者的"完美联姻"](#23-inheritednotifier--两者的完美联姻)
3. [代码实战：从零搭建](#3-代码实战从零搭建)
   - 3.1 [第一步：定义状态类](#31-第一步定义状态类)
   - 3.2 [第二步：创建 InheritedNotifier](#32-第二步创建-inheritednotifier)
   - 3.3 [第三步：在页面中使用](#33-第三步在页面中使用)
   - 3.4 [第四步：子组件读取数据](#34-第四步子组件读取数据)
4. [深入原理](#4-深入原理)
   - 4.1 [ChangeNotifier 的监听机制](#41-changenotifier-的监听机制)
   - 4.2 [InheritedWidget 的依赖追踪](#42-inheritedwidget-的依赖追踪)
   - 4.3 [InheritedNotifier 的自动监听](#43-inheritednotifier-的自动监听)
   - 4.4 [Element 的更新流程](#44-element-的更新流程)
5. [与 Provider 的关系](#5-与-provider-的关系)
6. [性能优化与最佳实践](#6-性能优化与最佳实践)
7. [常见陷阱与解决方案](#7-常见陷阱与解决方案)
8. [进阶：手写一个迷你 Provider](#8-进阶手写一个迷你-provider)
9. [总结](#9-总结)

---

## 1. 为什么要学这个？

在 Flutter 中，状态管理方案层出不穷：Provider、Riverpod、Bloc、GetX……但它们大多建立在同一个基础之上——**ChangeNotifier + InheritedWidget**。

理解这对组合，等于拿到了理解 Flutter 状态管理的"万能钥匙"：

- **Provider** 的底层就是 `InheritedNotifier` 的封装
- **Riverpod** 虽然摆脱了 BuildContext，但其通知机制仍借鉴了 ChangeNotifier 的思想
- **Bloc** 的 `BlocListener` 本质上也是监听-通知模式

> 💡 学会这对组合，其他框架都是"语法糖"层面的差异。

---

## 2. 三个核心概念

### 2.1 ChangeNotifier —— 数据的"广播站"

```dart
class AppState extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();  // 📢 广播："数据变了！"
  }
}
```

**ChangeNotifier 是什么？**

它是一个**观察者模式**的实现：

- 维护一个**监听器列表**（`List<VoidCallback>`）
- 提供 `addListener()` 让外界"订阅"
- 提供 `notifyListeners()` 触发所有订阅者的回调

**形象比喻**：

想象一个广播电台（ChangeNotifier）：
- 听众（Widget）拨打热线 `addListener()` 订阅节目
- 当有新闻（数据变化）时，电台 `notifyListeners()` 广播给所有听众
- 听众收到消息后，各自决定做什么（重建 UI）

**核心源码简析**：

```dart
// flutter/lib/src/foundation/change_notifier.dart
class ChangeNotifier {
  List<VoidCallback>? _listeners;  // 订阅者列表

  void addListener(VoidCallback listener) {
    _listeners ??= [];
    _listeners!.add(listener);
  }

  void notifyListeners() {
    if (_listeners == null) return;
    // 遍历所有监听器并调用
    for (final listener in _listeners!) {
      listener();
    }
  }

  void dispose() {
    _listeners = null;  // 清理，防止内存泄漏
  }
}
```

**关键点**：
- `notifyListeners()` 只是**调用回调函数**，它本身不处理 UI 重建
- 谁来把回调和 UI 重建关联起来？答案是 **InheritedNotifier**

---

### 2.2 InheritedWidget —— 数据的"高速公路"

在 Flutter 中，数据默认只能**从父到子通过构造函数传递**。如果组件嵌套很深：

```dart
// ❌ 糟糕：层层传递，中间层被迫参与
Level1(data: data)
  → Level2(data: data)    // 不用但得传
    → Level3(data: data)  // 不用但得传
      → Level4(data: data) // 真正需要的地方
```

**InheritedWidget 解决了这个问题**：

```dart
// ✅ 优雅：任意深度的子组件直接获取
Level1()
  → Level2()    // 什么都不用管
    → Level3()  // 什么都不用管
      → Level4() // Data.of(context) 直接拿到！
```

**InheritedWidget 的工作原理**：

```dart
class MyData extends InheritedWidget {
  final int value;

  const MyData({
    super.key,
    required this.value,
    required super.child,
  });

  // 子组件通过这个方法获取数据
  static MyData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyData>()!;
  }

  // 决定数据变化时是否需要通知依赖者重建
  @override
  bool updateShouldNotify(MyData oldWidget) {
    return value != oldWidget.value;  // 值变了就通知
  }
}
```

**形象比喻**：

InheritedWidget 像一条**数据高速公路**：
- 你在某个节点（Widget 树位置）"上高速"（放置 InheritedWidget）
- 下方任意深度的组件都可以"下高速"（`of(context)` 获取数据）
- 中间层组件完全无感知，不需要任何改动

**但纯 InheritedWidget 有个问题**：

它只能传递**静态数据**。如果数据变化了，需要外部调用 `setState` 来触发重建。这意味着状态管理和 UI 耦合在一起。

---

### 2.3 InheritedNotifier —— 两者的"完美联姻"

**InheritedNotifier = InheritedWidget + 自动监听 ChangeNotifier**

```dart
class AppInfo extends InheritedNotifier<AppState> {
  const AppInfo({
    super.key,
    required super.notifier,  // 传入 ChangeNotifier
    required super.child,
  });

  static AppState of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppInfo>()!;
    return widget.notifier!;
  }
}
```

**它做了什么？**

1. 继承 InheritedWidget，拥有"数据高速公路"能力
2. 内部**自动** `addListener` 监听 notifier
3. 当 notifier 调用 `notifyListeners()` 时，**自动触发依赖者重建**

**形象比喻**：

- ChangeNotifier = 广播电台（会发通知）
- InheritedWidget = 高速公路（能传数据）
- InheritedNotifier = **带广播系统的高速公路** —— 数据不仅能传递，数据变化时还能自动通知所有"在路上"的组件

---

## 3. 代码实战：从零搭建

### 3.1 第一步：定义状态类

```dart
/// 应用状态类
///
/// 职责：封装数据 + 业务逻辑 + 通知机制
class AppState extends ChangeNotifier {
  AppState({
    this._counter = 0,
    this._userName = 'Flutter 开发者',
  });

  int _counter;
  String _userName;

  // 对外暴露只读数据
  int get counter => _counter;
  String get userName => _userName;

  // 业务方法：修改数据 + 通知监听者
  void increment() {
    _counter++;
    notifyListeners();  // 📢 关键：通知所有依赖者重建
  }

  void changeUserName() {
    _userName = _userName == 'Flutter 开发者' ? 'Dart 爱好者' : 'Flutter 开发者';
    notifyListeners();
  }
}
```

**设计要点**：
- 数据私有化（`_counter`），通过 getter 暴露
- 所有修改都走方法，方法内统一调用 `notifyListeners()`
- 状态类**纯 Dart**，不依赖 Flutter Widget，可独立测试

### 3.2 第二步：创建 InheritedNotifier

```dart
/// 数据传递层
///
/// 职责：将 AppState 注入 Widget 树，并自动监听其变化
class AppInfo extends InheritedNotifier<AppState> {
  const AppInfo({
    super.key,
    required super.notifier,
    required super.child,
  });

  /// 获取状态实例的便捷方法
  ///
  /// 注意：调用此方法会自动建立依赖关系，
  /// 当 AppState 变化时，调用处所在的 Widget 会被重建
  static AppState of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppInfo>()!;
    return widget.notifier!;
  }
}
```

**关键理解**：
- `InheritedNotifier<AppState>` 是泛型，指定了 notifier 的类型
- `of(context)` 使用了 `dependOnInheritedWidgetOfExactType`，这会在**调用位置**和 **InheritedNotifier** 之间建立依赖关系
- 依赖关系建立后，当 notifier 通知时，Flutter 框架知道该重建哪些 Widget

### 3.3 第三步：在页面中使用

```dart
class InheritedWidgetNotifierPage extends StatefulWidget {
  const InheritedWidgetNotifierPage({super.key});

  @override
  State<InheritedWidgetNotifierPage> createState() => _InheritedWidgetNotifierPageState();
}

class _InheritedWidgetNotifierPageState extends State<InheritedWidgetNotifierPage> {
  final AppState _state = AppState();  // 创建状态实例

  @override
  void dispose() {
    _state.dispose();  // 清理，防止内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInfo(
      notifier: _state,  // 将状态注入 Widget 树
      child: Scaffold(
        appBar: AppBar(title: const Text('InheritedNotifier 演示')),
        body: const _DataDisplayCard(),  // 子组件通过 AppInfo.of 获取数据
        floatingActionButton: const _ActionButtons(),
      ),
    );
  }
}
```

**架构分层**：

| 层级 | 职责 | 对应代码 |
|------|------|----------|
| 页面层 | 持有状态实例，管理生命周期 | `_InheritedWidgetNotifierPageState` |
| 传递层 | 将状态注入子树，自动监听 | `AppInfo` (InheritedNotifier) |
| 状态层 | 封装数据 + 业务逻辑 + 通知 | `AppState` (ChangeNotifier) |
| UI 层 | 读取状态，渲染界面 | `_DataDisplayCard`, `_ActionButtons` |

### 3.4 第四步：子组件读取数据

```dart
class _DataDisplayCard extends StatelessWidget {
  const _DataDisplayCard();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 建立依赖，获取状态

    return Card(
      child: Column(
        children: [
          Text('计数器: ${state.counter}'),  // 读取数据
          Text('用户名: ${state.userName}'),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 同样建立依赖

    return FloatingActionButton(
      onPressed: state.increment,  // 调用业务方法
      child: const Icon(Icons.add),
    );
  }
}
```

**深层嵌套组件也能直接获取**：

```dart
class _Level3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 无需层层传递！

    return Text('计数器: ${state.counter}');
  }
}
```

---

## 4. 深入原理

### 4.1 ChangeNotifier 的监听机制

```dart
// 简化版源码
abstract class Listenable {
  void addListener(VoidCallback listener);
  void removeListener(VoidCallback listener);
}

class ChangeNotifier implements Listenable {
  List<VoidCallback>? _listeners;
  int _notificationCallStackDepth = 0;
  bool _reentrantlyRemovedListeners = false;

  @override
  void addListener(VoidCallback listener) {
    _listeners ??= [];
    _listeners!.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_listeners == null) return;
    // 如果在通知过程中移除，需要延迟处理
    _listeners!.remove(listener);
  }

  @protected
  void notifyListeners() {
    if (_listeners == null) return;

    _notificationCallStackDepth++;

    // 遍历所有监听器
    for (final listener in _listeners!) {
      try {
        listener();
      } catch (exception, stack) {
        // 错误处理...
      }
    }

    _notificationCallStackDepth--;
  }

  void dispose() {
    _listeners = null;
  }
}
```

**关键细节**：

1. **监听器列表是懒加载的**：`_listeners ??= []`，没有监听器时为空
2. **通知时允许修改列表**：通过 `_notificationCallStackDepth` 处理重入
3. **dispose 后不可再用**：`_listeners = null`，再次 notify 会静默返回

### 4.2 InheritedWidget 的依赖追踪

当你调用 `context.dependOnInheritedWidgetOfExactType<T>()` 时，Flutter 做了什么？

```dart
// flutter/lib/src/widgets/framework.dart
abstract class BuildContext {
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>();
  // ...
}
```

**实际流程**（简化）：

```
1. 从当前 Element 向上遍历 Widget 树
2. 找到类型匹配的 InheritedElement
3. 将当前 Element 注册到 InheritedElement._dependents 中
4. 返回 InheritedWidget 实例
```

```dart
// 简化示意
class InheritedElement extends ProxyElement {
  final Set<Element> _dependents = HashSet<Element>();

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    _dependents.add(dependent);  // 注册依赖者
  }

  @protected
  void notifyDependent(InheritedWidget oldWidget, Element dependent) {
    dependent.didChangeDependencies();  // 通知依赖者
  }
}
```

**依赖关系图**：

```
AppInfo (InheritedElement)
  ├── _dependents: [_DataDisplayCard.Element, _ActionButtons.Element, _Level3.Element]
  │
  └── notifier: AppState (ChangeNotifier)
        └── _listeners: [AppInfo._handleNotification]
```

### 4.3 InheritedNotifier 的自动监听

这是最关键的部分——**InheritedNotifier 如何自动监听 ChangeNotifier？**

```dart
// flutter/lib/src/widgets/inherited_notifier.dart
class InheritedNotifier<T extends Listenable> extends InheritedWidget {
  const InheritedNotifier({
    super.key,
    this.notifier,
    required super.child,
  });

  final T? notifier;

  @override
  InheritedNotifierElement<T> createElement() => InheritedNotifierElement<T>(this);

  @override
  bool updateShouldNotify(InheritedNotifier<T> oldWidget) {
    return oldWidget.notifier != notifier;  // notifier 实例变化时通知
  }
}

class InheritedNotifierElement<T extends Listenable> extends InheritedElement {
  InheritedNotifierElement(InheritedNotifier<T> super.widget);

  @override
  InheritedNotifier<T> get widget => super.widget as InheritedNotifier<T>;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    // 🔑 挂载时添加监听器
    widget.notifier?.addListener(_handleNotification);
  }

  @override
  void update(InheritedNotifier<T> newWidget) {
    final T? oldNotifier = widget.notifier;
    final T? newNotifier = newWidget.notifier;
    if (oldNotifier != newNotifier) {
      oldNotifier?.removeListener(_handleNotification);
      newNotifier?.addListener(_handleNotification);
    }
    super.update(newWidget);
  }

  @override
  void unmount() {
    // 🔑 卸载时移除监听器，防止内存泄漏
    widget.notifier?.removeListener(_handleNotification);
    super.unmount();
  }

  void _handleNotification() {
    // 🔑 收到通知时，标记需要重建
    markNeedsBuild();
  }
}
```

**流程图解**：

```
用户点击按钮
    ↓
state.increment() 被调用
    ↓
_counter++
    ↓
notifyListeners()  // ChangeNotifier 广播
    ↓
AppInfo.Element._handleNotification() 被调用
    ↓
markNeedsBuild()  // 标记 InheritedElement 需要重建
    ↓
Flutter 框架在下一帧重建
    ↓
InheritedElement 重建时，遍历 _dependents
    ↓
对每个 dependent 调用 didChangeDependencies()
    ↓
dependent.markNeedsBuild()  // 标记依赖者需要重建
    ↓
下一帧，所有依赖者重建，读取新数据
```

### 4.4 Element 的更新流程

为了彻底理解，我们需要了解 Flutter 的三棵树：

```
Widget Tree          Element Tree         Render Tree
(配置)                (状态)                (渲染)
  │                     │                    │
  ▼                     ▼                    ▼
InheritedNotifier    InheritedElement     RenderObject
  │                     │
  ├── _DataDisplayCard  ├── Element (dependent)
  │                       │   └── didChangeDependencies()
  ├── _ActionButtons    ├── Element (dependent)
  │                       │   └── didChangeDependencies()
  └── _Level3           └── Element (dependent)
                            └── didChangeDependencies()
```

**重建触发流程**：

```dart
// 1. ChangeNotifier 通知
notifyListeners();

// 2. InheritedNotifierElement 收到通知
void _handleNotification() {
  markNeedsBuild();  // 标记自己需要重建
}

// 3. 下一帧，InheritedNotifierElement 重建
@override
void performRebuild() {
  // 重建前，通知所有依赖者
  final oldWidget = this.widget;
  // ... 重建逻辑
  notifyClients(oldWidget);  // 通知所有 dependents
}

// 4. 通知每个依赖者
void notifyClients(InheritedWidget oldWidget) {
  for (final Element dependent in _dependents) {
    notifyDependent(oldWidget, dependent);
  }
}

// 5. 依赖者收到通知
void notifyDependent(InheritedWidget oldWidget, Element dependent) {
  dependent.didChangeDependencies();
}

// 6. StatefulElement 的 didChangeDependencies
didChangeDependencies() {
  markNeedsBuild();  // 标记自己需要重建
}
```

**重要理解**：

- `markNeedsBuild()` 不会立即重建，而是将 Element 加入**脏列表**
- Flutter 在下一帧统一处理所有脏 Element，这是性能优化的关键
- 依赖者重建时，`build()` 方法中的 `AppInfo.of(context)` 会返回最新的 notifier

---

## 5. 与 Provider 的关系

Provider 是 Flutter 社区最流行的状态管理库，它的底层就是 **ChangeNotifier + InheritedNotifier**。

**对比**：

| 特性 | 手写 ChangeNotifier + InheritedNotifier | Provider |
|------|----------------------------------------|----------|
| 代码量 | 较多 | 简洁 |
| 学习成本 | 需要理解底层原理 | 封装好，易上手 |
| 灵活性 | 完全可控 | 受限于 API 设计 |
| 功能 | 基础 | 丰富（MultiProvider、Consumer、Selector 等）|
| 性能优化 | 手动实现 | 内置优化 |

**Provider 的 `ChangeNotifierProvider` 本质上就是**：

```dart
// 伪代码，展示 Provider 的核心逻辑
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext) create;
  final Widget child;

  @override
  State createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  Widget build(BuildContext context) {
    return InheritedNotifier<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }
}
```

**Provider 额外提供的功能**：

1. **MultiProvider**：合并多个 Provider，避免嵌套地狱
2. **Consumer**：精确控制重建范围
3. **Selector**：细粒度监听，只重建真正关心的部分
4. **Provider.of(context, listen: false)**：只读取不监听

---

## 6. 性能优化与最佳实践

### 6.1 避免不必要的重建

**问题**：如果一个大 Widget 调用了 `AppInfo.of(context)`，整个 Widget 都会重建。

**方案 1：拆分小组件**

```dart
// ❌ 不好：整个页面重建
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 整个页面依赖
    return Scaffold(
      body: Column(
        children: [
          Text(state.counter.toString()),
          // ... 很多其他不依赖 counter 的组件
        ],
      ),
    );
  }
}

// ✅ 好：只让需要的部分重建
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _CounterDisplay(),  // 只有这里重建
          // ... 其他组件不受影响
        ],
      ),
    );
  }
}

class _CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 只有这个组件依赖
    return Text(state.counter.toString());
  }
}
```

**方案 2：使用 Selector（Provider 提供）**

```dart
// 只监听 counter，userName 变化时不重建
Selector<AppState, int>(
  selector: (context, state) => state.counter,
  builder: (context, counter, child) {
    return Text('$counter');
  },
)
```

### 6.2 状态生命周期管理

```dart
class _MyPageState extends State<MyPage> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState();
  }

  @override
  void dispose() {
    _state.dispose();  // 必须释放！
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInfo(
      notifier: _state,
      child: ...,
    );
  }
}
```

### 6.3 状态提升（Lifting State Up）

当多个页面需要共享状态时，将状态提升到它们共同的祖先：

```dart
class MyApp extends StatelessWidget {
  final AppState _state = AppState();

  @override
  Widget build(BuildContext context) {
    return AppInfo(
      notifier: _state,
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

// 现在所有页面都可以访问同一个 AppState
```

### 6.4 不可变数据 vs 可变数据

```dart
// 方案 A：可变数据（本文示例）
class AppState extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

// 方案 B：不可变数据（更函数式）
class AppState extends ChangeNotifier {
  AppStateData _data = const AppStateData(counter: 0);
  AppStateData get data => _data;

  void increment() {
    _data = _data.copyWith(counter: _data.counter + 1);
    notifyListeners();
  }
}

@immutable
class AppStateData {
  final int counter;
  const AppStateData({required this.counter});
  AppStateData copyWith({int? counter}) => AppStateData(counter: counter ?? this.counter);
}
```

**不可变数据的优点**：
- 更容易追踪变化
- 方便实现 `==` 比较，用于 `updateShouldNotify`
- 更符合 Flutter 的函数式风格

---

## 7. 常见陷阱与解决方案

### 陷阱 1：忘记 dispose

```dart
// ❌ 错误：内存泄漏
class _MyPageState extends State<MyPage> {
  final AppState _state = AppState();

  // 没有 dispose！
}

// ✅ 正确
class _MyPageState extends State<MyPage> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}
```

### 陷阱 2：在 build 中创建 ChangeNotifier

```dart
// ❌ 错误：每次重建都创建新的，丢失状态
@override
Widget build(BuildContext context) {
  final state = AppState();  // 不要在这里创建！
  return AppInfo(notifier: state, child: ...);
}

// ✅ 正确
class _MyPageState extends State<MyPage> {
  final AppState _state = AppState();  // 作为字段

  @override
  Widget build(BuildContext context) {
    return AppInfo(notifier: _state, child: ...);
  }
}
```

### 陷阱 3：notifyListeners 在 dispose 后调用

```dart
// ❌ 错误：异步操作可能在 dispose 后完成
class AppState extends ChangeNotifier {
  Future<void> fetchData() async {
    final data = await api.fetch();
    _data = data;
    notifyListeners();  // 如果此时已 dispose，会报错
  }
}

// ✅ 正确
class AppState extends ChangeNotifier {
  Future<void> fetchData() async {
    final data = await api.fetch();
    if (!mounted) return;  // 检查是否已 dispose
    _data = data;
    notifyListeners();
  }
}
```

> 注意：ChangeNotifier 没有 `mounted` 属性，需要自己维护：

```dart
class AppState extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
```

### 陷阱 4：整个页面重建导致性能问题

```dart
// ❌ 不好
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 整个页面依赖
    return Scaffold(/* 大量子组件 */);
  }
}

// ✅ 好
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const _Body(),  // 不在这里依赖
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);  // 只在需要的组件依赖
    return ...;
  }
}
```

### 陷阱 5：在 didChangeDependencies 中再次依赖

```dart
// ❌ 错误：可能导致无限循环
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppInfo.of(context);  // 再次建立依赖
    // 做一些操作导致状态变化...
  }
}
```

---

## 8. 进阶：手写一个迷你 Provider

理解了底层原理，我们可以手写一个简化版的 Provider：

```dart
// ============================================
// 1. 核心：MiniProvider（类似 Provider 的 ChangeNotifierProvider）
// ============================================

class MiniProvider<T extends ChangeNotifier> extends StatefulWidget {
  const MiniProvider({
    super.key,
    required this.create,
    required this.child,
  });

  final T Function(BuildContext) create;
  final Widget child;

  @override
  State<MiniProvider<T>> createState() => _MiniProviderState<T>();
}

class _MiniProviderState<T extends ChangeNotifier> extends State<MiniProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MiniInherited<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

// ============================================
// 2. 内部 InheritedNotifier
// ============================================

class _MiniInherited<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const _MiniInherited({
    required super.notifier,
    required super.child,
  });

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<_MiniInherited<T>>()!;
    return widget.notifier!;
  }
}

// ============================================
// 3. 使用方式
// ============================================

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MiniProvider<AppState>(
      create: (context) => AppState(),
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = _MiniInherited.of<AppState>(context);
    return Text('${state.counter}');
  }
}
```

**这几乎就是 Provider 的核心实现！**

---

## 9. 总结

### 核心要点回顾

1. **ChangeNotifier** = 观察者模式的实现，负责"通知"
2. **InheritedWidget** = 数据传递机制，负责"共享"
3. **InheritedNotifier** = 两者的结合，自动监听 + 自动重建

### 架构分层

```
┌─────────────────────────────────────┐
│           UI 层（Widget）            │
│    调用 AppInfo.of(context) 读取    │
├─────────────────────────────────────┤
│         传递层（InheritedNotifier）   │
│    自动监听 notifier，触发依赖者重建  │
├─────────────────────────────────────┤
│         状态层（ChangeNotifier）      │
│    封装数据 + 业务逻辑 + notifyListeners│
└─────────────────────────────────────┘
```

### 学习路径建议

```
阶段 1：掌握 ChangeNotifier 基本用法
    ↓
阶段 2：理解 InheritedWidget 的数据传递
    ↓
阶段 3：使用 InheritedNotifier 组合两者
    ↓
阶段 4：阅读源码，理解 Element 的依赖追踪
    ↓
阶段 5：手写迷你 Provider，彻底掌握原理
    ↓
阶段 6：使用 Provider / Riverpod 等生产级库
```

### 与项目中另一个方案的对比

项目中还有另一个方案 `test_inherited_widget/main.dart`（纯 InheritedWidget + StatefulWidget 包装）：

| 对比项 | 方案 A：ChangeNotifier + InheritedNotifier | 方案 B：StatefulWidget + InheritedWidget |
|--------|------------------------------------------|----------------------------------------|
| 状态管理 | 状态自管理，不依赖 Widget | 状态在 Widget 内部 |
| 通知机制 | 内置 notifyListeners | 手动 setState |
| 代码耦合 | 低（状态纯 Dart） | 高（状态在 Widget 中） |
| 复用性 | 高（状态可独立测试） | 低（依赖 Widget 树） |
| 推荐度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

**结论**：ChangeNotifier + InheritedNotifier 是更优雅、更可维护的方案，也是 Provider 的底层原理。

---

> 📚 **延伸阅读**：
> - [Flutter 官方文档：State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
> - [Provider 源码](https://github.com/rrousselGit/provider)
> - [Flutter 深入理解 BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html)
