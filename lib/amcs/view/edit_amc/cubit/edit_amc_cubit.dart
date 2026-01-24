import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

part 'edit_amc_state.dart';

class EditAmcCubit extends Cubit<EditAmcState> {
  EditAmcCubit({required AmcRepository repository, InveslyAmc? initialAmc})
    : _repository = repository,
      super(EditAmcState(initialAmc: initialAmc));

  final AmcRepository _repository;

  static const mfTags = {'Direct', 'Regular', 'Growth', 'Divident', 'Largecap', 'Midcap', 'Smallcap'};
  static const stockTags = {'Power Generation & Distribution', 'FMCG'};
  static const insuranceTags = {'Life insurance', 'Medical', 'Vehicle'};
  static const miscTags = {'Pradhan mantri yojona'};

  void updateName(String name) {
    emit(state.copyWith(name: name.trim()));
  }

  Set<String> _getAllTags(AmcGenre genre) {
    if (genre == AmcGenre.mf) {
      return mfTags;
    } else if (genre == AmcGenre.stock) {
      return stockTags;
    } else if (genre == AmcGenre.insurance) {
      return insuranceTags;
    } else {
      return miscTags;
    }
  }

  void updateGenre(AmcGenre genre) {
    final allTags = _getAllTags(genre);
    final newAllTags = allTags.difference(state.selectedTags);

    emit(state.copyWith(genre: genre, tags: newAllTags));
  }

  void updateSelectedTags(String tag, [bool isEntry = true]) {
    final allTags = _getAllTags(state.genre);
    // update selected tags
    final selectedTags = Set<String>.from(state.selectedTags);
    // This will partially work for textfield
    // selectedTags.contains(tag) ? selectedTags.remove(tag) : selectedTags.add(tag);
    isEntry ? selectedTags.add(tag) : selectedTags.remove(tag);
    final newAllTags = allTags.difference(selectedTags);
    emit(state.copyWith(tags: newAllTags, selectedTags: selectedTags));
  }

  Future<void> save() async {
    emit(state.copyWith(status: EditAmcStatus.loading));

    if (state.name == null) return;

    final amc = InveslyAmc(
      id: state.initialAmc?.id ?? $uuid.v1(),
      code: state.initialAmc?.code ?? 'This is temporary code',
      isin: state.initialAmc?.isin ?? 'This is temporary isin',
      name: state.name!,
      genre: state.genre,
      // tag: state.selectedTags,
    );

    try {
      await _repository.saveAmc(amc);
      emit(state.copyWith(status: EditAmcStatus.success));
    } on Exception catch (_) {
      emit(state.copyWith(status: EditAmcStatus.failure));
    }
  }
}
