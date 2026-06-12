import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';

part 'genre_details_state.dart';

class GenreDetailsCubit extends Cubit<GenreDetailsState> {
  GenreDetailsCubit({required AmcRepository repository, required AmcGenre genre, int? activeAccountId})
    : _repository = repository,
      super(GenreDetailsState(genre: genre, activeAccountId: activeAccountId));

  final AmcRepository _repository;

  // Get latest price for every amc whose quantity > 0,
  // this is required to calculate overall current amount and other metrics
  Future<void> loadStats(List<InveslyStat> stats) async {
    emit(state.copyWith(ltpStatus: LatestPriceStatus.loading, stats: stats));

    final nonZeroStats = stats.where((stat) => stat.totalQuantity > 0);
    try {
      final latestPrices = await Future.wait(
        nonZeroStats.map((stat) async {
          final ltp = await _repository.getLatestPrice(stat.amc);
          return MapEntry(stat.amc.id, ltp);
        }),
      ).then((entries) => Map.fromEntries(entries));

      if (isClosed) return;
      emit(state.copyWith(ltpStatus: LatestPriceStatus.loaded, latestPrices: latestPrices));
    } catch (err) {
      emit(state.copyWith(ltpStatus: LatestPriceStatus.error, errorMsg: err.toString()));
    }
  }

  void setSortAndFilterStatus(HoldingSortAndFilterStatus sortAndFilterStatus) {
    if (!state.isLtpLoaded) {
      return;
    }

    emit(state.copyWith(sortAndFilterStatus: sortAndFilterStatus));
  }

  void updateActiveAccountId(int id) {
    emit(state.copyWith(activeAccountId: id));
  }
}
