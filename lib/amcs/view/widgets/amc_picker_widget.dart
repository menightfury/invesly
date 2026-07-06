import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/widgets/cubit/amc_search_cubit.dart';
import 'package:invesly/common_libs.dart';

class InveslyAmcPickerWidget extends StatelessWidget {
  const InveslyAmcPickerWidget({super.key, this.keyword, this.genre, this.onPickup});

  final String? keyword;
  final AmcGenre? genre;
  final ValueChanged<InveslyAmc>? onPickup;

  static Future<InveslyAmc?> showModal(BuildContext context, [String? keyword, AmcGenre? genre]) async {
    return await showDialog<InveslyAmc>(
      context: context,
      builder: (context) {
        return InveslyAmcPickerWidget(keyword: keyword, genre: genre, onPickup: (amc) => Navigator.pop(context, amc));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AmcSearchCubit(amcRepository: AmcRepository.instance, genre: genre),
      child: _InveslyAmcPickerWidget(keyword: keyword, onPickup: onPickup),
    );
  }
}

class _InveslyAmcPickerWidget extends StatefulWidget {
  const _InveslyAmcPickerWidget({super.key, this.keyword, this.onPickup});

  final String? keyword;
  final ValueChanged<InveslyAmc>? onPickup;

  @override
  State<_InveslyAmcPickerWidget> createState() => _InveslyAmcPickerWidgetState();
}

class _InveslyAmcPickerWidgetState extends State<_InveslyAmcPickerWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.keyword)..addListener(textFieldChanged);
    // initial search
    textFieldChanged();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(textFieldChanged)
      ..dispose();
    super.dispose();
  }

  void textFieldChanged() {
    context.read<AmcSearchCubit>().search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<AmcSearchCubit>();
    final searchChipsData = AmcGenre.values;

    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<AmcSearchCubit, AmcSearchState, AmcGenre?>(
          selector: (state) => state.searchGenre,
          builder: (context, genre) {
            return Text('Search ${genre?.title ?? 'Companies / Service providers'}');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: iFormFieldLabelSpacing,
            children: <Widget>[
              // ~ Chips for filtering by genre
              BlocSelector<AmcSearchCubit, AmcSearchState, AmcGenre?>(
                selector: (state) => state.searchGenre,
                builder: (context, amcGenre) {
                  return InveslyChoiceChips<AmcGenre>(
                    extended: true,
                    options: searchChipsData,
                    labelBuilder: (context, genre) => Text(genre.title, overflow: TextOverflow.fade),
                    iconBuilder: (context, genre) => Icon(genre.icon),
                    selected: amcGenre,
                    onChanged: (value) {
                      cubit.updateSearchGenre(value);
                      cubit.search(_searchController.text);
                    },
                  );
                },
              ),
              Row(
                children: <Widget>[
                  IconButton(onPressed: () {}, icon: Icon(Icons.abc)),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter keyword to search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: iTileBorderRadius, borderSide: BorderSide.none),
                      ),
                      controller: _searchController,
                      autofocus: true,
                    ),
                  ),
                ],
              ),

              // ~ Result
              Expanded(
                child: BlocBuilder<AmcSearchCubit, AmcSearchState>(
                  builder: (context, state) {
                    return switch (state.status) {
                      AmcSearchStateStatus.loading => Center(child: const CircularProgressIndicator.adaptive()),
                      AmcSearchStateStatus.error => Center(child: Text(state.error!)),
                      AmcSearchStateStatus.success =>
                        state.results.isEmpty
                            ? const EmptyWidget(label: Text('Sorry! No results found 😞'))
                            : _SearchResults(
                                amcs: state.results,
                                onPickup: (amc) {
                                  // get more details of amc by id before picking
                                  widget.onPickup?.call(amc);
                                },
                              ),
                      _ => Center(child: const Text('Please enter a term to begin')),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({super.key, required this.amcs, this.onPickup});

  final List<InveslyAmc> amcs;
  final ValueChanged<InveslyAmc>? onPickup;

  @override
  Widget build(BuildContext context) {
    return Section.builder(
      margin: EdgeInsets.zero,
      tileCount: amcs.length,
      tileBuilder: (context, index) {
        final amc = amcs.elementAt(index);
        return SectionTile(
          onTap: () => onPickup?.call(amc),
          title: Text(amc.name),
          // subtitle: Wrap(
          //   spacing: 4.0,
          //   runSpacing: 4.0,
          //   children: <Widget>[
          //     SimpleChip(
          //       color: context.colors.primary,
          //       titleColor: context.colors.onPrimary,
          //       child: Text((amc.genre ?? AmcGenre.misc).title),
          //     ),

          //     if (amc.tags?.isNotEmpty ?? false)
          //       ...amc.tags!.map((tag) {
          //         if (tag.isEmpty) {
          //           return const SizedBox.shrink();
          //         }

          //         return SimpleChip(
          //           color: context.colors.tertiary,
          //           titleColor: context.colors.onTertiary,
          //           child: Text(tag),
          //         );
          //       }),
          //   ],
          // ),
          subtitle: (amc.tags?.isNotEmpty ?? false) ? Text(amc.tags!.join(' • ')) : null,
          contentSpacing: 4.0,
        );
      },
    );
  }
}
