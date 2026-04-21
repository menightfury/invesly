import 'dart:async';

import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/amc_stat_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'transaction_stat_state.dart';

class TransactionStatCubit extends Cubit<TransactionStatState> {
  TransactionStatCubit({required AmcRepository amcRepository, required TransactionRepository trnRepository})
    : _trnRepository = trnRepository,
      _amcRepository = amcRepository,
      super(const TransactionStatInitialState());

  final TransactionRepository _trnRepository;
  final AmcRepository _amcRepository;

  StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction statistics (on initial load, on transactions change)
  Future<void> fetchTransactionStats(String accountId, {String? amcId}) async {
    // Cancel any existing subscription
    await _subscription?.cancel();
    _subscription = null;

    // Get initial transactions
    emit(const TransactionStatLoadingState());
    try {
      // if (accountId == null) {
      //   emit(const TransactionStatErrorState('No account has been selected'));
      //   return;
      // }
      final transactionStats = await _amcRepository.getStats(accountId);
      // if (transactionStats.isNotEmpty) {
      //   for (final stat in transactionStats) {
      //     LatestPrice? latestPrice;
      //     if (stat.amc.latestPriceUri != null) {
      //       latestPrice = await _amcRepository.getLatestPrice(stat.amc);
      //     }
      //     if (latestPrice != null) {
      //       stat.copyWith(amc: stat.amc.copyWith(ltp: latestPrice));
      //     }
      //   }
      // }
      emit(TransactionStatLoadedState(stats: transactionStats));
    } on Exception catch (error) {
      emit(TransactionStatErrorState(error.toString()));
    }

    // Get transactions on table change
    _subscription ??= _trnRepository.onDataChanged.listen(
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
        final transactionStats = await _amcRepository.getStats(accountId);
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
