import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/widgets/cubit/amc_search_cubit.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/utils/keyboard.dart';
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
    final cubit = context.read<AmcSearchCubit>();

    return Scaffold(
      appBar: AppBar(
        title: BlocSelector<AmcSearchCubit, AmcSearchState, AmcGenre>(
          selector: (state) => state.searchGenre,
          builder: (context, genre) => Text('Search ${genre.title}'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: iFormFieldLabelSpacing,
            children: <Widget>[
              // // ~ Chips for filtering by genre
              // BlocSelector<AmcSearchCubit, AmcSearchState, AmcGenre>(
              //   selector: (state) => state.searchGenre,
              //   builder: (context, amcGenre) {
              //     return InveslyChoiceChips<AmcGenre>(
              //       extended: true,
              //       options: AmcGenre.values,
              //       labelBuilder: (context, genre) => Text(genre.title, overflow: TextOverflow.fade),
              //       iconBuilder: (context, genre) => Icon(genre.icon),
              //       selected: amcGenre,
              //       onChanged: (value) {
              //         cubit.updateSearchGenre(value);
              //         cubit.search(_searchController.text);
              //       },
              //     );
              //   },
              // ),
              SizedBox(
                height: 54.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 2.0,
                  children: <Widget>[
                    // ~ Genre Selector
                    MenuAnchor(
                      animated: true,
                      menuChildren: AmcGenre.values.map((genre) {
                        return MenuItemButton(
                          leadingIcon: Icon(genre.icon, color: genre.color),
                          onPressed: () {
                            cubit.updateSearchGenre(genre);
                            cubit.search(_searchController.text);
                          },
                          child: Text(genre.title, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      alignmentOffset: Offset(0.0, 4.0),
                      style: MenuStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: iCardBorderRadius)),
                        backgroundColor: WidgetStatePropertyAll<Color>(context.colors.primaryContainer),
                        elevation: WidgetStatePropertyAll<double>(5.0),
                      ),
                      builder: (context, controller, child) {
                        return IconButton(
                          onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                          style: IconButton.styleFrom(
                            backgroundColor: context.colors.primaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: iCardBorderRadius.copyWith(
                                topRight: iTileBorderRadius.topRight,
                                bottomRight: iTileBorderRadius.bottomRight,
                              ),
                            ),
                            fixedSize: const Size.square(54.0),
                            iconSize: 24.0,
                          ),
                          icon: child!,
                        );
                      },
                      child: BlocSelector<AmcSearchCubit, AmcSearchState, AmcGenre>(
                        selector: (state) => state.searchGenre,
                        builder: (context, amcGenre) {
                          return FadeIn(
                            key: ValueKey<AmcGenre>(amcGenre),
                            from: Offset(0.0, 0.4),
                            child: Icon(amcGenre.icon, color: amcGenre.color),
                          );
                        },
                      ),
                    ),

                    // ~ Search text field
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter keyword to search',

                          // prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: iCardBorderRadius.copyWith(
                              topLeft: iTileBorderRadius.topLeft,
                              bottomLeft: iTileBorderRadius.bottomLeft,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: _searchController,
                        autofocus: true,
                        onTapOutside: (_) => minimizeKeyboard(),
                      ),
                    ),
                  ],
                ),
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

// /// Alternate to Menu Anchor
// class PopupMenu extends StatefulWidget {
//   const PopupMenu({super.key});

//   @override
//   State<PopupMenu> createState() => _PopupMenuState();
// }

// class _PopupMenuState extends State<PopupMenu> with SingleTickerProviderStateMixin {
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;
//   late AnimationController _menuController;

//   @override
//   void initState() {
//     super.initState();
//     _menuController = AnimationController(duration: const Duration(milliseconds: 350), vsync: this);
//   }

//   @override
//   void dispose() {
//     _hideMenu();
//     _menuController.dispose();
//     super.dispose();
//   }

//   void _toggleMenu() {
//     if (_overlayEntry == null) {
//       _showMenu();
//     } else {
//       _hideMenu();
//     }
//   }

//   void _showMenu() {
//     _overlayEntry = _createOverlayEntry();
//     Overlay.of(context).insert(_overlayEntry!);
//     _menuController.forward();
//   }

//   void _hideMenu() async {
//     await _menuController.reverse();
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   OverlayEntry _createOverlayEntry() {
//     return OverlayEntry(
//       builder: (context) => Stack(
//         children: [
//           Positioned.fill(
//             child: GestureDetector(
//               onTap: _hideMenu,
//               behavior: HitTestBehavior.opaque,
//               child: Container(color: Colors.black45),
//             ),
//           ),
//           CompositedTransformFollower(
//             link: _layerLink,
//             showWhenUnlinked: false,
//             targetAnchor: Alignment.bottomRight,
//             followerAnchor: Alignment.topRight,
//             offset: const Offset(0, 4),
//             child: Container(color: Colors.red, height: 24.0, width: 24.0),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: IconButton(
//         // onPressed: () => controller.isOpen ? controller.close() : controller.open(),
//         onPressed: _toggleMenu,
//         style: IconButton.styleFrom(
//           backgroundColor: context.colors.primaryContainer,
//           shape: RoundedRectangleBorder(
//             borderRadius: iCardBorderRadius.copyWith(
//               topRight: iTileBorderRadius.topRight,
//               bottomRight: iTileBorderRadius.bottomRight,
//             ),
//           ),
//           fixedSize: const Size.square(56.0),
//         ),
//         icon: const Icon(Icons.more_vert, size: 24.0),
//       ),
//     );
//   }
// }

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
