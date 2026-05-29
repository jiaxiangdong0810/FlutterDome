import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== State（状态）====================

sealed class CounterState {}

final class CounterInitial extends CounterState {}

final class CounterLoading extends CounterState {}

final class CounterSuccess extends CounterState {
  final int count;
  CounterSuccess(this.count);
}

final class CounterFailure extends CounterState {
  final String message;
  CounterFailure(this.message);
}

// ==================== Event（事件）====================

sealed class CounterEvent {}

final class CounterIncrement extends CounterEvent {}

final class CounterDecrement extends CounterEvent {}

final class CounterReset extends CounterEvent {}

// ==================== Bloc（逻辑处理器）====================

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  int _count = 0;

  CounterBloc() : super(CounterInitial()) {
    on<CounterIncrement>(_onIncrement);
    on<CounterDecrement>(_onDecrement);
    on<CounterReset>(_onReset);
  }

  Future<void> _onIncrement(
    CounterIncrement event,
    Emitter<CounterState> emit,
  ) async {
    emit(CounterLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _count++;
    emit(CounterSuccess(_count));
  }

  Future<void> _onDecrement(
    CounterDecrement event,
    Emitter<CounterState> emit,
  ) async {
    emit(CounterLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    if (_count > 0) {
      _count--;
      emit(CounterSuccess(_count));
    } else {
      emit(CounterFailure('计数不能小于 0'));
    }
  }

  void _onReset(CounterReset event, Emitter<CounterState> emit) {
    _count = 0;
    emit(CounterInitial());
  }
}
