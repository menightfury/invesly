// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

enum GenreDetailsStateStatus { initial, loading, loaded, error }

class GenreDetailsState extends Equatable {
  const GenreDetailsState({
    required this.status,
    this.stats = const [],
    this.currentAmounts = const {},
    this.errorMessage,
  });

  final GenreDetailsStateStatus status;
  final List<AmcTransaction> stats;
  final Map<String, double> currentAmounts;
  final String? errorMessage;

  int get numHoldings => stats.length;
  double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalAmount);
  int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

  GenreDetailsState copyWith({
    GenreDetailsStateStatus? status,
    List<AmcTransaction>? stats,
    Map<String, double>? currentAmounts,
    String? errorMessage,
  }) {
    return GenreDetailsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      currentAmounts: currentAmounts ?? this.currentAmounts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, currentAmounts, errorMessage];
}

extension GenreDetailsStateX on GenreDetailsState {
  bool get isInitial => status == GenreDetailsStateStatus.initial;
  bool get isLoading => status == GenreDetailsStateStatus.loading;
  bool get isLoaded => status == GenreDetailsStateStatus.loaded;
  bool get isError => status == GenreDetailsStateStatus.error;
}

// abstract class GenreDetailsState extends Equatable {
//   const GenreDetailsState();

//   @override
//   List<Object?> get props => [];
// }

// class GenreDetailsInitialState extends GenreDetailsState {
//   const GenreDetailsInitialState();
// }

// class GenreDetailsLoadingState extends GenreDetailsState {
//   const GenreDetailsLoadingState();
// }

// class GenreDetailsLoadedState extends GenreDetailsState {
//   const GenreDetailsLoadedState({this.stats = const [], this.currentAmounts = const {}});

//   final List<AmcTransaction> stats;
//   final Map<String, double> currentAmounts;

//   double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
//   double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalAmount);
//   int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

//   @override
//   List<Object?> get props => [stats, currentAmounts];

//   GenreDetailsLoadedState copyWith({List<AmcTransaction>? stats, Map<String, double>? currentAmounts}) {
//     return GenreDetailsLoadedState(stats: stats ?? this.stats, currentAmounts: currentAmounts ?? this.currentAmounts);
//   }
// }

// class GenreDetailsErrorState extends GenreDetailsState {
//   const GenreDetailsErrorState(this.message);

//   final String message;

//   @override
//   List<Object?> get props => [message];
// }
