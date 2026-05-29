import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../router/app_router.dart';

@RoutePage()
class AutoRouteShellPage extends StatefulWidget {
  const AutoRouteShellPage({super.key});

  @override
  State<AutoRouteShellPage> createState() => _AutoRouteShellPageState();
}

class _AutoRouteShellPageState extends State<AutoRouteShellPage> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    // 使用 MaterialApp.router 提供 AutoRouter 环境
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
