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
  const AmcStatLoadedState(this.stats);

  final List<AmcStat> stats;

  List<AmcStat> getStatsByGenre(AmcGenre genre) {
    return stats.where((stat) => stat.amc.genre == genre).toList();
  }

  // double getTotalCurrentValue([AmcGenre? genre]) {
  //   final filteredStats = genre == null ? stats : getStatsByGenre(genre);
  //   return filteredStats.fold<double>(0, (v, el) => v + el.currentValue);
  // }

  double getTotalInvested([AmcGenre? genre]) {
    final filteredStats = genre == null ? stats : getStatsByGenre(genre);
    return filteredStats.fold<double>(0, (v, el) => v + el.totalInvested);
  }

  double getTotalRedeemed([AmcGenre? genre]) {
    final filteredStats = genre == null ? stats : getStatsByGenre(genre);
    return filteredStats.fold<double>(0, (v, el) => v + el.totalRedeemed);
  }

  int getTotalHoldings([AmcGenre? genre]) {
    final filteredStats = genre == null ? stats : getStatsByGenre(genre);
    return filteredStats.length;
  }

  int getPresentHoldings([AmcGenre? genre]) {
    final filteredStats = genre == null ? stats : getStatsByGenre(genre);
    return filteredStats.where((stat) => stat.totalQuantity > 0).length;
  }

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
