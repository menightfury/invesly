// part of 'database_cubit.dart';

// sealed class DatabaseState extends Equatable {
//   const DatabaseState();

//   @override
//   List<Object> get props => [];
// }

// final class DatabaseInitialState extends DatabaseState {}

// final class DatabaseLoadingState extends DatabaseState {}

// final class DatabaseLoadedState extends DatabaseState {}

// final class DatabaseErrorState extends DatabaseState {
//   final String message;

//   const DatabaseErrorState(this.message);

//   @override
//   List<Object> get props => [message];
// }

// extension DatabaseStateX on DatabaseState {
//   bool get isLoading => this is DatabaseInitialState || this is DatabaseLoadingState;
//   bool get isLoaded => this is DatabaseLoadedState;
//   bool get isError => this is DatabaseErrorState;
// }
