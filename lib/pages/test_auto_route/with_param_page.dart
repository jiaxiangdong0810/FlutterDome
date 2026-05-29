import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class WithParamPage extends StatelessWidget {
  final String userId;
  final String? userName;

  const WithParamPage({
    super.key,
    @PathParam('id') required this.userId,
    @QueryParam() this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('带参数跳转页面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('用户ID: $userId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('用户名: ${userName ?? "未传入"}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
