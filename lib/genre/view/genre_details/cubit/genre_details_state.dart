// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'genre_details_cubit.dart';

enum GenreDetailsStateStatus { initial, loading, loaded, error }

enum HoldingSortOption {
  name('Name'),
  invested('Invested'),
  currentValue('Current value');

  const HoldingSortOption(this.label);
  final String label;
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
  double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalAmount);
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
      final int result;
      switch (sortOption) {
        case HoldingSortOption.name:
          result = (a.amc?.name ?? '').compareTo(b.amc?.name ?? '');
        case HoldingSortOption.invested:
          result = a.totalAmount.compareTo(b.totalAmount);
        case HoldingSortOption.currentValue:
          final aVal = currentAmounts[a.amc?.id] ?? 0.0;
          final bVal = currentAmounts[b.amc?.id] ?? 0.0;
          result = aVal.compareTo(bVal);
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

// abstract class GenreDetailsState extends Equatable {
//   const GenreDetailsState();

//   @override
//   List<Object?> get props => [];
// }

// class GenreDetailsInitialState extends GenreDetailsState {
//   const GenreDetailsInitialState();
// }

// class GenreDetailsLoadingState extends GenreDetailsState {
//   const GenreDetailsLoadingState();
// }

// class GenreDetailsLoadedState extends GenreDetailsState {
//   const GenreDetailsLoadedState({this.stats = const [], this.currentAmounts = const {}});

//   final List<AmcTransaction> stats;
//   final Map<String, double> currentAmounts;

//   double get totalCurrentValue => currentAmounts.entries.fold<double>(0, (v, el) => v + el.value);
//   double get totalInvested => stats.fold<double>(0, (v, el) => v + el.totalAmount);
//   int get totalTransactions => stats.fold<int>(0, (v, el) => v + el.numTransactions);

//   @override
//   List<Object?> get props => [stats, currentAmounts];

//   GenreDetailsLoadedState copyWith({List<AmcTransaction>? stats, Map<String, double>? currentAmounts}) {
//     return GenreDetailsLoadedState(stats: stats ?? this.stats, currentAmounts: currentAmounts ?? this.currentAmounts);
//   }
// }

// class GenreDetailsErrorState extends GenreDetailsState {
//   const GenreDetailsErrorState(this.message);

//   final String message;

//   @override
//   List<Object?> get props => [message];
// }
