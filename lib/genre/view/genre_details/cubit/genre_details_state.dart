// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

// enum GenreDetailsStateStatus { initial, loading, loaded, error }

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

abstract class GenreDetailsState extends Equatable {
  const GenreDetailsState();
}

class GenreDetailsInitialState extends GenreDetailsState {
  @override
  List<Object?> get props => [];
}

class GenreDetailsLoadedState extends GenreDetailsState {
  const GenreDetailsLoadedState({
    // required this.status,
    required this.stats,
    // this.currentAmounts = const {},
    // this.errorMessage,
    this.sortAndFilterStatus = const HoldingSortAndFilterStatus(),
  });

  // final GenreDetailsStateStatus status;
  // final List<AmcTransaction> stats;
  final List<AmcStat> stats;
  // final Map<String, double> currentAmounts;
  // final String? errorMessage;
  final HoldingSortAndFilterStatus sortAndFilterStatus;

  int get totalHoldings => stats.length;
  int get presentHoldings => stats.where((stat) => stat.totalQuantity > 0).length;
  // double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalInvested);
  double get totalRedeemed => stats.fold<double>(0, (v, el) => v + el.totalRedeemed);
  // int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

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

        default:
          result = 1; // TODO:

        // case HoldingSortOption.currentValue:
        //   // final aVal = currentAmounts[a.amc?.id] ?? 0.0;
        //   // final bVal = currentAmounts[b.amc?.id] ?? 0.0;
        //   final aVal = a.totalCurrentValue ?? 0.0;
        //   final bVal = b.totalCurrentValue ?? 0.0;
        //   result = aVal.compareTo(bVal);
        //   break;

        // case HoldingSortOption.returns:
        //   final aReturns = a.amountReturn ?? 0.0;
        //   final bReturns = b.amountReturn ?? 0.0;
        //   result = aReturns.compareTo(bReturns);
        //   break;

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

  GenreDetailsLoadedState copyWith({
    // GenreDetailsStateStatus? status,
    List<AmcStat>? stats,
    Map<String, double>? currentAmounts,
    // String? errorMessage,
    HoldingSortAndFilterStatus? sortAndFilterStatus,
  }) {
    return GenreDetailsLoadedState(
      // status: status ?? this.status,
      stats: stats ?? this.stats,
      // currentAmounts: currentAmounts ?? this.currentAmounts,
      // errorMessage: errorMessage ?? this.errorMessage,
      sortAndFilterStatus: sortAndFilterStatus ?? this.sortAndFilterStatus,
    );
  }

  @override
  List<Object?> get props => [stats, sortAndFilterStatus];
}

extension GenreDetailsStateX on GenreDetailsState {
  //   bool get isInitial => status == GenreDetailsStateStatus.initial;
  bool get isLoading => this is GenreDetailsInitialState;
  bool get isLoaded => this is GenreDetailsLoadedState;
  //   bool get isError => status == GenreDetailsStateStatus.error;
}
