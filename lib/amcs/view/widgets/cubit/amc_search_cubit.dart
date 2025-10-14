import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'amc_search_state.dart';

class AmcSearchCubit extends Cubit<AmcSearchState> {
  AmcSearchCubit({required AmcRepository amcRepository})
    : _amcRepository = amcRepository,
      _debounce = _Debounce(1.seconds),
      _amcCache = const {},
      super(AmcSearchStateEmpty());

  final AmcRepository _amcRepository;
  final Map<String, List<InveslyAmc>> _amcCache;
  final _Debounce _debounce;

  Future<void> search(String query) async {
    $logger.d('Searching AMC for query: $query');
    if (query.isEmpty) return emit(AmcSearchStateEmpty());

    final cachedResult = _amcCache[query];
    if (cachedResult != null) {
      return emit(AmcSearchStateSuccess(cachedResult));
    }

    emit(AmcSearchStateLoading());

    try {
      await _debounce.wait(); // wait for 1 second
      final results = await _amcRepository.getAmcs(query);
      $logger.d(results);
      emit(AmcSearchStateSuccess(results));
      _amcCache[query] = results;
    } catch (error) {
      // emit(
      //   error is SearchResultError
      //       ? SearchStateError(error.message)
      //       : const SearchStateError('something went wrong'),
      // );
      emit(AmcSearchStateError(error.toString()));
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

// class AmcResultCache {
//   final _cache = <String, InveslyAmc>{};

//   InveslyAmc? get(String term) => _cache[term];

//   void set(String term, InveslyAmc result) => _cache[term] = result;

//   bool contains(String term) => _cache.containsKey(term);

//   void remove(String term) => _cache.remove(term);

//   void close() {
//     _cache.clear();
//   }
// }
