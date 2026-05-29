import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required AmcRepository repository}) : _repository = repository, super(const AmcOverviewState());

  final AmcRepository _repository;

  void loadStat(AmcStat stat) async {
    emit(state.copyWith(stat: stat));

    // Get latest price for amc if quantity > 0,
    // this is required to calculate current amount and other metrics
    if (stat.totalQuantity > 0) {
      try {
        final ltp = await _repository.getLatestPrice(stat.amc);

        if (ltp == null) return;
        final newStat = stat.copyWith(amc: stat.amc.copyWith(ltp: ltp));

        emit(state.copyWith(status: LatestPriceStatus.loaded, stat: newStat));
      } catch (err) {
        emit(state.copyWith(status: LatestPriceStatus.error, errorMsg: err.toString()));
      }
    }
  }
}
