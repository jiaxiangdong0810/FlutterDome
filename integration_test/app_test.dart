import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:untitled1/main.dart' as app;
import 'package:untitled1/pages/test_integration/main.dart';

/// Integration Test 演示
///
/// 运行方式：flutter test integration_test/app_test.dart
///
/// 本文件展示两种测试写法：
/// 1. 方式A - 全链路导航：从 app.main() 启动，逐层点击到目标页面
/// 2. 方式B - 直接挂载：用 pumpWidget 直接打开目标页面，跳过前置导航
///
/// 推荐：除非测试的就是导航流程本身，否则一律用方式B。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 方式A：全链路导航（从首页一步步点进来）
  // 适用场景：测试完整的用户操作流程、导航栈行为
  // 缺点：页面栈越深，前置步骤越多，测试越脆弱
  // ============================================================
  group('方式A - 全链路导航', () {
    testWidgets('从首页导航到登录页，正确凭据登录成功', (tester) async {
      // 1. 启动完整应用
      app.main();
      await tester.pumpAndSettle();

      // 2. 逐层导航：首页 → Integration Test 演示 → 登录页
      expect(find.text('Flutter Demo Home Page'), findsOneWidget);
      await tester.tap(find.text('Integration Test 演示'));
      await tester.pumpAndSettle();

      // 3. 执行被测逻辑
      expect(find.text('用户登录'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('password_field')), '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 4. 断言结果
      expect(find.byKey(const Key('welcome_text')), findsOneWidget);
      expect(find.text('欢迎，admin！'), findsOneWidget);
    });
  });

  // ============================================================
  // 方式B：直接挂载目标页面（推荐）
  // 适用场景：测试某个具体页面的交互逻辑
  // 优点：无视页面深度，测试代码聚焦在被测页面本身
  // ============================================================
  group('方式B - 直接挂载目标页面', () {
    testWidgets('登录页：正确凭据跳转首页', (tester) async {
      // 直接挂载登录页，跳过所有前置导航
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // 直接执行被测逻辑
      await tester.enterText(find.byKey(const Key('username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('password_field')), '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 断言跳转成功
      expect(find.byKey(const Key('welcome_text')), findsOneWidget);
      expect(find.text('欢迎，admin！'), findsOneWidget);
    });

    testWidgets('登录页：错误凭据显示错误提示', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      await tester.enterText(find.byKey(const Key('username_field')), 'wrong');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrong');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('error_text')), findsOneWidget);
      expect(find.text('用户名或密码错误'), findsOneWidget);
    });

    testWidgets('登录页：注销后返回登录页', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // 登录
      await tester.enterText(find.byKey(const Key('username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('password_field')), '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // 确认在首页
      expect(find.text('欢迎，admin！'), findsOneWidget);

      // 注销
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // 确认返回登录页
      expect(find.text('用户登录'), findsOneWidget);
    });
  });
}
