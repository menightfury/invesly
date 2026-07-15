import 'package:invesly/stat/model/stat_repository.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/common_libs.dart';

part 'account_details_state.dart';

class AccountDetailsCubit extends Cubit<AccountDetailsState> {
  AccountDetailsCubit({required StatRepository repository})
    : _repository = repository,
      super(const AccountDetailsState());

  final StatRepository _repository;

  Future<void> fetchAccountStats(int accountId) async {
    emit(state.copyWith(status: AccountDetailsStatus.loading));

    try {
      final stats = await _repository.getStats(accountId);
      final total = stats.fold<double>(0, (v, el) => v + el.totalInvested);

      emit(state.copyWith(status: AccountDetailsStatus.loaded, stats: stats, totalInvested: total));
    } catch (e) {
      emit(state.copyWith(status: AccountDetailsStatus.error));
      $logger.e('Failed to fetch account stats', error: e);
    }
  }

  void selectGenre(AmcGenre? genre) {
    emit(state.copyWith(selectedGenre: genre));
  }

  void updateActiveAccountId(int id) {
    emit(state.copyWith(activeAccountId: id));
  }
}
