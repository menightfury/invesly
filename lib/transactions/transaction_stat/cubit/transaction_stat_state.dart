// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'transaction_stat_cubit.dart';

sealed class TransactionStatState extends Equatable {
  const TransactionStatState();
  @override
  List<Object?> get props => [];
}

class TransactionStatInitialState extends TransactionStatState {
  const TransactionStatInitialState();
}

class TransactionStatLoadingState extends TransactionStatState {
  const TransactionStatLoadingState();
}

class TransactionStatErrorState extends TransactionStatState {
  const TransactionStatErrorState(this.errorMsg);

  final String errorMsg;
}

class TransactionStatLoadedState extends TransactionStatState {
  const TransactionStatLoadedState({this.stats = const [], this.recentTransactions = const []});

  final List<TransactionStat> stats;
  final List<InveslyTransaction> recentTransactions;

  TransactionStatLoadedState copyWith({List<TransactionStat>? stats, List<InveslyTransaction>? recentTransactions}) {
    return TransactionStatLoadedState(
      stats: stats ?? this.stats,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  @override
  List<Object?> get props => [stats, recentTransactions];
}

extension TransactionStatStateX on TransactionStatState {
  bool get isInitial => this is TransactionStatInitialState;
  bool get isLoading => this is TransactionStatLoadingState;
  bool get isLoaded => this is TransactionStatLoadedState;
  bool get isError => this is TransactionStatErrorState;

  bool get isNotEmpty => isLoaded && (this as TransactionStatLoadedState).stats.isNotEmpty;
  bool get isEmpty => isLoaded && (this as TransactionStatLoadedState).stats.isEmpty;
}
