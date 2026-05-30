# Riverpod 从入门到精通 —— 完整技术指南

> 本文档覆盖 Riverpod 的全部核心知识点，从基础概念到高级实战。
>
> 配套示例路径：
> - `01_hello_riverpod/` — 第一个 Riverpod 应用
> - `02_providers/` — Provider 类型全览
> - `03_state_notifier/` — StateNotifier / AsyncNotifier
> - `04_consumer/` — 消费状态的 N 种方式
> - `05_family/` — 参数化 Provider
> - `06_auto_dispose/` — 自动销毁机制
> - `07_dependency/` — Provider 依赖与注入
> - `08_optimization/` — 重建优化
> - `09_async_value/` — 异步状态统一处理
> - `10_scoped_provider/` — 局部状态覆盖
> - `11_refresh/` — 刷新与重试
> - `12_todo/` — 综合实战

## 目录

1. [Riverpod 是什么](#1-riverpod-是什么)
2. [与 Provider 的核心区别](#2-与-provider-的核心区别)
3. [Provider 类型全览](#3-provider-类型全览)
4. [状态管理：StateNotifier / AsyncNotifier](#4-状态管理statenotifier--asyncnotifier)
5. [消费状态的 4 种方式](#5-消费状态的-4-种方式)
6. [Family 参数化 Provider](#6-family-参数化-provider)
7. [AutoDispose 自动销毁](#7-autodispose-自动销毁)
8. [Provider 依赖与注入](#8-provider-依赖与注入)
9. [重建优化策略](#9-重建优化策略)
10. [AsyncValue 异步状态](#10-asyncvalue-异步状态)
11. [ProviderScope 局部覆盖](#11-providerscope-局部覆盖)
12. [Refresh / Invalidate](#12-refresh--invalidate)
13. [综合实战：Todo 应用](#13-综合实战todo-应用)
14. [常见问题与最佳实践](#14-常见问题与最佳实践)
15. [与 Provider 的迁移指南](#15-与-provider-的迁移指南)

---

## 1. Riverpod 是什么

### 1.1 解决的问题

Riverpod 是 Provider 的作者 Remi Rousselet 开发的下一代 Flutter 状态管理方案。它在 Provider 的基础上解决了几个核心痛点：

- **编译时安全**：Provider 在运行时可能找不到（`Could not find the correct Provider`），Riverpod 在编译期就能保证依赖正确
- **不依赖 BuildContext**：Provider 必须通过 `BuildContext` 获取状态，Riverpod 通过 `WidgetRef` 直接访问
- **全局可访问**：Provider 必须包裹在 Widget 树中，Riverpod 的 Provider 全局定义，随处可用
- **代码生成支持**：Riverpod 支持通过代码生成简化语法（`@riverpod` 注解）

### 1.2 设计哲学

Riverpod 遵循四个核心原则：

1. **编译安全** — 所有 Provider 依赖在编译期检查，杜绝运行时找不到 Provider 的错误
2. **去耦合** — 状态管理与 Widget 树解耦，不需要 BuildContext
3. **可测试** — Provider 不依赖 Flutter 框架，可以在纯 Dart 环境中单元测试
4. **可组合** — Provider 之间可以自由依赖、组合，形成清晰的数据流

### 1.3 与 Provider 的关系

Riverpod 不是 Provider 的替代品，而是进化版：

| 维度 | Provider | Riverpod |
|------|----------|----------|
| 作者 | Remi Rousselet | Remi Rousselet |
| 发布时间 | 2018 | 2020 |
| 编译安全 | 运行时检查 | 编译时保证 |
| BuildContext | 必需 | 不需要 |
| 代码生成 | 不支持 | 支持（推荐）|
| 学习曲线 | 低 | 中 |
| 知识迁移 | — | 80% 概念可迁移 |

> **建议**：如果你已经熟悉 Provider，学习 Riverpod 会非常快。两者的核心概念（Provider、watch/read、状态监听）几乎一致。

---

## 2. 与 Provider 的核心区别

### 2.1 定义方式对比

**Provider（依赖 Widget 树）：**

```dart
// 1. 定义状态类
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void increment() {
    _count++;
    notifyListeners();
  }
}

// 2. 在 Widget 树中包裹 Provider
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Counter(),
      child: MaterialApp(...),
    );
  }
}

// 3. 在子 Widget 中通过 BuildContext 获取
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>(); // 需要 BuildContext！
    return Text('${counter.count}');
  }
}
```

**Riverpod（全局定义，不依赖 Widget 树）：**

```dart
// 1. 全局定义 Provider（不需要 ChangeNotifier）
final counterProvider = StateProvider<int>((ref) => 0);

// 2. 在 main.dart 中包裹 ProviderScope
void main() {
  runApp(ProviderScope(child: MyApp()));
}

// 3. 使用 ConsumerWidget 替代 StatelessWidget
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider); // 不需要 BuildContext！
    return Text('$count');
  }
}
```

### 2.2 读取状态对比

| 操作 | Provider | Riverpod |
|------|----------|----------|
| 监听状态 | `context.watch<T>()` | `ref.watch(provider)` |
| 读取一次 | `context.read<T>()` | `ref.read(provider)` |
| 监听字段 | `context.select<T, R>()` | `ref.watch(provider.select(...))` |
| 在回调中读取 | `context.read<T>()` | `ref.read(provider)` |
| 修改状态 | `context.read<T>().method()` | `ref.read(provider.notifier).state = ...` |

### 2.3 核心优势总结

```
Provider 的问题                    Riverpod 的解决
─────────────────────────────────────────────────────────
运行时找不到 Provider    →        编译时就能检查错误
必须依赖 BuildContext    →        通过 WidgetRef 访问
Provider 嵌套地狱        →        全局定义，无嵌套
手动管理 dispose         →        autoDispose 自动销毁
无法参数化               →        family 修饰符支持参数
```

---

## 3. Provider 类型全览

### 3.1 全部 Provider 类型

```
Provider
├── Provider<T>              — 不可变值 / 纯计算
├── StateProvider<T>         — 简单可变状态（基础类型）
├── StateNotifierProvider    — 复杂状态管理（StateNotifier）
├── FutureProvider<T>        — 异步一次性数据
├── StreamProvider<T>        — 持续数据流
├── AsyncNotifierProvider    — 异步状态管理（AsyncNotifier）
└── 修饰符
    ├── .family              — 参数化 Provider
    ├── .autoDispose         — 自动销毁
    └── .family.autoDispose  — 组合使用
```

### 3.2 每种 Provider 详解

#### Provider<T>

最基础，提供不会变化的值。适合配置对象、常量、纯计算属性。

```dart
// 定义
final greetingProvider = Provider<String>((ref) => 'Hello, Riverpod!');

// 读取
final greeting = ref.watch(greetingProvider);

// Provider 对比
// Provider: Provider<ApiClient>(create: (_) => ApiClient())
// Riverpod: final apiProvider = Provider((ref) => ApiClient());
```

> 与 Provider 包的 `Provider<T>` 等价，但不需要包裹在 Widget 树中。

#### StateProvider<T>

管理简单的可变状态，适合基础类型（int、String、bool）。

```dart
// 定义
final counterProvider = StateProvider<int>((ref) => 0);

// 监听
final count = ref.watch(counterProvider); // 返回 int

// 修改
ref.read(counterProvider.notifier).state++; // 通过 notifier 修改

// Provider 对比
// Provider: ChangeNotifierProvider + Counter 类 + notifyListeners()
// Riverpod: 一行定义，自动处理通知
```

> 参考示例：`01_hello_riverpod/main.dart`、`02_providers/main.dart`

#### FutureProvider<T>

管理一次性异步操作，自动处理 loading/error/data 三态。

```dart
// 定义
final userInfoProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return '用户：张三\n等级：Lv.8';
});

// 消费 — 返回 AsyncValue<T>
final asyncUserInfo = ref.watch(userInfoProvider);

asyncUserInfo.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('错误：$error'),
  data: (info) => Text(info),
);

// Provider 对比
// Provider: FutureProvider<T> 返回 AsyncSnapshot<T>
// Riverpod: FutureProvider<T> 返回 AsyncValue<T>（更强大）
```

> 参考示例：`02_providers/main.dart` 中的 FutureProviderCard

#### StreamProvider<T>

管理持续数据流，如定时器、WebSocket、传感器数据。

```dart
// 定义
final timerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (count) => count + 1,
  );
});

// 消费 — 同样返回 AsyncValue<T>
final asyncTimer = ref.watch(timerProvider);

asyncTimer.when(
  loading: () => Text('等待数据流...'),
  error: (error, stack) => Text('流错误：$error'),
  data: (seconds) => Text('已运行 ${seconds}s'),
);
```

> 参考示例：`02_providers/main.dart` 中的 StreamProviderCard

#### StateNotifierProvider

管理复杂状态，适合对象类型的状态。需要配合 `StateNotifier` 使用。

```dart
// 1. 定义状态类
@freezed
class TodoState with _$TodoState {
  factory TodoState({
    required List<Todo> todos,
    required bool isLoading,
  }) = _TodoState;
}

// 2. 定义 StateNotifier
class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier() : super(TodoState(todos: [], isLoading: false));

  void addTodo(Todo todo) {
    state = state.copyWith(todos: [...state.todos, todo]);
  }

  void removeTodo(String id) {
    state = state.copyWith(
      todos: state.todos.where((t) => t.id != id).toList(),
    );
  }
}

// 3. 定义 Provider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  return TodoNotifier();
});

// 4. 消费
final todoState = ref.watch(todoProvider); // 返回 TodoState
final notifier = ref.read(todoProvider.notifier); // 返回 TodoNotifier
```

> 参考示例：`03_state_notifier/main.dart`

#### AsyncNotifierProvider

Riverpod 2.0 新增，专门用于异步状态管理，替代 `FutureProvider + StateNotifier` 的组合。

```dart
// 1. 定义 AsyncNotifier
class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    // 初始化时自动执行
    return await fetchUser();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchUser());
  }
}

// 2. 定义 Provider
final userProvider = AsyncNotifierProvider<UserNotifier, User>(() {
  return UserNotifier();
});

// 3. 消费
final userAsync = ref.watch(userProvider);
```

### 3.3 选择决策树

```
需要管理的状态是什么类型？
├── 不可变值 / 纯计算
│   └── Provider<T>
├── 简单可变状态（int、String、bool）
│   └── StateProvider<T>
├── 复杂对象状态
│   └── StateNotifierProvider / AsyncNotifierProvider
├── 一次性异步数据
│   └── FutureProvider<T>
├── 持续数据流
│   └── StreamProvider<T>
└── 需要根据参数创建？
    └── 加 .family 修饰符

需要自动销毁？
└── 加 .autoDispose 修饰符
```

---

## 4. 状态管理：StateNotifier / AsyncNotifier

### 4.1 为什么需要 StateNotifier

`StateProvider` 只适合简单的基础类型。对于复杂对象（如包含多个字段的 Todo 列表状态），需要：

1. **不可变状态** — 每次修改创建新对象，确保状态可预测
2. **封装修改逻辑** — 所有修改通过方法进行，便于追踪和测试
3. **类型安全** — 状态类型在编译期确定

### 4.2 StateNotifier 基础

```dart
// 1. 定义不可变状态（用 freezed 或手动实现）
class CounterState {
  final int count;
  final bool isLoading;

  const CounterState({this.count = 0, this.isLoading = false});

  // 手动实现 copyWith
  CounterState copyWith({int? count, bool? isLoading}) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. 定义 StateNotifier
class CounterNotifier extends StateNotifier<CounterState> {
  // 初始状态
  CounterNotifier() : super(const CounterState());

  void increment() {
    // 创建新状态对象，Riverpod 自动通知监听者
    state = state.copyWith(count: state.count + 1);
  }

  void decrement() {
    state = state.copyWith(count: state.count - 1);
  }

  Future<void> incrementAsync() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      count: state.count + 1,
      isLoading: false,
    );
  }
}

// 3. 定义 Provider
final counterNotifierProvider = StateNotifierProvider<CounterNotifier, CounterState>((ref) {
  return CounterNotifier();
});

// 4. 消费
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(counterNotifierProvider); // CounterState
    final notifier = ref.read(counterNotifierProvider.notifier); // CounterNotifier

    return Column(
      children: [
        Text('Count: ${state.count}'),
        if (state.isLoading) CircularProgressIndicator(),
        ElevatedButton(
          onPressed: notifier.increment,
          child: Text('增加'),
        ),
      ],
    );
  }
}
```

### 4.3 StateNotifier vs ChangeNotifier

| 维度 | ChangeNotifier（Provider） | StateNotifier（Riverpod） |
|------|---------------------------|--------------------------|
| 状态类型 | 可变对象，直接修改字段 | 不可变对象，每次创建新实例 |
| 通知方式 | 手动调用 `notifyListeners()` | 自动检测 `state` 变化 |
| 线程安全 | 不安全（可能读到中间状态）| 安全（原子替换） |
| 状态比较 | 不比较，总是通知 | 自动比较，相同值不通知 |
| 推荐程度 | 可用 | 强烈推荐 |

### 4.4 AsyncNotifier（Riverpod 2.0）

`AsyncNotifier` 是 Riverpod 2.0 为异步场景专门设计的类，结合了 `StateNotifier` 和 `FutureProvider` 的优点：

```dart
class UserListNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    // 初始化时执行，相当于 FutureProvider 的 create
    return await fetchUsers();
  }

  // 刷新数据
  Future<void> refresh() async {
    // 设置为 loading 状态
    state = const AsyncValue.loading();
    // 重新获取数据
    state = await AsyncValue.guard(() => fetchUsers());
  }

  // 添加用户
  Future<void> addUser(User user) async {
    // 保持当前数据，进入 loading
    final currentUsers = state.value ?? [];
    state = const AsyncValue.loading();
    // 执行添加操作
    state = await AsyncValue.guard(() async {
      await api.createUser(user);
      return [...currentUsers, user];
    });
  }
}

// 定义 Provider
final userListProvider = AsyncNotifierProvider<UserListNotifier, List<User>>(() {
  return UserListNotifier();
});

// 消费
final usersAsync = ref.watch(userListProvider);

usersAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('错误：$err'),
  data: (users) => ListView.builder(...),
);

// 刷新
ref.read(userListProvider.notifier).refresh();
```

> `AsyncValue.guard()` 是一个便利方法：如果 Future 成功，包装成 `AsyncValue.data()`；如果失败，包装成 `AsyncValue.error()`。

---

## 5. 消费状态的 4 种方式

Riverpod 通过 `WidgetRef` 提供了 4 种消费状态的方式：

### 5.1 ref.watch(provider)

**作用**：监听 Provider 的变化，状态更新时当前 Widget 重建。

**适用场景**：在 `build()` 方法中，需要响应式 UI 的地方。

```dart
class CounterDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 建立监听关系，counter 变化时 Widget 重建
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

**等价 Provider 写法**：`context.watch<Counter>().count`

### 5.2 ref.read(provider)

**作用**：只读取一次，不建立监听关系。

**适用场景**：事件回调（onPressed、onTap 等）、不需要监听变化的地方。

```dart
ElevatedButton(
  onPressed: () {
    // 只读取，不监听
    ref.read(counterProvider.notifier).state++;
  },
  child: Text('增加'),
)
```

**等价 Provider 写法**：`context.read<Counter>().increment()`

> ⚠️ **重要**：不要在 `build()` 中用 `read()` 来获取需要显示的数据，数据变化时 UI 不会更新。

### 5.3 ref.watch(provider.select(selector))

**作用**：监听对象的某个特定字段，只有该字段变化时才重建。

**适用场景**：状态对象有多个字段，只想监听其中一个。

```dart
// 只监听 username，其他字段变化不触发重建
final username = ref.watch(userProvider.select((user) => user.username));

// 等价于 Provider 的 context.select<UserState, String>((user) => user.username)
```

### 5.4 Consumer Widget

**作用**：局部重建，只重建 Consumer 的 builder 部分。

**适用场景**：需要控制重建范围，或需要在 StatelessWidget 中监听状态。

```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('标题'), // 不会重建
          Consumer(
            builder: (context, ref, child) {
              // 只有这部分会重建
              final count = ref.watch(counterProvider);
              return Text('Count: $count');
            },
          ),
        ],
      ),
    );
  }
}
```

### 5.5 四种方式对比

| 方式 | 监听范围 | 重建范围 | 适用位置 |
|------|----------|----------|----------|
| `ref.watch()` | 整个 Provider | 当前 Widget | ConsumerWidget build() 中 |
| `ref.read()` | 不监听 | 不重建 | 事件回调 |
| `ref.watch(select)` | 指定字段 | 当前 Widget | build() 中 |
| `Consumer` | 整个 Provider | builder 内部 | 任何 Widget 中 |

### 5.6 ConsumerWidget vs ConsumerStatefulWidget

```dart
// ConsumerWidget —— 替代 StatelessWidget
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}

// ConsumerStatefulWidget —— 替代 StatefulWidget
class MyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  @override
  void initState() {
    super.initState();
    // 可以直接使用 ref
    ref.read(counterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

> 参考示例：`04_consumer/main.dart`

---

## 6. Family 参数化 Provider

### 6.1 什么是 Family

`family` 是 Riverpod 独有的修饰符，让 Provider 可以接受参数，根据参数创建不同的实例。

**核心特性**：
- 传入不同参数，自动创建不同的 Provider 实例
- 相同参数复用已有实例（自动缓存）
- 参数必须实现 `==` 和 `hashCode`

### 6.2 基础用法

```dart
// 定义 family Provider
// 语法：Provider.family<返回值类型, 参数类型>((ref, 参数) => ...)
final userDetailProvider = Provider.family<Map<String, String>?, int>((ref, userId) {
  // 根据 userId 查询用户详情
  return users[userId];
});

// 使用
final user1 = ref.watch(userDetailProvider(1)); // 用户 1 的详情
final user2 = ref.watch(userDetailProvider(2)); // 用户 2 的详情
```

> 参考示例：`05_family/main.dart`

### 6.3 与 Provider 的对比

**Provider 要实现参数化（极其复杂）：**

```dart
// 需要手动管理缓存 + ProxyProvider
class UserDetailProvider extends ChangeNotifier {
  final Map<int, User> _cache = {};

  User? getUser(int id) {
    if (!_cache.containsKey(id)) {
      _cache[id] = fetchUser(id);
    }
    return _cache[id];
  }
}

// Widget 树中需要额外包裹 ProxyProvider
```

**Riverpod 一行搞定：**

```dart
final userDetailProvider = Provider.family<User, int>((ref, userId) {
  return fetchUser(userId);
});

// 使用时直接传参
ref.watch(userDetailProvider(1));
ref.watch(userDetailProvider(2));
```

### 6.4 复杂参数

如果参数是复杂对象，必须实现 `==` 和 `hashCode`：

```dart
// 使用 freezed 自动生成 == 和 hashCode
@freezed
class UserFilter with _$UserFilter {
  factory UserFilter({
    required String searchQuery,
    required int minAge,
    required int maxAge,
  }) = _UserFilter;
}

// family 参数可以是复杂对象
final filteredUsersProvider = FutureProvider.family<List<User>, UserFilter>(
  (ref, filter) async {
    return await fetchUsers(
      query: filter.searchQuery,
      minAge: filter.minAge,
      maxAge: filter.maxAge,
    );
  },
);

// 使用
final users = ref.watch(filteredUsersProvider(
  UserFilter(searchQuery: '张', minAge: 18, maxAge: 30),
));
```

### 6.5 与 autoDispose 组合

```dart
// family + autoDispose 组合
final userDetailProvider = Provider.family.autoDispose<User, int>((ref, userId) {
  // 当没有任何 widget 监听该 userId 对应的实例时，自动销毁
  return fetchUser(userId);
});
```

---

## 7. AutoDispose 自动销毁

### 7.1 为什么需要 AutoDispose

Provider 包中，Provider 的生命周期与 Widget 树绑定，需要手动管理 `dispose`，容易遗漏导致内存泄漏。

Riverpod 的 `autoDispose` 修饰符可以自动管理生命周期：当没有任何 widget 监听该 Provider 时，自动销毁。

### 7.2 基础用法

```dart
// 定义 autoDispose Provider
final autoDisposeCounterProvider = StateProvider.autoDispose<int>((ref) {
  // Provider 创建时触发
  debugPrint('Provider 创建');

  // Provider 销毁时触发
  ref.onDispose(() {
    debugPrint('Provider 销毁');
  });

  return 0;
});
```

> 参考示例：`06_auto_dispose/main.dart`

### 7.3 生命周期演示

```dart
class DemoPage extends StatefulWidget {
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _showCounter = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: Text('显示计数器'),
          value: _showCounter,
          onChanged: (value) {
            setState(() => _showCounter = value);
          },
        ),
        // 当 _showCounter 为 false 时，计数器 Widget 被移除
        // autoDispose Provider 自动销毁
        if (_showCounter)
          Consumer(
            builder: (context, ref, child) {
              final count = ref.watch(autoDisposeCounterProvider);
              return Text('Count: $count');
            },
          ),
      ],
    );
  }
}
```

**生命周期流程**：

```
显示计数器（Switch 打开）
    ↓
Widget 开始监听 autoDisposeCounterProvider
    ↓
Provider 创建（打印 "Provider 创建"）
    ↓
... 用户操作 ...
    ↓
隐藏计数器（Switch 关闭）
    ↓
Widget 被移除，不再监听 Provider
    ↓
Provider 自动销毁（打印 "Provider 销毁"）
```

### 7.4 与 Provider 的对比

| 维度 | Provider | Riverpod autoDispose |
|------|----------|---------------------|
| 销毁方式 | 手动调用 dispose() | 自动检测监听者数量 |
| 内存泄漏风险 | 高（容易遗漏） | 低（自动管理） |
| 代码复杂度 | 需要额外管理逻辑 | 加一个修饰符即可 |
| 适用场景 | 全局长期存在的状态 | 页面级、组件级状态 |

### 7.5 保持存活（Keep Alive）

有时希望 Provider 在一定时间内保持存活，即使暂时没有监听者：

```dart
final cacheProvider = FutureProvider.autoDispose<String>((ref) async {
  // 设置 5 分钟的缓存时间
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), link.close);

  return await fetchData();
});
```

---

## 8. Provider 依赖与注入

### 8.1 Provider 依赖另一个 Provider

Riverpod 中，一个 Provider 可以依赖另一个 Provider，形成清晰的数据流：

```dart
// 1. 基础 Provider
final userIdProvider = StateProvider<String>((ref) => 'user_123');

// 2. 依赖 userIdProvider
final userProfileProvider = FutureProvider<User>((ref) async {
  // ref.watch 建立依赖关系
  // 当 userIdProvider 变化时，userProfileProvider 自动重新执行
  final userId = ref.watch(userIdProvider);
  return await fetchUserProfile(userId);
});

// 3. 更复杂的依赖链
final userPostsProvider = FutureProvider<List<Post>>((ref) async {
  final user = await ref.watch(userProfileProvider.future);
  return await fetchPostsByUser(user.id);
});
```

### 8.2 依赖关系图

```
userIdProvider (StateProvider<String>)
    ↓ watch
userProfileProvider (FutureProvider<User>)
    ↓ watch
userPostsProvider (FutureProvider<List<Post>>)
```

当 `userIdProvider` 的值变化时：
1. `userProfileProvider` 自动重新执行
2. `userPostsProvider` 也随之重新执行
3. 所有监听这些 Provider 的 Widget 自动重建

### 8.3 与 Provider ProxyProvider 对比

**Provider（复杂，需要手动管理）：**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserState()),
    ChangeNotifierProxyProvider<UserState, CartState>(
      create: (context) => CartState(context.read<UserState>()),
      update: (context, userState, previousCart) {
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

**Riverpod（简洁，自动处理）：**

```dart
final userStateProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

final cartStateProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  // 自动监听 userStateProvider 的变化
  final userState = ref.watch(userStateProvider);
  return CartNotifier(userState);
});
```

### 8.4 依赖注入的最佳实践

```dart
// ✅ 好的做法：通过 Provider 注入依赖
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: 'https://api.example.com');
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  // 从其他 Provider 获取依赖
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
});

final userListProvider = FutureProvider<List<User>>((ref) async {
  // 从 Repository Provider 获取
  final repository = ref.watch(userRepositoryProvider);
  return await repository.getUsers();
});
```

> 参考示例：`07_dependency/main.dart`

---

## 9. 重建优化策略

### 9.1 问题：不必要的重建

```dart
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 监听整个状态对象，任何字段变化都重建整个页面
    final state = ref.watch(appStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(state.title)),
      body: Column(
        children: [
          Text('${state.counter}'),
          Text(state.username),
        ],
      ),
    );
  }
}
```

**问题**：修改 `counter` 时，`username` 相关的 Widget 也会重建。

### 9.2 优化策略对比

| 策略 | 代码 | 重建范围 | 适用场景 |
|------|------|----------|----------|
| 拆分 Widget | 将需要监听的部分拆成独立 Widget | 仅该 Widget | 简单场景 |
| Consumer | 包裹需要重建的部分 | builder 内部 | 局部重建 |
| select | 指定字段 | 当前 Widget | 精准字段监听 |
| Provider 拆分 | 一个 Provider 拆成多个 | 各自独立 | 复杂状态 |

### 9.3 优化实战

```dart
class OptimizedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 页面本身不监听任何 Provider，不会重建
    return Scaffold(
      appBar: AppBar(title: Text('优化示例')),
      body: Column(
        children: [
          // 标题区域独立监听
          _TitleWidget(),
          // 计数器区域独立监听
          _CounterWidget(),
          // 用户信息区域独立监听
          _UserWidget(),
        ],
      ),
    );
  }
}

// 只监听 title
class _TitleWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(appStateProvider.select((s) => s.title));
    return Text(title);
  }
}

// 只监听 counter
class _CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(appStateProvider.select((s) => s.counter));
    return Text('Counter: $counter');
  }
}

// 只监听 username
class _UserWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(appStateProvider.select((s) => s.username));
    return Text('User: $username');
  }
}
```

### 9.4 select 的高级用法

```dart
// 监听多个字段的组合
final summary = ref.watch(
  appStateProvider.select((s) => '${s.username}: ${s.counter}'),
);

// 监听列表长度（列表内容变化但长度不变时不重建）
final itemCount = ref.watch(
  todoProvider.select((todos) => todos.length),
);

// 监听是否存在某个条件
final hasItems = ref.watch(
  todoProvider.select((todos) => todos.isNotEmpty),
);
```

> 参考示例：`08_optimization/main.dart`

---

## 10. AsyncValue 异步状态

### 10.1 什么是 AsyncValue

`AsyncValue<T>` 是 Riverpod 提供的统一异步状态封装，替代了 Flutter 的 `AsyncSnapshot<T>`。

**三种状态**：
- `AsyncLoading()` — 加载中
- `AsyncError(error, stackTrace)` — 发生错误
- `AsyncData(value)` — 数据就绪

### 10.2 基础用法

```dart
final userProvider = FutureProvider<User>((ref) async {
  return await fetchUser();
});

// 消费
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(userProvider);

    return asyncUser.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('错误：$error')),
      data: (user) => Center(child: Text('用户名：${user.name}')),
    );
  }
}
```

> 参考示例：`02_providers/main.dart` 中的 FutureProviderCard

### 10.3 AsyncValue 的方法

```dart
final asyncValue = ref.watch(userProvider);

// 1. when — 处理三种状态（必须处理所有情况）
asyncValue.when(
  loading: () => Text('加载中...'),
  error: (err, stack) => Text('错误：$err'),
  data: (user) => Text(user.name),
);

// 2. whenOrNull — 只处理部分状态
asyncValue.whenOrNull(
  data: (user) => Text(user.name),
) ?? Text('加载中或出错');

// 3. maybeWhen — 提供默认值
asyncValue.maybeWhen(
  data: (user) => Text(user.name),
  orElse: () => Text('加载中...'),
);

// 4. map / mapOrNull / maybeMap — 类似 when，但参数是 AsyncValue 对象
asyncValue.map(
  loading: (loading) => Text('加载中'),
  error: (error) => Text('错误'),
  data: (data) => Text(data.value.name),
);

// 5. 属性访问
asyncValue.hasValue;    // 是否有数据
asyncValue.hasError;    // 是否出错
asyncValue.isLoading;   // 是否加载中
asyncValue.value;       // 获取数据（可能为 null）
asyncValue.valueOrNull; // 安全获取数据
asyncValue.error;       // 获取错误
asyncValue.stackTrace;  // 获取堆栈
```

### 10.4 AsyncValue.guard

在 `StateNotifier` 或 `AsyncNotifier` 中处理异步操作：

```dart
class UserNotifier extends StateNotifier<AsyncValue<User>> {
  UserNotifier() : super(const AsyncValue.loading());

  Future<void> fetch() async {
    state = const AsyncValue.loading();

    // guard 自动处理成功和失败
    state = await AsyncValue.guard(() async {
      return await api.fetchUser();
    });
  }
}
```

### 10.5 与 Provider AsyncSnapshot 对比

| 维度 | AsyncSnapshot（Provider） | AsyncValue（Riverpod） |
|------|--------------------------|----------------------|
| 状态定义 | 松散（connectionState + data + error） | 严格（loading / error / data） |
| 类型安全 | 弱（data 可能是 null） | 强（data 在 data 状态下一定有值） |
| 代码可读性 | 需要判断 connectionState | when() 方法清晰直观 |
| 强制处理 | 不强制 | when() 强制处理所有状态 |

---

## 11. ProviderScope 局部覆盖

### 11.1 什么是 ProviderScope

`ProviderScope` 是 Riverpod 的根容器，通常在 `main.dart` 中包裹 `MaterialApp`。但它还有一个强大功能：**局部覆盖 Provider 的值**。

### 11.2 全局 ProviderScope

```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 11.3 局部覆盖

```dart
// 全局定义
final greetingProvider = Provider<String>((ref) => 'Hello, World!');

// 在某个页面局部覆盖
class LocalPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      // 覆盖 greetingProvider 的值
      overrides: [
        greetingProvider.overrideWithValue('Hello, Riverpod!'),
      ],
      child: Column(
        children: [
          // 显示 "Hello, Riverpod!"
          Consumer(
            builder: (context, ref, child) {
              return Text(ref.watch(greetingProvider));
            },
          ),
        ],
      ),
    );
  }
}
```

### 11.4 使用场景

**场景 1：测试时覆盖依赖**

```dart
// 测试中使用 Mock
void main() {
  testWidgets('Counter test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(MockApiClient()),
        ],
        child: MyApp(),
      ),
    );
  });
}
```

**场景 2：不同页面使用不同配置**

```dart
// 主题配置
final themeConfigProvider = Provider<ThemeConfig>((ref) => defaultTheme);

// 页面 A 使用默认主题
class PageA extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Body(); // 使用默认主题
  }
}

// 页面 B 使用深色主题
class PageB extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        themeConfigProvider.overrideWithValue(darkTheme),
      ],
      child: Body(),
    );
  }
}
```

**场景 3：路由参数传递**

```dart
// 用户 ID Provider
final currentUserIdProvider = Provider<String>((ref) {
  throw UnimplementedError('需要在页面级别覆盖');
});

// 用户详情页面
class UserDetailPage extends ConsumerWidget {
  final String userId;

  const UserDetailPage({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue(userId),
      ],
      child: UserDetailBody(),
    );
  }
}

// 页面内部任意位置获取 userId
class UserDetailBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    // ...
  }
}
```

> 参考示例：`10_scoped_provider/main.dart`

---

## 12. Refresh / Invalidate

### 12.1 刷新 Provider

Riverpod 提供了多种方式刷新 Provider 的状态：

```dart
// 1. invalidate — 销毁并重建 Provider
ref.invalidate(userProvider);

// 2. refresh — 强制重新执行 Provider 的创建函数
// 返回新的值
final newValue = await ref.refresh(userProvider.future);

// 3. 在 StateNotifier 中手动刷新
class UserNotifier extends StateNotifier<AsyncValue<User>> {
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchUser());
  }
}
```

### 12.2 下拉刷新示例

```dart
class UserListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // 刷新数据，触发重建
        ref.invalidate(userListProvider);
        // 等待新数据加载完成
        await ref.read(userListProvider.future);
      },
      child: usersAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('错误：$err')),
        data: (users) => ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(users[index].name),
          ),
        ),
      ),
    );
  }
}
```

### 12.3 重试机制

```dart
class RetryPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);

    return dataAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Column(
        children: [
          Text('加载失败：$error'),
          ElevatedButton(
            onPressed: () {
              // 点击重试，重新执行 Provider
              ref.invalidate(dataProvider);
            },
            child: Text('重试'),
          ),
        ],
      ),
      data: (data) => Text(data),
    );
  }
}
```

> 参考示例：`11_refresh/main.dart`

---

## 13. 综合实战：Todo 应用

### 13.1 需求分析

实现一个完整的 Todo 应用，包含：
- 添加 / 删除 / 切换完成状态
- 过滤（全部 / 未完成 / 已完成）
- 统计信息（总数 / 已完成数）
- 异步加载初始数据

### 13.2 状态定义

```dart
// Todo 模型
@freezed
class Todo with _$Todo {
  factory Todo({
    required String id,
    required String title,
    required bool isCompleted,
  }) = _Todo;
}

// 过滤条件
enum TodoFilter { all, active, completed }
```

### 13.3 Provider 设计

```dart
// 1. Todo 列表状态（StateNotifier）
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier();
});

// 2. 当前过滤条件（StateProvider）
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// 3. 过滤后的列表（Provider — 纯计算，依赖上面两个 Provider）
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((t) => !t.isCompleted).toList();
    case TodoFilter.completed:
      return todos.where((t) => t.isCompleted).toList();
    case TodoFilter.all:
    default:
      return todos;
  }
});

// 4. 统计信息（Provider — 纯计算）
final todoStatsProvider = Provider<Map<String, int>>((ref) {
  final todos = ref.watch(todoListProvider);
  return {
    'total': todos.length,
    'completed': todos.where((t) => t.isCompleted).length,
    'active': todos.where((t) => !t.isCompleted).length,
  };
});
```

### 13.4 StateNotifier 实现

```dart
class TodoListNotifier extends StateNotifier<List<Todo>> {
  TodoListNotifier() : super([]);

  // 添加 Todo
  void add(String title) {
    state = [
      ...state,
      Todo(
        id: DateTime.now().toIso8601String(),
        title: title,
        isCompleted: false,
      ),
    ];
  }

  // 切换完成状态
  void toggle(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }

  // 删除 Todo
  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  // 从服务器加载
  Future<void> loadFromServer() async {
    final todos = await fetchTodos();
    state = todos;
  }
}
```

### 13.5 UI 实现

```dart
class TodoPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTodos = ref.watch(filteredTodosProvider);
    final stats = ref.watch(todoStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo 列表'),
        actions: [
          // 统计信息
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text('${stats['completed']}/${stats['total']}'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 过滤按钮
          _FilterBar(),
          // Todo 列表
          Expanded(
            child: ListView.builder(
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return _TodoItem(todo: todo);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: Icon(Icons.add),
      ),
    );
  }
}

// 过滤按钮（独立监听，减少重建）
class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(todoFilterProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: TodoFilter.values.map((filter) {
        return FilterChip(
          label: Text(filter.name),
          selected: currentFilter == filter,
          onSelected: (_) {
            ref.read(todoFilterProvider.notifier).state = filter;
          },
        );
      }).toList(),
    );
  }
}

// Todo 条目
class _TodoItem extends ConsumerWidget {
  final Todo todo;

  const _TodoItem({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (_) {
          ref.read(todoListProvider.notifier).toggle(todo.id);
        },
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          ref.read(todoListProvider.notifier).remove(todo.id);
        },
      ),
    );
  }
}
```

### 13.6 架构总结

```
Provider 依赖关系图：

                    ┌─────────────────┐
                    │ todoListProvider │
                    │ (StateNotifier)  │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
   ┌────────────────┐ ┌──────────────┐ ┌──────────────┐
   │ todoFilterProvider│ │ filteredTodos │ │ todoStats    │
   │ (StateProvider)   │ │ (Provider)    │ │ (Provider)   │
   └────────────────┘ └──────────────┘ └──────────────┘
                               │
                               ▼
                         ┌──────────┐
                         │   UI     │
                         └──────────┘
```

> 参考示例：`12_todo/main.dart`

---

## 14. 常见问题与最佳实践

### 14.1 常见错误

#### ❌ 在 build 中调用 read() 获取显示数据

```dart
// 错误：数据变化时不会更新
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.read(counterProvider); // ❌
  return Text('$count');
}

// 正确
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.watch(counterProvider); // ✅
  return Text('$count');
}
```

#### ❌ 在事件回调中使用 watch()

```dart
// 错误：watch 只能在 build 中使用
ElevatedButton(
  onPressed: () {
    final count = ref.watch(counterProvider); // ❌ 运行时错误
  },
)

// 正确
ElevatedButton(
  onPressed: () {
    final count = ref.read(counterProvider); // ✅
  },
)
```

#### ❌ 忘记给 family 参数实现 == 和 hashCode

```dart
// 错误：参数没有实现 == 和 hashCode
class MyFilter {
  final String query;
  MyFilter(this.query); // ❌ 没有实现 == 和 hashCode
}

final provider = Provider.family<List<User>, MyFilter>((ref, filter) {
  return fetchUsers(filter.query);
});

// 正确：使用 freezed 或手动实现
@freezed
class MyFilter with _$MyFilter {
  factory MyFilter({required String query}) = _MyFilter;
}
```

#### ❌ 在 Provider 中直接修改状态

```dart
// 错误：直接修改状态对象
class TodoNotifier extends StateNotifier<List<Todo>> {
  void add(Todo todo) {
    state.add(todo); // ❌ 直接修改，不会触发通知
  }
}

// 正确：创建新对象
class TodoNotifier extends StateNotifier<List<Todo>> {
  void add(Todo todo) {
    state = [...state, todo]; // ✅ 创建新列表
  }
}
```

### 14.2 最佳实践

#### ✅ Provider 命名规范

```dart
// 以 Provider 结尾，使用 final
final counterProvider = StateProvider<int>((ref) => 0);
final userRepositoryProvider = Provider<UserRepository>((ref) => ...);
final todoListProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) => ...);

// 避免
final counter = StateProvider<int>((ref) => 0); // ❌ 不以 Provider 结尾
var counterProvider = StateProvider<int>((ref) => 0); // ❌ 不用 var
```

#### ✅ 状态类使用不可变对象

```dart
// 推荐：使用 freezed 生成不可变类
@freezed
class UserState with _$UserState {
  factory UserState({
    required String name,
    required int age,
    required bool isLoading,
  }) = _UserState;
}

// 或手动实现 copyWith
class UserState {
  final String name;
  final int age;
  final bool isLoading;

  const UserState({
    required this.name,
    required this.age,
    required this.isLoading,
  });

  UserState copyWith({String? name, int? age, bool? isLoading}) {
    return UserState(
      name: name ?? this.name,
      age: age ?? this.age,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
```

#### ✅ 按功能拆分 Provider

```dart
// ✅ 好的做法：每个功能独立 Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) => ...);
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) => ...);
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) => ...);

// ❌ 不好的做法：God Object
final appStateProvider = StateNotifierProvider<AppNotifier, AppState>((ref) => ...);
// AppState 包含用户、购物车、主题等所有状态
```

#### ✅ 使用 select 减少不必要的重建

```dart
// ✅ 好的做法：只监听需要的字段
final username = ref.watch(userProvider.select((u) => u.name));

// ❌ 不好的做法：监听整个对象
final user = ref.watch(userProvider);
final username = user.name; // 其他字段变化也会重建
```

#### ✅ 异步操作使用 AsyncValue.guard

```dart
// ✅ 好的做法：使用 guard 自动处理错误
Future<void> fetchData() async {
  state = const AsyncValue.loading();
  state = await AsyncValue.guard(() => api.fetchData());
}

// ❌ 不好的做法：手动 try-catch
Future<void> fetchData() async {
  state = const AsyncValue.loading();
  try {
    final data = await api.fetchData();
    state = AsyncValue.data(data);
  } catch (e, stack) {
    state = AsyncValue.error(e, stack);
  }
}
```

### 14.3 调试技巧

#### 查看 Provider 状态

```dart
// 在任意位置打印 Provider 信息
debugPrint(ref.read(counterProvider).toString());
```

#### 使用 ProviderObserver 监听变化

```dart
class MyObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('''
Provider: ${provider.name ?? provider.runtimeType}
Previous: $previousValue
New: $newValue
''');
  }
}

void main() {
  runApp(
    ProviderScope(
      observers: [MyObserver()],
      child: MyApp(),
    ),
  );
}
```

---

## 15. 与 Provider 的迁移指南

### 15.1 迁移决策

是否需要从 Provider 迁移到 Riverpod？

| 情况 | 建议 |
|------|------|
| 新项目 | 直接使用 Riverpod |
| 小型项目，Provider 工作良好 | 可以暂不迁移 |
| 遇到 Provider 运行时错误频繁 | 建议迁移 |
| 需要 family / autoDispose 功能 | 必须迁移 |
| 团队已熟悉 Provider | 逐步迁移 |

### 15.2 逐步迁移策略

**阶段 1：新功能用 Riverpod**

```dart
// 现有代码保持 Provider
class OldPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OldState(),
      child: OldBody(),
    );
  }
}

// 新页面使用 Riverpod
class NewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newStateProvider);
    return ...;
  }
}
```

**阶段 2：Provider 包裹 Riverpod**

```dart
// 用 Provider 提供 Riverpod 的 container
class HybridApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiProvider(
        providers: [
          // 旧 Provider
          ChangeNotifierProvider(create: (_) => OldState()),
        ],
        child: MaterialApp(...),
      ),
    );
  }
}
```

**阶段 3：完全迁移**

将所有 Provider 替换为 Riverpod，移除 `provider` 包依赖。

### 15.3 概念映射表

| Provider 概念 | Riverpod 等价概念 |
|--------------|------------------|
| `ChangeNotifierProvider` | `StateNotifierProvider` 或 `AsyncNotifierProvider` |
| `Provider<T>` | `Provider<T>` |
| `FutureProvider<T>` | `FutureProvider<T>` |
| `StreamProvider<T>` | `StreamProvider<T>` |
| `MultiProvider` | 不需要，Provider 全局定义 |
| `ProxyProvider` | `ref.watch()` 依赖其他 Provider |
| `context.watch<T>()` | `ref.watch(provider)` |
| `context.read<T>()` | `ref.read(provider)` |
| `context.select<T, R>()` | `ref.watch(provider.select(...))` |
| `Consumer<T>` | `Consumer` Widget 或 `ConsumerWidget` |
| `Selector<T, R>` | `select` 修饰符 |
| 手动 dispose | `.autoDispose` 修饰符 |
| 无等价 | `.family` 修饰符 |
| 无等价 | `ProviderScope` 局部覆盖 |

### 15.4 代码迁移示例

**Provider 版本：**

```dart
// 状态类
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// Widget 树包裹
ChangeNotifierProvider(
  create: (_) => Counter(),
  child: CounterPage(),
)

// 消费
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>();
    return Scaffold(
      body: Text('${counter.count}'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<Counter>().increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**Riverpod 版本：**

```dart
// 全局定义（不需要 ChangeNotifier）
final counterProvider = StateProvider<int>((ref) => 0);

// main.dart 包裹 ProviderScope
void main() {
  runApp(ProviderScope(child: MyApp()));
}

// 消费
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Scaffold(
      body: Text('$count'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 附录：快速参考卡

### 常用代码片段

```dart
// 定义 Provider
final provider = Provider<T>((ref) => value);
final stateProvider = StateProvider<T>((ref) => initialValue);
final futureProvider = FutureProvider<T>((ref) async => await fetch());
final streamProvider = StreamProvider<T>((ref) => stream);
final notifierProvider = StateNotifierProvider<Notifier, State>((ref) => Notifier());

// 带修饰符
final familyProvider = Provider.family<T, Arg>((ref, arg) => value);
final autoDisposeProvider = Provider.autoDispose<T>((ref) => value);
final combinedProvider = Provider.family.autoDispose<T, Arg>((ref, arg) => value);

// 消费
final value = ref.watch(provider);           // 监听
final value = ref.read(provider);            // 读取一次
final field = ref.watch(provider.select((v) => v.field)); // 监听字段

// 修改 StateProvider
ref.read(provider.notifier).state = newValue;

// 修改 StateNotifierProvider
ref.read(notifierProvider.notifier).method();

// AsyncValue 处理
asyncValue.when(
  loading: () => Text('加载中'),
  error: (err, stack) => Text('错误'),
  data: (value) => Text('$value'),
);

// 刷新
ref.invalidate(provider);
await ref.refresh(provider.future);

// 局部覆盖
ProviderScope(
  overrides: [provider.overrideWithValue(newValue)],
  child: MyWidget(),
);
```

### 错误速查

| 错误信息 | 原因 | 解决 |
|----------|------|------|
| `The argument type '...' can't be assigned` | Provider 类型不匹配 | 检查泛型参数 |
| `Unhandled error` | Provider 中抛出异常 | 使用 try-catch 或 AsyncValue.guard |
| `Provider was disposed` | 访问已销毁的 Provider | 检查 autoDispose 生命周期 |
| `Family argument must implement ==` | family 参数没有实现 == | 使用 freezed 或手动实现 |

---

> 本文档与项目中的 12 个示例代码配合使用，建议按顺序阅读并运行示例：
> 1. `01_hello_riverpod` — 理解核心概念
> 2. `02_providers` — 理解四种 Provider 类型
> 3. `03_state_notifier` — 理解复杂状态管理
> 4. `04_consumer` — 理解消费方式
> 5. `05_family` — 理解参数化 Provider
> 6. `06_auto_dispose` — 理解自动销毁
> 7. `07_dependency` — 理解 Provider 依赖
> 8. `08_optimization` — 理解重建优化
> 9. `09_async_value` — 理解异步状态
> 10. `10_scoped_provider` — 理解局部覆盖
> 11. `11_refresh` — 理解刷新机制
> 12. `12_todo` — 综合实战
