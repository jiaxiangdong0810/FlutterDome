# Provider 从入门到精通 —— 完整技术指南

> 本文档覆盖 Provider 包的全部核心知识点，从基础概念到高级实战，配合项目中的 5 个示例代码，帮助你系统掌握 Flutter 状态管理。
>
> 配套示例路径：
> - `02_basic/` — 基础用法（watch/read/Consumer/Selector）
> - `03_multi/` — MultiProvider + ProxyProvider
> - `04_async/` — FutureProvider + StreamProvider
> - `05_optimization/` — 重建优化对比
> - `06_cart/` — 购物车实战

---

## 目录

1. [Provider 是什么](#1-provider-是什么)
2. [Provider 家族全览](#2-provider-家族全览)
3. [核心概念：ChangeNotifier](#3-核心概念changenotifier)
4. [四种消费方式详解](#4-四种消费方式详解)
5. [多状态管理](#5-多状态管理)
6. [异步状态管理](#6-异步状态管理)
7. [状态依赖与注入](#7-状态依赖与注入)
8. [重建优化策略](#8-重建优化策略)
9. [跨页面状态共享](#9-跨页面状态共享)
10. [常见问题与最佳实践](#10-常见问题与最佳实践)
11. [与其他方案对比](#11-与其他方案对比)

---

## 1. Provider 是什么

### 1.1 解决的问题

Flutter 中，Widget 树是单向数据流的。当多个页面/组件需要共享同一份数据时，直接传递参数（prop drilling）会导致：

- 中间层 Widget 被迫接收不需要的数据
- 数据变化时难以通知所有使用者
- 代码耦合度高，难以维护

**Provider 的本质**：在 Widget 树的某个节点"提供"一个对象，下游任意节点都可以"获取"这个对象，且能选择是否"监听"它的变化。

### 1.2 设计哲学

Provider 遵循三个核心原则：

1. **简单性** — API 极少，学习成本低
2. **组合性** — 多个 Provider 可以嵌套组合
3. **响应式** — 状态变化自动触发 UI 重建

### 1.3 与 InheritedWidget 的关系

Provider 底层基于 `InheritedWidget` 实现，但解决了它的痛点：

| InheritedWidget | Provider |
|-----------------|----------|
| 样板代码多 | 一行搞定 |
| 无法方便地监听变化 | watch/select 自动监听 |
| 手动管理生命周期 | dispose 自动处理 |
| 类型安全弱 | 泛型约束，编译期检查 |

---

## 2. Provider 家族全览

### 2.1 全部 Provider 类型

```
Provider（基类）
├── Provider<T>              — 提供不可变对象
├── ChangeNotifierProvider   — 提供 ChangeNotifier，自动 dispose
├── ValueListenableProvider  — 提供 ValueListenable
├── ListenableProvider       — 提供任意 Listenable
├── FutureProvider<T>        — 提供 Future 的结果
├── StreamProvider<T>        — 提供 Stream 的数据
└── ProxyProvider 系列        — 依赖其他 Provider 创建
    ├── ProxyProvider<A, T>
    ├── ProxyProvider2<A, B, T>
    ├── ...ProxyProvider6
    └── ChangeNotifierProxyProvider<A, T>
```

### 2.2 每种 Provider 详解

#### Provider<T>

最基础，只提供值，不监听变化。适合提供配置对象、服务实例等不变数据。

```dart
Provider<ApiClient>(
  create: (_) => ApiClient(baseUrl: 'https://api.example.com'),
  child: MyApp(),
)

// 读取
final api = context.read<ApiClient>();
```

#### ChangeNotifierProvider

最常用。提供 `ChangeNotifier` 子类，状态变化时调用 `notifyListeners()` 触发重建。

```dart
ChangeNotifierProvider(
  create: (_) => Counter(),
  child: MyApp(),
)
```

#### FutureProvider

管理一次性异步操作，自动处理 loading/error/data 三态。

```dart
FutureProvider<List<User>>(
  create: (_) => fetchUsers(),
  initialData: const [],
)

// 消费时得到 AsyncSnapshot<List<User>>
final snapshot = context.watch<AsyncSnapshot<List<User>>>();
```

#### StreamProvider

管理持续数据流，如实时消息、传感器数据等。

```dart
StreamProvider<int>(
  create: (_) => Stream.periodic(Duration(seconds: 1), (i) => i),
  initialData: 0,
)
```

#### ChangeNotifierProxyProvider

一个状态依赖另一个状态时使用。当依赖的状态变化时，自动重建被依赖的状态。

```dart
// CartState 依赖 UserState 的 discount
ChangeNotifierProxyProvider<UserState, CartState>(
  create: (context) => CartState(context.read<UserState>()),
  update: (context, userState, previousCart) {
    // userState 变化时，保留 cart 数据但更新折扣
    final newCart = CartState(userState);
    if (previousCart != null) {
      newCart.items.addAll(previousCart.items);
    }
    return newCart;
  },
)
```

### 2.3 选择决策树

```
需要管理的状态是什么类型？
├── 可变状态（需要通知更新）
│   └── 是否有依赖其他状态？
│       ├── 是 → ChangeNotifierProxyProvider
│       └── 否 → ChangeNotifierProvider
├── 一次性异步数据
│   └── FutureProvider
├── 持续数据流
│   └── StreamProvider
└── 不可变对象/服务
    └── Provider
```

---

## 3. 核心概念：ChangeNotifier

### 3.1 什么是 ChangeNotifier

`ChangeNotifier` 是 Flutter SDK 提供的类，实现了**观察者模式**：

- 维护一个监听器列表
- `addListener()` 添加监听器
- `removeListener()` 移除监听器
- `notifyListeners()` 通知所有监听器

### 3.2 自定义状态类

```dart
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 通知所有监听者，触发重建
  }
}
```

### 3.3 关键规则

1. **只有状态变化时才调用 notifyListeners()** — 避免不必要的重建
2. **不要在 build 中调用 notifyListeners()** — 会导致无限循环
3. **不要在 notifyListeners() 后同步读取状态** — 可能读到旧值

### 3.4 进阶：控制通知粒度

```dart
class UserState extends ChangeNotifier {
  String _name = '';
  int _age = 0;

  String get name => _name;
  int get age => _age;

  // 只修改 name，但可能触发所有监听者重建
  void updateName(String name) {
    if (_name != name) {
      _name = name;
      notifyListeners();
    }
  }
}
```

> 注意：ChangeNotifier 的通知是**粗粒度**的 — 任何一个字段变化都会通知所有监听者。要精准控制，需要用 `Selector` 或 `context.select()`（见第 8 章）。

---

## 4. 四种消费方式详解

Provider 通过 `BuildContext` 扩展提供了 4 个方法：

### 4.1 context.watch<T>()

**作用**：监听状态变化，状态更新时当前 Widget 重建。

**适用场景**：在 `build()` 方法中，需要响应式 UI 的地方。

```dart
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 建立监听关系，count 变化时整个 Widget 重建
    final count = context.watch<Counter>().count;
    return Text('Count: $count');
  }
}
```

**⚠️ 重要**：只能在 `build()` 方法或其调用的函数中使用，不能在事件回调中使用。

### 4.2 context.read<T>()

**作用**：只读取一次，不建立监听关系。

**适用场景**：事件回调（onPressed、onTap 等）、initState 中。

```dart
ElevatedButton(
  onPressed: () {
    // 只读取，不监听
    context.read<Counter>().increment();
  },
  child: Text('增加'),
)
```

**⚠️ 重要**：不要在 `build()` 中用 `read()` 来获取需要显示的数据 — 数据变化时 UI 不会更新。

### 4.3 context.select<T, R>(selector)

**作用**：监听对象的某个特定字段，只有该字段变化时才重建。

**适用场景**：状态对象有多个字段，只想监听其中一个。

```dart
// 只监听 username，其他字段变化不触发重建
final username = context.select<UserState, String>((user) => user.username);

// 等价写法
final username = context.select((UserState user) => user.username);
```

### 4.4 Consumer<T>

**作用**：局部重建，只重建 Consumer 的 builder 部分。

**适用场景**：需要控制重建范围，或需要访问 `child` 参数做优化。

```dart
Consumer<Counter>(
  builder: (context, counter, child) {
    // 只有这部分会重建
    return Text('Count: ${counter.count}');
  },
)
```

**child 参数优化**：

```dart
Consumer<Counter>(
  builder: (context, counter, child) {
    return Column(
      children: [
        Text('Count: ${counter.count}'), // 会重建
        child!, // 不会重建，复用实例
      ],
    );
  },
  // child 在 Counter 变化时不会重建
  child: ExpensiveWidget(),
)
```

### 4.5 四种方式对比

| 方式 | 监听范围 | 重建范围 | 适用位置 |
|------|----------|----------|----------|
| `watch()` | 整个对象 | 当前 Widget | build() 中 |
| `read()` | 不监听 | 不重建 | 事件回调 |
| `select()` | 指定字段 | 当前 Widget | build() 中 |
| `Consumer` | 整个对象 | builder 内部 | build() 中 |

### 4.6 Selector — Consumer + select 的结合

`Selector` 是 `Consumer` 的增强版，同时控制**重建范围**和**监听粒度**：

```dart
Selector<CartState, int>(
  // 只提取 totalQuantity 字段
  selector: (_, cart) => cart.totalQuantity,
  // 只有 totalQuantity 变化时才重建
  builder: (context, count, child) {
    return Badge(label: Text('$count'));
  },
)
```

---

## 5. 多状态管理

### 5.1 MultiProvider

当页面需要多个状态时，用 `MultiProvider` 避免嵌套地狱：

```dart
// ❌ 嵌套写法（不推荐）
ChangeNotifierProvider(
  create: (_) => UserState(),
  child: ChangeNotifierProvider(
    create: (_) => CartState(),
    child: ChangeNotifierProvider(
      create: (_) => ThemeState(),
      child: MyApp(),
    ),
  ),
)

// ✅ MultiProvider 写法（推荐）
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserState()),
    ChangeNotifierProvider(create: (_) => CartState()),
    ChangeNotifierProvider(create: (_) => ThemeState()),
  ],
  child: MyApp(),
)
```

### 5.2 状态组织建议

**按功能拆分**：

```dart
// 用户相关
class UserState extends ChangeNotifier { ... }

// 购物车相关
class CartState extends ChangeNotifier { ... }

// 主题相关
class ThemeState extends ChangeNotifier { ... }
```

**避免 God Object**：不要把所有状态放在一个类里，否则任何字段变化都会触发所有监听者重建。

---

## 6. 异步状态管理

### 6.1 FutureProvider 处理一次性请求

```dart
FutureProvider<AsyncValue<List<User>>>(
  create: (_) async {
    try {
      final users = await fetchUsers();
      return AsyncValue.data(users);
    } catch (e) {
      return AsyncValue.error(e);
    }
  },
  initialData: const AsyncValue.loading(),
)
```

自定义 AsyncValue 封装三态：

```dart
class AsyncValue<T> {
  final T? data;
  final Object? error;
  final bool isLoading;

  const AsyncValue._({this.data, this.error, this.isLoading = false});
  const AsyncValue.loading() : this._(isLoading: true);
  const AsyncValue.error(Object e) : this._(error: e);
  const AsyncValue.data(T value) : this._(data: value);

  bool get hasError => error != null;
  bool get hasData => data != null;
}
```

### 6.2 StreamProvider 处理持续数据流

```dart
StreamProvider<int>(
  create: (_) => Stream.periodic(
    Duration(seconds: 1),
    (i) => i,
  ),
  initialData: 0,
)

// 消费
final count = context.watch<int>();
```

### 6.3 刷新策略

FutureProvider 的 `create` 只在 Provider 重建时执行一次。要实现"下拉刷新"，需要：

```dart
// 方法1：用 Key 强制重建 Provider
FutureProvider<AsyncValue<List<User>>>(
  key: ValueKey(refreshKey), // 改变 key 触发重建
  create: (_) => fetchUsers(),
)

// 方法2：在状态类中管理 Future
class UserListState extends ChangeNotifier {
  Future<List<User>>? _future;
  Future<List<User>>? get future => _future;

  void refresh() {
    _future = fetchUsers();
    notifyListeners();
  }
}

// 配合 FutureBuilder 使用
FutureBuilder(
  future: context.watch<UserListState>().future,
  builder: ...
)
```

---

## 7. 状态依赖与注入

### 7.1 ChangeNotifierProxyProvider

当状态 B 需要依赖状态 A 时：

```dart
MultiProvider(
  providers: [
    // 1. 先提供 UserState
    ChangeNotifierProvider(create: (_) => UserState()),

    // 2. CartState 依赖 UserState
    ChangeNotifierProxyProvider<UserState, CartState>(
      create: (context) => CartState(context.read<UserState>()),
      update: (context, userState, previousCart) {
        // userState 变化时调用
        // previousCart 是之前的实例，可以迁移数据
        final newCart = CartState(userState);
        if (previousCart != null) {
          newCart.items.addAll(previousCart.items);
        }
        return newCart;
      },
    ),
  ],
  child: MyApp(),
)
```

### 7.2 依赖注入的生命周期

```
UserState 变化
    ↓
update() 被调用
    ↓
创建新的 CartState（传入新的 UserState）
    ↓
从 previousCart 迁移数据
    ↓
旧 CartState 被 dispose，监听者自动迁移到新实例
```

### 7.3 多依赖 ProxyProvider2-6

```dart
ProxyProvider2<UserState, SettingsState, AppState>(
  update: (context, user, settings, previous) => AppState(
    user: user,
    settings: settings,
  ),
)
```

---

## 8. 重建优化策略

### 8.1 问题：不必要的重建

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ 整个页面监听，任何字段变化都重建整个页面
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(state.title)), // 需要 title
      body: Column(
        children: [
          Text(state.counter.toString()), // 需要 counter
          Text(state.username), // 需要 username
        ],
      ),
    );
  }
}
```

**问题**：修改 `counter` 时，`username` 相关的 Widget 也会重建。

### 8.2 优化策略对比

| 策略 | 代码 | 重建范围 | 适用场景 |
|------|------|----------|----------|
| 拆分 Widget | 将需要监听的部分拆成独立 Widget | 仅该 Widget | 简单场景 |
| Consumer | 包裹需要重建的部分 | builder 内部 | 需要 child 优化 |
| Selector | 指定字段 | builder 内部 | 精准字段监听 |
| context.select | 指定字段 | 当前 Widget | 简单字段提取 |

### 8.3 优化实战

```dart
class OptimizedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // AppBar 需要 title，但不需要监听其他字段
    // 用 Selector 只监听 title
    return Selector<AppState, String>(
      selector: (_, state) => state.title,
      builder: (context, title, child) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: const _Body(), // Body 不依赖 title，不会重建
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // counter 区域独立监听
        Consumer<AppState>(
          builder: (context, state, child) {
            return Text('Counter: ${state.counter}');
          },
        ),
        // username 区域独立监听
        Selector<AppState, String>(
          selector: (_, state) => state.username,
          builder: (context, username, child) {
            return Text('User: $username');
          },
        ),
      ],
    );
  }
}
```

### 8.4 重建检测技巧

在开发中，用 `print` 或 `log` 观察重建：

```dart
@override
Widget build(BuildContext context) {
  log('【MyWidget】重建');
  return ...;
}
```

Flutter DevTools 的 **Performance** 标签页也可以查看重建情况。

---

## 9. 跨页面状态共享

### 9.1 状态放在哪里？

**原则**：状态放在它们的**共同祖先**节点上。

```dart
// ❌ 每个页面独立创建 — 状态不共享
class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartState(), // PageA 的 CartState
      child: ...,
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartState(), // PageB 的 CartState（不同的实例！）
      child: ...,
    );
  }
}
```

```dart
// ✅ 在共同祖先提供 — 状态共享
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartState(), // 全局唯一
      child: MaterialApp(...),
    );
  }
}

// PageA 和 PageB 都能访问同一个 CartState
class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>(); // 访问全局 CartState
    return ...;
  }
}
```

### 9.2 全局状态 vs 局部状态

| 类型 | 提供位置 | 例子 |
|------|----------|------|
| 全局状态 | MyApp 上方 | 用户信息、主题、购物车 |
| 页面级状态 | 页面入口 | 列表页的数据、表单状态 |
| 组件级状态 | 组件内部 | 动画控制器、展开/折叠 |

### 9.3 路由参数 vs Provider 状态

| 场景 | 方案 |
|------|------|
| 页面首次打开需要的标识（如 userId）| 路由参数 |
| 页面内需要修改且影响其他页面 | Provider |
| 只读配置（如 API 地址）| Provider |
| 临时状态（如搜索关键词）| StatefulWidget |

---

## 10. 常见问题与最佳实践

### 10.1 常见错误

#### ❌ 在 build 中调用 read() 获取显示数据

```dart
// 错误：数据变化时不会更新
Widget build(BuildContext context) {
  final count = context.read<Counter>().count; // ❌
  return Text('$count');
}

// 正确
Widget build(BuildContext context) {
  final count = context.watch<Counter>().count; // ✅
  return Text('$count');
}
```

#### ❌ 在事件回调中使用 watch()

```dart
// 错误：watch 只能在 build 中使用
ElevatedButton(
  onPressed: () {
    final counter = context.watch<Counter>(); // ❌ 运行时错误
    counter.increment();
  },
)

// 正确
ElevatedButton(
  onPressed: () {
    final counter = context.read<Counter>(); // ✅
    counter.increment();
  },
)
```

#### ❌ notifyListeners() 在 build 中同步调用

```dart
class BadState extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners(); // 如果在 Widget build 中同步调用，会报错
  }
}
```

**解决**：用 `SchedulerBinding.instance.addPostFrameCallback` 延迟通知，或确保通知发生在用户交互回调中。

#### ❌ 忘记在 ProxyProvider 中迁移数据

```dart
// 错误：用户状态变化时，购物车数据丢失
ChangeNotifierProxyProvider<UserState, CartState>(
  create: (context) => CartState(context.read<UserState>()),
  update: (context, userState, previousCart) {
    return CartState(userState); // ❌ 没有迁移 previousCart 的数据
  },
)

// 正确
ChangeNotifierProxyProvider<UserState, CartState>(
  create: (context) => CartState(context.read<UserState>()),
  update: (context, userState, previousCart) {
    final newCart = CartState(userState);
    if (previousCart != null) {
      newCart.items.addAll(previousCart.items); // ✅ 迁移数据
    }
    return newCart;
  },
)
```

### 10.2 最佳实践

#### ✅ 状态类命名规范

```dart
// 状态类以 State 或 Notifier 结尾
class CounterState extends ChangeNotifier { }
class UserNotifier extends ChangeNotifier { }

// 避免
class Counter extends ChangeNotifier { } // 容易和 Widget 类混淆
```

#### ✅ 状态类放在独立文件

```
lib/
├── state/
│   ├── counter_state.dart
│   ├── user_state.dart
│   └── cart_state.dart
├── pages/
│   └── ...
```

#### ✅ 使用 List.unmodifiable 保护状态

```dart
class CartState extends ChangeNotifier {
  final List<Item> _items = [];

  // 返回不可修改的列表，防止外部直接修改
  List<Item> get items => List.unmodifiable(_items);
}
```

#### ✅ 状态修改方法集中管理

```dart
class CartState extends ChangeNotifier {
  // ❌ 不好的做法：暴露内部列表让外部直接操作
  List<Item> get items => _items;

  // ✅ 好的做法：提供语义化方法
  void addItem(Item item) { ... }
  void removeItem(String id) { ... }
  void updateQuantity(String id, int qty) { ... }
}
```

#### ✅ 使用 freezed 或 equatable 处理复杂状态（可选）

```dart
// 对于复杂状态，可以用 freezed 自动生成 copyWith、==、hashCode
@freezed
class UserState with _$UserState {
  factory UserState({
    required String name,
    required int age,
    required bool isLoading,
  }) = _UserState;
}
```

### 10.3 调试技巧

#### 查看 Provider 树

```dart
// 在任意位置打印 Provider 信息
debugPrint(Provider.of<Counter>(context, listen: false).toString());
```

#### 使用 ProviderDebug 观察重建

```dart
class DebugWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('${DateTime.now()} DebugWidget 重建');
    final counter = context.watch<Counter>();
    return Text('${counter.count}');
  }
}
```

---

## 11. 与其他方案对比

### 11.1 Provider vs setState

| 维度 | setState | Provider |
|------|----------|----------|
| 学习成本 | 低 | 低 |
| 跨组件通信 | 需要层层传递 | 直接获取 |
| 代码组织 | 状态和 UI 耦合 | 状态独立 |
| 适用规模 | 小型页面 | 中大型应用 |

### 11.2 Provider vs BLoC (flutter_bloc)

| 维度 | Provider | BLoC |
|------|----------|------|
| 学习成本 | 低 | 中 |
| 状态变化方式 | 命令式 (notifyListeners) | 响应式 (Stream) |
| 代码量 | 少 | 多（需要定义 Event/State）|
| 适用场景 | 大多数应用 | 复杂业务逻辑、需要时间旅行调试 |
| 测试友好度 | 中 | 高 |

### 11.3 Provider vs Riverpod

Riverpod 是 Provider 作者开发的下一代方案：

| 维度 | Provider | Riverpod |
|------|----------|----------|
| 编译安全 | 运行时可能找不到 Provider | 编译时保证 |
| 与 Widget 树耦合 | 依赖 BuildContext | 不依赖 BuildContext |
| 代码生成 | 不需要 | 需要（推荐）|
| 学习成本 | 低 | 中 |
| 生态成熟度 | 成熟 | 发展中 |

> **建议**：先精通 Provider，再学 Riverpod 会很容易。Provider 的知识 80% 可以迁移到 Riverpod。

### 11.4 选择建议

```
项目规模小、团队 Flutter 经验少
    └── Provider（本文档）

需要严格的单向数据流、复杂状态机
    └── BLoC

追求极致的类型安全、不依赖 BuildContext
    └── Riverpod

简单的计数器、开关状态
    └── setState / ValueNotifier
```

---

## 附录：快速参考卡

### 常用代码片段

```dart
// 提供状态
ChangeNotifierProvider(create: (_) => MyState(), child: ...)

// 多状态
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => StateA()),
    ChangeNotifierProvider(create: (_) => StateB()),
  ],
  child: ...,
)

// 监听状态
final state = context.watch<MyState>();

// 读取状态（不监听）
final state = context.read<MyState>();

// 监听字段
final name = context.select<MyState, String>((s) => s.name);

// 局部重建
Consumer<MyState>(
  builder: (context, state, child) => Text('${state.count}'),
)

// 精准重建
Selector<MyState, int>(
  selector: (_, state) => state.count,
  builder: (context, count, child) => Text('$count'),
)
```

### 错误速查

| 错误信息 | 原因 | 解决 |
|----------|------|------|
| `Could not find the correct Provider` | Provider 在 Widget 树上方未找到 | 检查 Provider 是否在 MaterialApp 上方 |
| `Tried to use `watch` outside of build` | 在回调中使用了 watch | 回调中用 read |
| `setState() or markNeedsBuild() called during build` | build 中同步调用了 notifyListeners | 延迟通知或调整逻辑 |

---

> 本文档与项目中的 5 个示例代码配合使用，建议按顺序阅读并运行示例：
> 1. `02_basic` — 理解核心概念
> 2. `03_multi` — 理解多状态和依赖
> 3. `04_async` — 理解异步处理
> 4. `05_optimization` — 理解重建优化
> 5. `06_cart` — 综合实战
