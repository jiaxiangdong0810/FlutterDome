import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/app_router.gr.dart';

/// HTTP 学习路径 - 第一阶段：基础入门
///
/// 涵盖：
/// 1. HTTP 协议基础 + JSON 解析
/// 2. http 包使用
/// 3. dio 包使用
@RoutePage()
class TestHttpsPage extends StatelessWidget {
  const TestHttpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP 学习路径')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: '第一阶段：基础入门'),
          const SizedBox(height: 8),
          _LessonCard(
            icon: Icons.book,
            title: '01 HTTP 协议基础',
            subtitle: 'HTTP 方法、状态码、JSON 编解码',
            onTap: () => context.router.push(const HttpBasicRoute()),
          ),
          _LessonCard(
            icon: Icons.cloud_outlined,
            title: '02 http 包入门',
            subtitle: '使用 package:http 发送 GET/POST 请求',
            onTap: () => context.router.push(const HttpPackageDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.api,
            title: '03 dio 包入门',
            subtitle: '使用 dio 发送请求，对比 http 包',
            onTap: () => context.router.push(const DioBasicDemoRoute()),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: '第二阶段：进阶'),
          const SizedBox(height: 8),
          _LessonCard(
            icon: Icons.swap_horiz,
            title: '04 dio 拦截器',
            subtitle: 'Interceptor 统一加 token、日志、错误处理',
            onTap: () => context.router.push(const DioInterceptorDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.settings,
            title: '05 dio 高级配置',
            subtitle: 'BaseOptions、取消请求、重试机制',
            onTap: () => context.router.push(const DioAdvancedConfigRoute()),
          ),
          _LessonCard(
            icon: Icons.upload_file,
            title: '06 文件上传下载',
            subtitle: 'FormData、MultipartFile、进度监听',
            onTap: () => context.router.push(const FileUploadDownloadDemoRoute()),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: '第三阶段：架构层'),
          const SizedBox(height: 8),
          _LessonCard(
            icon: Icons.device_hub,
            title: '07 网络层封装',
            subtitle: '单例 DioClient、ApiResponse、统一错误处理',
            onTap: () => context.router.push(const DioClientDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.cached,
            title: '08 缓存策略',
            subtitle: '内存缓存、TTL 过期、拦截器缓存',
            onTap: () => context.router.push(const CacheStrategyDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.signal_wifi_off,
            title: '09 网络状态监听',
            subtitle: 'connectivity_plus、断网降级、重试队列',
            onTap: () => context.router.push(const NetworkStateDemoRoute()),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: '第四阶段：高级专题'),
          const SizedBox(height: 8),
          _LessonCard(
            icon: Icons.security,
            title: '10 认证与安全',
            subtitle: 'Token 自动刷新、请求签名、防重放',
            onTap: () => context.router.push(const AuthSecurityDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.sync,
            title: '11 WebSocket 实时通信',
            subtitle: '连接/心跳/自动重连',
            onTap: () => context.router.push(const WebSocketDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.query_stats,
            title: '12 GraphQL 基础',
            subtitle: 'Query/Mutation/Variables 对比 REST',
            onTap: () => context.router.push(const GraphQLDemoRoute()),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: '第五阶段：专家级'),
          const SizedBox(height: 8),
          _LessonCard(
            icon: Icons.speed,
            title: '性能优化',
            subtitle: '防抖、分页、分块上传、Isolate 解析',
            onTap: () => context.router.push(const PerfOptimizationRoute()),
          ),
          _LessonCard(
            icon: Icons.bug_report,
            title: '测试',
            subtitle: 'Mock 测试、依赖注入、测试策略',
            onTap: () => context.router.push(const HttpTestDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.architecture,
            title: 'Clean Architecture',
            subtitle: '分层架构、Repository 模式、依赖倒置',
            onTap: () => context.router.push(const ArchDemoRoute()),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LessonCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
