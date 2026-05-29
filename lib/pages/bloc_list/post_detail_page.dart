import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/user_bloc.dart';
import 'post_list_bloc.dart';

/// 帖子详情页
///
/// 知识点：跨页面传递数据的最简单方式——通过构造参数传递。
/// 不需要共享 Bloc，详情页只展示传入的帖子数据。
/// 如果详情页修改了数据，通过返回结果通知列表页刷新。
@RoutePage()
class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 作者信息
            Row(
              children: [
                CircleAvatar(
                  child: Text(post.author[0]),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '帖子 ID: ${post.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            // 帖子内容
            Text(
              post.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 32),
            // 模拟操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.thumb_up_outlined,
                  label: '点赞',
                  onTap: () {
                    // 模拟点赞后返回，通知列表页刷新
                    context.router.pop(true);
                  },
                ),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: '评论',
                  onTap: () {},
                ),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: '分享',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 当前用户信息展示（全局 Bloc）
            const Divider(height: 32),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '当前用户信息（全局 Bloc）',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                userState.name.isNotEmpty
                                    ? userState.name[0]
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '姓名: ${userState.name}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '年龄: ${userState.age}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 修改用户信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '修改用户信息',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NameEditor(),
                    const SizedBox(height: 12),
                    _AgeEditor(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 说明文字
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '提示：点击"点赞"后会返回列表页并触发刷新。'
                '这种方式通过 Navigator.pop 的返回值传递"数据已变更"的信号，'
                '列表页收到信号后重新加载数据。'
                '\n\n另外，本页面展示了全局 UserBloc 的使用：'
                '通过 context.read<UserBloc>() 读取和修改全局状态，'
                '修改后会自动同步到列表页顶部的用户信息卡片。',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _NameEditor extends StatefulWidget {
  @override
  State<_NameEditor> createState() => _NameEditorState();
}

class _NameEditorState extends State<_NameEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    _controller = TextEditingController(text: userState.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('姓名:', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '输入姓名',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            context.read<UserBloc>().add(
                  UserNameChanged(_controller.text),
                );
          },
          child: const Text('修改'),
        ),
      ],
    );
  }
}

class _AgeEditor extends StatefulWidget {
  @override
  State<_AgeEditor> createState() => _AgeEditorState();
}

class _AgeEditorState extends State<_AgeEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserBloc>().state;
    _controller = TextEditingController(text: userState.age.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('年龄:', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '输入年龄',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final age = int.tryParse(_controller.text);
            if (age != null) {
              context.read<UserBloc>().add(UserAgeChanged(age));
            }
          },
          child: const Text('修改'),
        ),
      ],
    );
  }
}
