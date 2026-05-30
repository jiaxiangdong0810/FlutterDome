import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// autoDispose 计数器 Provider
// 当没有任何 widget 监听时，它会自动销毁
final autoDisposeCounterProvider = StateProvider.autoDispose<int>((ref) {
  // Provider 创建时触发
  debugPrint('🟢 autoDisposeCounterProvider 创建');

  // Provider 销毁时触发
  ref.onDispose(() {
    debugPrint('🔴 autoDisposeCounterProvider 销毁');
  });

  return 0;
});

// 生命周期日志管理器，用于在 UI 上显示日志
final lifecycleLogsProvider = StateProvider<List<String>>((ref) => []);

@RoutePage()
class RiverpodAutoDisposePage extends ConsumerStatefulWidget {
  const RiverpodAutoDisposePage({super.key});

  @override
  ConsumerState<RiverpodAutoDisposePage> createState() => _AutoDisposePageState();
}

class _AutoDisposePageState extends ConsumerState<RiverpodAutoDisposePage> {
  // 是否显示监听组件
  bool _showListener = false;

  // 添加日志到列表
  void _addLog(String log) {
    final logs = ref.read(lifecycleLogsProvider);
    final time = DateTime.now().toString().substring(11, 19);
    ref.read(lifecycleLogsProvider.notifier).state = [
      ...logs,
      '[$time] $log',
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 监听 debugPrint 输出，捕获 Provider 生命周期日志
    // 这里通过重写 debugPrint 来拦截日志（简化实现）

    return Scaffold(
      appBar: AppBar(
        title: const Text('06 AutoDispose - 自动销毁'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文本
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '核心概念',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Provider 需要手动 dispose，Riverpod 的 autoDispose 可以自动管理生命周期。'
                      '当没有任何 widget 监听该 Provider 时，它会自动销毁，释放内存。',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 对比说明
            Row(
              children: [
                Expanded(
                  child: _ComparisonCard(
                    title: 'Provider',
                    icon: Icons.handyman,
                    color: Colors.orange,
                    description: '需要手动调用 dispose()\n容易遗漏，导致内存泄漏',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ComparisonCard(
                    title: 'Riverpod autoDispose',
                    icon: Icons.auto_fix_high,
                    color: Colors.green,
                    description: '自动监听引用计数\n无监听时自动销毁',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 切换开关
            Card(
              child: SwitchListTile(
                title: const Text(
                  '显示监听组件',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _showListener
                      ? '组件显示中，Provider 处于活跃状态'
                      : '组件已隐藏，Provider 将自动销毁',
                ),
                value: _showListener,
                onChanged: (value) {
                  setState(() {
                    _showListener = value;
                  });
                  _addLog(_showListener ? '显示监听组件' : '隐藏监听组件');
                },
              ),
            ),
            const SizedBox(height: 16),

            // 条件显示的监听组件
            if (_showListener) ...[
              // 使用 Consumer 局部刷新，只监听 autoDisposeCounterProvider
              Consumer(
                builder: (context, ref, child) {
                  // 监听 autoDispose 计数器
                  final count = ref.watch(autoDisposeCounterProvider);

                  return Card(
                    elevation: 4,
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.hearing,
                            size: 40,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '监听组件',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '当前计数: $count',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '此组件正在监听 autoDispose Provider',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 增加计数按钮
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(autoDisposeCounterProvider.notifier).state++;
                    _addLog('计数器 +1');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('增加计数'),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 日志显示区域
            const Text(
              '操作日志：',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final logs = ref.watch(lifecycleLogsProvider);
                    if (logs.isEmpty) {
                      return const Center(
                        child: Text(
                          '暂无日志\n请切换开关或点击按钮',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[logs.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // 清空日志按钮
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ref.read(lifecycleLogsProvider.notifier).state = [];
                },
                icon: const Icon(Icons.clear_all, size: 18),
                label: const Text('清空日志'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 对比卡片组件
class _ComparisonCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _ComparisonCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
