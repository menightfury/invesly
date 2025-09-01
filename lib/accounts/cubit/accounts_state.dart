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
  const AccountsErrorState(this.message);

  final String message;

  @override
  List<Object> get props => [message];
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

extension AccountsStateX on AccountsState {
  bool get isLoading => this is AccountsInitialState || this is AccountsLoadingState;
  bool get isLoaded => this is AccountsLoadedState;
  bool get isError => this is AccountsErrorState;
}
