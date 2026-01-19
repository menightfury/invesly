import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'amc_overview_state.dart';

class AmcOverviewCubit extends Cubit<AmcOverviewState> {
  AmcOverviewCubit({required AmcRepository repository})
    : _repository = repository,
      // _trnRepository = trnRepository,
      super(const AmcOverviewInitialState());

  final AmcRepository _repository;
  // final TransactionRepository _trnRepository;
  // StreamSubscription<TableChangeEvent>? _subscription;

  /// Fetch transaction statistics (on initial load, on transactions change)
  Future<void> fetchAmcOverview(String amcId) async {
    // Cancel any existing subscription
    // await _subscription?.cancel();
    // _subscription = null;

    // Get initial transactions
    emit(const AmcOverviewLoadingState());
    try {
      await Future.delayed(2.seconds); // TODO: Remove this
      final amc = await _repository.getAmcById(amcId);
      emit(AmcOverviewLoadedState(amc));
    } on Exception catch (error) {
      emit(AmcOverviewErrorState(error.toString()));
    }

    // Get transactions on table change
    // _subscription ??= _trnRepository.onDataChanged.listen(
    //   null,
    //   onError: (err) => emit(AmcOverviewState(status: AmcOverviewStatus.error, errorMsg: err.toString())),
    // );
    // _subscription?.onData((query) async {
    //   emit(const AmcOverviewState(status: AmcOverviewStatus.loading));
    //   _subscription?.pause();

    //   try {
    //     // if (accountId == null) {
    //     //   emit(const AmcOverviewErrorState('No account has been selected'));
    //     // } else {
    //     final AmcOverviews = await _repository.getAmcOverviews(accountId);
    //     emit(AmcOverviewState(stats: AmcOverviews));
    //     // }
    //     // }
    //   } on Exception catch (error) {
    //     emit(AmcOverviewErrorState(error.toString()));
    //   } finally {
    //     _subscription?.resume();
    //   }
    // });

    // _subscription?.onDone(() {
    //   _subscription?.cancel();
    // });
  }

  // @override
  // Future<void> close() {
  //   _subscription?.cancel();
  //   return super.close();
  // }
}
