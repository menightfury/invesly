part of 'edit_account_cubit.dart';

enum EditAccountFormStatus {
  initial,
  loading,
  success,
  failure;

  bool get isLoadingOrSuccess => [EditAccountFormStatus.loading, EditAccountFormStatus.success].contains(this);

  bool get isFailureOrSuccess => [EditAccountFormStatus.failure, EditAccountFormStatus.success].contains(this);
}

class EditAccountState extends Equatable {
  const EditAccountState({
    this.status = EditAccountFormStatus.initial,
    this.initialAccount,
    required this.name,
    // this.isNameValid = false,
    required this.avatarIndex,
    this.panNumber,
    this.aadhaarNumber,
  });

  final EditAccountFormStatus status;
  final InveslyAccount? initialAccount;
  final String name;
  // final bool isNameValid;
  final int avatarIndex;
  final String? panNumber;
  final String? aadhaarNumber;

  bool get isNewAccount => initialAccount == null;

  EditAccountState copyWith({
    EditAccountFormStatus? status,
    InveslyAccount? initialAccount,
    String? name,
    // bool? isNameValid,
    int? avatarIndex,
    String? panNumber,
    String? aadhaarNumber,
  }) {
    return EditAccountState(
      status: status ?? this.status,
      initialAccount: initialAccount ?? this.initialAccount,
      name: name ?? this.name,
      // isNameValid: isNameValid ?? this.isNameValid,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      panNumber: panNumber ?? this.panNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
    );
  }

  @override
  List<Object?> get props => [status, initialAccount, name, avatarIndex, panNumber, aadhaarNumber];
}
