import 'dart:async';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/profile/model/profile_model.dart';
import 'package:invesly/profile/model/profile_repository.dart';

part 'profiles_state.dart';

class ProfilesCubit extends Cubit<ProfilesState> {
  ProfilesCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const AccountsInitialState());

  final ProfileRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch accounts
  Future<void> fetchAccounts() async {
    // getting initial accounts
    emit(const AccountsLoadingState());
    try {
      final accounts = await _repository.getAccounts();
      $logger.f(accounts);
      emit(AccountsLoadedState(accounts));
    } on Exception catch (error) {
      emit(AccountsErrorState(error.toString()));
    }

    // getting accounts when accounts table changes
    _subscription ??= _repository.onDataChanged.listen(
      null,
      onError: (err) => emit(AccountsErrorState(err.toString())),
    );
    _subscription?.onData((_) async {
      emit(const AccountsLoadingState());
      _subscription?.pause();
      try {
        final accounts = await _repository.getAccounts();
        $logger.f(accounts);
        emit(AccountsLoadedState(accounts));
      } on Exception catch (error) {
        emit(AccountsErrorState(error.toString()));
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
