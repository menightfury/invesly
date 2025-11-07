import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'amc_search_state.dart';

class AmcSearchCubit extends Cubit<AmcSearchState> {
  AmcSearchCubit({required AmcRepository amcRepository})
    : _amcRepository = amcRepository,
      _debounce = _Debounce(1.seconds),
      super(AmcSearchState.initial());

  final AmcRepository _amcRepository;
  final Map<String, List<InveslyAmc>> _amcCache = {}; // key is combination of query and genre
  final _Debounce _debounce;

  void updateSearchGenre(AmcGenre? value) {
    if (value == null) return;
    emit(state.copyWith(searchGenre: value));
  }

  Future<void> search(String query) async {
    if (query.isEmpty) return emit(state.copyWith(status: AmcSearchStateStatus.empty));

    final key = '${state.searchGenre.name} - ${query.toLowerCase()}';
    final cachedResult = _amcCache[key];
    if (cachedResult != null) {
      return emit(state.copyWith(status: AmcSearchStateStatus.success, results: cachedResult));
    }

    emit(state.copyWith(status: AmcSearchStateStatus.loading));

    try {
      await _debounce.wait(); // wait for 1 second
      final results = await _amcRepository.getAmcs(query, state.searchGenre);
      $logger.d(results);
      emit(state.copyWith(status: AmcSearchStateStatus.success, results: results));
      _amcCache[key] = results;
    } catch (error) {
      // emit(
      //   error is SearchResultError
      //       ? SearchStateError(error.message)
      //       : const SearchStateError('something went wrong'),
      // );
      emit(state.copyWith(status: AmcSearchStateStatus.error, error: error.toString()));
    }
  }

  @override
  Future<void> close() {
    _amcCache.clear();
    return super.close();
  }
}

class _Debounce {
  _Debounce(this.delay);

  final Duration delay;
  Timer? _timer;

  Future<void> wait() async {
    final completer = Completer<void>();
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(delay, () => completer.complete());
    return completer.future;
  }

  void dispose() {
    _timer?.cancel();
  }
}
