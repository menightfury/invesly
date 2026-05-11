// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

enum GenreDetailsStateStatus { initial, loading, loaded, error }

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
    required this.status,
    this.stats = const [],
    this.currentAmounts = const {},
    this.errorMessage,
    this.sortAndFilterStatus = const HoldingSortAndFilterStatus(),
  });

  final GenreDetailsStateStatus status;
  final List<AmcTransaction> stats;
  final Map<String, double> currentAmounts;
  final String? errorMessage;
  final HoldingSortAndFilterStatus sortAndFilterStatus;

  int get numHoldings => stats.length;
  double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalInvested);
  int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

  List<AmcTransaction> get displayStats {
    // Filter
    final filtered = switch (sortAndFilterStatus.holdingFilter) {
      HoldingFilter.all => stats,
      HoldingFilter.active => stats.where((s) => s.totalUnits > 0).toList(),
      HoldingFilter.exited => stats.where((s) => s.totalUnits <= 0).toList(),
    };

    // Sort
    final sorted = List<AmcTransaction>.from(filtered);
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
          // final aVal = currentAmounts[a.amc?.id] ?? 0.0;
          // final bVal = currentAmounts[b.amc?.id] ?? 0.0;
          final aVal = a.totalCurrentValue ?? 0.0;
          final bVal = b.totalCurrentValue ?? 0.0;
          result = aVal.compareTo(bVal);
          break;

        case HoldingSortOption.returns:
          final aReturns = a.amountReturn ?? 0.0;
          final bReturns = b.amountReturn ?? 0.0;
          result = aReturns.compareTo(bReturns);
          break;

        case HoldingSortOption.xirr:
          final aXirr = a.xirr ?? 0.0;
          final bXirr = b.xirr ?? 0.0;
          result = aXirr.compareTo(bXirr);
          break;
      }
      return sortAndFilterStatus.sortAscending ? result : -result;
    });

    return sorted;
  }

  GenreDetailsState copyWith({
    GenreDetailsStateStatus? status,
    List<AmcTransaction>? stats,
    Map<String, double>? currentAmounts,
    String? errorMessage,
    HoldingSortAndFilterStatus? sortAndFilterStatus,
  }) {
    return GenreDetailsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      currentAmounts: currentAmounts ?? this.currentAmounts,
      errorMessage: errorMessage ?? this.errorMessage,
      sortAndFilterStatus: sortAndFilterStatus ?? this.sortAndFilterStatus,
    );
  }

  @override
  List<Object?> get props => [status, stats, currentAmounts, errorMessage, sortAndFilterStatus];
}

extension GenreDetailsStateX on GenreDetailsState {
  bool get isInitial => status == GenreDetailsStateStatus.initial;
  bool get isLoading => status == GenreDetailsStateStatus.loading;
  bool get isLoaded => status == GenreDetailsStateStatus.loaded;
  bool get isError => status == GenreDetailsStateStatus.error;
}
