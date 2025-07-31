part of 'edit_user_cubit.dart';

enum EditUserFormStatus {
  initial,
  loading,
  success,
  failure;

  bool get isLoadingOrSuccess => [EditUserFormStatus.loading, EditUserFormStatus.success].contains(this);

  bool get isFailureOrSuccess => [EditUserFormStatus.failure, EditUserFormStatus.success].contains(this);
}

class EditUserState extends Equatable {
  const EditUserState({
    this.status = EditUserFormStatus.initial,
    this.initialUser,
    required this.name,
    // this.isNameValid = false,
    required this.avatarIndex,
    this.panNumber,
    this.aadhaarNumber,
  });

  final EditUserFormStatus status;
  final InveslyUser? initialUser;
  final String name;
  // final bool isNameValid;
  final int avatarIndex;
  final String? panNumber;
  final String? aadhaarNumber;

  bool get isNewUser => initialUser == null;

  EditUserState copyWith({
    EditUserFormStatus? status,
    InveslyUser? initialUser,
    String? name,
    // bool? isNameValid,
    int? avatarIndex,
    String? panNumber,
    String? aadhaarNumber,
  }) {
    return EditUserState(
      status: status ?? this.status,
      initialUser: initialUser ?? this.initialUser,
      name: name ?? this.name,
      // isNameValid: isNameValid ?? this.isNameValid,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      panNumber: panNumber ?? this.panNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
    );
  }

  @override
  List<Object?> get props => [status, initialUser, name, avatarIndex, panNumber, aadhaarNumber];
}
