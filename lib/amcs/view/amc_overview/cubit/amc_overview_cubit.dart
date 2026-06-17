import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({
    required TransactionRepository trnRepository,
    required AmcRepository amcRepository,
    required int accountId,
    required String amcId,
  }) : _trnRepository = trnRepository,
       _amcRepository = amcRepository,
       super(AmcOverviewState(accountId: accountId, amcId: amcId));

  final TransactionRepository _trnRepository;
  final AmcRepository _amcRepository;

  StreamSubscription<TableEvent>? _subscription;

  /// Fetch overview (on initial load, on transactions change)
  Future<void> fetchOverview() async {
    // Cancel any existing subscription
    await _subscription?.cancel();
    _subscription = null;

    // Get initial transactions
    await _getOverview();

    // Get transactions on subsequent table change
    _subscription ??= _trnRepository.onDataChanged.listen(
      null,
      onError: (err) => emit(
        state.copyWith(
          // status: AmcOverviewStatus.error,
          errors: state.errors..add(AmcOverviewErrorType.transaction),
        ),
      ),
    );
    _subscription?.onData((_) async {
      _subscription?.pause();
      try {
        await _getOverview();
      } finally {
        _subscription?.resume();
      }
    });

    _subscription?.onDone(() => _subscription?.cancel());
  }

  Future<void> _getOverview() async {
    emit(state.copyWith(transactionStatus: AmcOverviewStatus.loading));

    AmcOverviewState state_ = state;
    // Get transactions
    try {
      final trns = await _trnRepository.getTransactions(accountId: state_.accountId, amcId: state_.amcId);
      state_ = state_.copyWith(transactionStatus: AmcOverviewStatus.loaded, transactions: trns);
    } on Exception catch (err) {
      $logger.e(err);
      state_ = state_.copyWith(
        transactionStatus: AmcOverviewStatus.error,
        errors: state_.errors..add(AmcOverviewErrorType.transaction),
      );
    }

    // Get amc details
    if (state_.amcStatus != AmcOverviewStatus.loaded) {
      if (state_.transactions.isNotEmpty) {
        state_ = state_.copyWith(amcStatus: AmcOverviewStatus.loaded, amc: state_.transactions.first.amc);
      } else {
        try {
          final amc = await _amcRepository.getAmcById(state.amcId);
          if (amc != null) {
            state_ = state_.copyWith(amcStatus: AmcOverviewStatus.loaded, amc: amc);
          }
        } catch (err) {
          $logger.e(err);
          state_ = state_.copyWith(
            amcStatus: AmcOverviewStatus.error,
            errors: state_.errors..add(AmcOverviewErrorType.amc),
          );
        }
      }
    }

    // Get latest price of amc
    if (state_.amc != null) {
      try {
        final ltp = await _amcRepository.getLatestPrice(state_.amc!);
        if (ltp != null) {
          state_ = state_.copyWith(ltpStatus: AmcOverviewStatus.loaded, ltp: ltp);
        }
      } catch (err) {
        $logger.e(err);
        state_ = state_.copyWith(
          ltpStatus: AmcOverviewStatus.error,
          errors: state_.errors..add(AmcOverviewErrorType.ltp),
        );
      }
    }

    emit(state_);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _subscription = null;
    return super.close();
  }
}

// class AmcOverviewCubit extends Cubit<AmcOverviewState> {
//   AmcOverviewCubit({required AmcRepository repository, required String amcId})
//     : _amcRepository = repository,
//       super(AmcOverviewState(amcId: amcId));

//   final AmcRepository _amcRepository;

//   Future<void> getAmcDetails() async {
//     try {
//       emit(state.copyWith(status: AmcOverviewStatus.loading));

//       final amc = await _amcRepository.getAmcById(state.amcId);
//       if (isClosed) return;
//       emit(state.copyWith(status: AmcOverviewStatus.loaded, amc: amc));
//     } catch (err) {
//       emit(state.copyWith(status: AmcOverviewStatus.error, errorMsg: err.toString()));
//     }
//   }

//   Future<void> getLatestPrice() async {
//     if (state.amc == null) return;

//     try {
//       final ltp = await _amcRepository.getLatestPrice(state.amc!);

//       if (ltp == null || isClosed) return;

//       emit(state.copyWith(ltpStatus: LatestPriceStatus.loaded, ltp: ltp));
//     } catch (err) {
//       emit(state.copyWith(ltpStatus: LatestPriceStatus.error, errorMsg: err.toString()));
//     }
//   }
// }
