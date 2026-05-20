import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'genre_details_state.dart';

class GenreDetailsCubit extends Cubit<GenreDetailsState> {
  GenreDetailsCubit({required AmcRepository repository})
    : _repository = repository,
      // _transactionRepository = transactionRepository,
      super(GenreDetailsState());

  final AmcRepository _repository;
  // final TransactionRepository _transactionRepository;

  // Future<void> loadTransactions({required String accountId, required AmcGenre genre}) async {
  //   emit(const GenreDetailsState(status: GenreDetailsStateStatus.loading));

  //   try {
  //     final transactions = await _transactionRepository.getTransactions(accountId: accountId, genre: genre);

  //     if (transactions.isEmpty) {
  //       emit(const GenreDetailsState(status: GenreDetailsStateStatus.loaded));
  //       return;
  //     }
  //     final amcTransactionsMap = groupBy(transactions, (trn) => trn.amc);
  //     final amcTransactions = amcTransactionsMap.entries.map((entry) {
  //       InveslyAmc? amc = entry.key;

  //       return AmcTransaction(amc: amc, transactions: entry.value);
  //     }).toList();

  //     emit(GenreDetailsState(status: GenreDetailsStateStatus.loaded, stats: amcTransactions));
  //   } catch (err) {
  //     emit(GenreDetailsState(status: GenreDetailsStateStatus.error, errorMessage: err.toString()));
  //   }
  // }

  // Future<void> loadStats({required String accountId, required AmcGenre genre}) async {
  //   emit(state.copyWith(status: GenreDetailsStateStatus.loading));

  //   _repository
  //       .fetchStats(accountId)
  //       .listen(
  //         (stats) => state.copyWith(status: GenreDetailsStateStatus.loaded, stats: stats),
  //         onError: (error, _) => state.copyWith(status: GenreDetailsStateStatus.error, errorMessage: error.toString()),
  //       );
  // }

  Future<void> loadStats(List<AmcStat> stats) async {
    emit(state.copyWith(status: GenreDetailsStateStatus.ltpLoading, stats: stats));

    // Get current amount for every stat, this is required to calculate overall current amount and other metrics.
    try {
      final latestPriceMap = await Future.wait(
        stats.map((stat) async {
          final ltp = await _repository.getLatestPrice(stat.amc);
          return MapEntry(stat.amc.id, ltp);
        }),
      ).then((entries) => Map.fromEntries(entries));

      final newStats = stats.map((stat) {
        final ltp = latestPriceMap[stat.amc.id];
        if (ltp == null) return stat;
        return stat.copyWith(amc: stat.amc.copyWith(ltp: ltp));
      }).toList();

      emit(state.copyWith(status: GenreDetailsStateStatus.ltpLoaded, stats: newStats));
    } catch (err) {
      emit(state.copyWith(status: GenreDetailsStateStatus.error, errorMsg: err.toString()));
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
    if (!state.isLoaded) {
      return;
    }

    emit(state.copyWith(sortAndFilterStatus: sortAndFilterStatus));
  }
}
