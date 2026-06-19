// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'stat_cubit.dart';

enum StatStatus { initial, loading, loaded, error }

class StatState extends Equatable {
  const StatState({this.status = StatStatus.initial, this.stats = const []});

  final StatStatus status;
  final List<InveslyStat> stats;

  List<InveslyStat> getStats({int? accountId, AmcGenre? genre}) {
    return stats.where((stat) {
      final accountMatch = accountId == null || stat.accountId == accountId;
      final genreMatch = genre == null || stat.amc.genre == genre;
      return accountMatch && genreMatch;
    }).toList();
  }

  InveslyStat? getStat({int? accountId, required String amcId}) {
    if (!isLoaded || stats.isEmpty) return null;
    final filteredStats = stats.where((stat) => stat.amc.id == amcId);
    return filteredStats.firstWhereOrNull((stat) => accountId == null || stat.accountId == accountId);
  }

  double getTotalInvested({int? accountId, AmcGenre? genre}) {
    final filteredStats = getStats(accountId: accountId, genre: genre);
    return filteredStats.fold<double>(0, (v, el) => v + el.totalInvested);
  }

  @override
  List<Object?> get props => [status, stats];

  StatState copyWith({StatStatus? status, List<InveslyStat>? stats}) {
    return StatState(status: status ?? this.status, stats: stats ?? this.stats);
  }
}

extension StatStateX on StatState {
  bool get isInitial => status == StatStatus.initial;
  bool get isLoading => status == StatStatus.loading;
  bool get isLoaded => status == StatStatus.loaded;
  bool get isError => status == StatStatus.error;

  bool get isNotEmpty => isLoaded && stats.isNotEmpty;
  bool get isEmpty => isLoaded && stats.isEmpty;
}
