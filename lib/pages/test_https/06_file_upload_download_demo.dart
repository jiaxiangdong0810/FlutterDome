import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// 06 - 文件上传与下载
///
/// 知识点：
/// - MultipartFile 文件上传
/// - FormData 表单提交
/// - download 下载文件 + 进度监听
/// - Upload 进度监听
@RoutePage()
class FileUploadDownloadDemoPage extends StatefulWidget {
  const FileUploadDownloadDemoPage({super.key});

  @override
  State<FileUploadDownloadDemoPage> createState() =>
      _FileUploadDownloadDemoPageState();
}

class _FileUploadDownloadDemoPageState
    extends State<FileUploadDownloadDemoPage> {
  String _output = '点击按钮开始演示';
  bool _loading = false;
  double _progress = 0;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://httpbin.org',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  ));

  /// 演示：FormData 表单提交
  ///
  /// 知识点：FormData 封装表单字段 + 文件
  Future<void> _demoFormData() async {
    _setLoading(true);
    try {
      // 知识点：FormData 可以包含普通字段和文件
      final formData = FormData.fromMap({
        // 普通字段
        'name': 'Flutter 学习',
        'description': '文件上传演示',

        // 知识点：MultipartFile.fromBytes 创建内存中的文件
        'file': MultipartFile.fromBytes(
          [80, 68, 70, 32, 102, 105, 108, 101], // "PDF file" 的 ASCII
          filename: 'demo.txt',
        ),
      });

      // httpbin.org/post 会回显我们发送的数据
      final response = await _dio.post('/post', data: formData);

      final files = response.data['files'] ?? {};
      final form = response.data['form'] ?? {};

      setState(() {
        _output = '【FormData 表单提交】\n\n'
            '状态码: ${response.statusCode}\n\n'
            '普通字段:\n'
            '  name: ${form["name"]}\n'
            '  description: ${form["description"]}\n\n'
            '文件字段:\n'
            '  files: $files\n\n'
            '💡 上传文件的方式：\n'
            '  MultipartFile.fromPath(filePath)  → 从文件路径\n'
            '  MultipartFile.fromBytes(bytes)     → 从内存数据\n'
            '  MultipartFile.fromString(str)      → 从字符串';
      });
    } on DioException catch (e) {
      setState(() => _output = '上传失败: ${e.message}');
    } finally {
      _setLoading(false);
    }
  }

  /// 演示：上传进度监听
  ///
  /// 知识点：通过 onSendProgress 监听上传进度
  Future<void> _demoUploadProgress() async {
    _setLoading(true);
    setState(() {
      _progress = 0;
      _output = '上传中...';
    });

    try {
      // 创建一个较大的数据来演示进度
      final largeData = List.filled(1024 * 100, 65); // 100KB 的 'A'
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          largeData,
          filename: 'large_file.bin',
        ),
      });

      await _dio.post(
        '/post',
        data: formData,
        // 知识点：onSendProgress 监听上传进度
        onSendProgress: (sent, total) {
          setState(() {
            _progress = sent / total;
            _output = '上传中... ${( _progress * 100).toStringAsFixed(1)}%\n'
                '已发送: ${(sent / 1024).toStringAsFixed(1)} KB\n'
                '总大小: ${(total / 1024).toStringAsFixed(1)} KB';
          });
        },
      );

      setState(() {
        _output = '【上传完成】\n\n'
            '进度: 100%\n\n'
            '💡 onSendProgress: (int sent, int total)\n'
            '  sent  → 已发送字节数\n'
            '  total → 总字节数\n'
            '  进度 = sent / total';
      });
    } on DioException catch (e) {
      setState(() => _output = '上传失败: ${e.message}');
    } finally {
      _setLoading(false);
    }
  }

  /// 演示：文件下载 + 进度
  ///
  /// 知识点：dio.download 下载文件到本地路径
  Future<void> _demoDownload() async {
    _setLoading(true);
    setState(() {
      _progress = 0;
      _output = '下载中...';
    });

    try {
      // 获取临时目录
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/downloaded_image.jpg';

      // 知识点：dio.download(url, savePath)
      // savePath 是文件保存的完整路径
      await _dio.download(
        'https://via.placeholder.com/1500/FF6B6B/FFFFFF?text=Flutter',
        savePath,
        // 知识点：onReceiveProgress 监听下载进度
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _progress = received / total;
              _output = '下载中... ${(_progress * 100).toStringAsFixed(1)}%\n'
                  '已下载: ${(received / 1024).toStringAsFixed(1)} KB\n'
                  '总大小: ${(total / 1024).toStringAsFixed(1)} KB';
            });
          }
        },
      );

      // 验证文件
      final file = File(savePath);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;

      setState(() {
        _output = '【下载完成】\n\n'
            '保存路径: $savePath\n'
            '文件存在: $exists\n'
            '文件大小: ${(size / 1024).toStringAsFixed(1)} KB\n\n'
            '💡 dio.download(url, savePath, onReceiveProgress: ...)\n'
            '  • savePath 必须是完整文件路径\n'
            '  • onReceiveProgress 回调下载进度\n'
            '  • 下载大文件建议增大 receiveTimeout';
      });
    } on DioException catch (e) {
      setState(() => _output = '下载失败: ${e.message}');
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
      appBar: AppBar(title: const Text('06 文件上传下载')),
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
                  '上传/下载要点：\n'
                  '• FormData.fromMap({...}) 构建表单\n'
                  '• MultipartFile 从文件/内存/字符串创建\n'
                  '• onSendProgress 监听上传进度\n'
                  '• dio.download + onReceiveProgress 监听下载进度',
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
                  onPressed: _loading ? null : _demoFormData,
                  child: const Text('FormData'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoUploadProgress,
                  child: const Text('上传进度'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _demoDownload,
                  child: const Text('下载 + 进度'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              Column(
                children: [
                  LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                  const SizedBox(height: 4),
                  if (_progress > 0)
                    Text('${(_progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                ],
              ),
            Container(
              height: 350,
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
