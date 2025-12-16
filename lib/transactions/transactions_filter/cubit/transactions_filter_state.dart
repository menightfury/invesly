part of 'transactions_filter_cubit.dart';

enum TransactionsFilterStatus { initial, loading, loaded, error }

class TransactionsFilterState extends Equatable {
  const TransactionsFilterState({
    this.status = TransactionsFilterStatus.initial,
    this.transactions = const [],
    this.errorMsg,
  });

  final TransactionsFilterStatus status;
  final List<InveslyTransaction> transactions;
  final String? errorMsg;

  TransactionsFilterState copyWith({
    TransactionsFilterStatus? status,
    List<InveslyTransaction>? transactions,
    String? errorMsg,
  }) {
    return TransactionsFilterState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMsg];
}

extension TransactionsFilterStateX on TransactionsFilterState {
  bool get isLoading => status == TransactionsFilterStatus.initial || status == TransactionsFilterStatus.initial;
  bool get isLoaded => status == TransactionsFilterStatus.loaded;
  bool get isError => status == TransactionsFilterStatus.error;
}
