import 'dart:async';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/filter_transactions_model.dart';

part 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({required TransactionRepository repository, FilterTransactionsModel? initialFilters})
    : _repository = repository,
      super(TransactionsState(searchFilters: initialFilters));

  final TransactionRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction (on initial load, on transactions change)
  Future<void> fetchTransactions({String? accountId, DateTimeRange<DateTime>? dateRange, int? limit}) async {
    // DateTimeRange? dateRange;
    // if (start != null || end != null) {
    //   dateRange = DateTimeRange(start: start ?? DateTime(1970), end: end ?? DateTime.now());
    // }
    // Get initial transactions
    emit(state.copyWith(status: TransactionsStatus.loading));
    try {
      final transactions = await _repository.getTransactions(accountId: accountId, dateRange: dateRange, limit: limit);

      emit(state.copyWith(status: TransactionsStatus.loaded, transactions: transactions));
    } on Exception catch (err) {
      emit(state.copyWith(status: TransactionsStatus.error, errorMsg: err.toString()));
    }

    // Get transactions on table change
    _subscription ??= _repository.onDataChanged.listen(
      null,
      onError: (err) => emit(state.copyWith(status: TransactionsStatus.error, errorMsg: err.toString())),
    );
    _subscription?.onData((query) async {
      emit(state.copyWith(status: TransactionsStatus.loading));

      _subscription?.pause();

      try {
        final transactions = await _repository.getTransactions(
          accountId: accountId,
          dateRange: dateRange,
          limit: limit,
        );

        emit(state.copyWith(status: TransactionsStatus.loaded, transactions: transactions));
      } on Exception catch (err) {
        emit(state.copyWith(status: TransactionsStatus.error, errorMsg: err.toString()));
      } finally {
        _subscription?.resume();
      }
    });

    _subscription?.onDone(() {
      _subscription?.cancel();
    });
  }

  void clearSearchFilters() {
    // // Don't change the DateTime selected, as its handles separately
    // DateTimeRange? dateTimeRange = searchFilters.dateTimeRange;
    // // Only clear the search query if there are special filters identified within the search query
    // String? savedSearchQuery;
    // ParsedDateTimeQuery? parsedDateTimeQuery = searchFilters.searchQuery == null
    //     ? null
    //     : parseSearchQueryForDateTimeText(searchFilters.searchQuery ?? "");
    // (double, double)? bounds = searchFilters.searchQuery == null
    //     ? null
    //     : parseSearchQueryForAmountText(searchFilters.searchQuery ?? "");
    // if (parsedDateTimeQuery != null || bounds != null) {
    //   savedSearchQuery = null;
    // } else {
    //   savedSearchQuery = searchFilters.searchQuery;
    // }
    // searchFilters.clearSearchFilters();
    // searchFilters.dateTimeRange = dateTimeRange;
    // searchFilters.searchQuery = savedSearchQuery;
    emit(TransactionsState());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
