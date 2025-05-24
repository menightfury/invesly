// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_amc_cubit.dart';

enum EditAmcStatus { initial, loading, success, failure }

class EditAmcState extends Equatable {
  const EditAmcState({
    this.status = EditAmcStatus.initial,
    this.initialAmc,
    this.name,
    this.genre = AmcGenre.misc,
    this.tags = EditAmcCubit.miscTags,
    this.selectedTags = const {},
  });

  final EditAmcStatus status;
  final String? name;
  final InveslyAmc? initialAmc;
  final AmcGenre genre;
  final Set<String> tags;
  final Set<String> selectedTags;

  bool get isNewAmc => initialAmc == null;

  @override
  List<Object?> get props => [status, initialAmc, name, genre, tags, selectedTags];

  EditAmcState copyWith({
    EditAmcStatus? status,
    InveslyAmc? initialAmc,
    String? name,
    AmcGenre? genre,
    Set<String>? tags,
    Set<String>? selectedTags,
  }) {
    return EditAmcState(
      status: status ?? this.status,
      initialAmc: initialAmc ?? this.initialAmc,
      name: name ?? this.name,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}
