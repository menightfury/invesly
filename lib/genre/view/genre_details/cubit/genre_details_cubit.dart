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
      super(const GenreDetailsInitialState());

  final AmcRepository _amcRepository;
  final TransactionRepository _transactionRepository;

  Future<void> loadDetails({required String accountId, required AmcGenre genre}) async {
    emit(const GenreDetailsLoadingState());

    try {
      final transactions = await _transactionRepository.getTransactions(accountId: accountId, genre: genre);

      if (transactions.isEmpty) {
        emit(const GenreDetailsLoadedState(stats: []));
        return;
      }
      final amcTransactionsMap = groupBy(transactions, (trn) => trn.amc);
      final amcTransactions = amcTransactionsMap.entries.map((entry) {
        return AmcTransaction(accountId: accountId, amc: entry.key, transactions: entry.value);
      }).toList();

      // final amcs = amcTransactions.map((e) => e.amc).nonNulls;
      // final prices = await Future.wait<LatestPrice?>(amcs.map((amc) => _amcRepository.getLatestPrice(amc)));
      // final latestPriceMap = Map.fromIterables(amcs, prices);

      // final newAmcTransactions = amcTransactions.map((e) {
      //   return e.copyWith(amc: e.amc?.copyWith(ltp: latestPriceMap[e.amc]));
      // }).toList();

      emit(GenreDetailsLoadedState(stats: amcTransactions));
    } catch (err) {
      emit(GenreDetailsErrorState(err.toString()));
    }
  }
}
