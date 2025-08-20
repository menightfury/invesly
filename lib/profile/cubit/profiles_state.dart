part of 'profiles_cubit.dart';

sealed class ProfilesState extends Equatable {
  const ProfilesState();

  @override
  List<Object?> get props => [];
}

class AccountsInitialState extends ProfilesState {
  const AccountsInitialState();
}

class AccountsLoadingState extends ProfilesState {
  const AccountsLoadingState();
}

class AccountsErrorState extends ProfilesState {
  const AccountsErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object> get props => [errorMsg];
}

class AccountsLoadedState extends ProfilesState {
  const AccountsLoadedState(this.accounts);

  final List<InveslyProfile> accounts;

  bool get hasNoAccount => accounts.isEmpty;

  InveslyProfile? getAccount(String accountId) {
    return accounts.firstWhereOrNull((account) => account.id == accountId);
  }

  bool hasAccount(String accountId) => getAccount(accountId) != null;

  @override
  List<Object> get props => [accounts];
}
