import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Widget Test 演示入口页面
///
/// 展示一个待测的计数器组件，配合 test/widget_test.dart 中的测试用例，
/// 演示 Widget Test 的核心 API：构建、查找、交互、断言。
@RoutePage()
class WidgetTestDemoPage extends StatelessWidget {
  const WidgetTestDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Test 演示')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '待测组件：CounterWidget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '这是一个用于 Widget Test 演示的计数器组件。'
              '运行 flutter test 查看测试过程。',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            CounterWidget(),
          ],
        ),
      ),
    );
  }
}

/// 待测组件：带计数、重置和文本输入功能的交互组件
///
/// 测试目标：
/// 1. 点击 + 按钮，计数增加
/// 2. 点击重置按钮，计数归零
/// 3. 输入框输入内容，实时显示
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;
  final TextEditingController _controller = TextEditingController();

  void _increment() {
    setState(() {
      _count++;
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 计数显示区
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('计数：', style: TextStyle(fontSize: 16)),
              Text(
                '$_count',
                key: const Key('counter_value'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 按钮区
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                key: const Key('increment_button'),
                onPressed: _increment,
                icon: const Icon(Icons.add),
                label: const Text('增加'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                key: const Key('reset_button'),
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('重置'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 文本输入区
          TextField(
            key: const Key('input_field'),
            controller: _controller,
            decoration: const InputDecoration(
              labelText: '输入你的名字',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          // 显示输入内容
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              return Text(
                value.text.isEmpty ? '等待输入...' : '你好，${value.text}！',
                key: const Key('greeting_text'),
                style: TextStyle(
                  fontSize: 16,
                  color: value.text.isEmpty ? Colors.grey : Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
