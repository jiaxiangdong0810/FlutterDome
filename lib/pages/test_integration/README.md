# Integration Test 实战指南

## 核心问题：如何直接测试深层页面？

当前测试每次从 `app.main()` 启动，需要逐层点击导航到目标页面。如果页面栈很深（首页 → 列表 → 详情 → 编辑 → 设置），测试代码会冗长且脆弱。

### 解决方案：直接挂载目标页面

不启动整个应用，而是直接用 `tester.pumpWidget()` 挂载要测试的页面，绕过所有前置导航：

```dart
// 不这样做：从首页一步步点进来
app.main();
await tester.pumpAndSettle();
await tester.tap(find.text('进入列表'));
await tester.pumpAndSettle();
await tester.tap(find.text('进入详情'));
...

// 这样做：直接挂载目标页面
await tester.pumpWidget(
  MaterialApp(
    home: LoginPage(),  // 直接打开登录页
  ),
);
```

### 页面依赖数据怎么办？

如果页面需要从路由参数或父组件获取数据，用 `MaterialApp.onGenerateRoute` 模拟：

```dart
await tester.pumpWidget(
  MaterialApp(
    onGenerateRoute: (settings) {
      if (settings.name == '/user-detail') {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => UserDetailPage(userId: args['id']),
        );
      }
      return MaterialPageRoute(builder: (_) => const LoginPage());
    },
    initialRoute: '/user-detail',
  ),
);
```

### 页面依赖 BLoC/Provider 怎么办？

用对应的 Provider 包裹：

```dart
await tester.pumpWidget(
  BlocProvider(
    create: (_) => UserBloc(),
    child: const MaterialApp(
      home: UserListPage(),
    ),
  ),
);
```

---

## 文件说明

| 文件 | 说明 |
|------|------|
| `main.dart` | 演示页面：登录页 + 首页 |
| `../../integration_test/app_test.dart` | 两种写法对比：全链路导航 vs 直接挂载 |

## 运行测试

```bash
flutter devices          # 确认设备已连接
flutter test integration_test/app_test.dart
```

## 测试代码编写原则

1. **优先直接挂载**：除非测试的就是导航流程，否则用 `pumpWidget` 直接打开目标页面
2. **给交互元素加 Key**：文本可能随语言变化，Key 是稳定的查找依据
3. **每个测试独立**：`app.main()` 在多次调用间不会自动清状态，要么直接挂载页面，要么在 `tearDown` 里处理
4. **用 pumpAndSettle 等动画**：点击、跳转后必须 `await tester.pumpAndSettle()`，否则断言会在动画中途执行

## 常用 API

| API | 作用 |
|-----|------|
| `tester.pumpWidget(widget)` | 直接挂载一个 Widget |
| `tester.enterText(finder, text)` | 在输入框输入文本 |
| `tester.tap(finder)` | 点击元素 |
| `tester.pumpAndSettle()` | 等待所有动画完成 |
| `tester.scrollUntilVisible(finder, delta)` | 滚动直到元素出现 |
| `find.byKey(Key('xxx'))` | 通过 Key 查找 |
| `find.text('xxx')` | 通过文本查找 |
| `find.byType(ElevatedButton)` | 通过类型查找 |
