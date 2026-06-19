import 'dart:async';

import 'package:invesly/stat/model/stat_repository.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/common_libs.dart';
// import 'package:invesly/database/table_schema.dart';

part 'stat_state.dart';

class StatCubit extends Cubit<StatState> {
  StatCubit({required StatRepository repository}) : _repository = repository, super(const StatInitialState());

  final StatRepository _repository;

  // StreamSubscription<TableEvent>? _subscription;
  StreamSubscription<List<InveslyStat>>? _subscription;

  Future<void> fetchAllStats() async {
    // Cancel any existing subscription
    await _subscription?.cancel();
    _subscription = null;

    // // Get initial stats
    // await _getAllStats();

    // // Get stats on subsequent table change
    // _subscription ??= _repository.onDataChanged.listen(null, onError: (err) => emit(StatErrorState(err.toString())));
    // _subscription?.onData((query) async {
    //   _subscription?.pause();

    //   try {
    //     await _getAllStats();
    //   } finally {
    //     _subscription?.resume();
    //   }
    // });

    // _subscription?.onDone(() => _subscription?.cancel());

    // ~ new method
    emit(const StatLoadingState());

    _subscription ??= _repository.fetchAllStats().listen(
      (data) => emit(StatLoadedState(data)),
      onError: (error) => emit(StatErrorState(error.toString())),
    );
  }

  // Future<void> _getAllStats() async {
  //   emit(const StatLoadingState());

  //   try {
  //     final stats = await _repository.getAllStats();
  //     emit(StatLoadedState(stats));
  //   } on Exception catch (error) {
  //     emit(StatErrorState(error.toString()));
  //   }
  // }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
