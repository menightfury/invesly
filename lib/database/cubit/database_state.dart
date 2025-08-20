part of 'database_cubit.dart';

sealed class DatabaseState extends Equatable {
  const DatabaseState();

  @override
  List<Object> get props => [];
}

final class DatabaseInitial extends DatabaseState {}

final class DatabaseLoading extends DatabaseState {}

final class DatabaseLoaded extends DatabaseState {}

final class DatabaseError extends DatabaseState {
  final String message;

  const DatabaseError(this.message);

  @override
  List<Object> get props => [message];
}
