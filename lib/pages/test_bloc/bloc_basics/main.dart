import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'counter_bloc.dart';

@RoutePage()
class BlocBasicsPage extends StatelessWidget {
  const BlocBasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bloc 入门示例'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 状态显示区域
          SizedBox(
            height: 120,
            child: BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                return switch (state) {
                  CounterInitial() => const Text(
                    '点击按钮开始',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  CounterLoading() => const CircularProgressIndicator(),
                  CounterSuccess(:final count) => Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CounterFailure(:final message) => Text(
                    message,
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                  ),
                };
              },
            ),
          ),
          const SizedBox(height: 48),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<CounterBloc>().add(CounterDecrement());
                },
                child: const Text('-1'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<CounterBloc>().add(CounterIncrement());
                },
                child: const Text('+1'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<CounterBloc>().add(CounterReset());
                },
                child: const Text('重置'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
