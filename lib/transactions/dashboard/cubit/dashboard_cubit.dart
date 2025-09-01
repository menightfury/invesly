import 'dart:async';

import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/common_libs.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required TransactionRepository repository}) : _repository = repository, super(const DashboardState());
  // super(const DashboardInitialState());

  final TransactionRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction statistics (on initial load, on transactions change)
  Future<void> fetchTransactionStats(String? accountId) async {
    // Get initial transactions
    // emit(const DashboardLoadingState());
    emit(const DashboardState(statStatus: DashboardStatus.loading, recentTransactionStatus: DashboardStatus.loading));
    try {
      final transactionStats = await _repository.getTransactionStats();
      List<InveslyTransaction>? recentTransactions;
      if (accountId != null) {
        recentTransactions = await _repository.getTransactions(accountId: accountId);
      }

      emit(DashboardLoadedState(summaries: transactionStats, recentTransactions: recentTransactions));
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
        final transactions = await _repository.getTransactions(accountId: accountId);
        final transactionStats = await _repository.getTransactionStats(accountId);

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

  /// Get recent transactions, (when account changes)
  Future<void> getRecentTransactions(String accountId) async {
    emit(state.copyWith(recentTransactionStatus: DashboardStatus.loading, recentTransactions: []));

    try {
      final recentTransactions = await _repository.getTransactions(accountId: accountId);
      emit(state.copyWith(recentTransactionStatus: DashboardStatus.loaded, recentTransactions: recentTransactions));
    } on Exception catch (error) {
      emit(state.copyWith(recentTransactionStatus: DashboardStatus.error, errorMsg: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
