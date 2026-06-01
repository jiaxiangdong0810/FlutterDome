import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/user_bloc.dart';
import '../../../router/app_router.gr.dart';
import 'post_list_bloc.dart';

@RoutePage()
class BlocListPage extends StatelessWidget {
  const BlocListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostListBloc()..add(PostListRefreshed()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bloc 列表实战'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<PostListBloc>().add(PostListLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= maxScroll - 200;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部用户信息卡片
        BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        userState.name.isNotEmpty ? userState.name[0] : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userState.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                    ),
                    const Icon(Icons.person, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
        // 列表区域
        Expanded(
          child: BlocListener<PostListBloc, PostListState>(
            listener: (context, state) {
              if (state is PostListFailure && state.posts.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    action: SnackBarAction(
                      label: '重试',
                      onPressed: () {
                        context.read<PostListBloc>().add(PostListRetried());
                      },
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<PostListBloc, PostListState>(
              builder: (context, state) {
                if (state is PostListInitial || state is PostListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PostListEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无数据', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (state is PostListFailure && state.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PostListBloc>().add(PostListRetried());
                          },
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PostListSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PostListBloc>().add(PostListRefreshed());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.posts.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.posts.length) {
                          return state.hasReachedMax
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      '没有更多了',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                        }
                        return _PostItem(post: state.posts[index]);
                      },
                    ),
                  );
                }

                if (state is PostListLoadingMore) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _PostItem(post: state.posts[index]);
                    },
                  );
                }

                if (state is PostListFailure) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      return _PostItem(post: state.posts[index]);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PostItem extends StatelessWidget {
  final Post post;

  const _PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        // 知识点：通过 Navigator.push 跳转到详情页，并传递 Post 对象
        // 详情页返回时，通过 await 获取返回值（是否数据有变更）
        onTap: () async {
          final needRefresh = await context.router.push<bool>(
            PostDetailRoute(post: post),
          );
          // 如果详情页返回 true（如点赞后），触发列表刷新
          if (needRefresh == true && context.mounted) {
            context.read<PostListBloc>().add(PostListRefreshed());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(post.author[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
