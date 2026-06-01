import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== 数据模型 ====================

class Post {
  final int id;
  final String title;
  final String content;
  final String author;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
  });
}

// ==================== State（状态）====================

sealed class PostListState {}

final class PostListInitial extends PostListState {}

final class PostListLoading extends PostListState {}

final class PostListSuccess extends PostListState {
  final List<Post> posts;
  final bool hasReachedMax;

  PostListSuccess(this.posts, {this.hasReachedMax = false});
}

final class PostListLoadingMore extends PostListState {
  final List<Post> posts;

  PostListLoadingMore(this.posts);
}

final class PostListFailure extends PostListState {
  final List<Post> posts;
  final String message;

  PostListFailure(this.posts, this.message);
}

final class PostListEmpty extends PostListState {}

// ==================== Event（事件）====================

sealed class PostListEvent {}

final class PostListRefreshed extends PostListEvent {}

final class PostListLoadMore extends PostListEvent {}

final class PostListRetried extends PostListEvent {}

// ==================== Bloc（逻辑处理器）====================

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  static const int _pageSize = 10;
  int _currentPage = 1;

  PostListBloc() : super(PostListInitial()) {
    on<PostListRefreshed>(_onRefreshed);
    on<PostListLoadMore>(_onLoadMore);
    on<PostListRetried>(_onRetried);
  }

  Future<void> _onRefreshed(
    PostListRefreshed event,
    Emitter<PostListState> emit,
  ) async {
    if (state is PostListLoading) return;

    emit(PostListLoading());
    _currentPage = 1;

    try {
      final posts = await _fetchPosts(_currentPage, _pageSize);
      if (posts.isEmpty) {
        emit(PostListEmpty());
      } else {
        emit(PostListSuccess(
          posts,
          hasReachedMax: posts.length < _pageSize,
        ));
      }
    } catch (e) {
      emit(PostListFailure([], e.toString()));
    }
  }

  Future<void> _onLoadMore(
    PostListLoadMore event,
    Emitter<PostListState> emit,
  ) async {
    if (state is PostListLoadingMore) return;
    if (state is! PostListSuccess) return;

    final currentState = state as PostListSuccess;
    if (currentState.hasReachedMax) return;

    emit(PostListLoadingMore(currentState.posts));
    _currentPage++;

    try {
      final newPosts = await _fetchPosts(_currentPage, _pageSize);
      if (newPosts.isEmpty) {
        emit(PostListSuccess(
          currentState.posts,
          hasReachedMax: true,
        ));
      } else {
        emit(PostListSuccess(
          [...currentState.posts, ...newPosts],
          hasReachedMax: newPosts.length < _pageSize,
        ));
      }
    } catch (e) {
      emit(PostListFailure(
        currentState.posts,
        e.toString(),
      ));
    }
  }

  Future<void> _onRetried(
    PostListRetried event,
    Emitter<PostListState> emit,
  ) async {
    if (state is PostListFailure) {
      final failureState = state as PostListFailure;
      if (failureState.posts.isEmpty) {
        add(PostListRefreshed());
      } else {
        add(PostListLoadMore());
      }
    }
  }

  // 模拟网络请求
  Future<List<Post>> _fetchPosts(int page, int limit) async {
    await Future.delayed(const Duration(seconds: 1));

    // 模拟偶发错误（第2页有50%概率失败）
    if (page == 2 && Random().nextBool()) {
      throw Exception('网络请求失败，请稍后重试');
    }

    // 模拟只有3页数据
    if (page > 3) {
      return [];
    }

    return List.generate(limit, (index) {
      final id = (page - 1) * limit + index + 1;
      return Post(
        id: id,
        title: '帖子 #$id',
        content: '这是帖子 #$id 的内容，模拟一段较长的文本用于展示列表项的排版效果。在实际项目中，这里会显示真实的帖子内容。',
        author: '作者${id % 5 + 1}',
      );
    });
  }
}
