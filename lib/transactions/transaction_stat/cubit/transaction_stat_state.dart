// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'transaction_stat_cubit.dart';

sealed class AmcStatState extends Equatable {
  const AmcStatState();
  @override
  List<Object?> get props => [];
}

class AmcStatInitialState extends AmcStatState {
  const AmcStatInitialState();
}

class AmcStatLoadingState extends AmcStatState {
  const AmcStatLoadingState();
}

class AmcStatErrorState extends AmcStatState {
  const AmcStatErrorState(this.errorMsg);

  final String errorMsg;
}

class AmcStatLoadedState extends AmcStatState {
  const AmcStatLoadedState({this.stats = const []});

  final List<AmcStat> stats;

  // int get numHoldings => stats.length;
  // double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
  // double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalInvested);
  // int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

  @override
  List<Object?> get props => [stats];
}

extension AmcStatStateX on AmcStatState {
  bool get isInitial => this is AmcStatInitialState;
  bool get isLoading => this is AmcStatLoadingState;
  bool get isLoaded => this is AmcStatLoadedState;
  bool get isError => this is AmcStatErrorState;

  bool get isNotEmpty => isLoaded && (this as AmcStatLoadedState).stats.isNotEmpty;
  bool get isEmpty => isLoaded && (this as AmcStatLoadedState).stats.isEmpty;
}
