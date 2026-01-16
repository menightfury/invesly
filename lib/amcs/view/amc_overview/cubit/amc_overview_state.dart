part of 'amc_overview_cubit.dart';

enum AmcOverviewStatus { initial, loading, loaded, error }

class AmcOverviewState extends Equatable {
  const AmcOverviewState({
    // this.searchFilters,
    this.status = AmcOverviewStatus.initial,
    this.transactions,
    this.errorMsg,
  });

  // final FilterTransactionsModel? searchFilters;
  final AmcOverviewStatus status;
  final List<InveslyTransaction>? transactions;
  final String? errorMsg;

  AmcOverviewState copyWith({
    // FilterTransactionsModel? searchFilters,
    AmcOverviewStatus? status,
    List<InveslyTransaction>? transactions,
    String? errorMsg,
  }) {
    return AmcOverviewState(
      // searchFilters: searchFilters ?? this.searchFilters,
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMsg];
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isInitial => status == AmcOverviewStatus.initial;
  bool get isLoading => status == AmcOverviewStatus.loading;
  bool get isLoaded => status == AmcOverviewStatus.loaded;
  bool get isError => status == AmcOverviewStatus.error;

  bool get hasTransactions => transactions != null && transactions!.isNotEmpty;
}
