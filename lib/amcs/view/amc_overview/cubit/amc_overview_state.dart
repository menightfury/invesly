part of 'amc_overview_cubit.dart';

abstract class AmcOverviewState extends Equatable {
  const AmcOverviewState();

  @override
  List<Object?> get props => [];
}

class AmcOverviewInitialState extends AmcOverviewState {
  const AmcOverviewInitialState();
}

class AmcOverviewLoadingState extends AmcOverviewState {
  const AmcOverviewLoadingState();
}

class AmcOverviewLoadedState extends AmcOverviewState {
  const AmcOverviewLoadedState({this.amc, this.latestPrice});

  final InveslyAmc? amc;
  final (DateTime, double?)? latestPrice;

  AmcOverviewLoadedState copyWith({(DateTime, double?)? latestPrice}) {
    return AmcOverviewLoadedState(amc: amc, latestPrice: latestPrice ?? this.latestPrice);
  }

  @override
  List<Object?> get props => [amc, latestPrice];
}

class AmcOverviewErrorState extends AmcOverviewState {
  const AmcOverviewErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object?> get props => [errorMsg];
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isInitial => this is AmcOverviewInitialState;
  bool get isLoading => this is AmcOverviewLoadingState;
  bool get isLoaded => this is AmcOverviewLoadedState;
  bool get isError => this is AmcOverviewErrorState;
}
