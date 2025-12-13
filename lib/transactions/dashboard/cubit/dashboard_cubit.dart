import 'dart:async';

import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/common_libs.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required TransactionRepository repository})
    : _repository = repository,
      super(const DashboardInitialState());

  final TransactionRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction statistics (on initial load, on transactions change)
  Future<void> fetchTransactionStats({DateTimeRange<DateTime>? dateRange, int? limit}) async {
    // DateTimeRange? dateRange;
    // if (start != null || end != null) {
    //   dateRange = DateTimeRange(start: start ?? DateTime(1970), end: end ?? DateTime.now());
    // }
    // Get initial transactions
    emit(const DashboardLoadingState());
    try {
      final transactionStats = await _repository.getTransactionStats();
      final recentTransactions = await _repository.getTransactions(dateRange: dateRange, limit: limit);

      emit(DashboardLoadedState(stats: transactionStats, recentTransactions: recentTransactions));
    } on Exception catch (error) {
      emit(DashboardErrorState(error.toString()));
    }

    // Get transactions on table change
    _subscription ??= _repository.onDataChanged.listen(
      null,
      onError: (err) => emit(DashboardErrorState(err.toString())),
    );
    _subscription?.onData((query) async {
      emit(const DashboardLoadingState());

      _subscription?.pause();

      try {
        final transactionStats = await _repository.getTransactionStats();
        final transactions = await _repository.getTransactions(dateRange: dateRange, limit: limit);

        emit(DashboardLoadedState(stats: transactionStats, recentTransactions: transactions));
      } on Exception catch (error) {
        emit(DashboardErrorState(error.toString()));
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
