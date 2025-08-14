import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';

part 'edit_account_state.dart';

class EditAccountCubit extends Cubit<EditAccountState> {
  EditAccountCubit({required AccountRepository repository, InveslyAccount? initialAccount})
    : _repository = repository,
      super(
        EditAccountState(
          initialAccount: initialAccount,
          name: initialAccount?.name ?? '',
          avatarIndex: initialAccount?.avatarIndex ?? 2,
          panNumber: initialAccount?.panNumber,
          aadhaarNumber: initialAccount?.aadhaarNumber,
        ),
      );

  final AccountRepository _repository;

  void updateAvatar(int value) {
    emit(state.copyWith(avatarIndex: value));
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
  }

  // void updateNameValidStatus(bool value) {
  //   emit(state.copyWith(isNameValid: value));
  // }

  void updatePanNumber(String value) {
    emit(state.copyWith(panNumber: value));
  }

  void updateAadhaarNumber(String value) {
    emit(state.copyWith(aadhaarNumber: value));
  }

  void save() async {
    emit(state.copyWith(status: EditAccountFormStatus.loading));
    final name = state.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(status: EditAccountFormStatus.failure));
      return;
    }

    final user = AccountInDb(
      id: state.initialAccount?.id ?? $uuid.v1(),
      name: name,
      avatarIndex: state.avatarIndex,
      panNumber: state.panNumber,
      aadhaarNumber: state.aadhaarNumber,
    );
    try {
      await _repository.saveAccount(user, state.isNewAccount);
      emit(state.copyWith(status: EditAccountFormStatus.success));
    } on Exception catch (err) {
      $logger.e(err);
      emit(state.copyWith(status: EditAccountFormStatus.failure));
    }
  }
}
