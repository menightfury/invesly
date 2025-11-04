part of 'amc_search_cubit.dart';

enum AmcSearchStateStatus { initial, empty, loading, success, error }

class AmcSearchState extends Equatable {
  const AmcSearchState.initial()
    : searchGenre = AmcGenre.stock,
      results = const [],
      error = null,
      status = AmcSearchStateStatus.initial;

  const AmcSearchState._empty({required this.searchGenre})
    : results = const [],
      error = null,
      status = AmcSearchStateStatus.empty;

  const AmcSearchState._loading({required this.searchGenre})
    : results = const [],
      error = null,
      status = AmcSearchStateStatus.loading;

  const AmcSearchState._success(this.results, {required this.searchGenre})
    : error = null,
      status = AmcSearchStateStatus.success;

  const AmcSearchState._error(this.error, {required this.searchGenre})
    : results = const [],
      status = AmcSearchStateStatus.error;

  final AmcSearchStateStatus status;
  final AmcGenre searchGenre;
  final List<InveslyAmc> results;
  final String? error;

  AmcSearchState copyWith({
    AmcSearchStateStatus? status,
    AmcGenre? searchGenre,
    List<InveslyAmc>? results,
    String? error,
  }) {
    final newStatus = status ?? this.status;
    final newSearchGenre = searchGenre ?? this.searchGenre;
    return switch (newStatus) {
      AmcSearchStateStatus.initial => AmcSearchState.initial(),
      AmcSearchStateStatus.empty => AmcSearchState._empty(searchGenre: newSearchGenre),
      AmcSearchStateStatus.loading => AmcSearchState._loading(searchGenre: newSearchGenre),
      AmcSearchStateStatus.success => AmcSearchState._success(results ?? this.results, searchGenre: newSearchGenre),
      AmcSearchStateStatus.error => AmcSearchState._error(error ?? this.error, searchGenre: newSearchGenre),
    };
  }

  @override
  List<Object?> get props => [status, searchGenre, results, error];
}

// final class AmcSearchStateEmpty extends AmcSearchState {}

// final class AmcSearchStateLoading extends AmcSearchState {}

// final class AmcSearchStateSuccess extends AmcSearchState {
//   const AmcSearchStateSuccess(this.items);

//   final List<InveslyAmc> items;

//   @override
//   List<Object> get props => [items];

//   @override
//   String toString() => 'SearchStateSuccess { items: ${items.length} }';
// }

// final class AmcSearchStateError extends AmcSearchState {
//   const AmcSearchStateError(this.error);

//   final String error;

//   @override
//   List<Object> get props => [error];
// }
