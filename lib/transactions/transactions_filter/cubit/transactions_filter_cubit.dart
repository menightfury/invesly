import 'dart:async';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'transactions_filter_state.dart';

class TransactionsFilterCubit extends Cubit<TransactionsFilterState> {
  TransactionsFilterCubit({required TransactionRepository repository})
    : _repository = repository,
      super(const TransactionsFilterState());

  final TransactionRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction (on initial load, on transactions change)
  Future<void> fetchTransactions({DateTimeRange<DateTime>? dateRange, int? limit}) async {
    // DateTimeRange? dateRange;
    // if (start != null || end != null) {
    //   dateRange = DateTimeRange(start: start ?? DateTime(1970), end: end ?? DateTime.now());
    // }
    // Get initial transactions
    emit(state.copyWith(status: TransactionsFilterStatus.loading));
    try {
      final transactions = await _repository.getTransactions(dateRange: dateRange, limit: limit);

      emit(state.copyWith(status: TransactionsFilterStatus.loaded, transactions: transactions));
    } on Exception catch (err) {
      emit(state.copyWith(status: TransactionsFilterStatus.error, errorMsg: err.toString()));
    }

    // Get transactions on table change
    _subscription ??= _repository.onDataChanged.listen(
      null,
      onError: (err) => emit(state.copyWith(status: TransactionsFilterStatus.error, errorMsg: err.toString())),
    );
    _subscription?.onData((query) async {
      emit(state.copyWith(status: TransactionsFilterStatus.loading));

      _subscription?.pause();

      try {
        final transactions = await _repository.getTransactions(dateRange: dateRange, limit: limit);

        emit(state.copyWith(status: TransactionsFilterStatus.loaded, transactions: transactions));
      } on Exception catch (err) {
        emit(state.copyWith(status: TransactionsFilterStatus.error, errorMsg: err.toString()));
      } finally {
        _subscription?.resume();
      }
    });

    _subscription?.onDone(() {
      _subscription?.cancel();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
