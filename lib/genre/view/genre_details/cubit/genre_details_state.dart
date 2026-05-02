// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

enum GenreDetailsStateStatus { initial, loading, loaded, error }

enum HoldingSortOption {
  name(label: 'Name', ascendingLabel: 'A-Z', descendingLabel: 'Z-A'),
  invested(label: 'Invested', ascendingLabel: 'Low to High', descendingLabel: 'High to Low'),
  currentValue(label: 'Current value', ascendingLabel: 'Low to High', descendingLabel: 'High to Low'),
  returns(label: 'Returns %', ascendingLabel: 'Low to High', descendingLabel: 'High to Low'),
  xirr(label: 'XIRR', ascendingLabel: 'Low to High', descendingLabel: 'High to Low');

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

class GenreDetailsState extends Equatable {
  const GenreDetailsState({
    required this.status,
    this.stats = const [],
    this.currentAmounts = const {},
    this.errorMessage,
    this.sortOption = HoldingSortOption.name,
    this.sortAscending = true,
    this.holdingFilter = HoldingFilter.all,
  });

  final GenreDetailsStateStatus status;
  final List<AmcTransaction> stats;
  final Map<String, double> currentAmounts;
  final String? errorMessage;
  final HoldingSortOption sortOption;
  final bool sortAscending;
  final HoldingFilter holdingFilter;

  int get numHoldings => stats.length;
  double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalInvested);
  int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

  List<AmcTransaction> get displayStats {
    // Filter
    final filtered = switch (holdingFilter) {
      HoldingFilter.all => stats,
      HoldingFilter.active => stats.where((s) => s.totalQuantity > 0).toList(),
      HoldingFilter.exited => stats.where((s) => s.totalQuantity <= 0).toList(),
    };

    // Sort
    final sorted = List<AmcTransaction>.from(filtered);
    sorted.sort((a, b) {
      late final int result;
      switch (sortOption) {
        case HoldingSortOption.name:
          result = (a.amc?.name ?? '').compareTo(b.amc?.name ?? '');
          break;

        case HoldingSortOption.invested:
          result = a.totalInvested.compareTo(b.totalInvested);
          break;

        case HoldingSortOption.currentValue:
          // final aVal = currentAmounts[a.amc?.id] ?? 0.0;
          // final bVal = currentAmounts[b.amc?.id] ?? 0.0;
          final aVal = a.currentValue ?? 0.0;
          final bVal = b.currentValue ?? 0.0;
          result = aVal.compareTo(bVal);
          break;

        case HoldingSortOption.returns:
          final aReturns = a.returns ?? 0.0;
          final bReturns = b.returns ?? 0.0;
          result = aReturns.compareTo(bReturns);
          break;

        case HoldingSortOption.xirr:
          final aXirr = a.xirr ?? 0.0;
          final bXirr = b.xirr ?? 0.0;
          result = aXirr.compareTo(bXirr);
          break;
      }
      return sortAscending ? result : -result;
    });

    return sorted;
  }

  GenreDetailsState copyWith({
    GenreDetailsStateStatus? status,
    List<AmcTransaction>? stats,
    Map<String, double>? currentAmounts,
    String? errorMessage,
    HoldingSortOption? sortOption,
    bool? sortAscending,
    HoldingFilter? holdingFilter,
  }) {
    return GenreDetailsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      currentAmounts: currentAmounts ?? this.currentAmounts,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
      holdingFilter: holdingFilter ?? this.holdingFilter,
    );
  }

  @override
  List<Object?> get props => [status, stats, currentAmounts, errorMessage, sortOption, sortAscending, holdingFilter];
}

extension GenreDetailsStateX on GenreDetailsState {
  bool get isInitial => status == GenreDetailsStateStatus.initial;
  bool get isLoading => status == GenreDetailsStateStatus.loading;
  bool get isLoaded => status == GenreDetailsStateStatus.loaded;
  bool get isError => status == GenreDetailsStateStatus.error;
}
