import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// Integration Test 演示入口页面
///
/// 展示一个完整的登录-首页流程，配合 integration_test/app_test.dart 中的测试用例，
/// 演示 Integration Test 的核心能力：在真实设备上测试完整用户流程。
@RoutePage()
class IntegrationTestDemoPage extends StatelessWidget {
  const IntegrationTestDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

/// 登录页面
///
/// 测试目标：
/// 1. 输入正确的用户名和密码，点击登录后跳转到首页
/// 2. 输入错误的凭据，显示错误提示
/// 3. 首页显示欢迎语和注销按钮，点击注销返回登录页
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 模拟登录验证：用户名 admin，密码 123456
    if (username == 'admin' && password == '123456') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomePage(username: username),
        ),
      );
    } else {
      setState(() {
        _errorText = '用户名或密码错误';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integration Test 演示')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '用户登录',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '用户名: admin / 密码: 123456',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              key: const Key('username_field'),
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('password_field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                key: const Key('error_text'),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('登录', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 首页（登录成功后跳转）
class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              '欢迎，$username！',
              key: const Key('welcome_text'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '登录成功',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              key: const Key('logout_button'),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.logout),
              label: const Text('注销'),
            ),
          ],
        ),
      ),
    );
  }
}