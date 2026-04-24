import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/amc_transaction_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/genre/view/genre_details/cubit/genre_details_cubit.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

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
    return BlocProvider(
      create: (_) {
        return GenreDetailsCubit(
          amcRepository: AmcRepository.instance,
          transactionRepository: TransactionRepository.instance,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(genre.title), floating: true, snap: true),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: BlocSelector<AppCubit, AppState, String?>(
                  selector: (state) => state.primaryAccountId,
                  builder: (context, accountId) {
                    return _GenreDetailsPageContent(accountId: accountId, genre: genre);
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

class _GenreDetailsPageContent extends StatefulWidget {
  const _GenreDetailsPageContent({super.key, this.accountId, required this.genre});

  final String? accountId;
  final AmcGenre genre;

  @override
  State<_GenreDetailsPageContent> createState() => _GenreDetailsPageContentState();
}

class _GenreDetailsPageContentState extends State<_GenreDetailsPageContent> {
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
      context.read<GenreDetailsCubit>().loadDetails(accountId: widget.accountId!, genre: widget.genre);
    }
  }

  @override
  Widget build(BuildContext context) {
    const spacing = 2.0;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
      builder: (context, genreDetailsState) {
        final isError = genreDetailsState is GenreDetailsErrorState;
        final isLoading = genreDetailsState is GenreDetailsLoadingState;

        return SliverSkeletonizer(
          enabled: isLoading,
          child: SliverList(
            delegate: SliverChildListDelegate.fixed(<Widget>[
              // ~ Overview
              Column(
                spacing: spacing,
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
                    value: _buildTotalCurrentAmount(context, genreDetailsState),
                    borderRadius: iCardBorderRadius.copyWith(
                      bottomLeft: iTileBorderRadius.bottomLeft,
                      bottomRight: iTileBorderRadius.bottomRight,
                    ),
                    color: isError ? colors.errorContainer : null,
                    valueColor: isError ? colors.error : null,
                  ),

                  Row(
                    spacing: spacing,
                    children: <Widget>[
                      // ~ Holding count
                      Expanded(
                        child: _SectionWidget(
                          label: const Skeleton.keep(child: Text('No. of holdings')),
                          value: _buildHoldingCount(context, genreDetailsState),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : null,
                        ),
                      ),

                      // ~ Invested amount section
                      Expanded(
                        child: _SectionWidget(
                          label: const Skeleton.keep(child: Text('Invested amount')),
                          value: _buildTotalInvestedAmount(context, genreDetailsState),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : null,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    spacing: spacing,
                    children: <Widget>[
                      // ~ Total returns sections
                      Expanded(
                        child: _SectionWidget(
                          label: const Skeleton.keep(child: Text('Total returns')),
                          value: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _buildAmountReturns(context, genreDetailsState),
                              _buildPercentageReturns(context, genreDetailsState),
                            ],
                          ),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : Colors.teal.shade500,
                          borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                        ),
                      ),

                      // ~ XIRR section
                      Expanded(
                        child: _SectionWidget(
                          label: const Skeleton.keep(child: Text('XIRR')),
                          value: _buildXirr(context, genreDetailsState),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : null,
                          borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Gap(16.0),

              _HoldingSection(state: genreDetailsState),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHoldingCount(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      return Text(state.stats.length.toString(), textAlign: TextAlign.right);
    }

    return const Text('Loading...');
  }

  Widget _buildTotalCurrentAmount(BuildContext context, GenreDetailsState state) {
    final textTheme = Theme.of(context).textTheme;
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: state.totalCurrentValue,
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

  Widget _buildTotalInvestedAmount(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

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
            children: <Widget>[
              Text(label, style: theme.textTheme.titleMedium),
              Align(
                alignment: Alignment.bottomRight,
                child: CurrencyView(
                  amount: amount,
                  style: theme.textTheme.headlineSmall,
                  decimalsStyle: theme.textTheme.titleMedium,
                  currencyStyle: theme.textTheme.titleMedium,
                  privateMode: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountReturns(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      final returns = state.totalCurrentValue - state.totalInvested;

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

    return const Text('Loading...');
  }

  Widget _buildPercentageReturns(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      final returns = state.totalInvested > 0 ? (state.totalCurrentValue / state.totalInvested - 1.0) * 100 : 0;

      return Text(
        '${returns.toPrecision(2)}%',
        textAlign: TextAlign.right,
        style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
      );
    }

    return const Text('Loading...');
  }

  Widget _buildXirr(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      //   final transactionsForXirr = state.stats.map((stat) => xf.Transaction(stat.totalAmount, stat.investedOn)).toList();
      //   if (transactionsForXirr.isNotEmpty) {
      //     transactionsForXirr.add(
      //       xf.Transaction(
      //         state.totalCurrentValue > 0 ? -(state.totalCurrentValue) : -0.0,
      //         latestPrice?.date ?? DateTime.now(),
      //       ),
      //     );
      //   }
      //   final xirr = transactionsForXirr != null && transactionsForXirr.isNotEmpty
      //       ? xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate()
      //       : 0.0;
      return Text(
        // xirr != null ? '${(xirr * 100).toPrecision(2)}%' : '0.00%',
        '0.00%',
        textAlign: TextAlign.right,
        // style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
        style: TextStyle(color: Colors.teal),
      );
    }

    return const Text('Loading...');
  }
}

class _HoldingSection extends StatelessWidget {
  const _HoldingSection({super.key, required this.state});

  final GenreDetailsState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = state is GenreDetailsLoadingState;
    final isError = state is GenreDetailsErrorState;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: <Widget>[
        Skeleton.keep(child: Text('Holdings', style: theme.textTheme.titleMedium)),
        _buildHoldings(context),
      ],
    );
  }

  Widget _buildHoldings(BuildContext context) {
    if (state is GenreDetailsErrorState) {
      return Center(
        child: Text('Error fetching data', style: TextStyle(color: context.colors.error)),
      );
    }

    if (state is GenreDetailsLoadedState && (state as GenreDetailsLoadedState).stats.isEmpty) {
      return Center(child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')));
    }

    return ColumnBuilder(
      mainAxisSize: MainAxisSize.min,
      spacing: 16.0,
      itemCount: state is GenreDetailsLoadedState
          ? (state as GenreDetailsLoadedState).stats.length
          : 2, // 2 for dummy loading
      itemBuilder: (context, index) {
        final amcTransaction = state is GenreDetailsLoadedState
            ? (state as GenreDetailsLoadedState).stats[index]
            : AmcTransaction(accountId: 'loading');

        return _HoldingStatCard(amcTransaction: amcTransaction);
      },
    );
  }
}

class _HoldingStatCard extends StatelessWidget {
  const _HoldingStatCard({super.key, required this.amcTransaction});

  final AmcTransaction amcTransaction;

  @override
  Widget build(BuildContext context) {
    const spacing = 2.0;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing,
      children: <Widget>[
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
                // spacing: 16.0,
                children: <Widget>[
                  Text(
                    amcTransaction.amc?.name ?? 'N/A',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    '${amcTransaction.numTransactions} transactions',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),

        Row(
          spacing: spacing,
          children: <Widget>[
            // ~ Invested amount
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: const Text('Invested'),
                value: CurrencyView(amount: amcTransaction.totalAmount, privateMode: false),
              ),
            ),
            // ~ Current value
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: const Text('Current value'),
                value: CurrencyView(amount: amcTransaction.currentValue, privateMode: false),
              ),
            ),
          ],
        ),

        Row(
          spacing: spacing,
          children: <Widget>[
            // ~ Returns amount
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: const Text('Returns'),
                value: CurrencyView(
                  amount: amcTransaction.currentValue - amcTransaction.totalAmount,
                  privateMode: false,
                ),
                valueColor: (amcTransaction.currentValue - amcTransaction.totalAmount) < 0 ? Colors.red : Colors.teal,
                borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
              ),
            ),

            // ~ Returns percentage
            // _SectionWidget(
            //   label: const Text('Returns %'),
            //   value: Text(
            //     stat.totalAmount > 0
            //         ? '${((stat.currentValue / stat.totalAmount - 1) * 100).toPrecision(2)}%'
            //         : '0.00%',
            //     style: TextStyle(color: (stat.currentValue - stat.totalAmount) < 0 ? Colors.red : Colors.teal),
            //   ),
            // ),

            // ~ XIRR
            Expanded(
              child: _SectionWidget(
                minHeight: 0.0,
                label: const Text('XIRR'),
                value: const Text('0.00%'),
                // value: Text(
                //   stat.transactionsForXirr != null && stat.transactionsForXirr!.isNotEmpty
                //       ? '${(xf.XirrFlutter.withTransactionsAndGuess(stat.transactionsForXirr!, 0.1).calculate() * 100).toPrecision(2)}%'
                //       : '0.00%',
                //   style: TextStyle(color: (stat.currentValue - stat.totalAmount) < 0 ? Colors.red : Colors.teal),
                // ),
                borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    super.key,
    this.minHeight = 96.0,
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
