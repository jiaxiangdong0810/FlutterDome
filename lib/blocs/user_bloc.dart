import 'package:flutter_bloc/flutter_bloc.dart';

// ==================== State ====================

class UserState {
  final String name;
  final int age;

  const UserState({required this.name, required this.age});

  UserState copyWith({String? name, int? age}) {
    return UserState(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

// ==================== Event ====================

sealed class UserEvent {}

final class UserNameChanged extends UserEvent {
  final String name;

  UserNameChanged(this.name);
}

final class UserAgeChanged extends UserEvent {
  final int age;

  UserAgeChanged(this.age);
}

// ==================== Bloc ====================

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState(name: '张三', age: 25)) {
    on<UserNameChanged>(_onNameChanged);
    on<UserAgeChanged>(_onAgeChanged);
  }

  void _onNameChanged(UserNameChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(name: event.name));
  }

  void _onAgeChanged(UserAgeChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(age: event.age));
  }
}
