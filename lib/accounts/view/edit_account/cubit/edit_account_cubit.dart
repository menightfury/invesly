import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';

part 'edit_account_state.dart';

class EditAccountCubit extends Cubit<EditAccountState> {
  EditAccountCubit({required AccountRepository repository, InveslyAccount? initial})
    : _repository = repository,
      super(
        initial != null
            ? EditAccountState(
                id: initial.id,
                name: initial.name,
                description: initial.description,
                icon: initial.icon,
                color: initial.color,
              )
            : const EditAccountState(),
      );

  final AccountRepository _repository;

  void updateIcon(InveslyAccountIcon icon) {
    emit(state.copyWith(icon: icon));
  }

  void updateColor(Color color) {
    emit(state.copyWith(color: color));
  }

  void updateName(String name) {
    emit(state.copyWith(status: EditAccountStatus.edited, name: name, nameError: () => null));
  }

  void updateDescription(String description) {
    emit(state.copyWith(status: EditAccountStatus.edited, description: description));
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

    final account = InveslyAccount(
      id: state.id ?? 0,
      name: state.name!,
      icon: state.icon,
      color: state.color,
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
