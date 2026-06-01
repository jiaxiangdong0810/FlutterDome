import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 请求防抖演示
///
/// 知识点：
/// - Timer 实现 debounce
/// - 延迟执行：用户停止输入 N 秒后才发请求
/// - 取消上一次未完成的请求
/// - 适用于搜索框、实时过滤等场景
@RoutePage()
class RequestDebouncePage extends StatefulWidget {
  const RequestDebouncePage({super.key});

  @override
  State<RequestDebouncePage> createState() => _RequestDebouncePageState();
}

class _RequestDebouncePageState extends State<RequestDebouncePage> {
  final List<String> _logs = [];
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 防抖定时器
  Timer? _debounceTimer;
  // 取消令牌：取消上一次未完成的请求
  CancelToken? _cancelToken;

  // 防抖延迟时间
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  /// 防抖搜索
  ///
  /// 每次输入时重置定时器，只有用户停止输入 500ms 后才真正发请求
  void _onSearchChanged(String query) {
    // 取消上一次定时器
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _addLog('输入为空，跳过搜索');
      return;
    }

    _addLog('输入: "$query" → 等待 ${_debounceDelay.inMilliseconds}ms...');

    // 重置定时器
    _debounceTimer = Timer(_debounceDelay, () {
      _executeSearch(query);
    });
  }

  /// 执行实际搜索
  Future<void> _executeSearch(String query) async {
    // 取消上一次未完成的请求
    _cancelToken?.cancel('新搜索替代');
    _cancelToken = CancelToken();

    _addLog('🔍 搜索: "$query"');
    try {
      final response = await _dio.get(
        '/posts',
        queryParameters: {'q': query},
        cancelToken: _cancelToken,
      );
      final results = response.data as List;
      _addLog('✅ 找到 ${results.length} 条结果');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _addLog('⏭️ 请求被取消（有新搜索）');
      } else {
        _addLog('❌ 搜索失败: ${e.type}');
      }
    }
  }

  /// 无防抖对比：每次输入都发请求
  void _withoutDebounce(String query) {
    if (query.isEmpty) return;
    _addLog('⚡ [无防抖] 每次输入都发请求: "$query"');
    _executeSearch(query);
  }

  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $log');
    });
  }

  void _clearLogs() {
    setState(() => _logs.clear());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel('页面销毁');
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('请求防抖')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '防抖要点：\n'
                  '• Timer 延迟执行，输入期间不断重置\n'
                  '• CancelToken 取消上一次未完成的请求\n'
                  '• 只有用户停止输入后才真正发请求\n'
                  '• 适用场景：搜索框、实时过滤、窗口 resize',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ---------- 防抖搜索框 ----------
            Text('防抖搜索（输入后等 500ms）',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '输入关键词搜索...',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            // ---------- 无防抖对比 ----------
            Text('无防抖对比（每次输入立即请求）',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            TextField(
              decoration: const InputDecoration(
                hintText: '快速输入看效果...',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.flash_on),
              ),
              onChanged: _withoutDebounce,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: _clearLogs,
                child: const Text('清空日志'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('在上方输入框中快速输入查看效果'))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[i],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
