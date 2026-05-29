import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class NoParamPage extends StatelessWidget {
  const NoParamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('无参跳转页面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text(
          '这是一个无参跳转的页面',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
