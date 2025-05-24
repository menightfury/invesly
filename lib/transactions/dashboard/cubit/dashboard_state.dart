// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitialState extends DashboardState {
  const DashboardInitialState();
}

class DashboardLoadingState extends DashboardState {
  const DashboardLoadingState();
}

class DashboardErrorState extends DashboardState {
  const DashboardErrorState(this.errorMsg);

  final String errorMsg;
}

class DashboardLoadedState extends DashboardState {
  const DashboardLoadedState({this.summaries = const [], this.recentTransactions = const []});

  final List<TransactionStat> summaries;
  final List<InveslyTransaction> recentTransactions;

  DashboardLoadedState copyWith({List<TransactionStat>? summaries, List<InveslyTransaction>? recentTransactions}) {
    return DashboardLoadedState(
      summaries: summaries ?? this.summaries,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  @override
  List<Object?> get props => [summaries, recentTransactions];
}
