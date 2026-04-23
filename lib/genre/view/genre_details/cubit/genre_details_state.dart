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
  const GenreDetailsLoadedState({required this.stats});

  final List<AmcTransaction> stats;

  double get totalCurrentValue => stats.fold<double>(0, (v, el) => v + el.currentValue);
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalAmount);
  int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

  @override
  List<Object?> get props => [stats];
}

class GenreDetailsErrorState extends GenreDetailsState {
  const GenreDetailsErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// class AmcGenreDetailsStat extends Equatable {
//   const AmcGenreDetailsStat({required this.stat, this.latestPrice});

//   final TransactionStat stat;
//   final LatestPrice? latestPrice;

//   double get currentValue => (latestPrice?.price ?? 0.0) * stat.totalQuantity;

//   @override
//   List<Object?> get props => [stat, latestPrice];
// }
