import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ReturnValuePage extends StatelessWidget {
  const ReturnValuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('返回结果页面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '选择一个结果返回',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 返回结果并关闭当前页面
                context.router.pop('成功');
              },
              child: const Text('返回: 成功'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.router.pop('失败');
              },
              child: const Text('返回: 失败'),
            ),
          ],
        ),
      ),
    );
  }
}
