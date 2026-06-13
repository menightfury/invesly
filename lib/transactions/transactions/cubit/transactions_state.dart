part of 'transactions_cubit.dart';

enum TransactionsStatus { initial, loading, loaded, error }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.searchFilters,
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.errorMsg,
  });

  final FilterTransactionsModel? searchFilters;
  final TransactionsStatus status;
  final List<InveslyTransaction> transactions;
  final String? errorMsg;

  int get numTransactions => transactions.length;
  double get totalUnits => transactions.fold<double>(0.0, (v, el) => v + (el.quantity ?? 0));
  double get totalInvested => transactions.fold<double>(0.0, (v, el) => v + (el.totalAmount > 0 ? el.totalAmount : 0));
  double get totalRedeemed => transactions.fold<double>(0.0, (v, el) => v + (el.totalAmount > 0 ? 0 : el.totalAmount));
  double get averageBuyPrice {
    if (totalUnits == 0) return 0;
    return totalInvested / totalUnits;
  }

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

  // bool get hasTransactions => transactions != null && transactions!.isNotEmpty;
}
