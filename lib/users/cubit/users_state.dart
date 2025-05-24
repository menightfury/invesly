part of 'users_cubit.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitialState extends UsersState {
  const UsersInitialState();
}

class UsersLoadingState extends UsersState {
  const UsersLoadingState();
}

class UsersErrorState extends UsersState {
  const UsersErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object> get props => [errorMsg];
}

class UsersLoadedState extends UsersState {
  const UsersLoadedState(this.users);

  final List<InveslyUser> users;

  bool get hasNoUser => users.isEmpty;

  InveslyUser? getUser(String userId) {
    return users.firstWhereOrNull((user) => user.id == userId);
  }

  bool hasUser(String userId) => getUser(userId) != null;

  @override
  List<Object> get props => [users];
}
