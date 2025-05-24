import 'package:invesly/common_libs.dart';
import 'package:invesly/users/model/user_model.dart';
import 'package:invesly/users/model/user_repository.dart';

part 'edit_user_state.dart';

class EditUserCubit extends Cubit<EditUserState> {
  EditUserCubit({required UserRepository repository, InveslyUser? initialUser})
    : _repository = repository,
      super(
        EditUserState(
          initialUser: initialUser,
          name: initialUser?.name ?? '',
          avatarIndex: initialUser?.avatarIndex ?? 2,
          panNumber: initialUser?.panNumber,
          aadhaarNumber: initialUser?.aadhaarNumber,
        ),
      );

  final UserRepository _repository;

  void updateAvatar(int value) {
    emit(state.copyWith(avatarIndex: value));
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
  }

  void updatePanNumber(String value) {
    emit(state.copyWith(panNumber: value));
  }

  void updateAadhaarNumber(String value) {
    emit(state.copyWith(aadhaarNumber: value));
  }

  void submit() async {
    emit(state.copyWith(status: EditUserStatus.loading));
    final name = state.name.trim();
    if (name.trim().isEmpty) {
      emit(state.copyWith(status: EditUserStatus.failure));
      return;
    }

    final user = UserInDb(
      id: state.initialUser?.id ?? $uuid.v1(),
      name: name.trim(),
      avatarIndex: state.avatarIndex,
      panNumber: state.panNumber,
      aadhaarNumber: state.aadhaarNumber,
    );
    try {
      await _repository.saveUser(user, state.isNewUser);
      emit(state.copyWith(status: EditUserStatus.success));
    } on Exception catch (err) {
      $logger.e(err);
      emit(state.copyWith(status: EditUserStatus.failure));
    }
  }
}
