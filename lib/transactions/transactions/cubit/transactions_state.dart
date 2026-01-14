part of 'transactions_cubit.dart';

enum TransactionsStatus { initial, loading, loaded, error }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.searchFilters,
    this.status = TransactionsStatus.initial,
    this.transactions,
    this.errorMsg,
  });

  final FilterTransactionsModel? searchFilters;
  final TransactionsStatus status;
  final List<InveslyTransaction>? transactions;
  final String? errorMsg;

  TransactionsState copyWith({
    FilterTransactionsModel? searchFilters,
    TransactionsStatus? status,
    List<InveslyTransaction>? transactions,
    String? errorMsg,
  }) {
    return TransactionsState(
      searchFilters: searchFilters ?? this.searchFilters,
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [searchFilters, status, transactions, errorMsg];
}

extension TransactionsStateX on TransactionsState {
  bool get isInitial => status == TransactionsStatus.initial;
  bool get isLoading => status == TransactionsStatus.loading;
  bool get isLoaded => status == TransactionsStatus.loaded;
  bool get isError => status == TransactionsStatus.error;
}
