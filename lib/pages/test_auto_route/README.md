# AutoRoute 使用指南

## 什么是 AutoRoute

AutoRoute 是 Flutter 的一个类型安全的路由库，基于代码生成。它在编译期生成路由代码，避免了手写字符串路径和手动解析参数的运行时错误。

---

## 核心概念

### 1. 装饰器（Annotations）

| 装饰器 | 作用 | 使用位置 |
|--------|------|----------|
| `@RoutePage()` | 标记一个 Widget 为路由页面 | 页面类上方 |
| `@AutoRouterConfig()` | 标记路由配置类 | 路由配置类上方 |
| `@PathParam('name')` | 标记路径参数（URL 路径中的变量） | 构造参数前 |
| `@QueryParam()` | 标记查询参数（URL ? 后的参数） | 构造参数前 |

### 2. 三个核心类

- **PageRouteInfo**: 路由信息的描述对象，用于跳转时传递参数
- **RootStackRouter**: 根路由器，管理整个应用的路由栈
- **StackRouter**: 子路由器，通过 `context.router` 获取

---

## 如何定义路由

### 步骤 1：标记页面

在要作为路由页面的 Widget 类上方添加 `@RoutePage()`：

```dart
import 'package:auto_route/auto_route.dart';

@RoutePage()  // <-- 添加这个装饰器
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

### 步骤 2：配置路由

创建路由配置文件（如 `lib/router/app_router.dart`）：

```dart
import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';  // 生成的文件

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MyHomeRoute.page, path: '/'),
    AutoRoute(page: MyPageRoute.page, path: '/my-page'),
  ];
}
```

### 步骤 3：生成代码

运行命令生成路由代码：

```bash
flutter pub run build_runner build
```

这会生成 `app_router.gr.dart` 文件，里面包含所有 `*Route` 类。

### 步骤 4：在应用中使用

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MaterialApp.router(
      routerConfig: appRouter.config(),
    );
  }
}
```

---

## 如何使用路由

### 无参跳转

```dart
context.router.push(const MyPageRoute());
```

### 带参数跳转

```dart
// 页面定义
@RoutePage()
class UserDetailPage extends StatelessWidget {
  final String userId;
  final String? userName;

  const UserDetailPage({
    super.key,
    @PathParam('id') required this.userId,  // 路径参数
    @QueryParam() this.userName,             // 查询参数
  });
}

// 跳转
context.router.push(
  UserDetailRoute(userId: '123', userName: '张三'),
);
```

### 等待返回值

```dart
// 跳转方
final result = await context.router.push<String>(
  ReturnValueRoute(),
);

// 返回方
context.router.pop('返回的数据');
```

### 带回调函数跳转

```dart
// 跳转方
context.router.push(
  WithCallbackRoute(
    onConfirmed: (value) {
      // 处理回调
    },
  ),
);

// 页面定义
@RoutePage()
class WithCallbackPage extends StatelessWidget {
  final void Function(String) onConfirmed;

  const WithCallbackPage({
    super.key,
    required this.onConfirmed,
  });
}
```

### 其他常用操作

```dart
// 返回上一页
context.router.pop();

// 返回并传递数据
context.router.pop(result);

// 替换当前页（不保留在栈中）
context.router.replace(const MyPageRoute());

// 清空栈并跳转到新页面
context.router.pushAndPopUntil(
  const MyPageRoute(),
  predicate: (_) => false,
);

// 返回指定页面
context.router.popUntil((route) => route.settings.name == 'HomeRoute');
```

---

## 本示例包含的四种跳转方式

| 文件 | 说明 |
|------|------|
| `auto_route_home_page.dart` | 示例入口，展示四个按钮 |
| `no_param_page.dart` | 无参跳转：直接 push |
| `with_param_page.dart` | 带参跳转：`@PathParam` + `@QueryParam` |
| `return_value_page.dart` | 返回结果：`push<T>()` + `pop(result)` |
| `with_callback_page.dart` | 回调函数：通过构造参数传递函数 |

---

## 与 go_router 对比

| 特性 | AutoRoute | go_router |
|------|-----------|-----------|
| **类型安全** | 编译期检查，参数类型安全 | 运行时解析，依赖字符串路径 |
| **代码生成** | 需要 `build_runner` 生成代码 | 不需要代码生成 |
| **参数传递** | 通过构造参数直接传递 | 通过 `state.pathParameters` / `extra` 传递 |
| **返回值** | `push<T>()` 泛型支持 | `push<T>()` 泛型支持 |
| **深层链接** | 支持 | 原生支持更完善 |
| **学习成本** | 需要理解装饰器和代码生成 | 更接近原生 Navigator |
| **IDE 支持** | 参数有代码补全和类型检查 | 字符串路径无代码补全 |

### AutoRoute 优势

1. **类型安全**：跳转时参数类型在编译期检查，不会传错参数
2. **IDE 友好**：路由和参数都有代码补全，重构时自动更新引用
3. **参数直观**：直接通过构造参数传递，不需要手动解析
4. **代码生成**：路由表自动生成，减少手写 boilerplate

### AutoRoute 劣势

1. **需要代码生成**：每次修改页面参数都要运行 `build_runner`
2. **额外依赖**：需要 `auto_route` 和 `auto_route_generator`
3. **构建时间**：代码生成会增加构建时间
4. **学习曲线**：需要理解装饰器、代码生成等新概念

---

## 什么时候用 AutoRoute

**推荐使用：**
- 项目路由较多，需要类型安全
- 团队开发，需要减少路由相关 bug
- 频繁重构，需要 IDE 支持重构路由

**不推荐使用：**
- 简单项目，只有几个页面
- 不想引入代码生成步骤
- 对深层链接有复杂需求（go_router 更成熟）

---

## 修改后重新生成代码

当修改了以下内容时，需要重新运行代码生成：

- 添加/删除 `@RoutePage()` 装饰器
- 修改页面构造参数（增删参数、改类型）
- 修改 `@PathParam` / `@QueryParam` 配置
- 修改 `app_router.dart` 中的路由配置

```bash
flutter pub run build_runner build
```

开发时可以开启监视模式，自动重新生成：

```bash
flutter pub run build_runner watch
```
