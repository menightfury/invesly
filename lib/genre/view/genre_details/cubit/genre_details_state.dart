// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

enum HoldingSortOption {
  name(label: 'Name', ascendingLabel: 'A to Z', descendingLabel: 'Z to A'),
  invested(label: 'Invested', ascendingLabel: 'High to Low', descendingLabel: 'Low to High'),
  currentValue(label: 'Current value', ascendingLabel: 'High to Low', descendingLabel: 'Low to High'),
  returns(label: 'Returns %', ascendingLabel: 'High to Low', descendingLabel: 'Low to High'),
  xirr(label: 'XIRR', ascendingLabel: 'High to Low', descendingLabel: 'Low to High');

  final String label;
  final String? ascendingLabel;
  final String? descendingLabel;

  const HoldingSortOption({required this.label, this.ascendingLabel, this.descendingLabel});
}

enum HoldingFilter {
  all('All'),
  active('Active'),
  exited('Exited');

  const HoldingFilter(this.label);
  final String label;
}

class HoldingSortAndFilterStatus extends Equatable {
  const HoldingSortAndFilterStatus({
    this.sortOption = HoldingSortOption.name,
    this.sortAscending = true,
    this.holdingFilter = HoldingFilter.active,
  });

  final HoldingSortOption sortOption;
  final bool sortAscending;
  final HoldingFilter holdingFilter;

  HoldingSortAndFilterStatus copyWith({
    HoldingSortOption? sortOption,
    bool? sortAscending,
    HoldingFilter? holdingFilter,
  }) {
    return HoldingSortAndFilterStatus(
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
      holdingFilter: holdingFilter ?? this.holdingFilter,
    );
  }

  @override
  List<Object?> get props => [sortOption, sortAscending, holdingFilter];
}

class GenreDetailsState extends Equatable {
  const GenreDetailsState({
    required this.genre,
    this.activeAccountId,
    this.stats = const [],
    this.ltpStatus = LatestPriceStatus.initial,
    this.latestPrices = const {},
    this.errorMsg,
    this.sortAndFilterStatus = const HoldingSortAndFilterStatus(),
  });

  final AmcGenre genre;
  final int? activeAccountId;
  final List<AmcStat> stats;
  final LatestPriceStatus ltpStatus;
  final Map<String, LatestPrice?> latestPrices;
  final String? errorMsg;
  final HoldingSortAndFilterStatus sortAndFilterStatus;

  int get totalHoldings => stats.length;
  int get presentHoldings => stats.where((stat) => stat.totalQuantity > 0).length;
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalInvested);
  double get totalRedeemed => stats.fold<double>(0, (v, el) => v + el.totalRedeemed);

  Map<String, double> get currentAmounts {
    final map = <String, double>{};
    for (var i = 0; i < stats.length; i++) {
      final stat = stats[i];
      map[stat.amc.id] = stat.totalQuantity * (latestPrices[stat.amc.id]?.price ?? 0.0);
    }
    return map;
  }

  double get totalCurrentAmount => currentAmounts.values.fold<double>(0, (v, el) => v + el);
  double get totalReturns => totalCurrentAmount - totalInvested;

  List<AmcStat> get displayStats {
    if (stats.isEmpty) return stats;

    // Filter
    final filtered = switch (sortAndFilterStatus.holdingFilter) {
      HoldingFilter.all => stats,
      HoldingFilter.active => stats.where((s) => s.totalQuantity > 0).toList(),
      HoldingFilter.exited => stats.where((s) => s.totalQuantity <= 0).toList(),
    };

    if (filtered.isEmpty) return filtered;

    // Sort
    final sorted = List<AmcStat>.from(filtered);
    sorted.sort((a, b) {
      late final int result;
      switch (sortAndFilterStatus.sortOption) {
        case HoldingSortOption.name:
          result = a.amc.name.compareTo(b.amc.name);
          break;

        case HoldingSortOption.invested:
          result = a.totalInvested.compareTo(b.totalInvested);
          break;

        case HoldingSortOption.currentValue:
          final aVal = currentAmounts[a.amc.id] ?? 0.0;
          final bVal = currentAmounts[b.amc.id] ?? 0.0;
          result = aVal.compareTo(bVal);
          break;

        case HoldingSortOption.returns:
          final aReturns = (currentAmounts[a.amc.id] ?? 0.0) - a.totalInvested;
          final bReturns = (currentAmounts[b.amc.id] ?? 0.0) - b.totalInvested;
          result = aReturns.compareTo(bReturns);
          break;

        default:
          result = 1; // TODO

        // case HoldingSortOption.xirr:
        //   final aXirr = a.xirr ?? 0.0;
        //   final bXirr = b.xirr ?? 0.0;
        //   result = aXirr.compareTo(bXirr);
        //   break;
      }
      return sortAndFilterStatus.sortAscending ? result : -result;
    });

    return sorted;
  }

  GenreDetailsState copyWith({
    AmcGenre? genre,
    int? activeAccountId,
    List<AmcStat>? stats,
    LatestPriceStatus? ltpStatus,
    Map<String, LatestPrice?>? latestPrices,
    String? errorMsg,
    HoldingSortAndFilterStatus? sortAndFilterStatus,
  }) {
    return GenreDetailsState(
      genre: genre ?? this.genre,
      activeAccountId: activeAccountId ?? this.activeAccountId,
      stats: stats ?? this.stats,
      ltpStatus: ltpStatus ?? this.ltpStatus,
      latestPrices: latestPrices ?? this.latestPrices,
      errorMsg: errorMsg ?? this.errorMsg,
      sortAndFilterStatus: sortAndFilterStatus ?? this.sortAndFilterStatus,
    );
  }

  @override
  List<Object?> get props => [ltpStatus, genre, activeAccountId, stats, errorMsg, sortAndFilterStatus];
}

extension GenreDetailsStateX on GenreDetailsState {
  // bool get isLtpInitial => status == LatestPriceStatus.initial;
  bool get isLtpLoading => ltpStatus == LatestPriceStatus.loading;
  bool get isLtpLoaded => ltpStatus == LatestPriceStatus.loaded;
  bool get isLtpError => ltpStatus == LatestPriceStatus.error;
}
