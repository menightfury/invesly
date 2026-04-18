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
  const TransactionStatLoadedState({this.stats = const []});

  final List<AmcStat> stats;

  @override
  List<Object?> get props => [stats];
}

extension TransactionStatStateX on TransactionStatState {
  bool get isInitial => this is TransactionStatInitialState;
  bool get isLoading => this is TransactionStatLoadingState;
  bool get isLoaded => this is TransactionStatLoadedState;
  bool get isError => this is TransactionStatErrorState;

  bool get isNotEmpty => isLoaded && (this as TransactionStatLoadedState).stats.isNotEmpty;
  bool get isEmpty => isLoaded && (this as TransactionStatLoadedState).stats.isEmpty;
}
