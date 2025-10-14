part of 'amc_search_cubit.dart';

sealed class AmcSearchState extends Equatable {
  const AmcSearchState();

  @override
  List<Object> get props => [];
}

final class AmcSearchStateEmpty extends AmcSearchState {}

final class AmcSearchStateLoading extends AmcSearchState {}

final class AmcSearchStateSuccess extends AmcSearchState {
  const AmcSearchStateSuccess(this.items);

  final List<InveslyAmc> items;

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'SearchStateSuccess { items: ${items.length} }';
}

final class AmcSearchStateError extends AmcSearchState {
  const AmcSearchStateError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
