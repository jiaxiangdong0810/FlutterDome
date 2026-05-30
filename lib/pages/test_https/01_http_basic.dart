import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// 01 - HTTP 协议基础 + JSON 编解码
///
/// 知识点：
/// - HTTP 请求方法（GET / POST / PUT / DELETE）
/// - HTTP 状态码含义
/// - dart:convert 的 jsonEncode / jsonDecode
@RoutePage()
class HttpBasicPage extends StatefulWidget {
  const HttpBasicPage({super.key});

  @override
  State<HttpBasicPage> createState() => _HttpBasicPageState();
}

class _HttpBasicPageState extends State<HttpBasicPage> {
  String _jsonOutput = '点击按钮开始演示';

  // ========== 知识点 1：JSON 编解码 ==========

  /// jsonEncode: Map → JSON 字符串
  void _demoEncode() {
    final user = {
      'name': '张三',
      'age': 25,
      'email': 'zhangsan@example.com',
      'hobbies': ['coding', 'reading'],
      'address': {
        'city': '北京',
        'district': '海淀',
      },
    };

    final jsonString = jsonEncode(user);
    setState(() {
      _jsonOutput = '【jsonEncode 编码】\n\n'
          'Dart Map:\n$user\n\n'
          'JSON 字符串:\n$jsonString';
    });
  }

  /// jsonDecode: JSON 字符串 → Map
  void _demoDecode() {
    const jsonString = '''
    {
      "id": 1,
      "title": "学习 Flutter",
      "completed": false,
      "tags": ["flutter", "dart"]
    }''';

    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    setState(() {
      _jsonOutput = '【jsonDecode 解码】\n\n'
          '原始 JSON:\n$jsonString\n\n'
          '解析后的 Map:\n$decoded\n\n'
          '取值演示:\n'
          '  decoded["title"] = ${decoded["title"]}\n'
          '  decoded["tags"]   = ${decoded["tags"]}\n'
          '  decoded["tags"][0] = ${decoded["tags"][0]}';
    });
  }

  /// 实际场景：解析 API 返回的 JSON
  void _demoParseApiResponse() {
    // 模拟一个典型的 API 响应
    const apiResponse = '''
    {
      "code": 200,
      "message": "success",
      "data": {
        "users": [
          {"id": 1, "name": "Alice", "role": "admin"},
          {"id": 2, "name": "Bob", "role": "user"},
          {"id": 3, "name": "Charlie", "role": "user"}
        ],
        "total": 3,
        "page": 1
      }
    }''';

    final response = jsonDecode(apiResponse);
    final users = response['data']['users'] as List;
    final total = response['data']['total'];

    final buffer = StringBuffer();
    buffer.writeln('【解析 API 响应】\n');
    buffer.writeln('状态: ${response['message']}');
    buffer.writeln('总数: $total\n');
    buffer.writeln('用户列表:');
    for (final user in users) {
      buffer.writeln('  [${user["id"]}] ${user["name"]} - ${user["role"]}');
    }

    setState(() {
      _jsonOutput = buffer.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 HTTP 协议基础')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- HTTP 方法知识卡片 ----------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HTTP 请求方法',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _methodRow('GET', '获取资源', Colors.green),
                    _methodRow('POST', '创建资源', Colors.blue),
                    _methodRow('PUT', '更新资源（全量）', Colors.orange),
                    _methodRow('DELETE', '删除资源', Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ---------- 状态码知识卡片 ----------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('常见状态码',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _statusRow('200', 'OK - 请求成功'),
                    _statusRow('201', 'Created - 资源创建成功'),
                    _statusRow('400', 'Bad Request - 请求参数错误'),
                    _statusRow('401', 'Unauthorized - 未认证'),
                    _statusRow('403', 'Forbidden - 无权限'),
                    _statusRow('404', 'Not Found - 资源不存在'),
                    _statusRow('500', 'Internal Server Error - 服务器错误'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ---------- JSON 演示按钮 ----------
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _demoEncode,
                  child: const Text('jsonEncode'),
                ),
                ElevatedButton(
                  onPressed: _demoDecode,
                  child: const Text('jsonDecode'),
                ),
                ElevatedButton(
                  onPressed: _demoParseApiResponse,
                  child: const Text('解析 API 响应'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ---------- 输出区域 ----------
            Container(
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _jsonOutput,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodRow(String method, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(method,
                style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ),
          Expanded(child: Text(desc)),
        ],
      ),
    );
  }

  Widget _statusRow(String code, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(code,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(desc)),
        ],
      ),
    );
  }
}
