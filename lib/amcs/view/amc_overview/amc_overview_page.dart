import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/tiny_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';

class AmcOverviewPage extends StatelessWidget {
  const AmcOverviewPage(this.amcId, {super.key});

  final String amcId;

  @override
  Widget build(BuildContext context) {
    final trnRepository = TransactionRepository.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AmcOverviewCubit(repository: AmcRepository.instance)),
        BlocProvider(create: (context) => TransactionsCubit(repository: trnRepository)),
      ],
      child: _AmcOverviewScreen(amcId),
    );
  }
}

class _AmcOverviewScreen extends StatefulWidget {
  const _AmcOverviewScreen(this.amcId, {super.key});

  final String amcId;

  @override
  State<_AmcOverviewScreen> createState() => _AmcOverviewScreenState();
}

class _AmcOverviewScreenState extends State<_AmcOverviewScreen> {
  @override
  void initState() {
    super.initState();
    _getAmcOverview();
    _getStats();
  }

  @override
  void didUpdateWidget(covariant _AmcOverviewScreen oldWidget) {
    if (oldWidget.amcId != widget.amcId) {
      _getAmcOverview();
      _getStats();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _getAmcOverview() {
    context.read<AmcOverviewCubit>().fetchAmcOverview(widget.amcId);
  }

  void _getStats() {
    final accountId = context.read<AppCubit>().state.primaryAccountId;
    if (accountId?.isEmpty ?? true) {
      return;
    }
    if (mounted) {
      context.read<TransactionsCubit>().fetchTransactions(accountId: accountId, amcId: widget.amcId);
    }
  }

  List<Widget> _buildAmcTags(AmcOverviewState amcState) {
    if (amcState is AmcOverviewLoadedState) {
      final amcTags = amcState.amc?.tags;
      if (amcTags == null || amcTags.isEmpty) {
        return [];
      }

      return amcTags.map((tag) {
        if (tag.isEmpty) {
          return const SizedBox.shrink();
        }

        return TinyChip(title: Text(tag), color: context.colors.tertiary, titleColor: context.colors.onTertiary);
      }).toList();
    }

    return List.filled(3, const Skeleton.leaf(child: TinyChip(title: Text('Loading...'))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
      builder: (context, amcState) {
        final latestPrice = amcState is AmcOverviewLoadedState && amcState.amc?.ltp != null
            ? amcState.amc!.ltp
            : null;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(title: const Text('Holding details'), floating: true, snap: true),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate.fixed(<Widget>[
                            // ~ AMC Details
                            PhysicalModel(
                              clipBehavior: Clip.antiAlias,
                              color: colors.primaryContainer.darken(3.0),
                              shadowColor: colors.shadow,
                              borderRadius: iCardBorderRadius.copyWith(
                                bottomLeft: iTileBorderRadius.bottomLeft,
                                bottomRight: iTileBorderRadius.bottomRight,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 52.0, minWidth: double.infinity),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12.0,
                                    children: <Widget>[
                                      amcState is AmcOverviewLoadedState && amcState.amc != null
                                          ? FadeIn(
                                              key: Key('amc_loaded'),
                                              child: Text(
                                                amcState.amc!.name,
                                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            )
                                          : Text(
                                              widget.amcId,
                                              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),

                                      // ~ Chips - if Error
                                      if (amcState.isError)
                                        TinyChip(
                                          title: const Text('Error loading AMC details'),
                                          color: context.colors.error,
                                          titleColor: context.colors.onError,
                                        ),

                                      // ~ Chips (tags) - otherwise
                                      if (!amcState.isError)
                                        Skeletonizer(
                                          enabled: amcState.isLoading || amcState.isInitial,
                                          child: Wrap(
                                            spacing: 6.0,
                                            runSpacing: 4.0,
                                            children: <Widget>[
                                              Skeleton.leaf(
                                                child: TinyChip(
                                                  title: Text(
                                                    amcState is AmcOverviewLoadedState
                                                        ? (amcState.amc?.genre ?? AmcGenre.misc).title
                                                        : 'Loading...', // 'Loading...' text will be replaced by shimmer effect when skeletonizer is enabled
                                                  ),
                                                  color: context.colors.primary,
                                                  titleColor: context.colors.onPrimary,
                                                ),
                                              ),

                                              ..._buildAmcTags(amcState),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Gap(4.0),

                            // ~ Stats Section
                            BlocBuilder<TransactionsCubit, TransactionsState>(
                              builder: (context, trnState) {
                                final isError = trnState.isError;
                                final isLoading = trnState.isLoading;
                                final totalUnits = trnState.transactions?.fold<double>(0.0, (v, el) => v + el.quantity);
                                final totalAmountInvested = trnState.transactions?.fold<double>(
                                  0.0,
                                  (v, el) => v + el.totalAmount,
                                );
                                final totalCurrentValue = totalUnits != null && latestPrice?.price != null
                                    ? totalUnits * latestPrice!.price!
                                    : null;
                                final returns = totalAmountInvested != null && totalCurrentValue != null
                                    ? totalCurrentValue - totalAmountInvested
                                    : 0.0;
                                final transactionsForXirr = trnState.transactions
                                    ?.map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn))
                                    .toList();
                                if (transactionsForXirr != null && transactionsForXirr.isNotEmpty) {
                                  transactionsForXirr.add(
                                    xf.Transaction(
                                      totalCurrentValue != null && totalCurrentValue > 0 ? -totalCurrentValue : -0.0,
                                      latestPrice?.date ?? DateTime.now(),
                                    ),
                                  );
                                }
                                final xirr = transactionsForXirr != null && transactionsForXirr.isNotEmpty
                                    ? xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate()
                                    : 0.0;

                                return Skeletonizer(
                                  enabled: isLoading,
                                  child: Column(
                                    spacing: 4.0,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      // ~ Current value
                                      _SectionWidget(
                                        label: FormattedDate(
                                          date: latestPrice?.date ?? DateTime.now(),
                                          prefix: const Skeleton.keep(child: Text('Current value as of ')),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        value: BlocSelector<AppCubit, AppState, bool>(
                                          selector: (state) => state.isPrivateMode,
                                          builder: (context, isPrivateMode) {
                                            return CurrencyView(
                                              amount: totalCurrentValue ?? 0.0,
                                              style: textTheme.headlineLarge,
                                              decimalsStyle: textTheme.headlineSmall,
                                              currencyStyle: textTheme.bodyMedium,
                                              privateMode: isPrivateMode,
                                              // compactView: snapshot.data! >= 1_00_00_000
                                            );
                                          },
                                        ),
                                        color: isError ? colors.errorContainer : null,
                                        valueColor: isError ? colors.error : null,
                                      ),

                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 4.0,
                                        crossAxisSpacing: 4.0,
                                        mainAxisExtent: 104.0,
                                        children: [
                                          // ~ No. of units section
                                          _SectionWidget(
                                            label: const Skeleton.keep(child: Text('No. of units')),
                                            value: Text(totalUnits?.toString() ?? '...'),
                                            color: isError ? colors.errorContainer : null,
                                            valueColor: isError ? colors.error : null,
                                          ),

                                          // ~ Invested amount section
                                          _SectionWidget(
                                            label: const Skeleton.keep(child: Text('Invested amount')),
                                            value: BlocSelector<AppCubit, AppState, bool>(
                                              selector: (state) => state.isPrivateMode,
                                              builder: (context, isPrivateMode) {
                                                return CurrencyView(
                                                  amount: totalAmountInvested ?? 0.0,
                                                  privateMode: isPrivateMode,
                                                );
                                              },
                                            ),
                                            color: isError ? colors.errorContainer : null,
                                            valueColor: isError ? colors.error : null,
                                          ),

                                          // ~ Latest NAV (Mkt. price) sections
                                          _SectionWidget(
                                            label: Skeleton.keep(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Text('Latest NAV'),
                                                  FormattedDate(
                                                    date: latestPrice?.date ?? DateTime.now(),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: textTheme.labelSmall?.copyWith(color: theme.disabledColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            value: BlocSelector<AppCubit, AppState, bool>(
                                              selector: (state) => state.isPrivateMode,
                                              builder: (context, isPrivateMode) {
                                                return CurrencyView(
                                                  amount: latestPrice?.price ?? 0.0,
                                                  privateMode: isPrivateMode,
                                                );
                                              },
                                            ),
                                            color: isError ? colors.errorContainer : null,
                                            valueColor: isError ? colors.error : null,
                                          ),

                                          // ~ Avg. price section
                                          _SectionWidget(
                                            label: const Skeleton.keep(child: Text('Avg. price')),
                                            value: BlocSelector<AppCubit, AppState, bool>(
                                              selector: (state) => state.isPrivateMode,
                                              builder: (context, isPrivateMode) {
                                                return CurrencyView(
                                                  amount:
                                                      totalAmountInvested != null &&
                                                          totalUnits != null &&
                                                          totalUnits > 0
                                                      ? totalAmountInvested / totalUnits
                                                      : 0.0,
                                                  privateMode: isPrivateMode,
                                                );
                                              },
                                            ),
                                            color: isError ? colors.errorContainer : null,
                                            valueColor: isError ? colors.error : null,
                                          ),

                                          // ~ Total returns sections
                                          _SectionWidget(
                                            label: const Skeleton.keep(child: Text('Total returns')),
                                            value: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                BlocSelector<AppCubit, AppState, bool>(
                                                  selector: (state) => state.isPrivateMode,
                                                  builder: (context, isPrivateMode) {
                                                    return CurrencyView(
                                                      amount: returns,
                                                      privateMode: isPrivateMode,
                                                      style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
                                                    );
                                                  },
                                                ),
                                                Text(
                                                  (totalAmountInvested?.isZero ?? true)
                                                      ? '0.00%'
                                                      : '${(returns / totalAmountInvested! * 100).toPrecision(2)}%',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
                                                ),
                                              ],
                                            ),
                                            color: isError ? colors.errorContainer : null,
                                            valueColor: isError ? colors.error : Colors.teal.shade500,
                                            borderRadius: iTileBorderRadius.copyWith(
                                              bottomLeft: iCardBorderRadius.bottomLeft,
                                            ),
                                          ),

                                          // ~ XIRR section
                                          _SectionWidget(
                                            label: const Skeleton.keep(child: Text('XIRR')),
                                            value: Text(
                                              xirr != null ? '${(xirr * 100).toPrecision(2)}%' : '0.00%',
                                              style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
                                            ),
                                            color: isError ? colors.errorContainer : null,
                                            valueColor: isError ? colors.error : null,
                                            borderRadius: iTileBorderRadius.copyWith(
                                              bottomRight: iCardBorderRadius.bottomRight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Gap(20.0),

                            // ~ Holding Transactions Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8.0,
                              children: <Widget>[
                                const Text('Transactions'),
                                BlocBuilder<TransactionsCubit, TransactionsState>(
                                  builder: (context, trnState) {
                                    final isLoading = trnState.isLoading;
                                    final isError = trnState.isError;
                                    final transactions = trnState.transactions;

                                    if (isError) {
                                      return Text('Some error occurred! Try again later'); // TODO: Redesign this
                                    }

                                    return Skeletonizer(
                                      enabled: isLoading,
                                      child: Section(
                                        margin: EdgeInsets.zero,
                                        tiles: !isLoading
                                            ? (transactions != null && transactions.isNotEmpty)
                                                  ? transactions.map((trn) => _buildTransaction(trn)).toList()
                                                  : [SectionTile(title: const Text('No transactions found'))]
                                            : List.filled(
                                                5,
                                                const SectionTile(
                                                  title: Text('Loading...'),
                                                  subtitle: Text('Loading...'),
                                                  icon: Icon(Icons.north_east_rounded),
                                                  trailingIcon: Text('Loading...'),
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                const InveslyDivider(),
                // ~ Buy/Sell Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    spacing: 16.0,
                    children: <Widget>[
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Sell'),
                        ),
                      ),

                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade500,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Buy'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SectionTile _buildTransaction(InveslyTransaction trn) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SectionTile(
      title: Text('${trn.quantity} units @ ₹${(trn.rate).toPrecision(2)}'),
      subtitle: FormattedDate(
        date: trn.investedOn,
        style: textTheme.labelSmall?.copyWith(color: theme.disabledColor),
      ),
      icon: PhysicalModel(
        shape: BoxShape.circle,
        color: trn.totalAmount > 0 ? Colors.teal.shade50 : Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            trn.totalAmount > 0 ? Icons.north_east_rounded : Icons.south_east_rounded,
            color: trn.totalAmount > 0 ? Colors.teal : Colors.red,
          ),
        ),
      ),
      trailingIcon: BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: trn.totalAmount,
            privateMode: isPrivateMode,
            style: textTheme.titleLarge?.copyWith(color: trn.totalAmount > 0 ? Colors.teal : Colors.red),
          );
        },
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.valueColor,
    this.borderRadius,
    this.contentSpacing,
  });

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

    return PhysicalModel(
      // curve: Curves.fastOutSlowIn,
      // duration: 600.ms,
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      color: color ?? theme.canvasColor.lighten(3),
      shadowColor: theme.colorScheme.shadow,
      borderRadius: borderRadius ?? iTileBorderRadius,
      child: SizedBox(
        height: 96.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: contentSpacing ?? 0.0,
            children: <Widget>[
              labelText,
              Align(alignment: Alignment.centerRight, child: valueText),
            ],
          ),
        ),
      ),
    );
  }
}
