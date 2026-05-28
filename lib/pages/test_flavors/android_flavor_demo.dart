import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Android Flavor 配置演示
///
/// 使用 --flavor xxx 运行，在 android/app/build.gradle.kts 中定义 productFlavors。
/// 优点：可区分应用名、图标、包名，可同时安装多环境；缺点：需修改原生配置。
class AndroidFlavorDemo extends StatelessWidget {
  const AndroidFlavorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const flavor = String.fromEnvironment('FLUTTER_FLAVOR');
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
                Icon(Icons.android, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '方案二：Android Flavor',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              'Flavor',
              flavor.isEmpty ? '未使用 Flavor' : flavor,
            ),
            _buildInfoRow(
              '应用名称',
              flavor.isEmpty
                  ? 'untitled1'
                  : 'Flutter Demo ${flavor == 'prod' ? '' : flavor}',
            ),
            _buildInfoRow(
              '包名后缀',
              flavor.isEmpty || flavor == 'prod'
                  ? '无'
                  : '.$flavor',
            ),
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
                  const Text('flutter run --flavor dev'),
                  const Text('flutter run --flavor prod'),
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
