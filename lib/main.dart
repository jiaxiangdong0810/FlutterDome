import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/user_bloc.dart';
import 'design_tokens/theme_provider.dart';
import 'generated/app_localizations.dart';
import 'router/app_router.dart';
import 'router/app_router.gr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return ThemeProvider(
      isDark: _isDark,
      toggleTheme: _toggleTheme,
      child: BlocProvider(
        create: (_) => UserBloc(),
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              title: 'Flutter Demo',
              theme: ThemeProvider.of(context).theme,
              routerConfig: appRouter.config(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('zh'),
                Locale('en'),
              ],
            );
          },
        ),
      ),
    );
  }
}

@RoutePage()
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.router.push(const UserListRoute()),
              child: const Text('跳转到用户列表'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const RebuildDemoRoute()),
              child: const Text('Widget 重建机制演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const BlocBasicsRoute()),
              child: const Text('Bloc 入门示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const BlocListRoute()),
              child: const Text('Bloc 列表实战'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const AutoRouteHomeRoute()),
              child: const Text('AutoRoute 示例'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const FlavorsDemoRoute()),
              child: const Text('多环境配置（Flavors）演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const WidgetTestDemoRoute()),
              child: const Text('Widget Test 演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const IntegrationTestDemoRoute()),
              child: const Text('Integration Test 演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const ThemeDemoRoute()),
              child: const Text('ThemeData + Design Token 演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const L10nDemoRoute()),
              child: const Text('gen-l10n 国际化演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const InheritedWidgetDemoRoute()),
              child: const Text('InheritedWidget 演示（方案 B）'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const InheritedWidgetNotifierRoute()),
              child: const Text('InheritedNotifier 演示（最优方案）'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const MultiListenerRoute()),
              child: const Text('ChangeNotifier 多订阅者演示'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const ProviderBasicRoute()),
              child: const Text('Provider 基础用法'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const ProviderMultiRoute()),
              child: const Text('MultiProvider + ProxyProvider'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const ProviderAsyncRoute()),
              child: const Text('Provider + 异步操作'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const ProviderOptimizationRoute()),
              child: const Text('Provider 重建优化'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.router.push(const ProviderCartRoute()),
              child: const Text('Provider 购物车实战'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
