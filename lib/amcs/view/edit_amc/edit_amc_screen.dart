import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/edit_amc/cubit/edit_amc_cubit.dart';
import 'package:invesly/common_libs.dart';

class EditAmcScreen extends StatelessWidget {
  const EditAmcScreen({super.key, this.initialAmc});

  final InveslyAmc? initialAmc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditAmcCubit(repository: context.read<AmcRepository>(), initialAmc: initialAmc),
      child: const _EditView(),
    );
  }
}

class _EditView extends StatefulWidget {
  const _EditView({super.key});

  @override
  State<_EditView> createState() => __EditViewState();
}

class __EditViewState extends State<_EditView> {
  final _formKey = GlobalKey<FormState>();
  final _allGenres = AmcGenre.values;

  late final ValueNotifier<AutovalidateMode> _validateNotifier;
  // late final TextEditingController _nameFieldController;
  // late final FocusNode _nameFieldFocusNode;
  late final TextEditingController _tagFieldController;
  late final FocusNode _tagFieldFocusNode;
  String? _tagErrorText;

  AmcGenre? selectedGenre;
  // final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _validateNotifier = ValueNotifier(AutovalidateMode.disabled);
    // _nameFieldController = TextEditingController();
    // _nameFieldFocusNode = FocusNode();
    _tagFieldController = TextEditingController();
    _tagFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    _validateNotifier.dispose();
    // _nameFieldController.dispose();
    // _nameFieldFocusNode.dispose();
    _tagFieldController.dispose();
    _tagFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNewEntry = context.select<EditAmcCubit, bool>((cubit) => cubit.state.isNewAmc);
    final editAmcCubit = context.read<EditAmcCubit>();

    return BlocListener<EditAmcCubit, EditAmcState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EditAmcStatus.success) {
          const message = SnackBar(content: Text('Amc saved successfully.'), backgroundColor: Colors.teal);
          ScaffoldMessenger.of(context).showSnackBar(message);

          Navigator.maybePop<bool>(context);
        } else if (state.status == EditAmcStatus.failure) {
          const message = SnackBar(
            content: Text('Sorry! some error occurred. Try again later'),
            backgroundColor: Colors.teal,
          );
          ScaffoldMessenger.of(context).showSnackBar(message);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          // key: scaffoldKey,
          appBar: AppBar(),
          body: SafeArea(
            child: ValueListenableBuilder<AutovalidateMode>(
              valueListenable: _validateNotifier,
              builder: (context, validateMode, child) {
                return Form(key: _formKey, autovalidateMode: validateMode, child: child!);
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      children: <Widget>[
                        // ~ Title
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(isNewEntry ? 'Add' : 'Edit', style: textTheme.headlineMedium),
                              // const Gap(AppConstants.formFieldLabelSpacing),
                              Text('Asset Management Company (AMC)', style: textTheme.headlineSmall),
                            ],
                          ),
                        ),
                        const Gap(12.0),

                        // ~ Name of AMC
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppConstants.formFieldLabelSpacing,
                          children: <Widget>[
                            const Text('Name of AMC'),
                            TextFormField(
                              // controller: _nameFieldController,
                              // focusNode: _nameFieldFocusNode,
                              autofocus: true,
                              decoration: const InputDecoration(hintText: 'e.g. Aditya Birla Sunlife'),
                              validator: (value) {
                                if (value == null || !value.isValidText) return 'Please enter name of the AMC';
                                return null;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
                              ],
                              onChanged: (value) => editAmcCubit.updateName(value),
                            ),
                          ],
                        ),
                        const Gap(12.0),

                        // ~ Genre
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppConstants.formFieldLabelSpacing,
                          children: <Widget>[
                            const Text('Genre'),
                            BlocSelector<EditAmcCubit, EditAmcState, AmcGenre>(
                              selector: (state) => state.genre,
                              builder: (context, genre) {
                                return InveslyChoiceChips<AmcGenre>.single(
                                  options: List.generate(_allGenres.length, (index) {
                                    final option = _allGenres[index];
                                    return InveslyChipData(value: option, label: Text(option.title));
                                  }),
                                  selected: genre,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    editAmcCubit.updateGenre(value);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const Gap(12.0),

                        // ~ Tags
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppConstants.formFieldLabelSpacing,
                          children: <Widget>[
                            const Text('Tags'),
                            BlocSelector<EditAmcCubit, EditAmcState, Set<String>>(
                              selector: (state) => state.selectedTags,
                              builder: (context, selectedTags) {
                                if (selectedTags.isEmpty) return const SizedBox();
                                return InveslyChoiceChips<String>(
                                  clearable: true,
                                  options: List.generate(selectedTags.length, (index) {
                                    final option = selectedTags.elementAt(index);
                                    return InveslyChipData(value: option, label: Text(option));
                                  }),
                                  onChanged: (_) {},
                                  chipSpacing: 8.0,
                                  selected: selectedTags,
                                  showCheckmark: false,
                                  onDeleted: (value) => editAmcCubit.updateSelectedTags(value, false),
                                );
                              },
                            ),
                            StatefulBuilder(
                              builder: (context, setInnerState) {
                                return TextField(
                                  controller: _tagFieldController,
                                  focusNode: _tagFieldFocusNode,
                                  decoration: InputDecoration(
                                    errorText: _tagErrorText,
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        if (!_tagFieldController.text.isValidText) {
                                          setInnerState(() => _tagErrorText = 'Please enter a proper tag!');
                                          return;
                                        }
                                        editAmcCubit.updateSelectedTags(_tagFieldController.text.toCapitalize());
                                        _tagFieldController.clear();
                                        _tagFieldFocusNode.unfocus();

                                        if (_tagErrorText != null) {
                                          setInnerState(() => _tagErrorText = null);
                                        }
                                      },
                                      child: const Icon(Icons.check_rounded),
                                    ),
                                    prefixIcon: const Icon(Icons.style_outlined),
                                    hintText: 'Add custom tag',
                                  ),
                                  // onSubmitted: (value) => $logger.d(value),
                                );
                              },
                            ),
                            BlocBuilder<EditAmcCubit, EditAmcState>(
                              buildWhen: (prevState, state) {
                                return state.tags != prevState.tags || state.selectedTags != prevState.selectedTags;
                              },
                              builder: (context, state) {
                                final tags = state.tags;
                                if (tags.isEmpty) return const SizedBox();

                                return InveslyChoiceChips<String>.single(
                                  clearable: true,
                                  options: List.generate(tags.length, (index) {
                                    final option = tags.elementAt(index);
                                    return InveslyChipData(value: option, label: Text(option));
                                  }),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    editAmcCubit.updateSelectedTags(value);
                                  },
                                  chipSpacing: 8.0,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const InveslyDivider(),

                  // ~ Save button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_rounded),
                        onPressed: () => _handleSavePressed(context),
                        label: const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSavePressed(BuildContext context) async {
    final editAmcCubit = context.read<EditAmcCubit>();
    if (_formKey.currentState?.validate() ?? false) {
      await editAmcCubit.save();
    } else if (_validateNotifier.value != AutovalidateMode.always) {
      _validateNotifier.value = AutovalidateMode.always;
    }
  }
}
