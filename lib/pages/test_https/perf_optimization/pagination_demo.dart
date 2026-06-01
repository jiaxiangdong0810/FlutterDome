import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 分页加载演示
///
/// 知识点：
/// - 滚动监听实现加载更多（ScrollController）
/// - 下拉刷新（RefreshIndicator）
/// - 分页参数管理（page / pageSize）
/// - 加载状态管理（loading / hasMore / error）
@RoutePage()
class PaginationDemoPage extends StatefulWidget {
  const PaginationDemoPage({super.key});

  @override
  State<PaginationDemoPage> createState() => _PaginationDemoPageState();
}

class _PaginationDemoPageState extends State<PaginationDemoPage> {
  final List<Map<String, dynamic>> _posts = [];
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  int _currentPage = 1;
  static const int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMore();

    // 知识点：监听滚动事件，到达底部时加载更多
    _scrollController.addListener(_onScroll);
  }

  /// 滚动监听：接近底部时触发加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// 加载更多数据
  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 知识点：通过 _start 和 _limit 实现分页
      final response = await _dio.get(
        '/posts',
        queryParameters: {
          '_start': (_currentPage - 1) * _pageSize,
          '_limit': _pageSize,
        },
      );

      final data = response.data as List;

      setState(() {
        _posts.addAll(data.cast<Map<String, dynamic>>());
        _currentPage++;
        // 如果返回数据少于 pageSize，说明没有更多了
        _hasMore = data.length >= _pageSize;
        _isLoading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载失败: ${e.type}';
      });
    }
  }

  /// 下拉刷新：重置分页，重新加载
  Future<void> _onRefresh() async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
      _errorMessage = null;
    });
    await _loadMore();
  }

  /// 重试
  void _retry() {
    setState(() => _errorMessage = null);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分页加载'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${_posts.length} 条',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 知识点提示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Text(
              '分页要点：\n'
              '• ScrollController 监听滚动到底部 → loadMore()\n'
              '• RefreshIndicator 下拉刷新 → 重置分页\n'
              '• _start / _limit 分页参数\n'
              '• 三态管理：loading / hasMore / error',
              style: TextStyle(fontSize: 13),
            ),
          ),
          // 列表
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // 错误状态
    if (_errorMessage != null && _posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _retry, child: const Text('重试')),
          ],
        ),
      );
    }

    // 空状态
    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 列表
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + 1, // +1 用于底部加载指示器
        itemBuilder: (context, index) {
          // 底部加载指示器
          if (index == _posts.length) {
            return _buildBottomIndicator();
          }

          final post = _posts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text('${post["id"]}'),
            ),
            title: Text(
              post['title'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              post['body'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomIndicator() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _retry, child: const Text('重试')),
          ],
        ),
      );
    }

    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('— 没有更多数据 —')),
      );
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}
