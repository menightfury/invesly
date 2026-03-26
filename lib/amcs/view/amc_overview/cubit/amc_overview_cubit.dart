import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required AmcRepository repository})
    : _repository = repository,
      super(const AmcOverviewInitialState());

  final AmcRepository _repository;

  Future<void> fetchAmcOverview(String amcId) async {
    emit(const AmcOverviewLoadingState());
    try {
      final amc = await _repository.getAmcById(amcId);
      final latestPrice = amc != null ? await _repository.getLatestPrice(amc) : null;

      if (isClosed) return;
      emit(AmcOverviewLoadedState(amc: amc, latestPrice: latestPrice));
    } on Exception catch (error) {
      emit(AmcOverviewErrorState(error.toString()));
    }
  }
}
