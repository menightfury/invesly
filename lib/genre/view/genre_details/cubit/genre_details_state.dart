part of 'genre_details_cubit.dart';

abstract class GenreDetailsState extends Equatable {
  const GenreDetailsState();

  @override
  List<Object?> get props => [];
}

class GenreDetailsLoadingState extends GenreDetailsState {
  const GenreDetailsLoadingState();
}

class GenreDetailsLoadedState extends GenreDetailsState {
  const GenreDetailsLoadedState({required this.detailsList});

  final List<AmcGenreDetailsStat> detailsList;

  double get totalCurrentValue => detailsList.fold<double>(0, (v, el) => v + el.currentValue);
  double get totalInvested => detailsList.fold<double>(0, (v, el) => v + el.stat.totalAmount);
  int get totalTransactions => detailsList.fold<int>(0, (v, el) => v + el.stat.numTransactions);

  @override
  List<Object?> get props => [detailsList];
}

class GenreDetailsErrorState extends GenreDetailsState {
  const GenreDetailsErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AmcGenreDetailsStat extends Equatable {
  const AmcGenreDetailsStat({required this.stat, this.latestPrice});

  final TransactionStat stat;
  final LatestPrice? latestPrice;

  double get currentValue => (latestPrice?.price ?? 0.0) * stat.totalQuantity;

  @override
  List<Object?> get props => [stat, latestPrice];
}
