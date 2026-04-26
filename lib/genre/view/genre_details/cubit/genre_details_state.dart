// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

abstract class GenreDetailsState extends Equatable {
  const GenreDetailsState();

  @override
  List<Object?> get props => [];
}

class GenreDetailsInitialState extends GenreDetailsState {
  const GenreDetailsInitialState();
}

class GenreDetailsLoadingState extends GenreDetailsState {
  const GenreDetailsLoadingState();
}

class GenreDetailsLoadedState extends GenreDetailsState {
  const GenreDetailsLoadedState({this.stats = const [], this.currentAmounts = const {}});

  final List<AmcTransaction> stats;
  final Map<String, double> currentAmounts;

  double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalAmount);
  int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

  @override
  List<Object?> get props => [stats, currentAmounts];

  GenreDetailsLoadedState copyWith({List<AmcTransaction>? stats, Map<String, double>? currentAmounts}) {
    return GenreDetailsLoadedState(stats: stats ?? this.stats, currentAmounts: currentAmounts ?? this.currentAmounts);
  }
}

class GenreDetailsErrorState extends GenreDetailsState {
  const GenreDetailsErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
