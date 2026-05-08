import 'package:invesly/amcs/model/amc_transaction_model.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';

class AmcOverviewPage extends StatelessWidget {
  const AmcOverviewPage(this.amcId, {super.key});

  final String amcId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AmcOverviewCubit(repository: AmcRepository.instance)),
        BlocProvider(create: (_) => TransactionsCubit(repository: TransactionRepository.instance)),
      ],
      child: BlocSelector<AppCubit, AppState, String?>(
        selector: (state) => state.primaryAccountId,
        builder: (context, accountId) {
          return _AmcOverviewPageContent(amcId: amcId, accountId: accountId);
        },
      ),
    );
  }
}

class _AmcOverviewPageContent extends StatefulWidget {
  const _AmcOverviewPageContent({super.key, required this.amcId, this.accountId});

  final String amcId;
  final String? accountId;

  @override
  State<_AmcOverviewPageContent> createState() => _AmcOverviewPageContentState();
}

class _AmcOverviewPageContentState extends State<_AmcOverviewPageContent> {
  @override
  void initState() {
    super.initState();
    _getAmcOverview();
    _getStats();
  }

  @override
  void didUpdateWidget(covariant _AmcOverviewPageContent oldWidget) {
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
    if (widget.accountId?.isEmpty ?? true) {
      return;
    }

    if (mounted) {
      context.read<TransactionsCubit>().fetchTransactions(accountId: widget.accountId, amcId: widget.amcId);
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

        return SimpleChip(title: Text(tag), color: context.colors.tertiary, titleColor: context.colors.onTertiary);
      }).toList();
    }

    return List.filled(3, const Skeleton.leaf(child: SimpleChip(title: Text('Loading...'))));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    const spacing = 2.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(title: const Text('Holding details'), floating: true, snap: true),

                  // ~ AMC Details & Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                        builder: (context, amcState) {
                          final isAmcLoading = amcState is AmcOverviewLoadingState;
                          return Column(
                            spacing: spacing,
                            children: <Widget>[
                              // ~ AMC Details
                              SimpleCard(
                                color: colors.primaryContainer.darken(3.0),
                                elevation: 0.0,
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
                                        // ~ Amc Name
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
                                          SimpleChip(
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
                                                  child: SimpleChip(
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

                              // ~ Stats Section
                              BlocBuilder<TransactionsCubit, TransactionsState>(
                                builder: (context, trnState) {
                                  final isTrnError = trnState.isError;
                                  final isTrnLoading = trnState.isLoading;
                                  final latestPrice = amcState is AmcOverviewLoadedState ? amcState.amc?.ltp : null;
                                  final amcTrn =
                                      trnState.isLoaded && amcState is AmcOverviewLoadedState && amcState.amc != null
                                      ? AmcTransaction(amc: amcState.amc, transactions: trnState.transactions)
                                      : null;

                                  return Skeletonizer(
                                    enabled: isTrnLoading,
                                    child: Column(
                                      spacing: spacing,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          mainAxisSpacing: spacing,
                                          crossAxisSpacing: spacing,
                                          mainAxisExtent: 104.0,
                                          children: <Widget>[
                                            // ~ No. of units section
                                            _SectionWidget(
                                              label: const Skeleton.keep(child: Text('No. of units')),
                                              value: isTrnLoading
                                                  ? const Text('Loading...')
                                                  : Text('${amcTrn?.totalUnits.toPrecision(4)}'),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                            ),

                                            // ~ Avg. price section
                                            _SectionWidget(
                                              label: const Skeleton.keep(child: Text('Avg. price')),
                                              value: isTrnLoading
                                                  ? const Text('Loading...')
                                                  : BlocSelector<AppCubit, AppState, bool>(
                                                      selector: (state) => state.isPrivateMode,
                                                      builder: (context, isPrivateMode) {
                                                        return CurrencyView(
                                                          amount: amcTrn?.averageBuyPrice ?? 0.0,
                                                          privateMode: isPrivateMode,
                                                        );
                                                      },
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                            ),

                                            // ~ Invested amount section
                                            _SectionWidget(
                                              label: const Skeleton.keep(child: Text('Invested amount')),
                                              value: isTrnLoading
                                                  ? const Text('Loading...')
                                                  : BlocSelector<AppCubit, AppState, bool>(
                                                      selector: (state) => state.isPrivateMode,
                                                      builder: (context, isPrivateMode) {
                                                        return CurrencyView(
                                                          amount: amcTrn?.totalInvested ?? 0,
                                                          privateMode: isPrivateMode,
                                                        );
                                                      },
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                            ),

                                            // ~ Current value
                                            _SectionWidget(
                                              label: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Text('Current value'),
                                                  isTrnLoading
                                                      ? const Text('Loading...')
                                                      : FormattedDate(
                                                          date: latestPrice?.date ?? DateTime.now(),
                                                          overflow: TextOverflow.ellipsis,
                                                          style: textTheme.labelSmall?.copyWith(
                                                            color: context.theme.disabledColor,
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              value: isTrnLoading
                                                  ? Text('Loading...')
                                                  : BlocSelector<AppCubit, AppState, bool>(
                                                      selector: (state) => state.isPrivateMode,
                                                      builder: (context, isPrivateMode) {
                                                        return CurrencyView(
                                                          amount: amcTrn?.totalCurrentValue ?? 0.0,
                                                          style: textTheme.headlineLarge,
                                                          decimalsStyle: textTheme.headlineSmall,
                                                          currencyStyle: textTheme.bodyMedium,
                                                          privateMode: isPrivateMode,
                                                          // compactView: snapshot.data! >= 1_00_00_000
                                                        );
                                                      },
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                            ),

                                            // ~ Latest NAV (Mkt. price) sections
                                            _SectionWidget(
                                              label: Skeleton.keep(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    const Text('Latest NAV'),
                                                    isAmcLoading
                                                        ? const Text('Loading...')
                                                        : FormattedDate(
                                                            date: latestPrice?.date ?? DateTime.now(),
                                                            overflow: TextOverflow.ellipsis,
                                                            style: textTheme.labelSmall?.copyWith(
                                                              color: context.theme.disabledColor,
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              value: isAmcLoading
                                                  ? const Text('Loading...')
                                                  : BlocSelector<AppCubit, AppState, bool>(
                                                      selector: (state) => state.isPrivateMode,
                                                      builder: (context, isPrivateMode) {
                                                        return CurrencyView(
                                                          amount: latestPrice?.price ?? 0.0,
                                                          privateMode: isPrivateMode,
                                                        );
                                                      },
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                            ),

                                            // ~ Amount return sections
                                            _SectionWidget(
                                              label: const Skeleton.keep(child: Text('Return')),
                                              value: isTrnLoading
                                                  ? const Text('Loading...')
                                                  : BlocSelector<AppCubit, AppState, bool>(
                                                      selector: (state) => state.isPrivateMode,
                                                      builder: (context, isPrivateMode) {
                                                        final returns = amcTrn?.amountReturn;
                                                        return CurrencyView(
                                                          amount: returns ?? 0.0,
                                                          privateMode: isPrivateMode,
                                                          style: TextStyle(
                                                            color: returns?.isNegative ?? true
                                                                ? Colors.red
                                                                : Colors.teal,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                            ),

                                            // ~ Percentage returns sections
                                            _SectionWidget(
                                              label: const Skeleton.keep(child: Text('Total returns')),
                                              value: isTrnLoading
                                                  ? const Text('Loading...')
                                                  : Text(
                                                      '${amcTrn?.percentageReturn?.toPrecision(2) ?? 0}%',
                                                      textAlign: TextAlign.right,
                                                      style: TextStyle(
                                                        color: amcTrn?.percentageReturn?.isNegative ?? true
                                                            ? Colors.red
                                                            : Colors.teal,
                                                      ),
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
                                              borderRadius: iTileBorderRadius.copyWith(
                                                bottomLeft: iCardBorderRadius.bottomLeft,
                                              ),
                                            ),

                                            // ~ XIRR section
                                            _SectionWidget(
                                              label: const Skeleton.keep(child: Text('XIRR')),
                                              value: isTrnLoading
                                                  ? const Text('Loading...')
                                                  : Text(
                                                      '${((amcTrn?.xirr ?? 0) * 100).toPrecision(2)}%',
                                                      style: TextStyle(
                                                        color: amcTrn?.xirr?.isNegative ?? true
                                                            ? Colors.red
                                                            : Colors.teal,
                                                      ),
                                                    ),
                                              color: isTrnError ? colors.errorContainer : null,
                                              valueColor: isTrnError ? colors.error : null,
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
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // ~ Holding Transactions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text('Transactions'),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: BlocBuilder<TransactionsCubit, TransactionsState>(
                      builder: (context, trnState) {
                        final isLoading = trnState.isLoading;
                        final isError = trnState.isError;
                        final isLoaded = trnState.isLoaded;

                        if (isError) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                'Some error occurred! Try again later.',
                                style: TextStyle(color: context.colors.error),
                              ),
                            ),
                          );
                        }

                        if (isLoaded && trnState.transactions.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: EmptyWidget(
                                label: Text('This is so empty.\n Add some transactions to see stats here.'),
                              ),
                            ),
                          );
                        }

                        final transactions = trnState.transactions;
                        return SliverSkeletonizer(
                          enabled: isLoading,
                          child: SliverList.separated(
                            itemCount: isLoaded ? transactions.length : 2, // Show 2 skeleton cards while loading
                            itemBuilder: (context, index) {
                              final trn = isLoaded ? transactions[index] : null;
                              return _buildTransaction(trn);
                            },
                            separatorBuilder: (_, _) => const Gap(2.0),
                          ),
                        );
                      },
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
  }

  Widget _buildTransaction(InveslyTransaction? trn) {
    final textTheme = context.textTheme;

    return SectionTile(
      title: trn != null ? Text('${trn.quantity} units @ ₹${(trn.rate).toPrecision(2)}') : const Text('Loading...'),
      subtitle: trn != null
          ? FormattedDate(
              date: trn.investedOn,
              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
            )
          : const Text('Loading...'),
      icon: PhysicalModel(
        shape: BoxShape.circle,
        color: (trn?.totalAmount.isNegative ?? false) ? Colors.red.shade50 : Colors.teal.shade50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: trn != null
              ? Icon(
                  trn.totalAmount.isNegative ? Icons.south_east_rounded : Icons.north_east_rounded,
                  color: trn.totalAmount.isNegative ? Colors.red : Colors.teal,
                )
              : const Bone.icon(),
        ),
      ),
      secondaryIcon: trn != null
          ? BlocSelector<AppCubit, AppState, bool>(
              selector: (state) => state.isPrivateMode,
              builder: (context, isPrivateMode) {
                return CurrencyView(
                  amount: trn.totalAmount,
                  privateMode: isPrivateMode,
                  style: textTheme.titleLarge?.copyWith(color: trn.totalAmount > 0 ? Colors.teal : Colors.red),
                );
              },
            )
          : Text('Loading...', style: textTheme.titleLarge),
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

    return SimpleCard(
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
              Align(alignment: Alignment.bottomRight, child: valueText),
            ],
          ),
        ),
      ),
    );
  }
}
