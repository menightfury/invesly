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
  const AmcOverviewLoadedState(this.amc);

  final InveslyAmc? amc;

  AmcOverviewLoadedState copyWith({InveslyAmc? amc}) {
    return AmcOverviewLoadedState(amc ?? this.amc);
  }

  @override
  List<Object?> get props => [amc];
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

  // bool get hasTransactions => transactions != null && transactions!.isNotEmpty;
}

// enum AmcOverviewStatus { initial, loading, loaded, error }

// class AmcOverviewState extends Equatable {
//   const AmcOverviewState({
//     // this.searchFilters,
//     this.status = AmcOverviewStatus.initial,
//     // this.transactions,
//     this.errorMsg,
//   });

//   // final FilterTransactionsModel? searchFilters;
//   final AmcOverviewStatus status;
//   // final List<InveslyTransaction>? transactions;
//   final String? errorMsg;

//   AmcOverviewState copyWith({
//     // FilterTransactionsModel? searchFilters,
//     AmcOverviewStatus? status,
//     // List<InveslyTransaction>? transactions,
//     String? errorMsg,
//   }) {
//     return AmcOverviewState(
//       // searchFilters: searchFilters ?? this.searchFilters,
//       status: status ?? this.status,
//       // transactions: transactions ?? this.transactions,
//       errorMsg: errorMsg ?? this.errorMsg,
//     );
//   }

//   @override
//   List<Object?> get props => [status, errorMsg];
// }

// extension AmcOverviewStateX on AmcOverviewState {
//   bool get isInitial => status == AmcOverviewStatus.initial;
//   bool get isLoading => status == AmcOverviewStatus.loading;
//   bool get isLoaded => status == AmcOverviewStatus.loaded;
//   bool get isError => status == AmcOverviewStatus.error;

//   // bool get hasTransactions => transactions != null && transactions!.isNotEmpty;
// }
