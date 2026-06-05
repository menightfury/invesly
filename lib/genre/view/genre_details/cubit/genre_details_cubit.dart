import 'package:invesly/amc_stat/model/amc_stat_model.dart';
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

  Future<void> loadStats(List<AmcStat> stats) async {
    emit(state.copyWith(status: LatestPriceStatus.loading, stats: stats));

    // Get latest price for every amc whose quantity > 0,
    // this is required to calculate overall current amount and other metrics
    final nonZeroStats = stats.where((stat) => stat.totalQuantity > 0);
    try {
      final latestPriceMap = await Future.wait(
        nonZeroStats.map((stat) async {
          final ltp = await _repository.getLatestPrice(stat.amc);
          return MapEntry(stat.amc.id, ltp);
        }),
      ).then((entries) => Map.fromEntries(entries));

      final newStats = stats.map((stat) {
        final ltp = latestPriceMap[stat.amc.id];
        if (ltp == null) return stat;
        return stat.copyWith(amc: stat.amc.copyWith(ltp: ltp));
      }).toList();

      if (isClosed) return;
      emit(state.copyWith(status: LatestPriceStatus.loaded, stats: newStats));
    } catch (err) {
      emit(state.copyWith(status: LatestPriceStatus.error, errorMsg: err.toString()));
    }
  }

  // void updateAmcLtp(String amcId, LatestPrice ltp) {
  //   if (state is! GenreDetailsLoadedState) {
  //     return;
  //   }

  //   final loadedState = state as GenreDetailsLoadedState;

  //   final stats = List<AmcStat>.from(loadedState.stats);
  //   final index = stats.indexWhere((stat) => stat.amc.id == amcId);
  //   if (index == -1) return;

  //   final updatedStat = stats[index].copyWith(amc: stats[index].amc.copyWith(ltp: ltp));
  //   stats[index] = updatedStat;

  //   emit(loadedState.copyWith(stats: stats));
  // }

  // void updateCurrentAmount(String amcId, double currentAmount) {
  //   if (state is! GenreDetailsLoadedState) {
  //     return;
  //   }

  //   final loadedState = state as GenreDetailsLoadedState;
  //   final currentAmounts = Map<String, double>.from(loadedState._currentAmounts);
  //   currentAmounts[amcId] = currentAmount;

  //   emit(loadedState.copyWith(currentAmounts: currentAmounts));
  // }

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
