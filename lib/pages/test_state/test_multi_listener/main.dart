import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// ChangeNotifier 多订阅者演示页面
///
/// 核心知识点：ChangeNotifier 内部维护一个 List<VoidCallback>，
/// 允许多个"听众"同时订阅同一个状态对象。
///
/// 本页面展示 4 类不同的听众同时监听同一个 AppState：
/// 1. InheritedNotifier（UI 重建）
/// 2. 手动 addListener（日志记录）
/// 3. 手动 addListener（数据持久化）
/// 4. 手动 addListener（跨组件通信）
@RoutePage()
class MultiListenerPage extends StatefulWidget {
  const MultiListenerPage({super.key});

  @override
  State<MultiListenerPage> createState() => _MultiListenerPageState();
}

class _MultiListenerPageState extends State<MultiListenerPage> {
  late final AppState _state;

  // 监听器1：日志记录器（手动订阅）
  late final _LoggerListener _logger;

  // 监听器2：持久化存储（手动订阅）
  late final _StorageListener _storage;

  // 监听器3：跨组件通信（手动订阅）
  late final _AnalyticsListener _analytics;

  // 记录每次 notifyListeners 时触发了几位听众
  final List<String> _notifyLog = [];

  @override
  void initState() {
    super.initState();
    _state = AppState();

    // 创建各个听众
    _logger = _LoggerListener();
    _storage = _StorageListener();
    _analytics = _AnalyticsListener();

    // 把它们都加入 ChangeNotifier 的监听器列表
    _state.addListener(_logger.onNotify);
    _state.addListener(_storage.onNotify);
    _state.addListener(_analytics.onNotify);

    // 再加一个内联监听器，用来记录触发次数
    _state.addListener(() {
      setState(() {
        _notifyLog.add(
          '第 ${_state.notifyCount} 次通知：'
          'counter=${_state.counter}, '
          'listeners=${_state.listenerCount}',
        );
      });
    });
  }

  @override
  void dispose() {
    // 必须按顺序移除所有手动添加的监听器！
    _state.removeListener(_analytics.onNotify);
    _state.removeListener(_storage.onNotify);
    _state.removeListener(_logger.onNotify);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppInfo(
      notifier: _state,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ChangeNotifier 多订阅者演示'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ListenerInfoCard(),
              SizedBox(height: 16),
              _CounterDisplay(),
              SizedBox(height: 16),
              _ListenerOutputCard(),
            ],
          ),
        ),
        floatingActionButton: const _ActionButtons(),
      ),
    );
  }
}

// ============================================
// 1. AppState：ChangeNotifier（广播站）
// ============================================

/// 应用状态类
///
/// 内部维护 _listeners 列表（继承自 ChangeNotifier）。
/// 每次 notifyListeners() 都会遍历这个列表，调用所有回调。
class AppState extends ChangeNotifier {
  int _counter = 0;
  int _notifyCount = 0;

  int get counter => _counter;
  int get notifyCount => _notifyCount;

  /// 获取当前监听器数量（展示 List 的存在）
  int get listenerCount {
    // ChangeNotifier 的 _listeners 是私有的，
    // 这里通过反射或额外计数来展示。
    // 实际开发中不需要这个，仅用于教学。
    // 我们通过外部计数来模拟：
    return _externalListenerCount;
  }

  int _externalListenerCount = 0;
  void setExternalListenerCount(int count) => _externalListenerCount = count;

  void increment() {
    _counter++;
    _notifyCount++;
    notifyListeners(); // 遍历 _listeners，调用所有回调
  }

  void decrement() {
    _counter--;
    _notifyCount++;
    notifyListeners();
  }

  void reset() {
    _counter = 0;
    _notifyCount++;
    notifyListeners();
  }
}

// ============================================
// 2. 各类"听众"（订阅者）
// ============================================

/// 听众 1：日志记录器
///
/// 每次状态变化时打印日志。
/// 它不关心 UI，只关心数据变化事件。
class _LoggerListener {
  int _logCount = 0;

  void onNotify() {
    _logCount++;
    // ignore: avoid_print
    print('📝 [Logger] 状态变化 #$_logCount');
  }
}

/// 听众 2：持久化存储
///
/// 模拟将数据保存到本地存储。
/// 实际场景中可能是 SharedPreferences、SQLite 等。
class _StorageListener {
  int _saveCount = 0;

  void onNotify() {
    _saveCount++;
    // ignore: avoid_print
    print('💾 [Storage] 保存数据 #$_saveCount');
  }
}

/// 听众 3：数据分析
///
/// 模拟上报统计事件。
/// 实际场景中可能是 Firebase Analytics、友盟等。
class _AnalyticsListener {
  int _eventCount = 0;

  void onNotify() {
    _eventCount++;
    // ignore: avoid_print
    print('📊 [Analytics] 上报事件 #$_eventCount');
  }
}

// ============================================
// 3. AppInfo：InheritedNotifier（听众 4）
// ============================================

class AppInfo extends InheritedNotifier<AppState> {
  const AppInfo({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AppInfo>()!;
    return widget.notifier!;
  }
}

// ============================================
// 4. UI 组件
// ============================================

/// 监听器信息说明卡片
class _ListenerInfoCard extends StatelessWidget {
  const _ListenerInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ChangeNotifier 的 List<_listeners>',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '同一个 AppState 实例被 4 个听众同时订阅：',
            ),
            const SizedBox(height: 8),
            _buildListenerRow('1️⃣', 'InheritedNotifier', '触发 UI 重建'),
            _buildListenerRow('2️⃣', '_LoggerListener', '打印日志'),
            _buildListenerRow('3️⃣', '_StorageListener', '持久化数据'),
            _buildListenerRow('4️⃣', '_AnalyticsListener', '上报统计'),
            const SizedBox(height: 12),
            Text(
              '每次调用 notifyListeners()，这 4 个回调都会被依次执行。',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenerRow(String emoji, String name, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$name → $action',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// 计数器显示（通过 InheritedNotifier 订阅）
class _CounterDisplay extends StatelessWidget {
  const _CounterDisplay();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Text(
                '当前计数',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.counter}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '已触发 ${state.notifyCount} 次通知',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 操作按钮
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final state = AppInfo.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'decrement',
          onPressed: state.decrement,
          child: const Icon(Icons.remove),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: 'reset',
          onPressed: state.reset,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: 'increment',
          onPressed: state.increment,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// 监听器输出记录
class _ListenerOutputCard extends StatefulWidget {
  const _ListenerOutputCard();

  @override
  State<_ListenerOutputCard> createState() => _ListenerOutputCardState();
}

class _ListenerOutputCardState extends State<_ListenerOutputCard> {
  // 这个 StatefulWidget 也手动订阅了 AppState，
  // 用来展示"不通过 InheritedNotifier 也能监听"。
  // 实际在这个页面中，我们通过父组件的 _notifyLog 来展示。

  @override
  Widget build(BuildContext context) {
    // 获取父组件的状态来展示日志
    final pageState = context.findAncestorStateOfType<_MultiListenerPageState>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通知日志（观察控制台输出）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '每次点击按钮，控制台会输出 3 行日志（Logger/Storage/Analytics），'
              '同时 UI 也会重建。',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pageState._notifyLog.isEmpty
                    ? [
                        const Text(
                          '点击按钮查看效果...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ]
                    : pageState._notifyLog.reversed.map((log) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
