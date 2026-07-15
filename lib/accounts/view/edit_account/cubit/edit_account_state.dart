part of 'edit_account_cubit.dart';

enum EditAccountStatus { initial, edited, error, saving, success, failure }

class EditAccountState extends Equatable {
  const EditAccountState({
    this.status = EditAccountStatus.initial,
    this.id,
    this.name,
    this.nameError,
    required this.avatarIndex,
  });

  final EditAccountStatus status;
  final int? id;
  final String? name;
  final String? nameError;
  final int avatarIndex;

  bool get isNewAccount => id == null;

  bool get isNameValid => name != null && name!.trim().isNotEmpty;

  // Check if all required fields are filled and valid
  bool get isFormValid {
    return isNameValid;
  }

  EditAccountState copyWith({
    EditAccountStatus? status,
    String? name,
    String? Function()? nameError,
    int? avatarIndex,
  }) {
    return EditAccountState(
      status: status ?? this.status,
      id: id,
      name: name ?? this.name,
      nameError: nameError != null ? nameError.call() : this.nameError,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  @override
  List<Object?> get props => [status, id, name, nameError, avatarIndex];
}

extension EditAccountStateX on EditAccountState {
  bool get isError => status == EditAccountStatus.error;
  bool get isEdited => [EditAccountStatus.edited, EditAccountStatus.error].contains(status);

  bool get isLoadingOrSuccess => [EditAccountStatus.saving, EditAccountStatus.success].contains(status);

  bool get isFailureOrSuccess => [EditAccountStatus.failure, EditAccountStatus.success].contains(status);
}
