import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Provider 异步示例
///
/// 核心知识点：
/// 1. FutureProvider — 管理一次性异步操作（如网络请求）
/// 2. StreamProvider — 管理持续的数据流（如实时数据）
/// 3. AsyncSnapshot 处理 loading / error / data 三种状态
///
/// 场景：模拟网络请求加载用户列表 + 实时倒计时

// ==================== 模拟数据 ====================

class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

/// 模拟网络请求
Future<List<User>> fetchUsers() async {
  await Future.delayed(const Duration(seconds: 2)); // 模拟网络延迟

  // 模拟随机失败（30% 概率）
  if (Random().nextDouble() < 0.3) {
    throw Exception('网络请求失败，请重试');
  }

  return [
    User(id: 1, name: '张三', email: 'zhangsan@example.com'),
    User(id: 2, name: '李四', email: 'lisi@example.com'),
    User(id: 3, name: '王五', email: 'wangwu@example.com'),
    User(id: 4, name: '赵六', email: 'zhaoliu@example.com'),
  ];
}

/// 模拟实时数据流 — 每秒产生一个数字
Stream<int> countdownStream({int from = 10}) {
  return Stream.periodic(
    const Duration(seconds: 1),
    (i) => from - i,
  ).take(from + 1);
}

// ==================== 页面入口 ====================

@RoutePage()
class ProviderAsyncRoute extends StatelessWidget {
  const ProviderAsyncRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // FutureProvider — 一次性异步操作
        // 用 AsyncState 包装，同时承载 loading / error / data 三种状态
        FutureProvider<AsyncState<List<User>>>(
          create: (_) async {
            try {
              final users = await fetchUsers();
              return AsyncState.data(users);
            } catch (e) {
              return AsyncState.error(e);
            }
          },
          initialData: const AsyncState.loading(),
        ),
        // StreamProvider — 持续数据流
        StreamProvider<int>(
          create: (_) => countdownStream(from: 15),
          initialData: 15,
        ),
      ],
      child: const ProviderAsyncPage(),
    );
  }
}

class ProviderAsyncPage extends StatelessWidget {
  const ProviderAsyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider + 异步'),
      ),
      body: Column(
        children: [
          // 实时倒计时区域
          const CountdownSection(),
          const Divider(),
          // 用户列表区域
          const Expanded(
            child: UserListSection(),
          ),
        ],
      ),
    );
  }
}

// ==================== 倒计时区域（StreamProvider）====================

class CountdownSection extends StatelessWidget {
  const CountdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    // 监听 StreamProvider 的数据
    final remaining = context.watch<int>();

    return Container(
      padding: const EdgeInsets.all(16),
      color: remaining == 0 ? Colors.red.shade50 : Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            remaining == 0 ? Icons.timer_off : Icons.timer,
            color: remaining == 0 ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 12),
          Text(
            remaining == 0 ? '倒计时结束！' : '剩余时间: $remaining 秒',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: remaining == 0 ? Colors.red : Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 用户列表区域（FutureProvider）====================

/// 异步状态封装类 — 同时承载 loading / error / data 三种状态
class AsyncState<T> {
  final T? data;
  final Object? error;
  final bool isLoading;

  const AsyncState._({this.data, this.error, this.isLoading = false});

  const AsyncState.loading() : this._(isLoading: true);
  const AsyncState.error(Object e) : this._(error: e);
  const AsyncState.data(T value) : this._(data: value);

  bool get hasError => error != null;
  bool get hasData => data != null;
}

class UserListSection extends StatelessWidget {
  const UserListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // FutureProvider<AsyncState<List<User>>> 暴露的是 AsyncState 对象
    final state = context.watch<AsyncState<List<User>>>();

    // 处理三种状态
    if (state.isLoading) {
      return const _LoadingView();
    }

    if (state.hasError) {
      return _ErrorView(
        error: state.error.toString(),
        onRetry: () {
          // 返回上一页再进入，重新触发 FutureProvider
          context.router.back();
        },
      );
    }

    final users = state.data;
    if (users == null || users.isEmpty) {
      return const _EmptyView();
    }

    return _UserListView(users: users);
  }
}

// ==================== 子视图 ====================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载用户列表中...'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('暂无用户数据'),
    );
  }
}

class _UserListView extends StatelessWidget {
  final List<User> users;

  const _UserListView({required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(user.name[0]),
            ),
            title: Text(user.name),
            subtitle: Text(user.email),
            trailing: Text('ID: ${user.id}'),
          ),
        );
      },
    );
  }
}
