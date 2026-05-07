import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/amc_transaction_model.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'genre_details_state.dart';

class GenreDetailsCubit extends Cubit<GenreDetailsState> {
  GenreDetailsCubit({required AmcRepository amcRepository, required TransactionRepository transactionRepository})
    : _amcRepository = amcRepository,
      _transactionRepository = transactionRepository,
      super(const GenreDetailsState(status: GenreDetailsStateStatus.initial));

  final AmcRepository _amcRepository;
  final TransactionRepository _transactionRepository;

  Future<void> loadTransactions({required String accountId, required AmcGenre genre}) async {
    emit(const GenreDetailsState(status: GenreDetailsStateStatus.loading));

    try {
      final transactions = await _transactionRepository.getTransactions(accountId: accountId, genre: genre);

      if (transactions.isEmpty) {
        emit(const GenreDetailsState(status: GenreDetailsStateStatus.loaded));
        return;
      }
      final amcTransactionsMap = groupBy(transactions, (trn) => trn.amc);
      final amcTransactions = amcTransactionsMap.entries.map((entry) {
        return AmcTransaction(accountId: accountId, amc: entry.key, transactions: entry.value);
      }).toList();

      emit(GenreDetailsState(status: GenreDetailsStateStatus.loaded, stats: amcTransactions));
    } catch (err) {
      emit(GenreDetailsState(status: GenreDetailsStateStatus.error, errorMessage: err.toString()));
    }
  }

  // void updateCurrentAmount(String amcId, double currentAmount) {
  //   if (state.status != GenreDetailsStateStatus.loaded) {
  //     return;
  //   }
  //   final amounts = Map<String, double>.from(state.currentAmounts);

  //   emit(state.copyWith(currentAmounts: amounts..addAll({amcId: currentAmount})));
  // }

  void updateAmcLtp(String amcId, LatestPrice ltp) {
    if (state.status != GenreDetailsStateStatus.loaded) {
      return;
    }

    final stats = List<AmcTransaction>.from(state.stats);
    final index = stats.indexWhere((trn) => trn.amc?.id == amcId);
    if (index == -1) return;

    final updatedTransaction = stats[index].copyWith(amc: stats[index].amc?.copyWith(ltp: ltp));
    stats[index] = updatedTransaction;

    emit(state.copyWith(stats: stats));
  }

  void setSortAndFilterStatus(HoldingSortAndFilterStatus sortAndFilterStatus) {
    emit(state.copyWith(sortAndFilterStatus: sortAndFilterStatus));
  }
}
