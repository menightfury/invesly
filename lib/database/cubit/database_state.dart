part of 'database_cubit.dart';

sealed class DatabaseState extends Equatable {
  const DatabaseState();

  @override
  List<Object> get props => [];
}

final class DatabaseInitialState extends DatabaseState {}

final class DatabaseLoadingState extends DatabaseState {}

final class DatabaseLoadedState extends DatabaseState {}

final class DatabaseErrorState extends DatabaseState {
  final String message;

  const DatabaseErrorState(this.message);

  @override
  List<Object> get props => [message];
}
