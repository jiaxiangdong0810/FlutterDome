import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class WithCallbackPage extends StatelessWidget {
  final void Function(String) onConfirmed;

  const WithCallbackPage({
    super.key,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('带回调函数页面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '点击按钮触发回调',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                onConfirmed('已确认');
                context.router.pop();
              },
              child: const Text('确认并回调'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                onConfirmed('已取消');
                context.router.pop();
              },
              child: const Text('取消并回调'),
            ),
          ],
        ),
      ),
    );
  }
}
