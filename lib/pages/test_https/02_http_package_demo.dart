import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// 02 - package:http 入门演示
///
/// 知识点：
/// - http.get / http.post 发送请求
/// - 设置请求头
/// - 处理响应（statusCode / body）
/// - 错误处理
///
/// 使用公开测试 API：https://jsonplaceholder.typicode.com
@RoutePage()
class HttpPackageDemoPage extends StatefulWidget {
  const HttpPackageDemoPage({super.key});

  @override
  State<HttpPackageDemoPage> createState() => _HttpPackageDemoPageState();
}

class _HttpPackageDemoPageState extends State<HttpPackageDemoPage> {
  String _output = '点击按钮发送请求';
  bool _loading = false;

  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  /// GET 请求 - 获取单条数据
  Future<void> _demoGet() async {
    _setLoading(true);
    try {
      // 知识点：http.get 发送 GET 请求
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );

      // 知识点：通过 statusCode 判断请求是否成功
      if (response.statusCode == 200) {
        // 知识点：response.body 是 JSON 字符串，用 jsonDecode 解析
        final data = jsonDecode(response.body);
        setState(() {
          _output = '【GET 请求成功】\n\n'
              '状态码: ${response.statusCode}\n'
              '标题: ${data["title"]}\n'
              '内容: ${data["body"]}\n\n'
              '原始响应:\n${const JsonEncoder.withIndent("  ").convert(data)}';
        });
      } else {
        setState(() {
          _output = '请求失败: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _output = '请求异常: $e';
      });
    } finally {
      _setLoading(false);
    }
  }

  /// GET 请求 - 获取列表
  Future<void> _demoGetList() async {
    _setLoading(true);
    try {
      // 知识点：请求头设置（自定义 Headers）
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=5'),
        headers: {
          'Accept': 'application/json',
          'X-Custom-Header': 'FlutterDemo',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> posts = jsonDecode(response.body);
        final buffer = StringBuffer();
        buffer.writeln('【GET 列表请求成功】');
        buffer.writeln('状态码: ${response.statusCode}');
        buffer.writeln('返回 ${posts.length} 条数据\n');
        for (final post in posts) {
          buffer.writeln('[${post["id"]}] ${post["title"]}');
        }
        setState(() => _output = buffer.toString());
      } else {
        setState(() => _output = '请求失败: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _output = '请求异常: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// POST 请求 - 创建数据
  Future<void> _demoPost() async {
    _setLoading(true);
    try {
      // 知识点：http.post 发送 POST 请求
      // body 传 JSON 字符串，需要设置 Content-Type
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': 'Flutter 学习笔记',
          'body': '今天学习了 http 包的使用',
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          _output = '【POST 请求成功】\n\n'
              '状态码: ${response.statusCode} (Created)\n'
              '返回的 ID: ${data["id"]}\n\n'
              '请求体:\n  title: ${data["title"]}\n  body: ${data["body"]}\n  userId: ${data["userId"]}';
        });
      } else {
        setState(() => _output = '请求失败: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _output = '请求异常: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('02 http 包入门')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- 知识点提示 ----------
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '核心 API：\n'
                  '• http.get(uri, headers: {...})\n'
                  '• http.post(uri, headers: {...}, body: jsonStr)\n'
                  '• response.statusCode / response.body',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ---------- 操作按钮 ----------
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _demoGet,
                  child: const Text('GET 单条'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoGetList,
                  child: const Text('GET 列表'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoPost,
                  child: const Text('POST 创建'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            // ---------- 输出区域 ----------
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _output,
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
}
