# Bloc 实战：复杂列表场景

## 场景描述

这是一个**贴合实际工作**的复杂场景：

> 一个帖子列表页面，支持下拉刷新、上拉加载更多、空数据提示、网络错误重试。

这个场景在几乎所有 App 中都会遇到，用 Bloc 实现能体现其真正的价值。

---

## 状态机设计

列表页面有 7 种状态，构成一个完整的状态机：

```
                    ┌─────────────┐
         ┌─────────▶│   Initial   │◀────────┐
         │          │  (初始状态)  │         │
         │          └──────┬──────┘         │
         │                 │ refresh        │
         │                 ▼                │
         │          ┌─────────────┐         │
         │          │   Loading   │         │
         │          │  (首次加载)  │         │
         │          └──────┬──────┘         │
         │            success/failure       │
         │                 │                │
         │       ┌─────────┴─────────┐      │
         │       ▼                   ▼      │
         │  ┌─────────┐         ┌─────────┐ │
         │  │ Success │         │ Failure │ │
         │  │(有数据) │         │(有数据) │ │
         │  └────┬────┘         └────┬────┘ │
         │       │                   │      │
         │  loadMore/refresh    retry/refresh
         │       │                   │      │
         │       ▼                   ▼      │
         │  ┌─────────────┐   ┌─────────────┐
         │  │ LoadingMore │   │   Empty     │
         │  │ (加载更多中) │   │  (无数据)   │
         │  └──────┬──────┘   └─────────────┘
         │    success/failure
         │         │
         │    ┌────┴────┐
         └───│ 回到对应 │
            │ 状态     │
            └─────────┘
```

### 状态定义

```dart
sealed class PostListState {}

// 初始状态
final class PostListInitial extends PostListState {}

// 首次加载中
final class PostListLoading extends PostListState {}

// 加载成功：有数据
final class PostListSuccess extends PostListState {
  final List<Post> posts;
  final bool hasReachedMax;  // 是否已加载完所有数据
  PostListSuccess(this.posts, {this.hasReachedMax = false});
}

// 加载失败：有数据（用于加载更多失败时保留已有数据）
final class PostListFailure extends PostListState {
  final List<Post> posts;
  final String message;
  PostListFailure(this.posts, this.message);
}

// 加载更多中（从 Success 状态进入）
final class PostListLoadingMore extends PostListState {
  final List<Post> posts;
  PostListLoadingMore(this.posts);
}

// 空数据
final class PostListEmpty extends PostListState {}
```

**关键设计决策**：

1. **Failure 状态携带已有数据** —— 加载更多失败时，列表不能清空，要保留已有数据并显示错误提示
2. **hasReachedMax 标记** —— 告诉 UI 是否还有下一页，控制是否继续触发加载更多
3. **LoadingMore 是独立状态** —— 区别于首次加载，UI 表现为底部显示加载动画而不是全屏 loading

---

## 事件设计

```dart
sealed class PostListEvent {}

// 下拉刷新 / 首次加载
final class PostListRefreshed extends PostListEvent {}

// 上拉加载更多
final class PostListLoadMore extends PostListEvent {}

// 点击重试
final class PostListRetried extends PostListEvent {}
```

**事件 vs 用户操作映射**：

| 用户操作 | 发出的事件 |
|----------|-----------|
| 页面首次进入 | `PostListRefreshed()` |
| 下拉刷新 | `PostListRefreshed()` |
| 滚动到底部 | `PostListLoadMore()` |
| 点击错误重试按钮 | `PostListRetried()` |

---

## Bloc 实现要点

### 1. 分页逻辑

```dart
static const int _pageSize = 10;
int _currentPage = 1;
```

- 刷新时 `_currentPage = 1`
- 加载更多时 `_currentPage++`

### 2. 防重复触发

```dart
if (state is PostListLoading || state is PostListLoadingMore) {
  return;  // 正在加载中，忽略重复请求
}
```

### 3. 模拟网络请求

本示例使用模拟数据，实际项目中替换为真实 API 调用：

```dart
Future<List<Post>> _fetchPosts(int page, int limit) async {
  await Future.delayed(const Duration(seconds: 1));  // 模拟网络延迟
  // 模拟偶发错误
  if (page == 2 && Random().nextBool()) {
    throw Exception('网络请求失败');
  }
  // 返回模拟数据...
}
```

---

## UI 层设计

### 状态 → UI 映射

| 状态 | UI 表现 |
|------|---------|
| `PostListInitial` | 全屏 loading |
| `PostListLoading` | 全屏 loading |
| `PostListSuccess` | 显示列表，底部根据 `hasReachedMax` 显示"没有更多了"或触发加载更多 |
| `PostListLoadingMore` | 列表正常显示，底部显示加载动画 |
| `PostListFailure` | 列表正常显示，底部显示错误提示 + 重试按钮 |
| `PostListEmpty` | 全屏空数据提示 |

### 使用的 Widget

- `BlocBuilder` —— 响应状态变化，重建列表
- `BlocListener` —— 监听失败状态，弹出 SnackBar 提示
- `RefreshIndicator` —— 下拉刷新手势
- `ListView.builder` + `ScrollController` —— 列表 + 滚动到底部检测

---

## 代码结构

```
lib/pages/bloc_list/
├── README.md              # 本文档
├── main.dart              # 列表页面
└── post_list_bloc.dart    # Bloc 定义
```

---

## 学到的要点

1. **状态设计要覆盖所有 UI 场景** —— 不要遗漏边界状态（如加载更多失败）
2. **Failure 状态可以携带数据** —— 不是所有失败都要清空界面
3. **事件可以复用** —— 下拉刷新和首次加载可以是同一个事件
4. **Bloc 内部做防重入** —— 不要让业务逻辑泄漏到 UI 层
