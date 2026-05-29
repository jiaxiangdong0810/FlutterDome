import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UserDetailPage extends StatelessWidget {
  final String userId;
  final String? userName;

  const UserDetailPage({
    super.key,
    @PathParam('id') required this.userId,
    @QueryParam() this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户详情')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              child: Icon(Icons.person, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              '姓名: ${userName ?? '未知用户'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $userId',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.router.pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
