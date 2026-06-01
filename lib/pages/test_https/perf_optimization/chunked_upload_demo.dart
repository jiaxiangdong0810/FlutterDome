import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// 分块上传 + 断点续传演示
///
/// 知识点：
/// - 大文件分片：将文件切分为多个 chunk
/// - 逐块上传：每块独立上传，失败后只重传失败的块
/// - 断点续传：记录已上传块，跳过已完成的部分
/// - 进度跟踪：每块上传后更新整体进度
@RoutePage()
class ChunkedUploadDemoPage extends StatefulWidget {
  const ChunkedUploadDemoPage({super.key});

  @override
  State<ChunkedUploadDemoPage> createState() => _ChunkedUploadDemoPageState();
}

class _ChunkedUploadDemoPageState extends State<ChunkedUploadDemoPage> {
  final List<String> _logs = [];
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://httpbin.org',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // 上传状态
  int _totalChunks = 0;
  int _uploadedChunks = 0;
  bool _isUploading = false;
  bool _isPaused = false;
  String? _uploadId;

  // 已完成的分块（用于断点续传）
  final Set<int> _completedChunks = {};

  // 模拟文件大小
  static const int _fileSize = 1024 * 500; // 500KB
  static const int _chunkSize = 1024 * 50; // 50KB per chunk

  /// 开始分块上传
  Future<void> _startUpload() async {
    _totalChunks = (_fileSize / _chunkSize).ceil();
    _uploadId = 'upload_${DateTime.now().millisecondsSinceEpoch}';
    _completedChunks.clear();
    _uploadedChunks = 0;
    _isPaused = false;

    setState(() => _isUploading = true);
    _addLog('--- 开始分块上传 ---');
    _addLog('文件大小: ${(_fileSize / 1024).toStringAsFixed(0)} KB');
    _addLog('分块大小: ${(_chunkSize / 1024).toStringAsFixed(0)} KB');
    _addLog('总块数: $_totalChunks');
    _addLog('上传ID: $_uploadId');

    await _uploadChunks();
  }

  /// 逐块上传
  Future<void> _uploadChunks() async {
    for (int i = 0; i < _totalChunks; i++) {
      // 暂停检查
      if (_isPaused) {
        _addLog('⏸️ 已暂停，$_uploadedChunks/$_totalChunks 块已上传');
        return;
      }

      // 断点续传：跳过已完成的块
      if (_completedChunks.contains(i)) {
        _addLog('⏭️ 跳过第 $i 块（已上传）');
        continue;
      }

      try {
        // 模拟上传分块
        final chunkData = _generateChunk(i);
        _addLog('📤 上传第 $i 块 (${(chunkData.length / 1024).toStringAsFixed(1)} KB)');

        // 模拟网络请求（httpbin 会回显数据）
        await _dio.post(
          '/post',
          data: FormData.fromMap({
            'upload_id': _uploadId,
            'chunk_index': i,
            'total_chunks': _totalChunks,
            'data': MultipartFile.fromBytes(
              chunkData,
              filename: 'chunk_$i.bin',
            ),
          }),
        );

        // 标记为完成
        _completedChunks.add(i);
        _uploadedChunks = i + 1;
        setState(() {});
        _addLog('✅ 第 $i 块上传成功 ($_uploadedChunks/$_totalChunks)');

        // 模拟网络延迟
        await Future.delayed(const Duration(milliseconds: 300));
      } on DioException catch (e) {
        _addLog('❌ 第 $i 块上传失败: ${e.type}');
        _addLog('💡 可点击"继续上传"从断点恢复');
        setState(() => _isUploading = false);
        return;
      }
    }

    _addLog('🎉 所有分块上传完成！');
    setState(() => _isUploading = false);
  }

  /// 暂停上传
  void _pauseUpload() {
    _isPaused = true;
    _addLog('⏸️ 暂停上传');
  }

  /// 继续上传（断点续传）
  Future<void> _resumeUpload() async {
    if (_completedChunks.isEmpty) {
      _addLog('没有可恢复的上传');
      return;
    }

    _isPaused = false;
    setState(() => _isUploading = true);
    _addLog('▶️ 继续上传（从第 ${_findNextChunk()} 块开始）');

    await _uploadChunks();
  }

  /// 模拟某块上传失败
  Future<void> _simulateFailure() async {
    if (_totalChunks == 0) {
      _addLog('请先开始上传');
      return;
    }

    final nextChunk = _findNextChunk();
    if (nextChunk < _totalChunks) {
      _addLog('💥 模拟第 $nextChunk 块上传失败');
      _addLog('💡 该块未标记为完成，继续上传时会重传');
    }
  }

  int _findNextChunk() {
    for (int i = 0; i < _totalChunks; i++) {
      if (!_completedChunks.contains(i)) return i;
    }
    return _totalChunks;
  }

  /// 生成模拟分块数据
  List<int> _generateChunk(int index) {
    final random = Random(index);
    final size = min(_chunkSize, _fileSize - index * _chunkSize);
    return List.generate(size, (_) => random.nextInt(256));
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
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalChunks > 0 ? _uploadedChunks / _totalChunks : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('分块上传 + 断点续传')),
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
                  '分块上传要点：\n'
                  '• 大文件切分为固定大小的 chunk\n'
                  '• 逐块上传，记录已完成的块\n'
                  '• 失败后只重传失败的块（断点续传）\n'
                  '• 暂停/继续：随时中断和恢复',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 进度条
            if (_totalChunks > 0) ...[
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$_uploadedChunks / $_totalChunks 块 | '
                '已完成: ${_completedChunks.join(", ")}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
            // 操作按钮
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _isUploading ? null : _startUpload,
                  child: const Text('开始上传'),
                ),
                ElevatedButton(
                  onPressed: _isUploading ? _pauseUpload : null,
                  child: const Text('暂停'),
                ),
                ElevatedButton(
                  onPressed: (!_isUploading && _completedChunks.isNotEmpty)
                      ? _resumeUpload
                      : null,
                  child: const Text('继续上传'),
                ),
                OutlinedButton(
                  onPressed: _simulateFailure,
                  child: const Text('模拟失败'),
                ),
                OutlinedButton(
                  onPressed: _clearLogs,
                  child: const Text('清空日志'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 日志
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _logs.isEmpty
                    ? const Center(child: Text('点击"开始上传"查看分块上传过程'))
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
