import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/amc_transaction_model.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/genre/view/genre_details/cubit/genre_details_cubit.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

class GenreDetailsPage extends StatelessWidget {
  const GenreDetailsPage({super.key, required this.genre});

  final AmcGenre genre;

  static Route<void> route(AmcGenre genre) {
    return MaterialPageRoute<void>(
      builder: (_) {
        return GenreDetailsPage(genre: genre);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (_) {
            return GenreDetailsCubit(
              amcRepository: AmcRepository.instance,
              transactionRepository: TransactionRepository.instance,
            );
          },
          child: BlocSelector<AppCubit, AppState, String?>(
            selector: (state) => state.primaryAccountId,
            builder: (context, accountId) {
              return _GenreDetailsPageContent(genre: genre, accountId: accountId);
            },
          ),
        ),
      ),
    );
  }
}

class _GenreDetailsPageContent extends StatefulWidget {
  const _GenreDetailsPageContent({super.key, this.accountId, required this.genre});

  final String? accountId;
  final AmcGenre genre;

  @override
  State<_GenreDetailsPageContent> createState() => _GenreDetailsPageContentState();
}

class _GenreDetailsPageContentState extends State<_GenreDetailsPageContent> {
  static const double _spacing = 2.0;

  @override
  void initState() {
    super.initState();
    _getStats();
  }

  @override
  void didUpdateWidget(covariant _GenreDetailsPageContent oldWidget) {
    if (widget.accountId != oldWidget.accountId) {
      _getStats();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _getStats() {
    if (widget.accountId?.isEmpty ?? true) {
      return;
    }
    if (mounted) {
      context.read<GenreDetailsCubit>().loadTransactions(accountId: widget.accountId!, genre: widget.genre);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(title: Text(widget.genre.title), floating: true, snap: true),

        // ~ AMC Overview Section
        SliverToBoxAdapter(
          child: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
            buildWhen: (prev, curr) {
              return prev.status != curr.status || prev.stats != curr.stats || prev.errorMessage != curr.errorMessage;
            },
            builder: (context, genreState) {
              final isError = genreState.isError;
              final isLoading = genreState.isLoading;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Skeletonizer(
                  enabled: isLoading,
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
                        value: _buildTotalCurrentAmount(context, genreState),
                        borderRadius: iCardBorderRadius.copyWith(
                          bottomLeft: iTileBorderRadius.bottomLeft,
                          bottomRight: iTileBorderRadius.bottomRight,
                        ),
                        color: isError ? colors.errorContainer : null,
                        valueColor: isError ? colors.error : null,
                      ),

                      Row(
                        spacing: _spacing,
                        children: <Widget>[
                          // ~ Holding count
                          Expanded(
                            child: _SectionWidget(
                              label: const Skeleton.keep(child: Text('No. of holdings')),
                              value: _buildHoldingCount(context, genreState),
                              color: isError ? colors.errorContainer : null,
                              valueColor: isError ? colors.error : null,
                            ),
                          ),

                          // ~ Invested amount section
                          Expanded(
                            child: _SectionWidget(
                              label: const Skeleton.keep(child: Text('Invested amount')),
                              value: _buildTotalInvestedAmount(context, genreState),
                              color: isError ? colors.errorContainer : null,
                              valueColor: isError ? colors.error : null,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        spacing: _spacing,
                        children: <Widget>[
                          // ~ Total returns sections
                          Expanded(
                            child: _SectionWidget(
                              label: const Skeleton.keep(child: Text('Total returns')),
                              value: _buildAmountReturns(context, genreState),
                              color: isError ? colors.errorContainer : null,
                              valueColor: isError ? colors.error : Colors.teal.shade500,
                              borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                            ),
                          ),

                          // ~ XIRR section
                          Expanded(
                            child: _SectionWidget(
                              label: const Skeleton.keep(child: Text('XIRR')),
                              value: _buildPercentageReturns(context, genreState),
                              color: isError ? colors.errorContainer : null,
                              valueColor: isError ? colors.error : null,
                              borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SliverGap(16.0),

        SliverToBoxAdapter(
          child: // Title row with sort button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Holdings', style: theme.textTheme.titleMedium),
                    _buildSortButton(context),
                  ],
                ),

                // Filter chips
                // if (showControls) _buildFilterChips(context),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          sliver: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
            buildWhen: (prev, curr) {
              return prev.status != curr.status ||
                  prev.stats != curr.stats ||
                  prev.errorMessage != curr.errorMessage ||
                  prev.sortOption != curr.sortOption ||
                  prev.sortAscending != curr.sortAscending ||
                  prev.holdingFilter != curr.holdingFilter;
            },
            builder: (context, genreState) {
              $logger.i('GenreDetailsPage is building with state: $genreState');
              final isError = genreState.isError;
              final isLoading = genreState.isLoading;

              return SliverList(
                delegate: SliverChildListDelegate.fixed(<Widget>[
                  // ~ Overview
                  _HoldingSection(state: genreState),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final cubit = context.read<GenreDetailsCubit>();
    final state = cubit.state;
    return InveslyChoiceChips<HoldingFilter>.single(
      options: HoldingFilter.values.map((f) => InveslyChipData(value: f, label: Text(f.label))).toList(),
      selected: state.holdingFilter,
      onChanged: (filter) {
        if (filter != null) cubit.setHoldingFilter(filter);
      },
      wrapped: false,
      showCheckmark: false,
    );
  }

  Widget _buildSortButton(BuildContext context) {
    // final theme = Theme.of(context);
    // final cubit = context.read<GenreDetailsCubit>();

    return BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
      buildWhen: (prev, curr) {
        return prev.status != curr.status || prev.stats != curr.stats;
      },
      builder: (context, genreState) {
        return AnimatedScale(
          key: ValueKey('button'),
          scale: genreState.isLoaded && genreState.stats.isNotEmpty ? 1.0 : 0.0,
          alignment: Alignment.centerRight,
          duration: 200.ms,
          child: IconButton(onPressed: () {}, icon: const Icon(Icons.sort_rounded), tooltip: 'Sort holdings'),
        );
      },
    );

    // return PopupMenuButton<HoldingSortOption>(
    //
    //   padding: EdgeInsets.zero,
    //   position: PopupMenuPosition.under,
    //   onSelected: (option) => cubit.setSortOption(option),
    //   itemBuilder: (_) {
    //     return HoldingSortOption.values.map((option) {
    //       final isSelected = state.sortOption == option;
    //       return PopupMenuItem<HoldingSortOption>(
    //         value: option,
    //         child: Row(
    //           children: <Widget>[
    //             Expanded(child: Text(option.label)),
    //             if (isSelected)
    //               Icon(
    //                 state.sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
    //                 size: 16.0,
    //                 color: theme.colorScheme.primary,
    //               ),
    //           ],
    //         ),
    //       );
    //     }).toList();
    //   },
    // );
  }

  Widget _buildHoldingCount(BuildContext context, GenreDetailsState state) {
    if (state.status == GenreDetailsStateStatus.error) {
      return Text('Error loading data');
    }

    if (state.status == GenreDetailsStateStatus.loaded) {
      final totalHoldings = state.stats.length;
      final presentHoldings = state.stats.where((stat) => stat.totalQuantity > 0).length;
      return Text('$presentHoldings / $totalHoldings', textAlign: TextAlign.right, overflow: TextOverflow.ellipsis);
    }

    return const Text('Loading...');
  }

  Widget _buildTotalCurrentAmount(BuildContext context, GenreDetailsState state) {
    final textTheme = Theme.of(context).textTheme;
    if (state.isError) {
      return Text('Error loading data');
    }

    if (state.isLoaded) {
      return BlocSelector<GenreDetailsCubit, GenreDetailsState, double>(
        selector: (state) => state.totalCurrentValue,
        builder: (context, totalCurrentValue) {
          return BlocSelector<AppCubit, AppState, bool>(
            selector: (state) => state.isPrivateMode,
            builder: (context, isPrivateMode) {
              return CurrencyView(
                amount: totalCurrentValue,
                style: textTheme.headlineLarge,
                decimalsStyle: textTheme.headlineSmall,
                currencyStyle: textTheme.bodyMedium,
                privateMode: isPrivateMode,
              );
            },
          );
        },
      );
    }

    return const Text('Loading...');
  }

  Widget _buildTotalInvestedAmount(BuildContext context, GenreDetailsState state) {
    if (state.isError) {
      return Text('Error loading data');
    }

    if (state.isLoaded) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(amount: state.totalInvested, privateMode: isPrivateMode);
        },
      );
    }

    return const Text('Loading...');
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount) {
    final theme = Theme.of(context);
    return SimpleCard(
      elevation: 0.0,
      child: SizedBox(
        height: 96.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(label, style: theme.textTheme.titleMedium),
              Align(
                alignment: Alignment.bottomRight,
                child: BlocSelector<AppCubit, AppState, bool>(
                  selector: (state) => state.isPrivateMode,
                  builder: (context, isPrivateMode) {
                    return CurrencyView(
                      amount: amount,
                      style: theme.textTheme.headlineSmall,
                      decimalsStyle: theme.textTheme.titleMedium,
                      currencyStyle: theme.textTheme.titleMedium,
                      privateMode: isPrivateMode,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountReturns(BuildContext context, GenreDetailsState state) {
    if (state.isError) {
      return Text('Error loading data');
    }

    if (state.isLoaded) {
      return BlocSelector<GenreDetailsCubit, GenreDetailsState, double>(
        selector: (state) => state.totalCurrentValue,
        builder: (context, totalCurrentValue) {
          final returns = totalCurrentValue - state.totalInvested;
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
        },
      );
    }

    return const Text('Loading...');
  }

  Widget _buildPercentageReturns(BuildContext context, GenreDetailsState state) {
    if (state.isError) {
      return Text('Error loading data');
    }

    if (state.isLoaded) {
      return BlocSelector<GenreDetailsCubit, GenreDetailsState, double>(
        selector: (state) => state.totalCurrentValue,
        builder: (context, totalCurrentValue) {
          final returns = state.totalInvested > 0 ? (totalCurrentValue / state.totalInvested - 1.0) * 100 : 0;
          return Text(
            '${returns.toPrecisionDouble(2)}%',
            textAlign: TextAlign.right,
            style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
          );
        },
      );
    }

    return const Text('Loading...');
  }
}

class _HoldingSection extends StatelessWidget {
  const _HoldingSection({super.key, required this.state});

  final GenreDetailsState state;

  bool get showControls => state.isLoaded && state.stats.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(enabled: state.isLoading, child: _buildHoldings(context));
  }

  Widget _buildHoldings(BuildContext context) {
    if (state.isError) {
      return Center(
        child: Text('Error fetching data', style: TextStyle(color: context.colors.error)),
      );
    }

    if (state.isLoaded && state.stats.isEmpty) {
      return Center(child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')));
    }

    final displayList = state.displayStats;

    if (state.isLoaded && displayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'No holdings match the current filter',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return ColumnBuilder(
      mainAxisSize: MainAxisSize.min,
      spacing: 16.0,
      itemCount: state.isLoaded ? displayList.length : 2,
      itemBuilder: (context, index) {
        final amcTransaction = state.isLoaded ? displayList[index] : null;
        return _HoldingStatCard(isLoaded: state.isLoaded, amcTransaction: amcTransaction);
      },
    );
  }
}

class _HoldingStatCard extends StatefulWidget {
  const _HoldingStatCard({super.key, this.isLoaded = false, this.amcTransaction});

  final bool isLoaded;
  final AmcTransaction? amcTransaction;

  @override
  State<_HoldingStatCard> createState() => _HoldingStatCardState();
}

class _HoldingStatCardState extends State<_HoldingStatCard> {
  static const double _spacing = 2.0;
  late Future<LatestPrice?> ltp;

  @override
  void initState() {
    super.initState();
    ltp = _getCurrentPrice();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: _spacing,
      children: <Widget>[
        // ~ AMC name and transaction count
        SimpleCard(
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
                  Text(
                    widget.isLoaded ? widget.amcTransaction?.amc?.name ?? 'N/A' : 'Loading...',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Wrap(spacing: 4.0, runSpacing: 4.0, children: _buildTagsForAmc(context)),
                  Text(
                    '${widget.isLoaded ? widget.amcTransaction?.numTransactions ?? 0 : 'Loading...'} transactions',
                    style: labelStyle,
                  ),
                ],
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
                  '${widget.isLoaded ? widget.amcTransaction?.totalQuantity.toPrecisionDouble(4) ?? '0' : 'Loading...'}',
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
                value: widget.isLoaded
                    ? BlocSelector<AppCubit, AppState, bool>(
                        selector: (state) => state.isPrivateMode,
                        builder: (context, isPrivateMode) {
                          return CurrencyView(
                            amount: widget.amcTransaction?.totalAmount ?? 0,
                            privateMode: isPrivateMode,
                          );
                        },
                      )
                    : const Text('Loading...'),
              ),
            ),
          ],
        ),

        if (!widget.isLoaded) _buildLtpDependentWidget(context, null, labelStyle),

        if (widget.isLoaded)
          FutureBuilder<LatestPrice?>(
            future: ltp,
            builder: (context, snapshot) {
              return Skeletonizer(
                enabled: snapshot.connectionState == ConnectionState.waiting,
                child: _buildLtpDependentWidget(context, snapshot, labelStyle),
              );
            },
          ),
      ],
    );
  }

  Widget _buildLtpDependentWidget(
    BuildContext context, [
    AsyncSnapshot<LatestPrice?>? snapshot,
    TextStyle? labelStyle,
  ]) {
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
                label: snapshot != null
                    ? Skeleton.keep(child: Text('Current value', style: labelStyle))
                    : const Text('Loading...'),
                value: snapshot != null ? _buildCurrentValue(context, snapshot) : const Text('Loading...'),
              ),
            ),

            // ~ Returns amount
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: snapshot != null
                    ? Skeleton.keep(child: Text('Returns', style: labelStyle))
                    : const Text('Loading...'),
                value: snapshot != null ? _buildReturnAmount(context, snapshot) : const Text('Loading...'),
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
                label: snapshot != null
                    ? Skeleton.keep(child: Text('% Returns', style: labelStyle))
                    : const Text('Loading...'),
                value: snapshot != null ? _buildReturnPercentage(context, snapshot) : const Text('Loading...'),
                borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
              ),
            ),

            // ~ XIRR
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: snapshot != null
                    ? Skeleton.keep(child: Text('XIRR', style: labelStyle))
                    : const Text('Loading...'),
                value: snapshot != null ? _buildXirr(context, snapshot) : const Text('Loading...'),
                borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildTagsForAmc(BuildContext context) {
    if (!widget.isLoaded) {
      return List.generate(4, (index) => const Skeleton.leaf(child: SimpleChip(title: Text('Loading...'))));
    }

    final tags = widget.amcTransaction?.amc?.tags;
    if (tags?.isEmpty ?? true) {
      return [const SizedBox.shrink()];
    }

    return List.generate(tags!.length, (index) {
      final tag = tags.elementAt(index);
      return SimpleChip(title: Text(tag), color: context.colors.tertiary, titleColor: context.colors.onTertiary);
    });
  }

  Widget _buildXirr(BuildContext context, AsyncSnapshot<LatestPrice?> snapshot) {
    if (snapshot.hasError) {
      return Text(
        'Error loading LTP',
        style: TextStyle(color: context.colors.error),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (widget.amcTransaction?.transactions.isEmpty ?? true) {
      return Text('0.00%', style: TextStyle(color: Colors.teal));
    }

    if (snapshot.hasData) {
      final transactionsForXirr = widget.amcTransaction!.transactions
          .map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn))
          .toList();
      if (transactionsForXirr.isNotEmpty) {
        final currentAmount = snapshot.data!.price * (widget.amcTransaction?.totalQuantity ?? 0);
        transactionsForXirr.add(xf.Transaction(-currentAmount, snapshot.data!.date ?? snapshot.data!.fetchDate));
      }

      double? xirr = 0.0;
      if (transactionsForXirr.isNotEmpty) {
        try {
          xirr = xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate();
        } catch (e) {
          $logger.e('Error calculating XIRR: $e');
        }
      }
      return Text(
        xirr != null ? '${(xirr * 100).toPrecisionDouble(2)}%' : '0.00%',
        style: TextStyle(color: (xirr ?? 0) < 0 ? Colors.red : Colors.teal),
      );
    }

    return Skeletonizer.zone(child: const Bone.text());
  }

  Widget _buildReturnPercentage(BuildContext context, AsyncSnapshot<LatestPrice?> snapshot) {
    if (snapshot.hasError) {
      return Text(
        'Error loading LTP',
        style: TextStyle(color: context.colors.error),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (snapshot.hasData) {
      final currentAmount = snapshot.data!.price * (widget.amcTransaction?.totalQuantity ?? 0);
      final returns = currentAmount - (widget.amcTransaction?.totalAmount ?? 0);
      final percentageReturns = (widget.amcTransaction?.totalAmount ?? 0) > 0
          ? ((currentAmount / (widget.amcTransaction?.totalAmount ?? 1) - 1) * 100)
          : 0.0;

      return Text(
        percentageReturns > 0 ? '${percentageReturns.toPrecisionDouble(2)}%' : '(0.00%)',
        style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return Skeletonizer.zone(child: const Bone.text());
  }

  Widget _buildReturnAmount(BuildContext context, AsyncSnapshot<LatestPrice?> snapshot) {
    if (snapshot.hasError) {
      return Text(
        'Error loading LTP',
        style: TextStyle(color: context.colors.error),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (snapshot.hasData) {
      final currentAmount = snapshot.data!.price * (widget.amcTransaction?.totalQuantity ?? 0);
      final returns = currentAmount - (widget.amcTransaction?.totalAmount ?? 0);
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

  Widget _buildCurrentValue(BuildContext context, AsyncSnapshot<LatestPrice?> snapshot) {
    if (snapshot.hasError) {
      $logger.e(snapshot.error);
      return Text(
        'Error loading LTP',
        style: TextStyle(color: context.colors.error),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (snapshot.hasData) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: snapshot.data!.price * (widget.amcTransaction?.totalQuantity ?? 0),
            privateMode: isPrivateMode,
          );
        },
      );
    }

    return Text('Loading...', overflow: TextOverflow.ellipsis);
  }

  Future<LatestPrice?> _getCurrentPrice() async {
    await Future.delayed(5.seconds); // TODO: Remove this delay, it's just to simulate loading state for demo purposes.
    final amc = widget.amcTransaction?.amc;
    if (amc == null) {
      return null;
    }

    try {
      final ltp = await AmcRepository.instance.getLatestPrice(amc);
      $logger.i('Fetched LTP for ${amc.name}: ${ltp?.price} on ${ltp?.date}');
      if (mounted && ltp != null) {
        context.read<GenreDetailsCubit>().updateCurrentAmount(
          amc.id,
          ltp.price * (widget.amcTransaction?.totalQuantity ?? 0),
        );
      }
      return ltp;
    } catch (e) {
      // Handle error, maybe return a default LatestPrice or rethrow
      rethrow;
    }
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
