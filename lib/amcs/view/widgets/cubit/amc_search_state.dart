part of 'amc_search_cubit.dart';

enum AmcSearchStateStatus { empty, loading, success, error }

class AmcSearchState extends Equatable {
  const AmcSearchState.empty() : items = const [], error = null, status = AmcSearchStateStatus.empty;
  const AmcSearchState.loading() : items = const [], error = null, status = AmcSearchStateStatus.loading;
  const AmcSearchState.success(this.items) : error = null, status = AmcSearchStateStatus.success;
  const AmcSearchState.error(this.error) : items = const [], status = AmcSearchStateStatus.error;

  final AmcSearchStateStatus status;
  final List<InveslyAmc> items;
  final String? error;

  AmcSearchState copyWith({AmcSearchStateStatus? status, List<InveslyAmc>? items, String? error}) {
    final newStatus = status ?? this.status;
    return switch (newStatus) {
      AmcSearchStateStatus.empty => AmcSearchState.empty(),
      AmcSearchStateStatus.loading => AmcSearchState.loading(),
      AmcSearchStateStatus.success => AmcSearchState.success(items ?? this.items),
      AmcSearchStateStatus.error => AmcSearchState.error(error ?? this.error),
    };
  }

  @override
  List<Object?> get props => [status, items, error];
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
