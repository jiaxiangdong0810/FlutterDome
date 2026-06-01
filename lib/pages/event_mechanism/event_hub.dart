import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/app_router.gr.dart';

@RoutePage()
class EventHubPage extends StatelessWidget {
  const EventHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('事件传递机制')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('一、基础篇：触摸事件与手势识别', Colors.blue),
          _buildTile(
            context,
            title: '1.1 Pointer 原始事件',
            subtitle: 'Listener | PointerDown/Move/Up/Cancel | 多指触控',
            icon: Icons.touch_app,
            color: Colors.blue,
            route: const PointerEventsRoute(),
          ),
          _buildTile(
            context,
            title: '1.2 手势识别器',
            subtitle: 'Tap | Drag | Scale | LongPress | RawGestureDetector',
            icon: Icons.gesture,
            color: Colors.blue,
            route: const GestureRecognizersRoute(),
          ),
          _buildTile(
            context,
            title: '1.3 手势竞技场',
            subtitle: 'GestureArena | accept/reject | 竞争与裁决',
            icon: Icons.stadium,
            color: Colors.blue,
            route: const GestureArenaRoute(),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('二、进阶篇：事件传递的完整链路', Colors.green),
          _buildTile(
            context,
            title: '2.1 命中测试（Hit Testing）',
            subtitle: 'HitTestBehavior | IgnorePointer | AbsorbPointer | 嵌套命中',
            icon: Icons.adjust,
            color: Colors.green,
            route: const HitTestingRoute(),
          ),
          _buildTile(
            context,
            title: '2.2 事件分发链路',
            subtitle: '向下命中 | 向上冒泡 | Pointer vs 手势触发顺序',
            icon: Icons.swap_vert,
            color: Colors.green,
            route: const EventDispatchRoute(),
          ),
          _buildComingSoon('2.3 Pointer 事件与手势的桥接'),

          const SizedBox(height: 24),
          _buildSectionHeader('三、高级篇：Widget 层的事件与通知', Colors.purple),
          _buildTile(
            context,
            title: '3.1 Notification 通知机制',
            subtitle: 'NotificationListener | dispatch | 自定义 Notification | 跨层通信',
            icon: Icons.notifications_active,
            color: Colors.purple,
            route: const NotificationDemoRoute(),
          ),
          _buildTile(
            context,
            title: '3.2 InheritedWidget 依赖传播',
            subtitle: 'dependOnInheritedWidgetOfExactType | updateShouldNotify | 依赖精细化',
            icon: Icons.device_hub,
            color: Colors.purple,
            route: const InheritedWidgetEventDemoRoute(),
          ),
          _buildTile(
            context,
            title: '3.3 Focus 与键盘事件传递',
            subtitle: 'FocusNode | KeyEvent | Shortcuts+Actions | 焦点遍历',
            icon: Icons.keyboard,
            color: Colors.purple,
            route: const FocusKeyboardDemoRoute(),
          ),
          _buildTile(
            context,
            title: '3.4 事件机制的调试',
            subtitle: '调试开关 | 事件日志 | GestureArena 诊断 | 焦点树转储',
            icon: Icons.bug_report,
            color: Colors.purple,
            route: const EventDebuggingDemoRoute(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required PageRouteInfo route,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.router.push(route),
      ),
    );
  }

  Widget _buildComingSoon(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade100,
          child: Icon(Icons.lock_outline, color: Colors.grey.shade400),
        ),
        title: Text(title, style: TextStyle(color: Colors.grey.shade500)),
        subtitle: Text('待开发', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
      ),
    );
  }
}
