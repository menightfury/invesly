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

  /// Fetch transaction statistics
  Future<void> fetchTransactionStats() async {
    // Get initial transactions
    emit(const DashboardLoadingState());
    try {
      final transactions = await _repository.getTransactions();
      final transactionStats = await _repository.getTransactionStats();

      emit(DashboardLoadedState(summaries: transactionStats, recentTransactions: transactions));
    } on Exception catch (error) {
      emit(DashboardErrorState(error.toString()));
    }

    // Get transactions on table change
    _subscription ??= _repository.onTableChange.listen(
      null,
      onError: (err) => emit(DashboardErrorState(err.toString())),
    );
    _subscription?.onData((query) async {
      emit(const DashboardLoadingState());

      _subscription?.pause();

      try {
        final transactions = await _repository.getTransactions();
        final transactionStats = await _repository.getTransactionStats();

        emit(DashboardLoadedState(summaries: transactionStats, recentTransactions: transactions));
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
