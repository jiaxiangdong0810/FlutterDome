import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Dart 层环境配置演示
///
/// 使用 --dart-define=ENV=xxx 传入环境标识，通过 String.fromEnvironment 读取。
/// 优点：纯 Dart 实现，无需修改原生配置；缺点：无法区分应用名/图标/包名。
class DartEnvConfigDemo extends StatelessWidget {
  const DartEnvConfigDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    final config = AppConfig.current;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '方案一：Dart 层 --dart-define',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('环境标识 (ENV)', env.isEmpty ? 'dev (默认)' : env),
            _buildInfoRow('API Base URL', config.apiBaseUrl),
            _buildInfoRow('日志级别', config.logLevel.name),
            _buildInfoRow('调试菜单', config.enableDebugMenu ? '开启' : '关闭'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '运行命令：',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text('flutter run --dart-define=ENV=dev'),
                  const Text('flutter run --dart-define=ENV=prod'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
