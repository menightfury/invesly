import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/widget/account_picker_widget.dart';
import 'package:invesly/amc_stat/cubit/amc_stat_cubit.dart';
import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
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
          create: (context) => GenreDetailsCubit(
            repository: AmcRepository.instance,
            genre: genre,
            activeAccountId: context.read<AppCubit>().state.primaryAccountId,
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Text(genre.title, overflow: TextOverflow.ellipsis),
                floating: true,
                snap: true,
                actions: <Widget>[_AccountPickerWidget()],
                actionsPadding: const EdgeInsets.only(right: 16.0),
              ),

              BlocBuilder<AmcStatCubit, AmcStatState>(
                builder: (context, statState) {
                  if (statState.isError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Some error occurred while fetching data',
                          overflow: TextOverflow.ellipsis,
                        ), // TODO: Redesign & test
                      ),
                    );
                  }

                  if (statState is AmcStatLoadedState) {
                    return BlocSelector<GenreDetailsCubit, GenreDetailsState, String?>(
                      selector: (state) => state.activeAccountId,
                      builder: (context, activeAccountId) {
                        if (activeAccountId == null || activeAccountId.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No account is selected.\n Please select an account to view stats.',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final filteredStats = statState.filterStats(accountId: activeAccountId, genre: genre);
                        if (filteredStats.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyWidget(
                              label: Text('This is so empty!\nAdd some transactions to see stats here.'),
                            ),
                          );
                        }
                        return _GenreDetailsPageContent(key: ValueKey(activeAccountId), stats: filteredStats);
                      },
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Center(
                      child: LoadingAnimationWidget.newtonCradle(color: context.colors.primary, size: 48.0),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreDetailsPageContent extends StatefulWidget {
  const _GenreDetailsPageContent({super.key, required this.stats});

  final List<AmcStat> stats;

  @override
  State<_GenreDetailsPageContent> createState() => _GenreDetailsPageContentState();
}

class _GenreDetailsPageContentState extends State<_GenreDetailsPageContent> {
  @override
  void initState() {
    super.initState();
    context.read<GenreDetailsCubit>().loadStats(widget.stats);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<GenreDetailsCubit>();

    return SliverMainAxisGroup(
      slivers: <Widget>[
        // ~ Overview section
        SliverToBoxAdapter(child: _GenreOverviewSection()),

        // ~ Title row with sort & filter button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 4.0),
            child: Row(
              spacing: 8.0,
              children: <Widget>[
                Text('Holdings', style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                SimpleChip(
                  title: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
                    buildWhen: (prev, curr) => prev.sortAndFilterStatus != curr.sortAndFilterStatus,
                    builder: (context, genreState) {
                      return Text(
                        '${genreState.sortAndFilterStatus.holdingFilter.label} : ${genreState.displayStats.length}',
                        style: theme.textTheme.labelSmall,
                      );
                    },
                  ),
                ),
                Spacer(),

                // ~ Sort button
                BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
                  // buildWhen: (prev, curr) {
                  //   return prev.status != curr.status && (prev.isLoaded || curr.isLoaded);
                  // },
                  builder: (context, genreState) {
                    return AnimatedScale(
                      scale: genreState.isLtpLoaded && genreState.stats.isNotEmpty ? 1.0 : 0.0,
                      alignment: Alignment.centerRight,
                      duration: 240.ms,
                      curve: Curves.easeInOut,
                      child: IconButton(
                        onPressed: genreState.isLtpLoaded
                            ? () async {
                                final sortOptions = await _showSortOptions(context, genreState.sortAndFilterStatus);
                                if (sortOptions == null) return;
                                cubit.setSortAndFilterStatus(sortOptions);
                              }
                            : null,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.sort_rounded),
                        tooltip: 'Filter & Sort',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // ~ Holdings list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          sliver: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
            buildWhen: (prev, curr) {
              return prev.stats != curr.stats || prev.sortAndFilterStatus != curr.sortAndFilterStatus;
            },
            builder: (context, state) {
              // ~ If no stats
              if (state.stats.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')),
                );
              }

              // ~ If stats available but search result is empty
              final displayList = state.displayStats;
              if (displayList.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyWidget(label: Text('No holdings match the current filter')),
                );
              }

              // ~ Display stats
              return SliverList.separated(
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final stat = displayList.elementAt(index);
                  return _HoldingStatCard(stat: stat);
                },
                separatorBuilder: (_, _) => const Gap(12.0),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<HoldingSortAndFilterStatus?> _showSortOptions(
    BuildContext context,
    HoldingSortAndFilterStatus sortAndFilterStatus,
  ) async {
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
                options: HoldingFilter.values
                    .map(
                      (f) => InveslyChipData(
                        value: f,
                        label: Text(f.label, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
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
                                  InveslyChipData(
                                    value: true,
                                    label: Text(option.ascendingLabel ?? 'Ascending', overflow: TextOverflow.ellipsis),
                                  ),
                                  InveslyChipData(
                                    value: false,
                                    label: Text(
                                      option.descendingLabel ?? 'Descending',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
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
              label: const Text('Apply', overflow: TextOverflow.ellipsis),
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
  static const double _sectionHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
        // buildWhen: (prev, curr) => prev.stats != curr.stats,
        builder: (context, state) {
          $logger.i('Rebuilding genre overview section with state: $state');
          return Skeletonizer(
            enabled: state.isLtpLoading,
            child: Column(
              spacing: _spacing,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ~ Current Value
                _SectionWidget(
                  height: _sectionHeight,
                  label: Skeleton.keep(
                    child: FormattedDate(
                      date: DateTime.now(),
                      prefix: const Text('Current value as of ', overflow: TextOverflow.ellipsis),
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

                Skeleton.keep(
                  child: Row(
                    spacing: _spacing,
                    children: <Widget>[
                      // ~ Holding count
                      Expanded(
                        child: _SectionWidget(
                          height: _sectionHeight,
                          label: const Text('Present holdings', overflow: TextOverflow.ellipsis),
                          value: _buildHoldingCount(context, state),
                        ),
                      ),

                      // ~ Invested amount section
                      Expanded(
                        child: _SectionWidget(
                          height: _sectionHeight,
                          label: const Text('Invested amount', overflow: TextOverflow.ellipsis),
                          value: _buildTotalInvestedAmount(context, state),
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  spacing: _spacing,
                  children: <Widget>[
                    // ~ Total returns sections
                    Expanded(
                      child: _SectionWidget(
                        height: _sectionHeight,
                        label: const Skeleton.keep(child: Text('Total returns', overflow: TextOverflow.ellipsis)),
                        value: _buildAmountReturns(context, state),
                        borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                      ),
                    ),

                    // ~ % Return section
                    Expanded(
                      child: _SectionWidget(
                        height: _sectionHeight,
                        label: const Skeleton.keep(child: Text('% returns', overflow: TextOverflow.ellipsis)),
                        value: _buildPercentageReturns(context, state),
                        borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCurrentAmount(BuildContext context, GenreDetailsState state) {
    final textTheme = Theme.of(context).textTheme;

    if (state.isLtpError) {
      return const Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (state.isLtpLoaded) {
      final currentAmount = state.totalCurrentAmount;
      final color = currentAmount < 0 ? Colors.red : Colors.teal;
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: currentAmount,
            style: textTheme.headlineLarge?.copyWith(color: color),
            decimalsStyle: textTheme.headlineSmall?.copyWith(color: color),
            currencyStyle: textTheme.bodyMedium?.copyWith(color: color),
            privateMode: isPrivateMode,
          );
        },
      );
    }

    return const Text('Loading...', overflow: TextOverflow.ellipsis);
  }

  Widget _buildHoldingCount(BuildContext context, GenreDetailsState state) {
    return Text('${state.presentHoldings}', textAlign: TextAlign.right, overflow: TextOverflow.ellipsis);
  }

  Widget _buildTotalInvestedAmount(BuildContext context, GenreDetailsState state) {
    return BlocSelector<AppCubit, AppState, bool>(
      selector: (state) => state.isPrivateMode,
      builder: (context, isPrivateMode) {
        return CurrencyView(amount: state.totalInvested, privateMode: isPrivateMode);
      },
    );
  }

  Widget _buildAmountReturns(BuildContext context, GenreDetailsState state) {
    if (state.isLtpError) {
      return const Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (state.isLtpLoaded) {
      final returns = state.totalReturns;
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

    return const Text('Loading...', overflow: TextOverflow.ellipsis);
  }

  Widget _buildPercentageReturns(BuildContext context, GenreDetailsState state) {
    if (state.isLtpError) {
      return const Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (state.isLtpLoaded) {
      final returns = state.totalReturns / state.totalInvested;
      return Text(
        '${returns.toPrecisionDouble(2)}%',
        textAlign: TextAlign.right,
        style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
        overflow: TextOverflow.ellipsis,
      );
    }

    return const Text('Loading...', overflow: TextOverflow.ellipsis);
  }
}

class _HoldingStatCard extends StatelessWidget {
  const _HoldingStatCard({super.key, required this.stat});
  final AmcStat stat;

  static const double _spacing = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    final accountId =
        context.read<GenreDetailsCubit>().state.activeAccountId ?? context.read<AppCubit>().state.primaryAccountId;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _spacing,
      children: <Widget>[
        // ~ AMC name, Chips and Transaction count
        GestureDetector(
          onTap: () {
            if (accountId == null) {
              $logger.w('Account ID is null. Cannot navigate to AMC overview page.');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No account is selected. Please select an account to view AMC details.')),
              );
              return;
            }
            context.push(AmcOverviewPage(accountId: accountId, stat: stat));
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
                            stat.amc.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),

                        Skeleton.ignore(
                          child: FadeIn(
                            duration: 240.ms,
                            curve: Curves.easeInOut,
                            child: const Icon(Icons.east_rounded),
                          ),
                        ),
                      ],
                    ),
                    _buildTagsForAmc(context),
                    Text('${stat.numTransactions} transactions', style: labelStyle, overflow: TextOverflow.ellipsis),
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
                label: Skeleton.keep(
                  child: Text('Available units', style: labelStyle, overflow: TextOverflow.ellipsis),
                ),
                value: Text(
                  '${stat.totalQuantity.toPrecisionDouble(4)}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),

            // ~ Invested amount
            Expanded(
              child: _SectionWidget(
                label: Skeleton.keep(
                  child: Text('Invested', style: labelStyle, overflow: TextOverflow.ellipsis),
                ),
                value: BlocSelector<AppCubit, AppState, bool>(
                  selector: (state) => state.isPrivateMode,
                  builder: (context, isPrivateMode) {
                    return CurrencyView(amount: stat.totalInvested, privateMode: isPrivateMode);
                  },
                ),
              ),
            ),
          ],
        ),

        BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
          buildWhen: (prev, curr) {
            // final prevStat = prev.stats.firstWhereOrNull((s) => s.amc.id == stat.amc.id);
            // final currStat = curr.stats.firstWhereOrNull((s) => s.amc.id == stat.amc.id);
            // return prevStat != currStat || prevStat?.amc.ltp != currStat?.amc.ltp;
            return prev.status != curr.status;
          },
          builder: (context, genreState) {
            $logger.i('Rebuilding LTP-dependent widget for AMC ${stat.amc.name} with state: $genreState');
            return Skeletonizer(
              enabled: genreState.isLtpLoading,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: _spacing,
                children: <Widget>[
                  Row(
                    spacing: _spacing,
                    children: <Widget>[
                      // ~ Current value
                      Expanded(
                        child: _SectionWidget(
                          label: Skeleton.keep(
                            child: Text('Current value', style: labelStyle, overflow: TextOverflow.ellipsis),
                          ),
                          value: _buildCurrentValue(context, genreState),
                        ),
                      ),

                      // ~ Returns amount
                      Expanded(
                        child: _SectionWidget(
                          label: Skeleton.keep(
                            child: Text('Returns', style: labelStyle, overflow: TextOverflow.ellipsis),
                          ),
                          value: _buildReturnAmount(context, genreState),
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
                          label: Skeleton.keep(
                            child: Text('% Returns', style: labelStyle, overflow: TextOverflow.ellipsis),
                          ),
                          value: _buildReturnPercentage(context, genreState),
                          borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                        ),
                      ),

                      // ~ XIRR
                      Expanded(
                        child: _SectionWidget(
                          label: Skeleton.keep(
                            child: Text('XIRR', style: labelStyle, overflow: TextOverflow.ellipsis),
                          ),
                          value: _buildXirr(context, genreState),
                          borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTagsForAmc(BuildContext context) {
    final tags = stat.amc.tags;
    if (tags == null || tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: tags.map((tag) {
        return SimpleChip(title: Text(tag), color: context.colors.tertiary, titleColor: context.colors.onTertiary);
      }).toList(),
    );
  }

  Widget _buildXirr(BuildContext context, GenreDetailsState genreState) {
    if (genreState.isLtpError) {
      return Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (genreState.isLtpLoaded) {
      final stat_ = genreState.stats.firstWhereOrNull((s) => s.amc.id == stat.amc.id);

      final xirr = stat_?.amc.xirr?.value;
      return Text(
        xirr != null ? '${(xirr * 100).toPrecisionDouble(2)}%' : 'N/A',
        style: TextStyle(color: xirr != null && xirr < 0 ? Colors.red : Colors.teal),
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text('Loading...', overflow: TextOverflow.ellipsis);
  }

  Widget _buildReturnPercentage(BuildContext context, GenreDetailsState genreState) {
    if (genreState.isLtpError) {
      return Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (genreState.isLtpLoaded) {
      final stat_ = genreState.stats.firstWhereOrNull((s) => s.amc.id == stat.amc.id);
      final percentageReturns = stat_?.percentageReturn ?? 0.0;

      return Text(
        percentageReturns > 0 ? '${percentageReturns.toPrecisionDouble(2)}%' : '(0.00%)',
        style: TextStyle(color: percentageReturns < 0 ? Colors.red : Colors.teal),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Text('Loading...', overflow: TextOverflow.ellipsis);
  }

  Widget _buildReturnAmount(BuildContext context, GenreDetailsState genreState) {
    if (genreState.isLtpError) {
      return Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (genreState.isLtpLoaded) {
      final stat_ = genreState.stats.firstWhereOrNull((s) => s.amc.id == stat.amc.id);
      final returns = stat_?.amountReturn ?? 0;

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

    return Text('Loading...', overflow: TextOverflow.ellipsis);
  }

  Widget _buildCurrentValue(BuildContext context, GenreDetailsState genreState) {
    if (genreState.isLtpError) {
      return Text('N/A', overflow: TextOverflow.ellipsis);
    }

    if (genreState.isLtpLoaded) {
      final stat_ = genreState.stats.firstWhereOrNull((s) => s.amc.id == stat.amc.id);
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(amount: stat_?.currentValue ?? 0, privateMode: isPrivateMode);
        },
      );
    }

    return Text('Loading...', overflow: TextOverflow.ellipsis);
  }
}

class _AccountPickerWidget extends StatefulWidget {
  const _AccountPickerWidget({super.key});

  @override
  State<_AccountPickerWidget> createState() => _AccountPickerWidgetState();
}

class _AccountPickerWidgetState extends State<_AccountPickerWidget> {
  List<InveslyAccount>? accounts;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AccountsCubit>();
    // if accounts are not loaded, fetch accounts.
    // This is to ensure that accounts are available for account picker.
    if (cubit.state is! AccountsLoadedState) {
      cubit.fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        if (state is AccountsLoadedState) {
          accounts = state.accounts;
        }

        return BlocSelector<GenreDetailsCubit, GenreDetailsState, String?>(
          selector: (state) => state.activeAccountId,
          builder: (context, activeAccountId) {
            final account = activeAccountId != null && accounts != null && accounts!.isNotEmpty
                ? accounts?.firstWhereOrNull((a) => a.id == activeAccountId)
                : null;
            return ActionChip(
              label: Text(account?.name ?? activeAccountId ?? 'N/A', overflow: TextOverflow.ellipsis, maxLines: 1),
              avatar: CircleAvatar(
                foregroundImage: account != null ? AssetImage(account.avatarSrc) : null,
                child: account == null ? Icon(Icons.person_rounded) : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              onPressed: () async {
                final newAccount = await InveslyAccountPickerWidget.showModal(
                  context,
                  accountId: activeAccountId,
                  showAddAccountOption: false,
                );
                if (newAccount == null || !context.mounted) return;
                context.read<GenreDetailsCubit>().updateActiveAccountId(newAccount.id);
              },
            );
          },
        );
      },
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    super.key,
    this.height = 80.0,
    required this.label,
    required this.value,
    this.color,
    this.valueColor,
    this.borderRadius,
    this.contentSpacing,
  });

  final double? height;
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
      child: SizedBox(
        height: height,
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
