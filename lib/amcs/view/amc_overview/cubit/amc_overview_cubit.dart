import 'dart:async';

import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required AmcRepository repository, required String amcId})
    : _amcRepository = repository,
      super(AmcOverviewState(amcId: stat));

  final AmcRepository _amcRepository;

  Future<void> getAmcDetails() async {
    // Implementation for fetching AMC details
  }

  Future<void> getLatestPrice() async {
    try {
      final ltp = await _amcRepository.getLatestPrice(state.amcId.amc);

      if (ltp == null || isClosed) return;

      emit(state.copyWith(ltpStatus: LatestPriceStatus.loaded, ltp: ltp));
    } catch (err) {
      emit(state.copyWith(ltpStatus: LatestPriceStatus.error, errorMsg: err.toString()));
    }
  }
}
