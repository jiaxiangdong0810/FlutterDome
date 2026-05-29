import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/app_router.gr.dart';

@RoutePage()
class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  final List<Map<String, String>> _users = const [
    {'id': '1', 'name': '张三'},
    {'id': '2', 'name': '李四'},
    {'id': '3', 'name': '王五'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户列表')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            leading: CircleAvatar(child: Text(user['name']![0])),
            title: Text(user['name']!),
            subtitle: Text('ID: ${user['id']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.router.push(
              UserDetailRoute(userId: user['id']!, userName: user['name']!),
            ),
          );
        },
      ),
    );
  }
}
