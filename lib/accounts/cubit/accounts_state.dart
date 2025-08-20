part of 'accounts_cubit.dart';

sealed class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object?> get props => [];
}

class AccountsInitialState extends AccountsState {
  const AccountsInitialState();
}

class AccountsLoadingState extends AccountsState {
  const AccountsLoadingState();
}

class AccountsErrorState extends AccountsState {
  const AccountsErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object> get props => [errorMsg];
}

class AccountsLoadedState extends AccountsState {
  const AccountsLoadedState(this.accounts);

  final List<InveslyAccount> accounts;

  bool get hasNoAccounts => accounts.isEmpty;

  InveslyAccount? getAccount(String id) {
    return accounts.firstWhereOrNull((a) => a.id == id);
  }

  bool hasAccount(String id) => getAccount(id) != null;

  @override
  List<Object> get props => [accounts];
}
