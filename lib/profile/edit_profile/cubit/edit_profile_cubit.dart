import 'package:invesly/common_libs.dart';
import 'package:invesly/profile/model/profile_model.dart';
import 'package:invesly/profile/model/profile_repository.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required ProfileRepository repository, InveslyProfile? initialAccount})
    : _repository = repository,
      super(
        EditProfileState(
          initialAccount: initialAccount,
          name: initialAccount?.name ?? '',
          avatarIndex: initialAccount?.avatarIndex ?? 2,
          panNumber: initialAccount?.panNumber,
          aadhaarNumber: initialAccount?.aadhaarNumber,
        ),
      );

  final ProfileRepository _repository;

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

    final user = ProfileInDb(
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
