import 'dart:async';

import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amc_stat/model/amc_stat_repository.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required String accountId, required String amcId, AmcStat? stat})
    : _statRepository = AmcStatRepository.instance,
      _amcRepository = AmcRepository.instance,
      super(AmcOverviewState(accountId: accountId, amcId: amcId, stat: stat));

  final AmcStatRepository _statRepository;
  final AmcRepository _amcRepository;

  Future<void> getStat() async {
    if (state.stat != null) {
      emit(state.copyWith(status: AmcOverviewStatus.loaded));
      return;
    }

    emit(state.copyWith(status: AmcOverviewStatus.loading));
    try {
      final stat = await _statRepository.getStat(accountId: state.accountId, amcId: state.amcId);
      emit(state.copyWith(status: AmcOverviewStatus.loaded, stat: stat));
    } on Exception catch (error) {
      emit(state.copyWith(status: AmcOverviewStatus.error, errorMsg: error.toString()));
    }
  }

  Future<void> getLatestPrice() async {
    // Get latest price for amc if quantity > 0,
    // this is required to calculate current amount and other metrics
    if (state.stat != null && state.stat!.totalQuantity > 0) {
      try {
        final ltp = await _amcRepository.getLatestPrice(state.stat!.amc);

        if (ltp == null) return;
        final newStat = state.stat!.copyWith(amc: state.stat!.amc.copyWith(ltp: ltp));

        emit(state.copyWith(ltpStatus: LatestPriceStatus.loaded, stat: newStat));
      } catch (err) {
        emit(state.copyWith(ltpStatus: LatestPriceStatus.error, errorMsg: err.toString()));
      }
    }
  }
}
