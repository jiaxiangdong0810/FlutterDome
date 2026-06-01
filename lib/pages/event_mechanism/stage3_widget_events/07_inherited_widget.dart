import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// ==================== 自定义 InheritedWidget ====================

/// 主题色数据，通过 InheritedWidget 向下传递
class ThemeColorData extends InheritedWidget {
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;

  const ThemeColorData({
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
    required super.child,
  });

  static ThemeColorData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<ThemeColorData>();
    assert(data != null, 'ThemeColorData not found in context');
    return data!;
  }

  /// 安全获取，不注册依赖（不会触发 rebuild）
  static ThemeColorData? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<ThemeColorData>();
  }

  @override
  bool updateShouldNotify(ThemeColorData oldWidget) {
    return primaryColor != oldWidget.primaryColor ||
        accentColor != oldWidget.accentColor ||
        isDark != oldWidget.isDark;
  }
}

/// 计数器数据
class CounterData extends InheritedWidget {
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterData({
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    required super.child,
  });

  static CounterData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<CounterData>();
    assert(data != null, 'CounterData not found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(CounterData oldWidget) {
    return count != oldWidget.count;
  }
}

/// 用户信息数据
class UserData extends InheritedWidget {
  final String name;
  final String avatar;
  final String role;

  const UserData({
    required this.name,
    required this.avatar,
    required this.role,
    required super.child,
  });

  static UserData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<UserData>();
    assert(data != null, 'UserData not found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(UserData oldWidget) {
    return name != oldWidget.name || role != oldWidget.role;
  }
}

// ==================== Demo 页面 ====================

@RoutePage()
class InheritedWidgetEventDemoPage extends StatefulWidget {
  const InheritedWidgetEventDemoPage({super.key});

  @override
  State<InheritedWidgetEventDemoPage> createState() => _InheritedWidgetDemoPageState();
}

class _InheritedWidgetDemoPageState extends State<InheritedWidgetEventDemoPage> {
  // 主题状态
  Color _primaryColor = Colors.blue;
  Color _accentColor = Colors.orange;
  bool _isDark = false;

  // 计数器状态
  int _count = 0;

  // 用户状态
  String _userName = '张三';
  String _userRole = '开发者';

  @override
  Widget build(BuildContext context) {
    // 用三个 InheritedWidget 嵌套，演示依赖注入
    return ThemeColorData(
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      isDark: _isDark,
      child: CounterData(
        count: _count,
        onIncrement: () => setState(() => _count++),
        onDecrement: () => setState(() => _count--),
        child: UserData(
          name: _userName,
          avatar: '👤',
          role: _userRole,
          child: _buildScaffold(),
        ),
      ),
    );
  }

  Widget _buildScaffold() {
    // 读取 isDark 来决定 Scaffold 的主题
    final theme = ThemeColorData.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InheritedWidget 依赖传播'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExplanationCard(),
          const SizedBox(height: 12),
          _buildThemeControls(),
          const SizedBox(height: 12),
          _buildCounterDemo(),
          const SizedBox(height: 12),
          _buildUserDemo(),
          const SizedBox(height: 12),
          _buildDependencyTree(),
        ],
      ),
    );
  }

  // ==================== 说明卡片 ====================

  Widget _buildExplanationCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text('InheritedWidget 工作原理',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 祖先创建 InheritedWidget 持有数据\n'
              '2. 后代调用 dependOnInheritedWidgetOfExactType 获取数据并注册依赖\n'
              '3. 当 updateShouldNotify 返回 true 时，所有依赖者被标记为 dirty\n'
              '4. dirty 的 Element 在下一帧 rebuild，读取新数据',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 主题控制 ====================

  Widget _buildThemeControls() {
    final theme = ThemeColorData.of(context); // 注册依赖

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text('主题色控制 (ThemeColorData)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
              ],
            ),
            const SizedBox(height: 4),
            Text('当前：primary=${theme.primaryColor}, dark=${theme.isDark}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final color in [Colors.blue, Colors.red, Colors.green, Colors.purple, Colors.teal])
                  GestureDetector(
                    onTap: () => setState(() => _primaryColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _primaryColor == color
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: _primaryColor == color
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('深色模式'),
              value: _isDark,
              onChanged: (v) => setState(() => _isDark = v),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 计数器演示 ====================

  Widget _buildCounterDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.add_circle_outline),
                SizedBox(width: 8),
                Text('计数器 (CounterData)', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text('子组件通过 CounterData.of(context) 读取 count 并调用回调',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            _CounterDisplay(),
            const SizedBox(height: 8),
            _CounterButtons(),
          ],
        ),
      ),
    );
  }

  // ==================== 用户信息演示 ====================

  Widget _buildUserDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline),
                SizedBox(width: 8),
                Text('用户信息 (UserData)', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text('深层嵌套的子组件直接读取用户数据，无需层层传参',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            _UserControls(),
            const Divider(height: 24),
            _UserCard(),
          ],
        ),
      ),
    );
  }

  // ==================== 依赖树可视化 ====================

  Widget _buildDependencyTree() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.account_tree),
                SizedBox(width: 8),
                Text('Widget 树结构', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTreeNode('ThemeColorData (InheritedWidget)', Colors.blue.shade100, [
              _buildTreeNode('CounterData (InheritedWidget)', Colors.green.shade100, [
                _buildTreeNode('UserData (InheritedWidget)', Colors.orange.shade100, [
                  _buildTreeNode('Scaffold', Colors.grey.shade100, [
                    _buildTreeNode('CounterDisplay → dependOn CounterData', Colors.green.shade50, []),
                    _buildTreeNode('CounterButtons → dependOn CounterData', Colors.green.shade50, []),
                    _buildTreeNode('UserCard → dependOn UserData', Colors.orange.shade50, []),
                  ]),
                ]),
              ]),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 当 CounterData.updateShouldNotify 返回 true 时，'
                '只有 CounterDisplay 和 CounterButtons 会 rebuild，'
                'UserCard 不受影响——这就是依赖精细化管理的优势。',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeNode(String label, Color color, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ==================== 子组件 ====================

/// 计数器显示——通过 InheritedWidget 获取数据
class _CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = CounterData.of(context); // 注册依赖
    return Center(
      child: Text(
        '${counter.count}',
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: ThemeColorData.of(context).primaryColor, // 同时依赖 ThemeColorData
        ),
      ),
    );
  }
}

/// 计数器按钮——通过 InheritedWidget 获取回调
class _CounterButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = CounterData.of(context); // 注册依赖
    final theme = ThemeColorData.of(context); // 注册依赖
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: counter.onDecrement,
          icon: const Icon(Icons.remove),
          label: const Text('-1'),
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: counter.onIncrement,
          icon: const Icon(Icons.add),
          label: const Text('+1'),
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
        ),
      ],
    );
  }
}

/// 用户控制面板
class _UserControls extends StatefulWidget {
  @override
  State<_UserControls> createState() => _UserControlsState();
}

class _UserControlsState extends State<_UserControls> {
  final _nameController = TextEditingController(text: '张三');
  String _selectedRole = '开发者';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '用户名',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(
            labelText: '角色',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: '开发者', child: Text('开发者')),
            DropdownMenuItem(value: '设计师', child: Text('设计师')),
            DropdownMenuItem(value: '产品经理', child: Text('产品经理')),
          ],
          onChanged: (v) => setState(() => _selectedRole = v!),
        ),
      ],
    );
  }
}

/// 用户信息卡片——深层嵌套，通过 InheritedWidget 获取数据
class _UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = UserData.of(context); // 注册依赖
    final theme = ThemeColorData.of(context); // 注册依赖

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(user.avatar, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user.role,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
