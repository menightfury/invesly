import 'dart:async';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'transaction_stat_state.dart';

class TransactionStatCubit extends Cubit<TransactionStatState> {
  TransactionStatCubit({required TransactionRepository repository})
    : _repository = repository,
      super(const TransactionStatInitialState());

  final TransactionRepository _repository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction statistics (on initial load, on transactions change)
  Future<void> fetchTransactionStats(String accountId, {String? amcId}) async {
    // Cancel any existing subscription
    await _subscription?.cancel();
    _subscription = null;

    // Get initial transactions
    emit(const TransactionStatLoadingState());
    try {
      // wait for 2 seconds
      await Future.delayed(2.seconds); // TODO: Remove this
      // if (accountId == null) {
      //   emit(const TransactionStatErrorState('No account has been selected'));
      //   return;
      // }
      final transactionStats = await _repository.getTransactionStats(accountId);
      emit(TransactionStatLoadedState(stats: transactionStats));
    } on Exception catch (error) {
      emit(TransactionStatErrorState(error.toString()));
    }

    // Get transactions on table change
    _subscription ??= _repository.onDataChanged.listen(
      null,
      onError: (err) => emit(TransactionStatErrorState(err.toString())),
    );
    _subscription?.onData((query) async {
      emit(const TransactionStatLoadingState());

      _subscription?.pause();

      try {
        // if (accountId == null) {
        //   emit(const TransactionStatErrorState('No account has been selected'));
        // } else {
        final transactionStats = await _repository.getTransactionStats(accountId);
        emit(TransactionStatLoadedState(stats: transactionStats));
        // }
      } on Exception catch (error) {
        emit(TransactionStatErrorState(error.toString()));
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
