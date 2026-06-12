// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'stat_cubit.dart';

sealed class StatState extends Equatable {
  const StatState();
  @override
  List<Object?> get props => [];
}

class StatInitialState extends StatState {
  const StatInitialState();
}

class StatLoadingState extends StatState {
  const StatLoadingState();
}

class StatErrorState extends StatState {
  const StatErrorState(this.errorMsg);

  final String errorMsg;
}

class StatLoadedState extends StatState {
  const StatLoadedState(this.stats);

  final List<InveslyStat> stats;

  List<InveslyStat> getStats({int? accountId, AmcGenre? genre}) {
    return stats.where((stat) {
      final accountMatch = accountId == null || stat.accountId == accountId;
      final genreMatch = genre == null || stat.amc.genre == genre;
      return accountMatch && genreMatch;
    }).toList();
  }

  InveslyStat? getStat({int? accountId, required String amcId}) {
    final filteredStats = stats.where((stat) => stat.amc.id == amcId);
    return filteredStats.firstWhereOrNull((stat) => accountId == null || stat.accountId == accountId);
  }

  double getTotalInvested({int? accountId, AmcGenre? genre}) {
    final filteredStats = getStats(accountId: accountId, genre: genre);
    return filteredStats.fold<double>(0, (v, el) => v + el.totalInvested);
  }

  @override
  List<Object?> get props => [stats];
}

extension StatStateX on StatState {
  bool get isInitial => this is StatInitialState;
  bool get isLoading => this is StatLoadingState;
  bool get isLoaded => this is StatLoadedState;
  bool get isError => this is StatErrorState;

  bool get isNotEmpty => isLoaded && (this as StatLoadedState).stats.isNotEmpty;
  bool get isEmpty => isLoaded && (this as StatLoadedState).stats.isEmpty;
}
