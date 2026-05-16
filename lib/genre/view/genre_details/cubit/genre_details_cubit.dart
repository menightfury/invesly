import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';

part 'genre_details_state.dart';

class GenreDetailsCubit extends Cubit<GenreDetailsState> {
  GenreDetailsCubit()
    : // _repository = repository,
      // _transactionRepository = transactionRepository,
      super(GenreDetailsInitialState());

  // final AmcStatRepository _repository;
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

  void loadStats(List<AmcStat> stats) {
    late final GenreDetailsState newState;
    if (state is GenreDetailsLoadedState) {
      newState = (state as GenreDetailsLoadedState).copyWith(stats: stats);
    } else {
      newState = GenreDetailsLoadedState(stats: stats);
    }

    emit(newState);
  }

  void updateAmcLtp(String amcId, LatestPrice ltp) {
    if (state is! GenreDetailsLoadedState) {
      return;
    }

    final state_ = state as GenreDetailsLoadedState;

    final stats = List<AmcStat>.from(state_.stats);
    final index = stats.indexWhere((stat) => stat.amc.id == amcId);
    if (index == -1) return;

    final updatedStat = stats[index].copyWith(amc: stats[index].amc.copyWith(ltp: ltp));
    stats[index] = updatedStat;

    emit(state_.copyWith(stats: stats));
  }

  void setSortAndFilterStatus(HoldingSortAndFilterStatus sortAndFilterStatus) {
    if (state is! GenreDetailsLoadedState) {
      return;
    }

    final state_ = state as GenreDetailsLoadedState;
    emit(state_.copyWith(sortAndFilterStatus: sortAndFilterStatus));
  }
}
