# Flutter 异步编程 —— 从入门到精通

## 学习路线图

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Flutter 异步编程学习路线                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Stage 1 ─→ Stage 2 ─→ Stage 3 ─→ Stage 4                          │
│  事件循环     Future      Stream      Stream                         │
│  微任务      async/await  基础        进阶                           │
│  地基                                               ↓               │
│                                              Stage 5 ─→ Stage 6    │
│                                              Isolate    Flutter UI  │
│                                              并发       异步集成     │
│                                                     ↓               │
│                                               Stage 7               │
│                                               高级模式              │
│                                               实战陷阱              │
└─────────────────────────────────────────────────────────────────────┘
```

## 各阶段概览

### Stage 1: 事件循环与微任务队列
**目标**：理解 Dart 单线程事件循环模型，明白"异步不是并行"
- 事件循环是什么？为什么 Dart 选择单线程？
- 微任务队列 vs 事件队列的优先级关系
- 综合实验：同步、微任务、Future 的执行顺序预测

**前置知识**：Dart 基础语法

### Stage 2: Future 与 async/await
**目标**：掌握 Future 的状态机模型，熟练使用 async/await
- Future 的三种状态（uncompleted / completed with value / completed with error）
- 语法糖背后的 .then() 转换
- 链式调用 vs async/await 对比
- Future.wait（并行）、Future.any（竞速）、Future.forEach（串行）
- try-catch / catchError / timeout / whenComplete

**前置知识**：Stage 1

### Stage 3: Stream 基础
**目标**：理解 Stream 是"异步版的 Iterable"，掌握基本使用
- Stream 概念、listen / onDone / onError
- 单订阅 Stream vs 广播 Stream
- StreamController 手动控制
- map / where / take / skip / transform 操作符链

**前置知识**：Stage 2

### Stage 4: Stream 进阶
**目标**：能自定义 Stream 转换器，理解背压机制
- async* 函数与 yield / yield* 语法
- 实现 StreamTransformer<S, T> 接口
- 多 Stream 合并、一对多分发
- 当生产者快于消费者时的处理策略

**前置知识**：Stage 3

### Stage 5: Isolate 与并发
**目标**：理解 Dart 的 Isolate 模型，能在 CPU 密集任务中正确使用
- Isolate vs 线程、内存隔离模型
- Dart 2.19+ 的 Isolate.run() 简洁 API
- Flutter 的 compute() 便捷函数
- ReceivePort / SendPort / 消息传递协议

**前置知识**：Stage 2

### Stage 6: Flutter 异步 UI 集成
**目标**：掌握 Flutter 中异步数据驱动 UI 的标准模式
- FutureBuilder 用法与 key 的陷阱
- StreamBuilder 实时更新 UI
- AsyncSnapshot 的 connectionState / data / error
- dispose 中取消异步、mounted 检查

**前置知识**：Stage 2 + Stage 3 + Flutter Widget 基础

### Stage 7: 高级模式与实战陷阱
**目标**：掌握生产级异步模式，避免常见坑
- 用 Completer 桥接回调与 Future
- scheduleMicrotask / Timer.run / 事件循环插队
- 忘记 await、setState after dispose、内存泄漏
- 轮询、指数退避重试、超时、缓存 + 过期

**前置知识**：Stage 1~6 全部

## 推荐学习顺序

1. 按 Stage 顺序逐步推进，每个 Stage 的课程按编号顺序学习
2. 每学完一个课程，动手修改示例代码做实验
3. Stage 1~2 是基础，务必扎实
4. Stage 3~4 可按需深入，但建议完整学习
5. Stage 5 在实际遇到性能问题时重点突破
6. Stage 6 是 Flutter 开发必备
7. Stage 7 是面试和实战的加分项

## 参考资料

- [Dart 异步编程](https://dart.dev/libraries/async)
- [Dart 官方文档：Asynchrony support](https://dart.dev/language/async)
- [Flutter 官方文档：Async UI](https://docs.flutter.dev/data-and-backend/async)
- [Dart 源码：dart:async](https://github.com/dart-lang/sdk/tree/main/sdk/lib/async)
