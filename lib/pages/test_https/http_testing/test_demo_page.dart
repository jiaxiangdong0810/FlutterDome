import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';

/// 测试概念演示页面
///
/// 知识点：
/// - Dio 拦截器模拟测试（无需 Mock 库）
/// - 依赖注入便于测试
/// - 测试策略：成功/失败/边界情况
@RoutePage()
class HttpTestDemoPage extends StatefulWidget {
  const HttpTestDemoPage({super.key});

  @override
  State<HttpTestDemoPage> createState() => _HttpTestDemoPageState();
}

class _HttpTestDemoPageState extends State<HttpTestDemoPage> {
  final List<String> _logs = [];

  /// 演示：使用拦截器模拟 API 响应（无需真实网络）
  ///
  /// 知识点：这种方式不需要 mockito 等库
  /// 通过 Dio 拦截器拦截请求，直接返回模拟数据
  Future<void> _demoMockWithInterceptor() async {
    _addLog('--- 拦截器模拟测试 ---');
    _addLog('原理：用 Interceptor 拦截请求，返回模拟数据');

    final mockDio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

    // 知识点：拦截器可以拦截请求并返回模拟响应
    mockDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == '/posts' && options.method == 'GET') {
          // 模拟成功响应
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: [
              {'id': 1, 'title': '测试帖子1', 'body': '内容1', 'userId': 1},
              {'id': 2, 'title': '测试帖子2', 'body': '内容2', 'userId': 1},
            ],
          ));
        } else {
          handler.next(options);
        }
      },
    ));

    final apiService = ApiService(mockDio);
    try {
      final posts = await apiService.getPosts();
      _addLog('✅ 获取到 ${posts.length} 个帖子');
      for (final post in posts) {
        _addLog('  ${post}');
      }
    } catch (e) {
      _addLog('❌ 异常: $e');
    }
  }

  /// 演示：模拟失败场景
  Future<void> _demoMockFailure() async {
    _addLog('--- 模拟失败场景 ---');
    _addLog('测试错误处理是否正确');

    final mockDio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));

    mockDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 模拟 404 响应
        handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ));
      },
    ));

    final apiService = ApiService(mockDio);
    try {
      await apiService.getPost(999);
      _addLog('❌ 不应该走到这里');
    } on DioException catch (e) {
      _addLog('✅ 正确捕获异常: ${e.type}');
      _addLog('   状态码: ${e.response?.statusCode}');
    }
  }

  /// 演示：测试策略说明
  void _showTestStrategy() {
    _addLog('--- 网络测试策略 ---');
    _addLog('');
    _addLog('1️⃣ 单元测试（Unit Test）');
    _addLog('   测试对象：ApiService、Model');
    _addLog('   方式：注入 Mock Dio，验证逻辑');
    _addLog('   工具：mocktail / Mockito + Dio 拦截器');
    _addLog('');
    _addLog('2️⃣ 集成测试（Integration Test）');
    _addLog('   测试对象：完整网络流程');
    _addLog('   方式：启动 App，模拟用户操作');
    _addLog('   工具：integration_test + Mock Server');
    _addLog('');
    _addLog('3️⃣ 端到端测试（E2E Test）');
    _addLog('   测试对象：真实 API 调用');
    _addLog('   方式：调用 staging 环境 API');
    _addLog('   工具：真实网络');
    _addLog('');
    _addLog('💡 Mock 方式对比：');
    _addLog('   Dio 拦截器：轻量，无需额外依赖');
    _addLog('   Mocktail：类型安全，编译时检查');
    _addLog('   MockServer：最接近真实场景');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('测试演示')),
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
                  '测试要点：\n'
                  '• 依赖注入：Dio 通过构造函数传入\n'
                  '• Interceptor 模拟：无需 mock 库\n'
                  '• 测试三种场景：成功/失败/边界\n'
                  '• 分层测试：单元 → 集成 → 端到端',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _demoMockWithInterceptor,
                  child: const Text('Mock 成功'),
                ),
                ElevatedButton(
                  onPressed: _demoMockFailure,
                  child: const Text('Mock 失败'),
                ),
                OutlinedButton(
                  onPressed: _showTestStrategy,
                  child: const Text('测试策略'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击查看测试演示'))
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
