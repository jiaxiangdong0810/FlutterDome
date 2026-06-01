import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 12 - GraphQL 基础
///
/// 知识点：
/// - GraphQL 与 REST 的区别
/// - Query 查询
/// - Mutation 变更
/// - Variables 变量
/// - 使用 dio 发送 GraphQL 请求（无需额外依赖）
///
/// 使用公开 GraphQL API：https://graphql.org/swapi-graphql
@RoutePage()
class GraphQLDemoPage extends StatefulWidget {
  const GraphQLDemoPage({super.key});

  @override
  State<GraphQLDemoPage> createState() => _GraphQLDemoPageState();
}

class _GraphQLDemoPageState extends State<GraphQLDemoPage> {
  String _output = '点击按钮查看 GraphQL 演示';
  bool _loading = false;

  final Dio _dio = Dio(BaseOptions(
    // GraphQL 所有请求都发到同一个 endpoint
    baseUrl: 'https://graphql.org/swapi-graphql',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  /// 演示：GraphQL vs REST 对比
  void _showComparison() {
    setState(() {
      _output = '【GraphQL vs REST】\n\n'
          'REST API：\n'
          '  GET /users/1          → 获取用户\n'
          '  GET /users/1/posts    → 获取用户的帖子\n'
          '  GET /users/1/friends  → 获取用户的好友\n'
          '  → 3 次请求，返回 3 个完整 JSON\n\n'
          'GraphQL：\n'
          '  POST /graphql\n'
          '  query {\n'
          '    user(id: 1) {\n'
          '      name\n'
          '      posts { title }\n'
          '      friends { name }\n'
          '    }\n'
          '  }\n'
          '  → 1 次请求，只返回需要的字段\n\n'
          '💡 核心优势：\n'
          '  • 按需获取：客户端决定返回哪些字段\n'
          '  • 单一端点：所有请求发到 /graphql\n'
          '  • 强类型：Schema 定义数据结构\n'
          '  • 减少请求：一次查询获取关联数据';
    });
  }

  /// 演示：Query 查询
  ///
  /// 知识点：GraphQL Query 用于获取数据
  Future<void> _demoQuery() async {
    _setLoading(true);
    try {
      // 知识点：GraphQL 请求体结构
      final response = await _dio.post('', data: {
        'query': '''
          query {
            allFilms(first: 3) {
              films {
                title
                director
                releaseDate
                openingCrawl
              }
            }
          }
        ''',
      });

      final films = response.data['data']['allFilms']['films'] as List;
      final buffer = StringBuffer();
      buffer.writeln('【GraphQL Query 查询】');
      buffer.writeln('获取前 3 部星球大战电影\n');
      for (final film in films) {
        buffer.writeln('🎬 ${film["title"]}');
        buffer.writeln('   导演: ${film["director"]}');
        buffer.writeln('   上映: ${film["releaseDate"]}');
        buffer.writeln('');
      }
      buffer.writeln('💡 Query = REST 的 GET，用于读取数据');

      setState(() => _output = buffer.toString());
    } on DioException catch (e) {
      setState(() => _output = '查询失败: ${e.message}');
    } finally {
      _setLoading(false);
    }
  }

  /// 演示：Variables 变量
  ///
  /// 知识点：用变量替代硬编码的参数
  Future<void> _demoVariables() async {
    _setLoading(true);
    try {
      // 知识点：用 \$id 声明变量，在 variables 中传值
      final response = await _dio.post('', data: {
        'query': r'''
          query GetPerson($id: ID!) {
            person(id: $id) {
              name
              birthYear
              eyeColor
              hairColor
              height
              mass
              homeworld {
                name
              }
            }
          }
        ''',
        'variables': {
          'id': 'cGVvcGxlOjE=', // Luke Skywalker 的 base64 ID
        },
      });

      final person = response.data['data']['person'];
      setState(() {
        _output = '【GraphQL Variables 变量】\n\n'
            '👤 ${person["name"]}\n'
            '   出生年: ${person["birthYear"]}\n'
            '   眼睛: ${person["eyeColor"]}\n'
            '   头发: ${person["hairColor"]}\n'
            '   身高: ${person["height"]}\n'
            '   体重: ${person["mass"]}\n'
            '   母星: ${person["homeworld"]["name"]}\n\n'
            '💡 Variables 好处：\n'
            '  • 避免字符串拼接\n'
            '  • 防止注入攻击\n'
            '  • 可复用同一 query 不同参数';
      });
    } on DioException catch (e) {
      setState(() => _output = '查询失败: ${e.message}');
    } finally {
      _setLoading(false);
    }
  }

  /// 演示：嵌套查询
  ///
  /// 知识点：一次请求获取关联数据
  Future<void> _demoNestedQuery() async {
    _setLoading(true);
    try {
      final response = await _dio.post('', data: {
        'query': '''
          query {
            allPlanets(first: 2) {
              planets {
                name
                climates
                terrains
                population
                residentConnection(first: 2) {
                  residents {
                    name
                    birthYear
                  }
                }
              }
            }
          }
        ''',
      });

      final planets = response.data['data']['allPlanets']['planets'] as List;
      final buffer = StringBuffer();
      buffer.writeln('【GraphQL 嵌套查询】');
      buffer.writeln('一次请求获取：星球 + 居民信息\n');
      for (final planet in planets) {
        buffer.writeln('🌍 ${planet["name"]}');
        buffer.writeln('   气候: ${planet["climates"]}');
        buffer.writeln('   地形: ${planet["terrains"]}');
        final residents = planet['residentConnection']['residents'] as List;
        if (residents.isNotEmpty) {
          buffer.writeln('   居民:');
          for (final r in residents) {
            buffer.writeln('     - ${r["name"]} (${r["birthYear"]})');
          }
        }
        buffer.writeln('');
      }
      buffer.writeln('💡 REST 需要多次请求，GraphQL 一次搞定');

      setState(() => _output = buffer.toString());
    } on DioException catch (e) {
      setState(() => _output = '查询失败: ${e.message}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('12 GraphQL 基础')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'GraphQL 要点：\n'
                  '• 单一端点 POST /graphql\n'
                  '• Query 读取数据，Mutation 修改数据\n'
                  '• Variables 参数化查询\n'
                  '• 按需获取字段，减少数据传输',
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
                  onPressed: _loading ? null : _showComparison,
                  child: const Text('对比 REST'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoQuery,
                  child: const Text('Query 查询'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoVariables,
                  child: const Text('Variables'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoNestedQuery,
                  child: const Text('嵌套查询'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Container(
              height: 450,
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
