import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/widgets/cubit/amc_search_cubit.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';

class InveslyAmcPickerWidget extends StatelessWidget {
  const InveslyAmcPickerWidget({super.key, this.amcId, this.onPickup});

  final String? amcId;
  final ValueChanged<InveslyAmc>? onPickup;

  static Future<InveslyAmc?> showModal(BuildContext context, [String? amcId]) async {
    return await showDialog<InveslyAmc>(
      context: context,
      builder: (context) {
        return InveslyAmcPickerWidget(amcId: amcId, onPickup: (amc) => Navigator.maybePop(context, amc));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Asset Management Company')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocProvider(
            create: (context) => AmcSearchCubit(amcRepository: context.read<AmcRepository>()),
            child: _InveslyAmcPickerWidget(onPickup: onPickup),
          ),
        ),
      ),
    );
  }
}

class _InveslyAmcPickerWidget extends StatefulWidget {
  const _InveslyAmcPickerWidget({super.key, this.amcId, this.onPickup});

  final String? amcId;
  final ValueChanged<InveslyAmc>? onPickup;

  @override
  State<_InveslyAmcPickerWidget> createState() => _InveslyAmcPickerWidgetState();
}

class _InveslyAmcPickerWidgetState extends State<_InveslyAmcPickerWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(textFieldChanged);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.formFieldLabelSpacing,
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(hintText: 'Enter keyword to search', prefixIcon: Icon(Icons.search)),
          controller: _searchController,
          autofocus: true,
        ),
        SingleChildScrollView(
          child: const Row(
            spacing: 8.0,
            children: <Widget>[
              ChoiceChip(label: Text('Stock'), selected: true),
              ChoiceChip(label: Text('Mutual fund'), selected: false),
              ChoiceChip(label: Text('Miscellaneous'), selected: false),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<AmcSearchCubit, AmcSearchState>(
            builder: (context, state) {
              return switch (state.status) {
                AmcSearchStateStatus.empty => Center(child: const Text('Please enter a term to begin')),
                AmcSearchStateStatus.loading => Center(child: const CircularProgressIndicator.adaptive()),
                AmcSearchStateStatus.error => Center(child: Text(state.error!)),
                AmcSearchStateStatus.success =>
                  state.items.isEmpty
                      ? const Text('Sorry! No results found 😞')
                      : _SearchResults(amcs: state.items, onPickup: (amc) => widget.onPickup?.call(amc)),
              };
            },
          ),
        ),
      ],
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
          subtitle: Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: <Widget>[
              DecoratedBox(
                decoration: ShapeDecoration(shape: StadiumBorder(), color: Theme.of(context).colorScheme.primary),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Text(
                    (amc.genre ?? AmcGenre.misc).title,
                    style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ),

              if (amc.tags != null && amc.tags!.isNotEmpty)
                ...amc.tags!.map(
                  (tag) => DecoratedBox(
                    decoration: ShapeDecoration(
                      shape: StadiumBorder(),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: Text(tag, style: context.textTheme.labelSmall?.copyWith()),
                    ),
                  ),
                ),
            ],
          ),
          contentSpacing: 4.0,
        );
      },
    );
  }
}
