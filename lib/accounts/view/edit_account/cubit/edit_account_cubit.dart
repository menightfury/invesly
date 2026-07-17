import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';

part 'edit_account_state.dart';

class EditAccountCubit extends Cubit<EditAccountState> {
  EditAccountCubit({required AccountRepository repository, InveslyAccount? initial})
    : _repository = repository,
      super(
        EditAccountState(
          id: initial?.id,
          name: initial?.name,
          description: initial?.description,
          iconName: initial?.iconName ?? InveslyAccountIcon.wallet.name,
          colorValue: initial?.colorValue ?? Colors.blueAccent.toARGB32(),
        ),
      );

  final AccountRepository _repository;

  void updateIcon(String value) {
    emit(state.copyWith(iconName: value));
  }

  void updateColor(int value) {
    emit(state.copyWith(colorValue: value));
  }

  void updateName(String value) {
    emit(state.copyWith(status: EditAccountStatus.edited, name: value, nameError: () => null));
  }

  void updateDescription(String value) {
    emit(state.copyWith(status: EditAccountStatus.edited, description: value));
  }

  void updateInitialBalance(String value) {
    final parsed = double.tryParse(value);
    emit(state.copyWith(status: EditAccountStatus.edited, initialBalance: parsed));
  }

  Future<void> save() async {
    emit(state.copyWith(status: EditAccountStatus.saving));

    final nameError = state.isNameValid ? null : state.nameError ?? 'Name can\'t be empty';

    if (!state.isFormValid) {
      emit(state.copyWith(status: EditAccountStatus.error, nameError: () => nameError));
      return;
    }

    final account = AccountInDb(
      id: state.id ?? 0,
      name: state.name!,
      iconName: state.iconName,
      colorValue: state.colorValue,
      description: state.description?.trim().isEmpty == true ? null : state.description?.trim(),
    );
    try {
      await _repository.saveAccount(account, state.isNewAccount);
      emit(state.copyWith(status: EditAccountStatus.success));
    } on Exception catch (err) {
      $logger.e(err);
      emit(state.copyWith(status: EditAccountStatus.failure));
    }
  }
}
