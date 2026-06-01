# Bloc 入门：认识 Bloc

## Bloc 是什么？

**Bloc** = **B**usiness **Lo**gic **C**omponent（业务逻辑组件）

它是 Flutter 中一种**状态管理**方案，核心思想是：

> **把"用户操作"和"界面状态"彻底分离**

用户点击按钮 → 发出**事件(Event)** → Bloc 处理逻辑 → 输出新**状态(State)** → UI 自动更新

---

## 为什么要用 Bloc？

| 场景 | setState | Bloc |
|------|----------|------|
| 简单计数器 | 够用 | 也可以 |
| 加载中/成功/失败 多状态 | 代码混乱 | 清晰分层 |
| 多个页面共享状态 | 难以维护 | 天然支持 |
| 业务逻辑复杂 | 和 UI 混在一起 | 独立可测试 |
| 需要单元测试 | 难测 | 纯 Dart，好测 |

**Bloc 不是必须的**，但在中大型项目中，它能让代码：
- 更可维护
- 更可测试
- 更可预测

---

## 核心概念（3个）

### 1. State（状态）

State 是**不可变**的数据对象，描述 UI 当前应该长什么样。

```dart
// 状态基类
sealed class CounterState {}

// 初始状态
final class CounterInitial extends CounterState {}

// 加载中
final class CounterLoading extends CounterState {}

// 成功：携带数据
final class CounterSuccess extends CounterState {
  final int count;
  CounterSuccess(this.count);
}

// 失败：携带错误信息
final class CounterFailure extends CounterState {
  final String message;
  CounterFailure(this.message);
}
```

**关键点**：
- 用 `sealed class` 定义基类，Dart 3 特性，可以 `switch` 穷举所有子类
- 每个子类代表一种 UI 状态
- 状态是**不可变的**——状态变了就创建新对象，不是修改旧对象

### 2. Event（事件）

Event 是**用户操作**或**系统通知**的抽象。

```dart
// 事件基类
sealed class CounterEvent {}

// 增加
final class CounterIncrement extends CounterEvent {}

// 减少
final class CounterDecrement extends CounterEvent {}

// 重置
final class CounterReset extends CounterEvent {}
```

**关键点**：
- 事件也是 `sealed class`，和状态对称
- 事件可以携带参数（如搜索关键词、表单数据）
- 所有用户操作都必须通过 Event 进入 Bloc

### 3. Bloc（逻辑处理器）

Bloc 是连接 Event 和 State 的**纯函数**。

```dart
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  int _count = 0;

  CounterBloc() : super(CounterInitial()) {
    // 注册事件处理器
    on<CounterIncrement>(_onIncrement);
    on<CounterDecrement>(_onDecrement);
    on<CounterReset>(_onReset);
  }

  Future<void> _onIncrement(
    CounterIncrement event,
    Emitter<CounterState> emit,
  ) async {
    emit(CounterLoading());           // 先显示加载中
    await Future.delayed(Duration(milliseconds: 500)); // 模拟网络请求
    _count++;
    emit(CounterSuccess(_count));     // 再显示成功结果
  }
  // ...
}
```

**关键点**：
- `Bloc<Event, State>` 是泛型类，指定事件和状态的类型
- `on<EventType>(handler)` 注册事件处理器
- `emit(newState)` 发出新状态，UI 会自动重建
- Bloc 内部**不能**直接操作 UI，只能通过 emit 状态间接影响

---

## 使用流程（4步）

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  1. 定义State │ ──▶ │  2. 定义Event │ ──▶ │  3. 创建Bloc  │ ──▶ │  4. UI使用   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### 第4步：UI 层怎么写？

```dart
// 提供 Bloc
BlocProvider(
  create: (context) => CounterBloc(),
  child: const MyPage(),
)

// 响应状态变化
BlocBuilder<CounterBloc, CounterState>(
  builder: (context, state) {
    return switch (state) {
      CounterInitial() => Text('点击按钮开始'),
      CounterLoading() => CircularProgressIndicator(),
      CounterSuccess(:final count) => Text('计数: $count'),
      CounterFailure(:final message) => Text('错误: $message', style: TextStyle(color: Colors.red)),
    };
  },
)

// 发送事件
context.read<CounterBloc>().add(CounterIncrement());
```

**三个 Widget**：

| Widget | 作用 |
|--------|------|
| `BlocProvider` | 创建并提供 Bloc 实例 |
| `BlocBuilder` | 监听状态变化，重建 UI |
| `BlocListener` | 监听状态变化，执行副作用（如弹 Toast、导航） |

---

## 本示例代码结构

```
lib/pages/bloc_basics/
├── README.md          # 本文档
├── main.dart          # 示例页面（UI 层）
└── counter_bloc.dart  # Bloc 定义（状态 + 事件 + Bloc 类）
```

---

## 下一步

理解了基础概念后，可以思考：

1. **多个 Bloc 如何协作？**（阶段2）
2. **项目中如何规范使用？**（阶段3）
3. **有哪些常见坑？**（阶段4）
