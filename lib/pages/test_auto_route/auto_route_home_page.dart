import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/app_router.gr.dart';

@RoutePage()
class AutoRouteHomePage extends StatelessWidget {
  const AutoRouteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoRoute 示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 无参跳转
                context.router.push(const NoParamRoute());
              },
              child: const Text('无参跳转'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 带参数跳转（PathParam + QueryParam）
                context.router.push(
                  WithParamRoute(userId: '123', userName: '张三'),
                );
              },
              child: const Text('带参数跳转'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // 跳转并等待返回值
                final result = await context.router.push<String>(
                  ReturnValueRoute(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('返回结果: $result')),
                  );
                }
              },
              child: const Text('跳转并等待返回值'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 带回调函数跳转
                context.router.push(
                  WithCallbackRoute(
                    onConfirmed: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('回调结果: $value')),
                      );
                    },
                  ),
                );
              },
              child: const Text('带回调函数跳转'),
            ),
          ],
        ),
      ),
    );
  }
}
