import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required AmcRepository repository, required String amcId})
    : _amcRepository = repository,
      super(AmcOverviewState(amcId: amcId));

  final AmcRepository _amcRepository;

  Future<void> getAmcDetails() async {
    try {
      emit(state.copyWith(status: AmcOverviewStatus.loading));

      final amc = await _amcRepository.getAmcById(state.amcId);
      if (isClosed) return;
      emit(state.copyWith(status: AmcOverviewStatus.loaded, amc: amc));
    } catch (err) {
      emit(state.copyWith(status: AmcOverviewStatus.error, errorMsg: err.toString()));
    }
  }

  Future<void> getLatestPrice() async {
    if (state.amc == null) return;

    try {
      final ltp = await _amcRepository.getLatestPrice(state.amc!);

      if (ltp == null || isClosed) return;

      emit(state.copyWith(ltpStatus: LatestPriceStatus.loaded, ltp: ltp));
    } catch (err) {
      emit(state.copyWith(ltpStatus: LatestPriceStatus.error, errorMsg: err.toString()));
    }
  }
}
