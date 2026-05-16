import 'package:invesly/amc_stat/cubit/amc_stat_cubit.dart';
import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/amc_transaction_model.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/amcs/view/amc_overview/amc_overview_page.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/genre/view/genre_details/cubit/genre_details_cubit.dart';

class GenreDetailsPage extends StatelessWidget {
  const GenreDetailsPage(this.genre, {super.key});

  final AmcGenre genre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) => GenreDetailsCubit(),

          // child: BlocSelector<AppCubit, AppState, String?>(
          //   selector: (state) => state.primaryAccountId,
          //   builder: (context, accountId) {
          //     return _GenreDetailsPageContent(genre: genre, accountId: accountId);
          //   },
          // ),
          child: _GenreDetailsPageContent(genre: genre),
        ),
      ),
    );
  }
}

class _GenreDetailsPageContent extends StatefulWidget {
  const _GenreDetailsPageContent({super.key, required this.genre});

  final AmcGenre genre;

  @override
  State<_GenreDetailsPageContent> createState() => _GenreDetailsPageContentState();
}

class _GenreDetailsPageContentState extends State<_GenreDetailsPageContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<GenreDetailsCubit>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(title: Text(widget.genre.title), floating: true, snap: true),

            BlocConsumer<AmcStatCubit, AmcStatState>(
              listener: (context, statState) {
                // Bloc to bloc communication
                if (statState is AmcStatLoadedState) {
                  final stats = statState.getStatsByGenre(widget.genre);
                  context.read<GenreDetailsCubit>().loadStats(stats);
                }
              },
              builder: (context, statState) {
                // ~ If AmcStatState is error or initial
                if (statState.isInitial) {
                  return SliverToBoxAdapter(child: SizedBox.shrink());
                }

                if (statState.isError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text('Some error occurred while fetching data'), // TODO: Redesign & test
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: <Widget>[
                    // ~ Overview section
                    SliverToBoxAdapter(child: _GenreOverviewSection()),

                    const SliverGap(16.0),

                    // ~ Title row with sort & filter button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              spacing: 8.0,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'Holdings',
                                    style: theme.textTheme.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // ~ Sort button
                                BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
                                  // buildWhen: (prev, curr) {
                                  //   return prev.status != curr.status && (prev.isLoaded || curr.isLoaded);
                                  // },
                                  builder: (context, genreState) {
                                    return AnimatedScale(
                                      scale: genreState is GenreDetailsLoadedState && genreState.stats.isNotEmpty
                                          ? 1.0
                                          : 0.0,
                                      alignment: Alignment.centerRight,
                                      duration: 240.ms,
                                      curve: Curves.easeInOut,
                                      child: IconButton(
                                        onPressed: genreState.isLoaded
                                            ? () async {
                                                final state_ = cubit.state as GenreDetailsLoadedState;
                                                final sortOptions = await _showSortOptions(
                                                  context,
                                                  sortAndFilterStatus: state_.sortAndFilterStatus,
                                                );
                                                if (sortOptions == null) return;
                                                cubit.setSortAndFilterStatus(sortOptions);
                                              }
                                            : null,
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.sort_rounded),
                                        tooltip: 'Sort holdings',
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ~ Holdings list
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                      sliver: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
                        // buildWhen: (prev, curr) {
                        //   return prev.status != curr.status ||
                        //       prev.stats != curr.stats ||
                        //       prev.errorMessage != curr.errorMessage ||
                        //       prev.sortAndFilterStatus != curr.sortAndFilterStatus;
                        // },
                        builder: (context, state) {
                          final isLoading = state.isLoading;

                          // ~ If loaded but empty
                          if (state is GenreDetailsLoadedState && state.stats.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: EmptyWidget(
                                  label: Text('This is so empty.\n Add some transactions to see stats here.'),
                                ),
                              ),
                            );
                          }

                          // ~ If loaded but search result is empty
                          final displayList = state.isLoaded ? (state as GenreDetailsLoadedState).displayStats : null;
                          if (displayList != null && displayList.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: Text(
                                    'No holdings match the current filter',
                                    style: TextStyle(color: context.colors.onSurfaceVariant),
                                  ),
                                ),
                              ),
                            );
                          }

                          // ~ If loading or loaded with data
                          return SliverSkeletonizer(
                            enabled: isLoading,
                            child: SliverList.separated(
                              itemCount: displayList?.length ?? 2, // Show 2 skeleton cards while loading
                              itemBuilder: (context, index) {
                                final stat = displayList?.elementAt(index);
                                return stat != null ? _HoldingStatCard(stat: stat) : _HoldingStatCard.loading();
                              },
                              separatorBuilder: (_, _) => const Gap(12.0),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<HoldingSortAndFilterStatus?> _showSortOptions(
    BuildContext context, {
    required HoldingSortAndFilterStatus sortAndFilterStatus,
  }) async {
    return showModalBottomSheet<HoldingSortAndFilterStatus>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _HoldingSortAndFilterOptions(sortAndFilterStatus: sortAndFilterStatus),
    );
  }
}

class _HoldingSortAndFilterOptions extends StatefulWidget {
  const _HoldingSortAndFilterOptions({super.key, required this.sortAndFilterStatus});

  final HoldingSortAndFilterStatus sortAndFilterStatus;

  @override
  State<_HoldingSortAndFilterOptions> createState() => _HoldingSortAndFilterOptionsState();
}

class _HoldingSortAndFilterOptionsState extends State<_HoldingSortAndFilterOptions> {
  late final ValueNotifier<HoldingFilter> _holdingFilter;
  late final ValueNotifier<HoldingSortOption> _holdingSortOption;
  late final ValueNotifier<bool> _isAscending;

  @override
  void initState() {
    super.initState();
    _holdingFilter = ValueNotifier<HoldingFilter>(widget.sortAndFilterStatus.holdingFilter);
    _holdingSortOption = ValueNotifier<HoldingSortOption>(widget.sortAndFilterStatus.sortOption);
    _isAscending = ValueNotifier<bool>(widget.sortAndFilterStatus.sortAscending);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: <Widget>[
          // ~ Filtering
          Text('Filter holdings', style: context.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
          ValueListenableBuilder(
            valueListenable: _holdingFilter,
            builder: (context, filter, _) {
              return InveslyChoiceChips<HoldingFilter>.single(
                options: HoldingFilter.values.map((f) => InveslyChipData(value: f, label: Text(f.label))).toList(),
                selected: filter,
                onChanged: (filter) {
                  if (filter == null) return;
                  _holdingFilter.value = filter;
                },
                wrapped: false,
              );
            },
          ),

          // ~ Sorting
          Text('Sort holdings by', style: context.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
          ValueListenableBuilder<HoldingSortOption>(
            valueListenable: _holdingSortOption,
            builder: (context, sortOption, _) {
              return RadioGroup<HoldingSortOption>(
                groupValue: sortOption,
                onChanged: (option) {
                  if (option == null) return;
                  _holdingSortOption.value = option;
                },
                child: Section(
                  margin: EdgeInsets.zero,
                  tiles: HoldingSortOption.values.map((option) {
                    return RadioSectionTile<HoldingSortOption>(
                      title: Text(
                        option.label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: option,
                      subtitle: AnimatedExpand(
                        expand: sortOption == option,
                        duration: 240.ms,
                        axis: Axis.vertical,
                        alignment: -1.0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _isAscending,
                            builder: (context, isAscending, _) {
                              return InveslyChoiceChips<bool>.single(
                                options: [
                                  InveslyChipData(value: true, label: Text(option.ascendingLabel ?? 'Ascending')),
                                  InveslyChipData(value: false, label: Text(option.descendingLabel ?? 'Descending')),
                                ],
                                selected: isAscending,
                                onChanged: (value) {
                                  if (value == null) return;
                                  _isAscending.value = value;
                                },
                                wrapped: false,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // ~ Filter apply button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final status = HoldingSortAndFilterStatus(
                  sortOption: _holdingSortOption.value,
                  sortAscending: _isAscending.value,
                  holdingFilter: _holdingFilter.value,
                );

                context.pop<HoldingSortAndFilterStatus>(status);
              },
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _holdingFilter.dispose();
    _holdingSortOption.dispose();
    _isAscending.dispose();
    super.dispose();
  }
}

class _GenreOverviewSection extends StatelessWidget {
  const _GenreOverviewSection({super.key});

  static const double _spacing = 2.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
      // buildWhen: (prev, curr) => prev.stats != curr.stats,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Skeletonizer(
            enabled: state.isLoading,
            child: Column(
              spacing: _spacing,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ~ Current Value
                _SectionWidget(
                  label: Skeleton.keep(
                    child: FormattedDate(
                      date: DateTime.now(),
                      prefix: const Text('Current value as of '),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  value: _buildTotalCurrentAmount(context, state),
                  borderRadius: iCardBorderRadius.copyWith(
                    bottomLeft: iTileBorderRadius.bottomLeft,
                    bottomRight: iTileBorderRadius.bottomRight,
                  ),
                ),

                Row(
                  spacing: _spacing,
                  children: <Widget>[
                    // ~ Holding count
                    Expanded(
                      child: _SectionWidget(
                        label: const Skeleton.keep(child: Text('No. of holdings')),
                        value: _buildHoldingCount(context, state),
                      ),
                    ),

                    // ~ Invested amount section
                    Expanded(
                      child: _SectionWidget(
                        label: const Skeleton.keep(child: Text('Invested amount')),
                        value: _buildTotalInvestedAmount(context, state),
                      ),
                    ),
                  ],
                ),

                // Row(
                //   spacing: _spacing,
                //   children: <Widget>[
                //     // ~ Total returns sections
                //     Expanded(
                //       child: _SectionWidget(
                //         label: const Skeleton.keep(child: Text('Total returns')),
                //         value: _buildAmountReturns(context, statState),
                //         color: isError ? colors.errorContainer : null,
                //         valueColor: isError ? colors.error : Colors.teal.shade500,
                //         borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                //       ),
                //     ),

                //     // ~ XIRR section
                //     Expanded(
                //       child: _SectionWidget(
                //         label: const Skeleton.keep(child: Text('XIRR')),
                //         value: _buildPercentageReturns(context, statState),
                //         color: isError ? colors.errorContainer : null,
                //         valueColor: isError ? colors.error : null,
                //         borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalCurrentAmount(BuildContext context, GenreDetailsState state) {
    final textTheme = Theme.of(context).textTheme;

    if (state.isLoaded) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: 0.0, // TODO: Fix
            style: textTheme.headlineLarge,
            decimalsStyle: textTheme.headlineSmall,
            currencyStyle: textTheme.bodyMedium,
            privateMode: isPrivateMode,
          );
        },
      );
    }

    return const Text('Loading...');
  }

  Widget _buildHoldingCount(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsLoadedState) {
      return Text(
        '${state.presentHoldings} / ${state.totalHoldings}',
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
      );
    }

    return const Text('Loading...');
  }

  Widget _buildTotalInvestedAmount(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsLoadedState) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(amount: state.totalInvested, privateMode: isPrivateMode);
        },
      );
    }

    return const Text('Loading...');
  }

  // Widget _buildAmountReturns(BuildContext context, GenreDetailsState state) {
  //   if (state.isError) {
  //     return Text('Error loading data');
  //   }

  //   if (state.isLoaded) {
  //     return BlocSelector<GenreDetailsCubit, GenreDetailsState, double>(
  //       selector: (state) => state.totalCurrentValue,
  //       builder: (context, totalCurrentValue) {
  //         final returns = totalCurrentValue - state.totalInvested;
  //         return BlocSelector<AppCubit, AppState, bool>(
  //           selector: (state) => state.isPrivateMode,
  //           builder: (context, isPrivateMode) {
  //             return CurrencyView(
  //               amount: returns,
  //               privateMode: isPrivateMode,
  //               style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
  //             );
  //           },
  //         );
  //       },
  //     );
  //   }

  //   return const Text('Loading...');
  // }

  // Widget _buildPercentageReturns(BuildContext context, GenreDetailsState state) {
  //   if (state.isError) {
  //     return Text('Error loading data');
  //   }

  //   if (state.isLoaded) {
  //     return BlocSelector<GenreDetailsCubit, GenreDetailsState, double>(
  //       selector: (state) => state.totalCurrentValue,
  //       builder: (context, totalCurrentValue) {
  //         final returns = state.totalInvested > 0 ? (totalCurrentValue / state.totalInvested - 1.0) * 100 : 0;
  //         return Text(
  //           '${returns.toPrecisionDouble(2)}%',
  //           textAlign: TextAlign.right,
  //           style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
  //         );
  //       },
  //     );
  //   }

  //   return const Text('Loading...');
  // }
}

class _HoldingStatCard extends StatefulWidget {
  const _HoldingStatCard({super.key, required AmcStat stat}) : _stat = stat;

  const _HoldingStatCard.loading({super.key}) : _stat = null;

  final AmcStat? _stat;

  @override
  State<_HoldingStatCard> createState() => _HoldingStatCardState();
}

class _HoldingStatCardState extends State<_HoldingStatCard> {
  static const double _spacing = 2.0;

  Future<void> _getCurrentPrice() async {
    final amc = widget._stat?.amc;
    if (amc == null) return;

    // if amc already has latest ltp, do nothing
    if (amc.ltp?.fetchDate.isToday ?? false) return;

    try {
      final ltp = await AmcRepository.instance.getLatestPrice(amc);
      $logger.i('Fetched LTP for ${amc.name}: ${ltp?.price} on ${ltp?.date}');
      if (mounted && ltp != null) {
        // context.read<GenreDetailsCubit>().updateCurrentAmount(
        //   amc.id,
        //   ltp.price * (widget.amcTransaction?.totalQuantity ?? 0),
        // );
        context.read<GenreDetailsCubit>().updateAmcLtp(amc.id, ltp);
      }
    } catch (e) {
      // Handle error, maybe return a default LatestPrice or rethrow
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPrice();
  }

  @override
  void didUpdateWidget(covariant _HoldingStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._stat != oldWidget._stat) {
      _getCurrentPrice();
    }
  }

  bool get isLoaded => widget._stat != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _spacing,
      children: <Widget>[
        // ~ AMC name and transaction count
        GestureDetector(
          onTap: () {
            if (isLoaded) context.push(AmcOverviewPage(widget._stat!.amc.id));
          },
          child: SimpleCard(
            elevation: 0.0,
            color: theme.canvasColor,
            borderRadius: iCardBorderRadius.copyWith(
              bottomLeft: iTileBorderRadius.bottomLeft,
              bottomRight: iTileBorderRadius.bottomRight,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.0,
                  children: <Widget>[
                    Row(
                      spacing: 4.0,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            isLoaded ? widget._stat?.amc.name ?? 'N/A' : 'Loading...',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),

                        Skeleton.ignore(
                          child: FadeIn(
                            fadeIn: isLoaded,
                            duration: 240.ms,
                            curve: Curves.easeInOut,
                            child: const Icon(Icons.east_rounded),
                          ),
                        ),
                      ],
                    ),
                    Wrap(spacing: 4.0, runSpacing: 4.0, children: _buildTagsForAmc(context)),
                    Text(
                      '${isLoaded ? widget._stat?.numTransactions ?? 0 : 'Loading...'} transactions',
                      style: labelStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Row(
          spacing: _spacing,
          children: <Widget>[
            // ~ Available quantity
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: Text('Available units', style: labelStyle),
                value: Text(
                  '${widget._stat?.totalQuantity.toPrecisionDouble(4) ?? '0.000'}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),

            // ~ Invested amount
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: Text('Invested', style: labelStyle),
                value: isLoaded
                    ? BlocSelector<AppCubit, AppState, bool>(
                        selector: (state) => state.isPrivateMode,
                        builder: (context, isPrivateMode) {
                          return CurrencyView(amount: widget._stat?.totalInvested ?? 0, privateMode: isPrivateMode);
                        },
                      )
                    : const Text('Loading...'),
              ),
            ),
          ],
        ),

        // if (!isLoaded) _buildLtpDependentWidget(context, null, labelStyle),

        // if (isLoaded)
        BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
          // buildWhen: (prev, curr) {
          //   final prevTrn = prev.stats.firstWhereOrNull((trn) => trn.amc.id == widget._amcTransaction?.amc.id);
          //   final currTrn = curr.stats.firstWhereOrNull((trn) => trn.amc.id == widget._amcTransaction?.amc.id);
          //   return prevTrn != currTrn || prevTrn?.amc.ltp != currTrn?.amc.ltp;
          // },
          builder: (context, genreState) {
            $logger.i('Rebuilding LTP-dependent widget for AMC ${widget._stat?.amc.name} with state: $genreState');
            return _buildLtpDependentWidget(context, genreState, labelStyle);
          },
        ),
      ],
    );
  }

  List<Widget> _buildTagsForAmc(BuildContext context) {
    if (!isLoaded) {
      return List.generate(4, (index) => const Skeleton.leaf(child: SimpleChip(title: Text('Loading...'))));
    }

    final tags = widget._stat?.amc.tags;
    if (tags?.isEmpty ?? true) {
      return [const SizedBox.shrink()];
    }

    return List.generate(tags!.length, (index) {
      final tag = tags.elementAt(index);
      return SimpleChip(title: Text(tag), color: context.colors.tertiary, titleColor: context.colors.onTertiary);
    });
  }

  Widget _buildLtpDependentWidget(BuildContext context, GenreDetailsState? genreState, TextStyle? labelStyle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _spacing,
      children: <Widget>[
        Row(
          spacing: _spacing,
          children: <Widget>[
            // ~ Current value
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: genreState != null
                    ? Skeleton.keep(child: Text('Current value', style: labelStyle))
                    : const Text('Loading...'),
                value: genreState != null ? _buildCurrentValue(context, genreState) : const Text('Loading...'),
              ),
            ),

            // ~ Returns amount
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: genreState != null
                    ? Skeleton.keep(child: Text('Returns', style: labelStyle))
                    : const Text('Loading...'),
                value: genreState != null ? _buildReturnAmount(context, genreState) : const Text('Loading...'),
              ),
            ),
          ],
        ),

        Row(
          spacing: _spacing,
          children: <Widget>[
            // ~ % Returns
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: genreState != null
                    ? Skeleton.keep(child: Text('% Returns', style: labelStyle))
                    : const Text('Loading...'),
                value: genreState != null ? _buildReturnPercentage(context, genreState) : const Text('Loading...'),
                borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
              ),
            ),

            // ~ XIRR
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: genreState != null
                    ? Skeleton.keep(child: Text('XIRR', style: labelStyle))
                    : const Text('Loading...'),
                value: genreState != null ? _buildXirr(context, genreState) : const Text('Loading...'),
                borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildXirr(BuildContext context, GenreDetailsState genreState) {
    return Text('xirr is not available', overflow: TextOverflow.ellipsis);
    // if (widget.stat?.transactions.isEmpty ?? true) {
    //   return Text('0.00%', style: TextStyle(color: Colors.teal));
    // }

    // if (genreState is GenreDetailsLoadedState) {
    //   final amcTrn = genreState.stats.firstWhereOrNull((trn) => trn.amc.id == widget.stat?.amc.id);
    //   final xirr = amcTrn?.xirr ?? 0.0;
    //   return Text(
    //     '${(xirr * 100).toPrecisionDouble(2)}%',
    //     style: TextStyle(color: xirr < 0 ? Colors.red : Colors.teal),
    //   );
    // }

    // return Skeletonizer.zone(child: const Bone.text());
  }

  Widget _buildReturnPercentage(BuildContext context, GenreDetailsState genreState) {
    if (genreState is GenreDetailsLoadedState) {
      final stat = genreState.stats.firstWhereOrNull((trn) => trn.amc.id == widget._stat?.amc.id);
      final percentageReturns = stat?.percentageReturn ?? 0.0;

      return Text(
        percentageReturns > 0 ? '${percentageReturns.toPrecisionDouble(2)}%' : '(0.00%)',
        style: TextStyle(color: percentageReturns < 0 ? Colors.red : Colors.teal),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Skeletonizer.zone(child: const Bone.text());
  }

  Widget _buildReturnAmount(BuildContext context, GenreDetailsState genreState) {
    if (genreState is GenreDetailsLoadedState) {
      final amcTrn = genreState.stats.firstWhereOrNull((trn) => trn.amc.id == widget._stat?.amc.id);
      final returns = amcTrn?.amountReturn ?? 0;

      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: returns,
            privateMode: isPrivateMode,
            style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
          );
        },
      );
    }

    return Skeletonizer.zone(child: const Bone.text());
  }

  Widget _buildCurrentValue(BuildContext context, GenreDetailsState genreState) {
    if (genreState is GenreDetailsLoadedState) {
      final amcStat = genreState.stats.firstWhereOrNull((stat) => stat.amc.id == widget._stat?.amc.id);
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(amount: amcStat?.currentValue ?? 0, privateMode: isPrivateMode);
        },
      );
    }

    return Text('Loading...', overflow: TextOverflow.ellipsis);
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    super.key,
    this.minHeight = 80.0,
    required this.label,
    required this.value,
    this.color,
    this.valueColor,
    this.borderRadius,
    this.contentSpacing,
  });

  final double minHeight;
  final Widget label;
  final Widget value;
  final Color? color;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final double? contentSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelText = DefaultTextStyle(
      style: theme.textTheme.bodyMedium!,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      child: label,
    );

    final valueText = DefaultTextStyle(
      style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
      textAlign: TextAlign.end,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      child: value,
    );

    return SimpleCard(
      elevation: 0.0,
      color: color ?? theme.canvasColor.lighten(3),
      shadowColor: theme.colorScheme.shadow,
      borderRadius: borderRadius ?? iTileBorderRadius,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: contentSpacing ?? 0.0,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              labelText,
              Align(alignment: Alignment.bottomRight, child: valueText),
            ],
          ),
        ),
      ),
    );
  }
}
