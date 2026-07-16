part of 'edit_account_cubit.dart';

enum EditAccountStatus { initial, edited, error, saving, success, failure }

class EditAccountState extends Equatable {
  const EditAccountState({
    this.status = EditAccountStatus.initial,
    this.id,
    this.name,
    this.nameError,
    this.iconName = 'wallet',
    this.colorValue = 0xFF1976D2,
    this.description,
    this.initialBalance,
  });

  final EditAccountStatus status;
  final int? id;
  final String? name;
  final String? nameError;
  final String iconName;
  final int colorValue;
  final String? description;
  final double? initialBalance;

  bool get isNewAccount => id == null;

  bool get isNameValid => name != null && name!.trim().isNotEmpty;

  bool get isFormValid {
    return isNameValid;
  }

  EditAccountState copyWith({
    EditAccountStatus? status,
    String? name,
    String? Function()? nameError,
    String? iconName,
    int? colorValue,
    String? description,
    double? initialBalance,
  }) {
    return EditAccountState(
      status: status ?? this.status,
      id: id,
      name: name ?? this.name,
      nameError: nameError != null ? nameError.call() : this.nameError,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      description: description ?? this.description,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }

  @override
  List<Object?> get props => [status, id, name, nameError, iconName, colorValue, description, initialBalance];
}

extension EditAccountStateX on EditAccountState {
  bool get isError => status == EditAccountStatus.error;
  bool get isEdited => [EditAccountStatus.edited, EditAccountStatus.error].contains(status);

  bool get isLoadingOrSuccess => [EditAccountStatus.saving, EditAccountStatus.success].contains(status);

  bool get isFailureOrSuccess => [EditAccountStatus.failure, EditAccountStatus.success].contains(status);
}
