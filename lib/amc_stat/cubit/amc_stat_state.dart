// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_stat_cubit.dart';

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

  List<AmcStat> filterStats({int? accountId, AmcGenre? genre}) {
    return stats.where((stat) {
      final accountMatch = accountId == null || stat.accountId == accountId;
      final genreMatch = genre == null || stat.amc.genre == genre;
      return accountMatch && genreMatch;
    }).toList();
  }

  AmcStat? getStat({int? accountId, required String amcId}) {
    final filteredStats = stats.where((stat) => stat.amc.id == amcId);
    return filteredStats.firstWhereOrNull((stat) => accountId == null || stat.accountId == accountId);
  }

  double getTotalInvested({int? accountId, AmcGenre? genre}) {
    final filteredStats = filterStats(accountId: accountId, genre: genre);
    return filteredStats.fold<double>(0, (v, el) => v + el.totalInvested);
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
