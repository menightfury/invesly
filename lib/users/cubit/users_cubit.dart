import 'dart:async';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/users/model/user_model.dart';
import 'package:invesly/users/model/user_repository.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit({required UserRepository repository}) : _repository = repository, super(const UsersInitialState());

  final UserRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch users
  Future<void> fetchUsers() async {
    // getting initial users
    emit(const UsersLoadingState());
    try {
      final users = await _repository.getUsers();
      $logger.f(users);
      emit(UsersLoadedState(users));
    } on Exception catch (error) {
      emit(UsersErrorState(error.toString()));
    }

    // getting users when users table changes
    _subscription ??= _repository.onTableChange.listen(null, onError: (err) => emit(UsersErrorState(err.toString())));
    _subscription?.onData((_) async {
      emit(const UsersLoadingState());
      _subscription?.pause();
      try {
        final users = await _repository.getUsers();
        $logger.f(users);
        emit(UsersLoadedState(users));
      } on Exception catch (error) {
        emit(UsersErrorState(error.toString()));
      } finally {
        _subscription?.resume();
      }
    });

    _subscription?.onDone(() {
      _subscription?.cancel();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
