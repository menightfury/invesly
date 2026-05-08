import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required AmcRepository repository})
    : _amcRepository = repository,

      super(const AmcOverviewInitialState());

  final AmcRepository _amcRepository;

  Future<void> fetchAmcOverview(String amcId) async {
    emit(const AmcOverviewLoadingState());
    try {
      final amc = await _amcRepository.getAmcById(amcId);

      // get latest price from server if amc is not null & amc.ltp is either null or not fetched today
      final latestPrice = amc != null ? await _amcRepository.getLatestPrice(amc) : null;

      if (isClosed) return;
      emit(AmcOverviewLoadedState(amc: amc?.copyWith(ltp: latestPrice)));
    } on Exception catch (error) {
      emit(AmcOverviewErrorState(error.toString()));
    }
  }
}
