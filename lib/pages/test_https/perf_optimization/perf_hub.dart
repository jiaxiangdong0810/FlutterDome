import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../router/app_router.gr.dart';

/// 性能优化专题入口
@RoutePage()
class PerfOptimizationPage extends StatelessWidget {
  const PerfOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('性能优化')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LessonCard(
            icon: Icons.timer,
            title: '请求防抖',
            subtitle: 'Debounce 避免频繁请求，适用于搜索框',
            onTap: () => context.router.push(const RequestDebounceRoute()),
          ),
          _LessonCard(
            icon: Icons.format_list_numbered,
            title: '分页加载',
            subtitle: '滚动加载更多 + 下拉刷新',
            onTap: () => context.router.push(const PaginationDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.upload_file,
            title: '分块上传 + 断点续传',
            subtitle: '大文件分片上传、失败后从断点继续',
            onTap: () => context.router.push(const ChunkedUploadDemoRoute()),
          ),
          _LessonCard(
            icon: Icons.memory,
            title: 'Isolate JSON 解析',
            subtitle: '后台线程解析大型 JSON，不阻塞 UI',
            onTap: () => context.router.push(const IsolateParseDemoRoute()),
          ),
        ],
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
