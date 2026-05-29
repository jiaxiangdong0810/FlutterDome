import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1/pages/test_widget/main.dart';

/// Widget Test 演示：测试 CounterWidget 的交互行为
///
/// 运行方式：
///   flutter test test/widget_test_demo_test.dart
///   flutter test test/widget_test_demo_test.dart --verbose（查看详细输出）
void main() {
  group('CounterWidget', () {
    testWidgets('初始状态显示计数为 0', (WidgetTester tester) async {
      // 1. 构建 Widget：将待测组件加载到测试环境
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CounterWidget())),
      );

      // 2. 查找 + 断言：验证初始计数为 0
      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('点击增加按钮，计数加 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CounterWidget())),
      );

      // 通过 Key 查找按钮并点击
      await tester.tap(find.byKey(const Key('increment_button')));

      // pump() 触发重建，让 setState 生效
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('多次点击后点击重置，计数归零', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CounterWidget())),
      );

      // 点击 3 次
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();

      expect(find.text('3'), findsOneWidget);

      // 点击重置
      await tester.tap(find.byKey(const Key('reset_button')));
      await tester.pump();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('文本输入后显示问候语', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CounterWidget())),
      );

      // 初始状态显示"等待输入..."
      expect(find.text('等待输入...'), findsOneWidget);

      // 在输入框中输入文本
      await tester.enterText(find.byKey(const Key('input_field')), 'Flutter');
      await tester.pump();

      // 验证问候语更新
      expect(find.text('你好，Flutter！'), findsOneWidget);
      expect(find.text('等待输入...'), findsNothing);
    });

    testWidgets('多种查找方式演示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CounterWidget())),
      );

      // byType：按 Widget 类型查找
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);

      // byIcon：按图标查找
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // byKey：按 Key 查找
      expect(find.byKey(const Key('counter_value')), findsOneWidget);

      // text：按文本内容查找
      expect(find.text('增加'), findsOneWidget);
      expect(find.text('重置'), findsOneWidget);

      // descendant：查找父 Widget 下的子 Widget
      expect(
        find.descendant(
          of: find.byType(Row),
          matching: find.byType(ElevatedButton),
        ),
        findsOneWidget,
      );
    });
  });
}
