import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'genre_details_state.dart';

class GenreDetailsCubit extends Cubit<GenreDetailsState> {
  GenreDetailsCubit({required TransactionRepository trnRepository, required AmcRepository amcRepository})
    : _trnRepository = trnRepository,
      _amcRepository = amcRepository,
      super(const GenreDetailsLoadingState());

  final TransactionRepository _trnRepository;
  final AmcRepository _amcRepository;

  Future<void> loadDetails(String accountId) async {
    emit(const GenreDetailsLoadingState());

    try {
      final transactionStats = await _trnRepository.getTransactionStats(accountId);
      final detailsList = <AmcGenreDetailsStat>[];

      // Fetch latest price for each AMC that has an API
      for (final stat in transactionStats) {
        LatestPrice? latestPrice;
        if (stat.amc.latestPriceUri != null) {
          latestPrice = await _amcRepository.getLatestPrice(stat.amc);
        }
        detailsList.add(AmcGenreDetailsStat(stat: stat, latestPrice: latestPrice));
      }

      emit(GenreDetailsLoadedState(detailsList: detailsList));
    } catch (e) {
      emit(GenreDetailsErrorState(e.toString()));
    }
  }
}
