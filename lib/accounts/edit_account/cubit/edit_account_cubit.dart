import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';

part 'edit_account_state.dart';

class EditAccountCubit extends Cubit<EditAccountState> {
  EditAccountCubit({required AccountRepository repository, InveslyAccount? initial})
    : _repository = repository,
      super(EditAccountState(id: initial?.id, name: initial?.name, avatarIndex: initial?.avatarIndex ?? 2));

  final AccountRepository _repository;

  void updateAvatar(int value) {
    emit(state.copyWith(avatarIndex: value));
  }

  void updateName(String value) {
    emit(state.copyWith(status: EditAccountStatus.edited, name: value, nameError: () => null));
  }

  Future<void> save() async {
    emit(state.copyWith(status: EditAccountStatus.saving));

    final nameError = state.isNameValid ? null : state.nameError ?? 'Name can\'t be empty';

    if (!state.isFormValid) {
      emit(state.copyWith(status: EditAccountStatus.error, nameError: () => nameError));
      return;
    }

    final account = AccountInDb(id: state.id ?? 0, name: state.name!, avatarIndex: state.avatarIndex);
    try {
      await _repository.saveAccount(account, state.isNewAccount);
      emit(state.copyWith(status: EditAccountStatus.success));
    } on Exception catch (err) {
      $logger.e(err);
      emit(state.copyWith(status: EditAccountStatus.failure));
    }
  }
}
