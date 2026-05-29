import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../config/app_config.dart';

/// 多环境配置（Flavors）演示入口页面
///
/// 读取当前环境标识，展示对应的配置。
/// 运行方式：
///   flutter run --flavor dev
///   flutter run --flavor prod
@RoutePage()
class FlavorsDemoPage extends StatelessWidget {
  const FlavorsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const flavor = String.fromEnvironment('FLUTTER_APP_FLAVOR');
    final config = AppConfig.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('多环境配置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('环境标识', [
              _buildRow('FLUTTER_APP_FLAVOR', flavor.isEmpty ? '未设置' : flavor),
            ]),
            const SizedBox(height: 16),
            _buildSection('当前配置', [
              _buildRow('环境名称', config.envName),
              _buildRow('API 地址', config.apiBaseUrl),
              _buildRow('日志级别', config.logLevel.name),
              _buildRow('调试菜单', config.enableDebugMenu ? '开启' : '关闭'),
            ]),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('运行命令：', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('flutter run --flavor dev'),
                  Text('flutter run --flavor prod'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
