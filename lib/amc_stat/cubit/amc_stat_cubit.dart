import 'dart:async';

import 'package:invesly/amc_stat/model/amc_stat_repository.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

part 'amc_stat_state.dart';

class AmcStatCubit extends Cubit<AmcStatState> {
  AmcStatCubit({required AmcStatRepository repository}) : _repository = repository, super(const AmcStatInitialState());

  final AmcStatRepository _repository;

  StreamSubscription<TableEvent>? _subscription;

  Future<void> fetchAllStats() async {
    // Cancel any existing subscription
    await _subscription?.cancel();
    _subscription = null;

    // Get initial stats
    await _getAllStats();

    // Get stats on subsequent table change
    _subscription ??= _repository.onDataChanged.listen(null, onError: (err) => emit(AmcStatErrorState(err.toString())));
    _subscription?.onData((query) async {
      _subscription?.pause();

      try {
        await _getAllStats();
      } finally {
        _subscription?.resume();
      }
    });

    _subscription?.onDone(() => _subscription?.cancel());
  }

  Future<void> _getAllStats() async {
    emit(const AmcStatLoadingState());

    try {
      final stats = await _repository.getAllStats();
      emit(AmcStatLoadedState(stats));
    } on Exception catch (error) {
      emit(AmcStatErrorState(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
