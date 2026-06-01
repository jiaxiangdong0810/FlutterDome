# Bloc 框架级项目设计规范

> 本文档面向团队，定义在项目中如何一致、高效地使用 Bloc 状态管理框架。
> 目标：降低认知成本，减少重复决策，提升代码可维护性。

---

## 1. 目录结构规范

### 1.1 推荐结构（按功能模块划分）

```
lib/
├── main.dart
├── app.dart                    # MaterialApp / 全局配置
├── router.dart                 # 路由配置（推荐 go_router）
├── core/                       # 全局共享的基础设施
│   ├── bloc/                   # 全局 Bloc 相关（如 AppBlocObserver）
│   ├── constants/              # 常量定义
│   ├── exceptions/             # 自定义异常
│   ├── extensions/             # Dart 扩展方法
│   ├── theme/                  # 主题配置
│   └── utils/                  # 工具函数
├── data/                       # 数据层
│   ├── models/                 # 数据模型（DTO / Entity）
│   ├── repositories/           # 仓库接口 + 实现
│   └── datasources/            # 数据源（本地 / 远程）
├── features/                   # 按功能模块划分（核心原则）
│   └── posts/                  # 帖子模块示例
│       ├── bloc/               # 该模块的 Bloc
│       │   ├── post_list_bloc.dart
│       │   ├── post_list_event.dart
│       │   └── post_list_state.dart
│       ├── views/              # 页面
│       │   ├── post_list_page.dart
│       │   └── post_detail_page.dart
│       ├── widgets/            # 模块内共享的组件
│       │   └── post_card.dart
│       └── posts_feature.dart  # 模块导出文件（可选）
└── pages/                      # 简单页面 / 演示页面（学习项目适用）
    └── bloc_basics/
        ├── main.dart
        └── counter_bloc.dart
```

### 1.2 为什么按功能模块划分？

| 维度 | 按功能模块 (`features/`) | 按技术层次 (`bloc/`, `ui/`, `data/`)
|------|--------------------------|--------------------------------------|
| 新增功能 | 在一个文件夹内完成所有改动 | 需要在多个文件夹间跳转 |
| 代码复用 | 模块自包含，可整体迁移 | 容易耦合全局代码 |
| 团队协作 | 不同模块并行开发，减少冲突 | 多人同时改 `bloc/` 目录 |
| 可维护性 | 删除一个模块 = 删除一个文件夹 | 需要跨目录清理残留 |

**结论**：生产项目使用 `features/` 按模块划分；学习/演示项目可用 `pages/` 简化。

---

## 2. 命名约定

### 2.1 文件命名

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| Bloc | `{feature}_{action}_bloc.dart` | `post_list_bloc.dart` |
| Event | `{feature}_{action}_event.dart` | `post_list_event.dart` |
| State | `{feature}_{action}_state.dart` | `post_list_state.dart` |
| Page | `{feature}_{action}_page.dart` | `post_list_page.dart` |
| Widget | `{feature}_{description}.dart` | `post_card.dart` |

> 如果 Bloc 较小（<150行），允许合并为单个文件：`{feature}_bloc.dart` 内包含 State、Event、Bloc 三部分。

### 2.2 类命名

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| Bloc | `{Feature}{Action}Bloc` | `PostListBloc` |
| Event 基类 | `{Feature}{Action}Event` | `PostListEvent` |
| State 基类 | `{Feature}{Action}State` | `PostListState` |
| 具体 Event | `{Verb}{Noun}` 或 `{Action}{Detail}` | `PostListRefreshed`, `PostListLoadMore` |
| 具体 State | `{Noun}{Adjective}` | `PostListLoading`, `PostListSuccess` |

### 2.3 事件命名规范（重点）

事件名要体现**用户意图**，而非**技术动作**：

```dart
// ✅ 好：描述用户做了什么
final class PostListRefreshed extends PostListEvent {}      // 用户下拉刷新
final class PostListLoadMore extends PostListEvent {}       // 用户滚动到底部
final class PostListRetried extends PostListEvent {}        // 用户点击重试
final class PostDetailLiked extends PostDetailEvent {}      // 用户点赞

// ❌ 坏：描述技术实现
final class FetchPostList extends PostListEvent {}         // 太技术化
final class LoadNextPage extends PostListEvent {}          // 不够意图化
final class ApiRequestFailed extends PostListEvent {}      // 这是结果，不是意图
```

### 2.4 状态命名规范

状态名要体现**UI 应该呈现什么**：

```dart
// ✅ 好：UI 可以直接映射
final class PostListLoading extends PostListState {}        // 显示全屏 loading
final class PostListSuccess extends PostListState {}        // 显示列表数据
final class PostListEmpty extends PostListState {}          // 显示空页面
final class PostListFailure extends PostListState {}        // 显示错误提示

// ❌ 坏：模糊或技术化
final class PostListLoadingData extends PostListState {}    // 冗余
final class PostListApiError extends PostListState {}       // 太具体，UI 不关心是 API 错误
```

---

## 3. 状态设计原则

### 3.1 什么时候用 `sealed class`？

**推荐：绝大多数场景使用 `sealed class`**

```dart
sealed class PostListState {}

final class PostListInitial extends PostListState {}
final class PostListLoading extends PostListState {}
final class PostListSuccess extends PostListState {
  final List<Post> posts;
  final bool hasReachedMax;
  PostListSuccess(this.posts, {this.hasReachedMax = false});
}
final class PostListFailure extends PostListState {
  final List<Post> posts;  // 携带已有数据，失败不丢数据
  final String message;
  PostListFailure(this.posts, this.message);
}
```

**优点**：
- Dart 3 原生支持，无需额外依赖
- 编译器可检查 exhaustive switch（穷尽匹配）
- 无运行时开销

### 3.2 什么时候用 `freezed`？

**仅在以下情况考虑**：

1. **需要不可变数据 + copyWith**：
```dart
@freezed
class PostListState with _$PostListState {
  const factory PostListState.initial() = _Initial;
  const factory PostListState.loading() = _Loading;
  const factory PostListState.success({
    required List<Post> posts,
    @Default(false) bool hasReachedMax,
  }) = _Success;
}
```

2. **需要自动实现 `==` 和 `hashCode`**（用于 Bloc 的 `emit` 去重）

3. **状态需要频繁 copyWith（如表单状态）**：
```dart
// 表单场景：每次修改一个字段都需要 copyWith
@freezed
class LoginFormState with _$LoginFormState {
  const factory LoginFormState({
    @Default('') String username,
    @Default('') String password,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _LoginFormState;
}
```

**决策树**：

```
状态是否包含多个可变字段？
  ├─ 是（如表单）→ 考虑 freezed
  └─ 否（如列表的离散状态）→ 用 sealed class

是否需要 copyWith 频繁更新部分字段？
  ├─ 是 → 考虑 freezed
  └─ 否 → 用 sealed class

团队是否熟悉 code generation？
  ├─ 是 → freezed 可用
  └─ 否 → 用 sealed class（零学习成本）
```

**本项目建议**：先掌握 `sealed class`，需要时再引入 `freezed`。

### 3.3 状态设计 checklist

- [ ] 是否覆盖了所有 UI 场景？（loading / success / empty / error / loadingMore）
- [ ] Failure 状态是否携带了已有数据？（加载更多失败时不应清空列表）
- [ ] 状态是否不可变？（所有字段用 `final`，State 类用 `final class`）
- [ ] 是否避免了"万能状态"？（不要用 `isLoading` + `isError` + `data` 的组合状态）

---

## 4. Bloc 拆分粒度

### 4.1 原则：一个 Bloc 管理一个**用户交互单元**

| 场景 | 粒度 | 说明 |
|------|------|------|
| 帖子列表页 | 1 个 `PostListBloc` | 列表的刷新、加载更多、重试 |
| 帖子详情页 | 1 个 `PostDetailBloc` | 详情加载、点赞、评论 |
| 全局主题切换 | 1 个 `ThemeBloc` | 全局共享，放最顶层 |
| 用户登录状态 | 1 个 `AuthBloc` | 全局共享，决定路由守卫 |

### 4.2 不要过度拆分

```dart
// ❌ 过度拆分：一个按钮一个 Bloc
class LikeButtonBloc extends Bloc<LikeEvent, LikeState> {}
class ShareButtonBloc extends Bloc<ShareEvent, ShareState> {}

// ✅ 合理拆分：一个页面一个 Bloc
class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  // 处理点赞、分享、收藏等所有交互
}
```

### 4.3 也不要一个 Bloc 管太多

```dart
// ❌ 过于庞大：一个 Bloc 管整个 App
class AppBloc extends Bloc<AppEvent, AppState> {
  // 同时处理：用户登录、帖子列表、消息通知、主题切换...
  // 文件会膨胀到 500+ 行，难以维护
}

// ✅ 合理拆分：按功能域分离
class AuthBloc extends Bloc<AuthEvent, AuthState> {}       // 认证域
class PostListBloc extends Bloc<PostListEvent, PostListState> {}  // 帖子域
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {}  // 通知域
```

### 4.4 跨页面共享状态

**场景**：用户详情页点赞后，回到列表页，列表的点赞数也要更新。

**方案对比**：

| 方案 | 实现 | 适用 |
|------|------|------|
| 全局 Bloc | `AuthBloc` / `UserBloc` 放最顶层 | 用户状态、全局配置 |
| Repository 模式 | 数据层统一，UI 各自订阅 | 列表 ↔ 详情的数据同步 |
| 页面返回刷新 | `Navigator.pop(result)` 触发刷新 | 简单的单向同步 |

**推荐**：优先用 Repository 模式保证数据一致性，必要时配合全局 Bloc。

---

## 5. 团队使用模板

### 5.1 最小 Bloc 模板（sealed class 版）

```dart
// ============ state ============
sealed class CounterState {}

final class CounterInitial extends CounterState {}
final class CounterLoading extends CounterState {}
final class CounterSuccess extends CounterState {
  final int count;
  CounterSuccess(this.count);
}
final class CounterFailure extends CounterState {
  final String message;
  CounterFailure(this.message);
}

// ============ event ============
sealed class CounterEvent {}

final class CounterIncrement extends CounterEvent {}
final class CounterDecrement extends CounterEvent {}
final class CounterReset extends CounterEvent {}

// ============ bloc ============
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<CounterIncrement>(_onIncrement);
    on<CounterDecrement>(_onDecrement);
    on<CounterReset>(_onReset);
  }

  Future<void> _onIncrement(
    CounterIncrement event,
    Emitter<CounterState> emit,
  ) async {
    // 实现...
  }

  // ...其他 handler
}
```

### 5.2 列表 Bloc 模板（带分页）

```dart
sealed class PostListState {}

final class PostListInitial extends PostListState {}
final class PostListLoading extends PostListState {}
final class PostListEmpty extends PostListState {}
final class PostListSuccess extends PostListState {
  final List<Post> posts;
  final bool hasReachedMax;
  PostListSuccess(this.posts, {this.hasReachedMax = false});
}
final class PostListLoadingMore extends PostListState {
  final List<Post> posts;
  PostListLoadingMore(this.posts);
}
final class PostListFailure extends PostListState {
  final List<Post> posts;
  final String message;
  PostListFailure(this.posts, this.message);
}

sealed class PostListEvent {}

final class PostListRefreshed extends PostListEvent {}
final class PostListLoadMore extends PostListEvent {}
final class PostListRetried extends PostListEvent {}

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  static const int _pageSize = 10;
  int _currentPage = 1;

  PostListBloc() : super(PostListInitial()) {
    on<PostListRefreshed>(_onRefreshed);
    on<PostListLoadMore>(_onLoadMore);
    on<PostListRetried>(_onRetried);
  }

  Future<void> _onRefreshed(
    PostListRefreshed event,
    Emitter<PostListState> emit,
  ) async {
    if (state is PostListLoading) return;
    emit(PostListLoading());
    _currentPage = 1;
    try {
      final posts = await _fetchPosts(_currentPage, _pageSize);
      if (posts.isEmpty) {
        emit(PostListEmpty());
      } else {
        emit(PostListSuccess(posts, hasReachedMax: posts.length < _pageSize));
      }
    } catch (e) {
      emit(PostListFailure([], e.toString()));
    }
  }

  Future<void> _onLoadMore(
    PostListLoadMore event,
    Emitter<PostListState> emit,
  ) async {
    if (state is PostListLoadingMore) return;
    if (state is! PostListSuccess) return;
    final current = state as PostListSuccess;
    if (current.hasReachedMax) return;

    emit(PostListLoadingMore(current.posts));
    _currentPage++;
    try {
      final newPosts = await _fetchPosts(_currentPage, _pageSize);
      emit(PostListSuccess(
        [...current.posts, ...newPosts],
        hasReachedMax: newPosts.length < _pageSize,
      ));
    } catch (e) {
      emit(PostListFailure(current.posts, e.toString()));
    }
  }

  Future<void> _onRetried(
    PostListRetried event,
    Emitter<PostListState> emit,
  ) async {
    if (state is PostListFailure) {
      final failure = state as PostListFailure;
      if (failure.posts.isEmpty) {
        add(PostListRefreshed());
      } else {
        add(PostListLoadMore());
      }
    }
  }

  Future<List<Post>> _fetchPosts(int page, int limit) async {
    // 调用 Repository
    throw UnimplementedError();
  }
}
```

### 5.3 VS Code 代码片段配置

在 `.vscode/bloc.code-snippets` 中创建：

```json
{
  "Bloc State": {
    "prefix": "blocstate",
    "description": "Create sealed class state",
    "body": [
      "sealed class ${1:Feature}State {}",
      "",
      "final class ${1:Feature}Initial extends ${1:Feature}State {}",
      "final class ${1:Feature}Loading extends ${1:Feature}State {}",
      "final class ${1:Feature}Success extends ${1:Feature}State {",
      "  final ${2:dynamic} data;",
      "  ${1:Feature}Success(this.data);",
      "}",
      "final class ${1:Feature}Failure extends ${1:Feature}State {",
      "  final String message;",
      "  ${1:Feature}Failure(this.message);",
      "}"
    ]
  },
  "Bloc Event": {
    "prefix": "blocevent",
    "description": "Create sealed class event",
    "body": [
      "sealed class ${1:Feature}Event {}",
      "",
      "final class ${1:Feature}Started extends ${1:Feature}Event {}",
      "final class ${1:Feature}Refreshed extends ${1:Feature}Event {}",
      "final class ${1:Feature}Retried extends ${1:Feature}Event {}"
    ]
  },
  "Bloc Class": {
    "prefix": "blocclass",
    "description": "Create Bloc class",
    "body": [
      "class ${1:Feature}Bloc extends Bloc<${1:Feature}Event, ${1:Feature}State> {",
      "  ${1:Feature}Bloc() : super(${1:Feature}Initial()) {",
      "    on<${1:Feature}Started>(_onStarted);",
      "    on<${1:Feature}Refreshed>(_onRefreshed);",
      "    on<${1:Feature}Retried>(_onRetried);",
      "  }",
      "",
      "  Future<void> _onStarted(",
      "    ${1:Feature}Started event,",
      "    Emitter<${1:Feature}State> emit,",
      "  ) async {",
      "    // TODO: implement",
      "  }",
      "",
      "  Future<void> _onRefreshed(",
      "    ${1:Feature}Refreshed event,",
      "    Emitter<${1:Feature}State> emit,",
      "  ) async {",
      "    // TODO: implement",
      "  }",
      "",
      "  Future<void> _onRetried(",
      "    ${1:Feature}Retried event,",
      "    Emitter<${1:Feature}State> emit,",
      "  ) async {",
      "    // TODO: implement",
      "  }",
      "}"
    ]
  }
}
```

---

## 6. 与 Repository 层的交互规范

### 6.1 分层职责

```
UI Layer (Page/Widget)
    ↓ 发送 Event
Bloc Layer (Business Logic)
    ↓ 调用
Repository Layer (Abstract Data Access)
    ↓ 调用
DataSource Layer (Remote API / Local DB)
```

### 6.2 Bloc 不直接调用 API

```dart
// ❌ 错误：Bloc 直接依赖 Dio
class PostListBloc extends Bloc<PostListEvent, PostListState> {
  Future<List<Post>> _fetchPosts(int page, int limit) async {
    final response = await Dio().get('/api/posts');  // 不要这样做
    return response.data.map(...);
  }
}

// ✅ 正确：Bloc 依赖 Repository 抽象
class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostRepository _postRepository;

  PostListBloc(this._postRepository) : super(PostListInitial()) {
    // ...
  }

  Future<void> _onRefreshed(
    PostListRefreshed event,
    Emitter<PostListState> emit,
  ) async {
    emit(PostListLoading());
    try {
      final posts = await _postRepository.getPosts(page: 1, limit: 10);
      emit(PostListSuccess(posts));
    } catch (e) {
      emit(PostListFailure([], e.toString()));
    }
  }
}
```

### 6.3 Repository 接口定义

```dart
// data/repositories/post_repository.dart
abstract class PostRepository {
  Future<List<Post>> getPosts({required int page, required int limit});
  Future<Post> getPostDetail(int id);
  Future<void> likePost(int id);
}

// data/repositories/post_repository_impl.dart
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;

  PostRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Post>> getPosts({required int page, required int limit}) async {
    return _remoteDataSource.fetchPosts(page: page, limit: limit);
  }

  // ...
}
```

### 6.4 依赖注入

使用 `get_it` + `injectable` 或手动注入：

```dart
// main.dart
void main() {
  // 手动注入示例
  final postRepository = PostRepositoryImpl(PostRemoteDataSource());

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: postRepository),
      ],
      child: const MyApp(),
    ),
  );
}

// page.dart
BlocProvider(
  create: (context) => PostListBloc(
    context.read<PostRepository>(),  // 从上层获取
  )..add(PostListRefreshed()),
  child: const PostListPage(),
)
```

---

## 7. 测试规范

### 7.1 测试金字塔

```
      /\
     /  \      Widget 测试（少量）
    /____\     —— 验证页面渲染和交互
   /      \    
  /        \   Bloc 测试（重点）
 /          \  —— 验证状态转换逻辑
/____________\ Unit 测试（基础）
               —— 验证工具函数、模型
```

### 7.2 Bloc 测试（使用 `bloc_test`）

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late PostRepository postRepository;
  late PostListBloc postListBloc;

  setUp(() {
    postRepository = MockPostRepository();
    postListBloc = PostListBloc(postRepository);
  });

  tearDown(() => postListBloc.close());

  group('PostListBloc', () {
    blocTest<PostListBloc, PostListState>(
      'emits [Loading, Success] when refreshed successfully',
      build: () => postListBloc,
      act: (bloc) => bloc.add(PostListRefreshed()),
      setUp: () {
        when(() => postRepository.getPosts(page: 1, limit: 10))
            .thenAnswer((_) async => [Post(id: 1, title: 'Test')]);
      },
      expect: () => [
        isA<PostListLoading>(),
        isA<PostListSuccess>(),
      ],
    );

    blocTest<PostListBloc, PostListState>(
      'emits [Loading, Empty] when no posts returned',
      build: () => postListBloc,
      act: (bloc) => bloc.add(PostListRefreshed()),
      setUp: () {
        when(() => postRepository.getPosts(page: 1, limit: 10))
            .thenAnswer((_) async => []);
      },
      expect: () => [
        isA<PostListLoading>(),
        isA<PostListEmpty>(),
      ],
    );

    blocTest<PostListBloc, PostListState>(
      'emits [Loading, Failure] when repository throws',
      build: () => postListBloc,
      act: (bloc) => bloc.add(PostListRefreshed()),
      setUp: () {
        when(() => postRepository.getPosts(page: 1, limit: 10))
            .thenThrow(Exception('network error'));
      },
      expect: () => [
        isA<PostListLoading>(),
        isA<PostListFailure>(),
      ],
    );
  });
}
```

### 7.3 测试 checklist

- [ ] 每个 Event Handler 至少一个测试
- [ ] 成功路径测试
- [ ] 失败路径测试
- [ ] 边界条件测试（空数据、最后一页）
- [ ] 防重入逻辑测试（重复触发是否被忽略）

---

## 8. 常见反模式（提前避坑）

### 8.1 在 Bloc 中持有 BuildContext

```dart
// ❌ 绝对禁止
class MyBloc extends Bloc<MyEvent, MyState> {
  final BuildContext context;  // 不要这样做！

  MyBloc(this.context) : super(MyInitial());
}
```

### 8.2 在 Event 中传递 Widget

```dart
// ❌ 禁止
final class ShowDialogEvent extends MyEvent {
  final Widget dialog;  // Event 只传数据，不传 UI
  ShowDialogEvent(this.dialog);
}

// ✅ 正确
final class UserDeleted extends MyEvent {
  final int userId;  // 只传数据
  UserDeleted(this.userId);
}
// UI 层监听 UserDeleted，决定弹不弹对话框
```

### 8.3 直接修改 State 中的列表

```dart
// ❌ 禁止：直接修改
final posts = (state as PostListSuccess).posts;
posts.add(newPost);  // 修改了原状态！
emit(PostListSuccess(posts));

// ✅ 正确：创建新列表
final current = state as PostListSuccess;
emit(PostListSuccess([...current.posts, newPost]));
```

### 8.4 在 `emit` 后访问 `state`

```dart
// ❌ 危险：emit 后 state 已改变，但这里可能拿到旧值
emit(NewState());
print(state);  // 可能还是旧状态

// ✅ 正确：emit 前准备好所有数据
final newData = computeNewData();
emit(NewState(newData));
```

---

## 9. 总结：团队快速上手 checklist

**新建功能时**：

1. [ ] 在 `features/{模块}/bloc/` 下创建文件
2. [ ] 使用 `sealed class` 定义 State 和 Event
3. [ ] Bloc 只依赖 Repository 接口，不直接调 API
4. [ ] UI 层用 `BlocProvider` 提供，`BlocBuilder` / `BlocListener` 消费
5. [ ] 为每个 Event Handler 写 `bloc_test`

**Code Review 时检查**：

1. [ ] State 是否覆盖了所有 UI 场景？
2. [ ] Failure 状态是否携带了已有数据？
3. [ ] 是否做了防重入处理？
4. [ ] 是否有直接修改状态的可变操作？
5. [ ] Bloc 是否耦合了 UI 层（Context / Widget）？

---

> 规范是活的，不是死的。遇到本文档未覆盖的场景，团队讨论后更新本文档。
