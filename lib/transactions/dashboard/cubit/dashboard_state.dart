// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'dashboard_cubit.dart';

enum DashboardStatus {
  initial,
  loading,
  loaded,
  error;

  bool get isLoading => this == DashboardStatus.initial || this == DashboardStatus.loading;
  bool get isLoaded => this == DashboardStatus.loaded;
  bool get isError => this == DashboardStatus.error;
}

// sealed class DashboardState extends Equatable {
class DashboardState extends Equatable {
  const DashboardState({
    this.statStatus = DashboardStatus.initial,
    this.stats = const [],
    this.recentTransactionStatus = DashboardStatus.initial,
    this.recentTransactions = const [],
    this.errorMsg,
  });

  final DashboardStatus statStatus;
  final List<TransactionStat> stats;
  final DashboardStatus recentTransactionStatus;
  final List<InveslyTransaction> recentTransactions;
  final String? errorMsg;

  DashboardState copyWith({
    DashboardStatus? statStatus,
    List<TransactionStat>? stats,
    DashboardStatus? recentTransactionStatus,
    List<InveslyTransaction>? recentTransactions,
    String? errorMsg,
  }) {
    return DashboardState(
      statStatus: statStatus ?? this.statStatus,
      stats: stats ?? this.stats,
      recentTransactionStatus: recentTransactionStatus ?? this.recentTransactionStatus,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [statStatus, stats, recentTransactionStatus, recentTransactions, errorMsg];
}

// class DashboardInitialState extends DashboardState {
//   const DashboardInitialState();
// }

// class DashboardLoadingState extends DashboardState {
//   const DashboardLoadingState();
// }

// class DashboardErrorState extends DashboardState {
//   const DashboardErrorState(this.errorMsg);

//   final String errorMsg;
// }

// class DashboardLoadedState extends DashboardState {
//   const DashboardLoadedState({this.summaries = const [], this.recentTransactions = const []});

//   final List<TransactionStat> summaries;
//   final List<InveslyTransaction> recentTransactions;

//   DashboardLoadedState copyWith({List<TransactionStat>? summaries, List<InveslyTransaction>? recentTransactions}) {
//     return DashboardLoadedState(
//       summaries: summaries ?? this.summaries,
//       recentTransactions: recentTransactions ?? this.recentTransactions,
//     );
//   }

//   @override
//   List<Object?> get props => [summaries, recentTransactions];
// }
