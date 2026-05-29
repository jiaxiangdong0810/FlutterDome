# Bloc 的坑和解决方案

> 本文档记录实际项目中使用 Bloc 时常见的陷阱、错误和解决方案。
> 每个坑都附带：问题现象 → 根因分析 → 解决方案 → 代码示例。

---

## 目录

1. [坑 1：状态不更新（引用相等陷阱）](#坑-1状态不更新引用相等陷阱)
2. [坑 2：Bloc 生命周期错乱](#坑-2bloc-生命周期错乱)
3. [坑 3：UI 不必要的重建](#坑-3ui-不必要的重建)
4. [坑 4：异步竞态条件](#坑-4异步竞态条件)
5. [坑 5：context.read 和 context.watch 混用](#坑-5contextread-和-contextwatch-混用)
6. [坑 6：在 Bloc 中直接操作 UI](#坑-6在-bloc-中直接操作-ui)
7. [坑 7：测试时状态顺序对不上](#坑-7测试时状态顺序对不上)
8. [坑 8：错误的状态拆分](#坑-8错误的状态拆分)
9. [坑 9：忘记关闭 StreamSubscription](#坑-9忘记关闭-streamsubscription)
10. [坑 10：过度使用 Bloc](#坑-10过度使用-bloc)

---

## 坑 1：状态不更新（引用相等陷阱）

### 现象

```dart
// 列表加载更多后，UI 没有变化
final current = state as PostListSuccess;
current.posts.add(newPost);  // 直接修改原列表
emit(PostListSuccess(current.posts));  // UI 不刷新！
```

### 根因

Bloc 内部使用 `==` 判断状态是否变化。如果新旧状态引用同一个对象，`==` 返回 `true`，Bloc 认为状态没变，不会通知 UI 重建。

```dart
// Bloc 内部逻辑（简化）
void emit(State state) {
  if (this.state == state) return;  // 引用相等，直接返回！
  // ...通知 UI
}
```

### 解决方案

**始终创建新的集合/对象**：

```dart
// ✅ 正确：创建新列表
final current = state as PostListSuccess;
emit(PostListSuccess([...current.posts, ...newPosts]));

// ✅ 正确：对象也新建
emit(UserState(
  name: '新名字',
  profile: current.profile.copyWith(avatar: newAvatar),  // copyWith 创建新对象
));
```

### 防御性编程

```dart
// 在 State 类中禁用可变操作
@immutable  // 虽然 Dart 不强制，但加上提醒
class PostListSuccess extends PostListState {
  final List<Post> posts;  // final 防止重新赋值
  // 不提供任何修改 posts 的方法
}
```

---

## 坑 2：Bloc 生命周期错乱

### 现象 1：页面返回后 Bloc 还在发事件

```dart
// 用户快速进入页面又返回
// Bloc 里的异步操作完成后 emit，但页面已经 dispose，导致报错
```

### 根因

`BlocProvider` 默认在 Widget dispose 时关闭 Bloc，但异步操作可能在关闭后才完成。

### 解决方案

**方案 A：使用 `autoClose: false` + 手动管理（不推荐）**

```dart
BlocProvider(
  lazy: false,
  create: (_) => MyBloc(),
  child: ...,
)
// 需要自己在合适时机调用 bloc.close()
```

**方案 B：在 Bloc 中检查 `isClosed`（推荐）**

```dart
Future<void> _onRefreshed(
  PostListRefreshed event,
  Emitter<PostListState> emit,
) async {
  emit(PostListLoading());

  try {
    final posts = await _fetchPosts();

    // 关键：emit 前检查 Bloc 是否已关闭
    if (isClosed) return;

    emit(PostListSuccess(posts));
  } catch (e) {
    if (isClosed) return;
    emit(PostListFailure([], e.toString()));
  }
}
```

**方案 C：使用 `StreamSubscription` 并正确取消**

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  StreamSubscription? _subscription;

  MyBloc() : super(MyInitial()) {
    on<MyStarted>(_onStarted);
  }

  void _onStarted(MyStarted event, Emitter<MyState> emit) {
    _subscription?.cancel();  // 先取消旧的
    _subscription = _repository.stream.listen((data) {
      if (!isClosed) {
        emit(MySuccess(data));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();  // 清理订阅
    return super.close();
  }
}
```

### 现象 2：同一个 Bloc 被多个页面共享，状态互相影响

```dart
// 错误：在 MaterialApp 级别提供，所有页面共享同一个实例
MaterialApp(
  home: BlocProvider(
    create: (_) => PostListBloc(),  // 全局唯一
    child: const HomePage(),
  ),
)

// 页面 A 刷新列表 → 页面 B 的列表也变了
```

### 解决方案

```dart
// ✅ 正确：在需要使用的页面级别提供
GoRoute(
  path: '/posts',
  builder: (context, state) => BlocProvider(
    create: (_) => PostListBloc()..add(PostListRefreshed()),
    child: const PostListPage(),
  ),
)

// 如果需要跨页面共享（如购物车），再考虑提升到上层
```

---

## 坑 3：UI 不必要的重建

### 现象

整个页面在状态变化时全部重建，导致动画卡顿、输入框失焦。

### 根因

在顶层使用 `BlocBuilder`，任何状态变化都重建整个页面。

```dart
// ❌ 错误：整个 Scaffold 重建
@override
Widget build(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('标题')),  // 不需要重建
        body: Column(
          children: [
            const Text('固定文案'),  // 不需要重建
            Text(state.data),  // 只有这里需要重建
          ],
        ),
      );
    },
  );
}
```

### 解决方案

**方案 A：精细化使用 BlocBuilder**

```dart
// ✅ 正确：只在需要的地方用 BlocBuilder
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('标题')),  // 固定，不重建
    body: Column(
      children: [
        const Text('固定文案'),  // 固定，不重建
        BlocBuilder<MyBloc, MyState>(  // 只有这个区域重建
          builder: (context, state) {
            return Text(state.data);
          },
        ),
      ],
    ),
  );
}
```

**方案 B：使用 `buildWhen` 控制重建条件**

```dart
BlocBuilder<PostListBloc, PostListState>(
  buildWhen: (previous, current) {
    // 只有 posts 变化时才重建，loading 状态变化不重建这个组件
    if (previous is PostListSuccess && current is PostListSuccess) {
      return previous.posts != current.posts;
    }
    return true;
  },
  builder: (context, state) {
    return ListView.builder(...);
  },
)
```

**方案 C：使用 `BlocSelector` 只监听部分字段**

```dart
// 只监听 count 字段，其他字段变化不触发重建
BlocSelector<CounterBloc, CounterState, int>(
  selector: (state) => state.count,
  builder: (context, count) {
    return Text('$count');
  },
)
```

**方案 D：使用 `BlocListener` 处理副作用，不重建 UI**

```dart
BlocListener<PostListBloc, PostListState>(
  listener: (context, state) {
    // 显示 SnackBar、导航等副作用
    if (state is PostListFailure) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
  child: BlocBuilder<PostListBloc, PostListState>(
    builder: (context, state) {
      // 纯 UI 构建
      return ListView(...);
    },
  ),
)
```

---

## 坑 4：异步竞态条件

### 现象

用户快速连续下拉刷新，旧请求的结果覆盖了新请求的结果，显示错误数据。

```dart
// 时间线：
// t=0: 用户下拉刷新 → 请求 A 发出（page=1）
// t=1: 用户又下拉刷新 → 请求 B 发出（page=1）
// t=2: 请求 B 返回 → 显示 B 的数据 ✅
// t=3: 请求 A 返回 → 覆盖了 B 的数据 ❌（显示的是旧请求的结果）
```

### 根因

多个并发的异步请求，后发出的请求先返回，先发出的请求后返回，导致状态被旧数据覆盖。

### 解决方案

**方案 A：防重入（简单场景）**

```dart
Future<void> _onRefreshed(
  PostListRefreshed event,
  Emitter<PostListState> emit,
) async {
  if (state is PostListLoading) return;  // 正在加载，忽略新请求
  emit(PostListLoading());
  // ...
}
```

**方案 B：取消旧请求（推荐用于搜索等场景）**

```dart
class PostSearchBloc extends Bloc<PostSearchEvent, PostSearchState> {
  CancelableOperation? _currentOperation;

  Future<void> _onSearched(
    PostSearchSearched event,
    Emitter<PostSearchState> emit,
  ) async {
    // 取消上一次的搜索
    await _currentOperation?.cancel();

    emit(PostSearchLoading());

    _currentOperation = CancelableOperation.fromFuture(
      _repository.search(event.keyword),
    );

    try {
      final results = await _currentOperation!.value;
      emit(PostSearchSuccess(results));
    } catch (e) {
      if (e is CancelledException) return;  // 被取消的请求，忽略
      emit(PostSearchFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _currentOperation?.cancel();
    return super.close();
  }
}
```

**方案 C：使用 `switchMap` 模式（Stream 场景）**

```dart
// 使用 rxdart 的 switchMap，自动取消旧 Stream
_repository.searchStream(keyword)
  .switchMap((results) => Stream.value(PostSearchSuccess(results)))
  .listen((state) => emit(state));
```

---

## 坑 5：context.read 和 context.watch 混用

### 现象

在 `build` 方法中使用 `context.read<Bloc>()` 期望 UI 随状态变化重建，但 UI 不更新。

```dart
// ❌ 错误：在 build 中用 read，UI 不会重建
@override
Widget build(BuildContext context) {
  final state = context.read<MyBloc>().state;  // 只读一次，不监听
  return Text(state.data);  // 状态变了也不重建
}
```

### 根因

| 方法 | 作用 | 使用场景 |
|------|------|----------|
| `context.read<T>()` | 获取实例，**不监听** | 在回调中发送事件 |
| `context.watch<T>()` | 获取实例，**监听变化** | 在 build 方法中 |
| `context.select<T, R>()` | 监听部分字段 | 只需要部分数据时 |

### 解决方案

```dart
// ✅ 正确：build 中用 watch 或 BlocBuilder
@override
Widget build(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) {
      return Text(state.data);  // 状态变化自动重建
    },
  );
}

// ✅ 正确：回调中用 read
ElevatedButton(
  onPressed: () {
    // 在事件回调中，用 read 获取 bloc 发送事件
    context.read<MyBloc>().add(MyEvent());
  },
  child: const Text('点击'),
)
```

### 记忆口诀

> **build 里用 watch，回调里用 read。**

---

## 坑 6：在 Bloc 中直接操作 UI

### 现象

在 Bloc 中调用 `showDialog`、`Navigator.push`、`ScaffoldMessenger` 等 UI 操作。

```dart
// ❌ 绝对禁止
class MyBloc extends Bloc<MyEvent, MyState> {
  final BuildContext context;  // 更不能持有 Context！

  Future<void> _onEvent(event, emit) async {
    final result = await doSomething();
    if (result) {
      showDialog(context: context, ...);  // 在 Bloc 中弹对话框！
    }
  }
}
```

### 根因

- Bloc 是业务逻辑层，不应该依赖 UI 层
- 持有 `BuildContext` 会导致内存泄漏
- UI 操作应该在 UI 层处理

### 解决方案

**使用 `BlocListener` 处理副作用**：

```dart
// Bloc 只发状态
class MyBloc extends Bloc<MyEvent, MyState> {
  Future<void> _onEvent(event, emit) async {
    final result = await doSomething();
    if (result) {
      emit(MyShowDialogNeeded());  // 发状态，不操作 UI
    }
  }
}

// UI 层监听并处理
BlocListener<MyBloc, MyState>(
  listener: (context, state) {
    if (state is MyShowDialogNeeded) {
      showDialog(context: context, ...);  // UI 操作在 UI 层
    }
    if (state is MyNavigateNeeded) {
      context.push('/target');
    }
  },
  child: ...,
)
```

---

## 坑 7：测试时状态顺序对不上

### 现象

```dart
blocTest<MyBloc, MyState>(
  'should emit [Loading, Success]',
  build: () => myBloc,
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [
    MyLoading(),
    MySuccess(),
  ],
);
// 报错：Expected [Loading, Success] but got [Loading]
```

### 根因

1. **初始状态不计入 expect**：`expect` 只包含 `act` 之后 emit 的状态
2. **状态相等性**：自定义 State 没有实现 `==` 和 `hashCode`
3. **异步问题**：异步操作未完成测试就结束了

### 解决方案

**问题 1：理解 expect 的范围**

```dart
blocTest<MyBloc, MyState>(
  'emits [Loading, Success]',
  build: () => MyBloc(),  // 初始状态是 MyInitial()
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [
    MyLoading(),    // act 后第一个 emit
    MySuccess(),    // act 后第二个 emit
  ],
  // 注意：MyInitial() 不在 expect 中！
);
```

**问题 2：使用 `isA<T>()` 或实现 `==`**

```dart
// 方案 A：用 isA 匹配类型（推荐）
expect: () => [
  isA<MyLoading>(),
  isA<MySuccess>(),
],

// 方案 B：用 predicate 匹配字段
expect: () => [
  isA<MySuccess>().having((s) => s.data, 'data', equals(expectedData)),
],

// 方案 C：用 freezed 自动生成 ==
@freezed
class MyState with _$MyState { ... }
```

**问题 3：等待异步完成**

```dart
blocTest<MyBloc, MyState>(
  'async test',
  build: () => myBloc,
  act: (bloc) => bloc.add(MyEvent()),
  wait: const Duration(seconds: 1),  // 等待异步完成
  expect: () => [MySuccess()],
);
```

---

## 坑 8：错误的状态拆分

### 现象 A：万能状态（一个状态类走天下）

```dart
// ❌ 错误：所有场景用一个状态
class PostListState {
  final bool isLoading;
  final bool isError;
  final List<Post> posts;
  final String? errorMessage;

  PostListState({
    this.isLoading = false,
    this.isError = false,
    this.posts = const [],
    this.errorMessage,
  });
}

// 问题：
// 1. isLoading=true 且 isError=true 同时出现怎么办？
// 2. UI 代码里一堆 if-else 判断
// 3. 无法做 exhaustive switch 检查
```

### 现象 B：过度拆分（每个字段一个状态）

```dart
// ❌ 错误：过度拆分
class PostsLoaded extends PostListState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}
class HasReachedMax extends PostListState {}  // 单独一个状态？
class IsRefreshing extends PostListState {}   // 和 Loading 什么区别？

// 问题：状态之间关系混乱，无法表达"加载更多时保留已有数据"
```

### 解决方案

```dart
// ✅ 正确：按 UI 场景拆分，数据按需携带
sealed class PostListState {}

final class PostListInitial extends PostListState {}
final class PostListLoading extends PostListState {}           // 首次加载
final class PostListEmpty extends PostListState {}             // 空数据
final class PostListSuccess extends PostListState {            // 有数据
  final List<Post> posts;
  final bool hasReachedMax;                                    // 携带标记
  PostListSuccess(this.posts, {this.hasReachedMax = false});
}
final class PostListLoadingMore extends PostListState {         // 加载更多中
  final List<Post> posts;                                      // 保留已有数据
  PostListLoadingMore(this.posts);
}
final class PostListFailure extends PostListState {             // 失败（保留数据）
  final List<Post> posts;
  final String message;
  PostListFailure(this.posts, this.message);
}
```

### 状态设计原则

- 一个状态 = 一个 UI 场景
- 状态名应该让 UI 层一眼知道该渲染什么
- 用 `sealed class` 让编译器帮你检查遗漏

---

## 坑 9：忘记关闭 StreamSubscription

### 现象

页面反复进入退出后，内存占用越来越高，最终 OOM。

### 根因

Bloc 中订阅了 Stream（如 WebSocket、Firebase、数据库监听），但在 Bloc 关闭时没有取消订阅。

```dart
// ❌ 错误：只订阅不取消
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    _messageStream.listen((msg) {  // 订阅了但 never cancel
      add(MessageReceived(msg));
    });
  }
}
```

### 解决方案

```dart
// ✅ 正确：在 close 中取消订阅
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  StreamSubscription? _messageSubscription;

  ChatBloc() : super(ChatInitial()) {
    _messageSubscription = _messageStream.listen((msg) {
      if (!isClosed) {
        add(MessageReceived(msg));
      }
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();  // 必须取消！
    return super.close();
  }
}
```

---

## 坑 10：过度使用 Bloc

### 现象

项目中每个按钮、每个输入框都有一个独立的 Bloc，代码量爆炸，开发效率低下。

```dart
// ❌ 过度设计
class LikeButtonBloc extends Bloc<LikeEvent, LikeState> {}
class ShareButtonBloc extends Bloc<ShareEvent, ShareState> {}
class CommentInputBloc extends Bloc<CommentEvent, CommentState> {}
class FollowButtonBloc extends Bloc<FollowEvent, FollowState> {}
// ... 一个页面 10 个 Bloc
```

### 根因

把 Bloc 当成唯一的 state management 方案，忽略了 Flutter 内置的状态管理方式。

### 决策树：什么时候用什么？

```
状态是否跨多个 Widget 共享？
  ├─ 否 → 用 StatefulWidget + setState
  │        └─ 表单验证？→ 考虑 Form + TextEditingController
  └─ 是 → 状态是否跨页面共享？
           ├─ 否 → 用 Bloc（页面级）
           └─ 是 → 用 Bloc（全局）或 Riverpod

是否只是简单的 UI 状态（如动画、展开/收起）？
  └─ 是 → 用 StatefulWidget，不需要 Bloc

是否需要响应式地监听数据变化（如数据库、WebSocket）？
  └─ 是 → 用 StreamBuilder + Repository
```

### 不同场景的状态管理方案

| 场景 | 推荐方案 | 理由 |
|------|----------|------|
| 页面内计数器 | `StatefulWidget` | 简单，不需要 Bloc |
| 页面内表单 | `TextEditingController` + `Form` | Flutter 原生支持 |
| 列表页（刷新/加载更多） | `Bloc` | 状态复杂，需要状态机 |
| 用户登录状态 | `Bloc`（全局） | 跨页面共享，影响路由 |
| 主题/语言切换 | `Bloc` 或 `ChangeNotifier` | 全局共享 |
| 简单的父子组件通信 | `ValueNotifier` + `ValueListenableBuilder` | 轻量 |
| 数据库监听 | `StreamBuilder` | 直接消费 Stream |

### 原则

> **Bloc 是工具，不是信仰。用对的工具做对应的事。**

---

## 总结：避坑 checklist

**编码时自查**：

- [ ] 修改状态前，确认创建了新的对象/集合（`[...old, new]`）
- [ ] 异步操作后 emit 前，检查 `isClosed`
- [ ] Bloc 中不持有 `BuildContext`，不调用 UI 操作
- [ ] `build` 方法中用 `watch`/`BlocBuilder`，回调中用 `read`
- [ ] 有 `StreamSubscription` 就有对应的 `cancel`
- [ ] 状态设计覆盖所有 UI 场景，不用"万能状态"

**Code Review 时重点检查**：

- [ ] 是否有直接修改状态的可变操作？
- [ ] Bloc 的生命周期是否正确？
- [ ] UI 重建范围是否过大？
- [ ] 异步操作是否有竞态处理？
- [ ] 是否过度使用 Bloc（简单场景用 StatefulWidget 即可）？

---

> 坑是踩出来的，规范是总结出来的。遇到新问题，补充到本文档。
