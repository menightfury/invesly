import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

part 'genre_details_state.dart';

class GenreDetailsCubit extends Cubit<GenreDetailsState> {
  GenreDetailsCubit({required this.repository}) : super(const GenreDetailsLoadingState());

  final AmcRepository repository;

  Future<void> loadDetails(List<TransactionStat> stats) async {
    emit(const GenreDetailsLoadingState());

    try {
      final detailsList = <AmcGenreDetailsStat>[];

      // Fetch latest price for each AMC that has an API
      for (final stat in stats) {
        LatestPrice? latestPrice;
        if (stat.amc.latestPriceUri != null) {
          latestPrice = await repository.getLatestPrice(stat.amc);
        }
        detailsList.add(AmcGenreDetailsStat(stat: stat, latestPrice: latestPrice));
      }

      emit(GenreDetailsLoadedState(detailsList: detailsList));
    } catch (e) {
      emit(GenreDetailsErrorState(e.toString()));
    }
  }
}
