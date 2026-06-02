import 'dart:math' as math;

import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'package:invesly/amc_stat/cubit/amc_stat_cubit.dart';
import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_xirr_model.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';

class AmcOverviewPage extends StatefulWidget {
  const AmcOverviewPage({super.key, required this.amcId, required this.accountId});

  final String amcId;
  final String accountId;

  @override
  State<AmcOverviewPage> createState() => _AmcOverviewPageState();
}

class _AmcOverviewPageState extends State<AmcOverviewPage> {
  @override
  void initState() {
    super.initState();
    final statCubit = context.read<AmcStatCubit>();
    if (!statCubit.state.isLoaded) {
      statCubit.fetchAllStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar(
              title: Text('Holding details', overflow: TextOverflow.ellipsis),
              floating: true,
              snap: true,
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
                  final stat = statState.getStat(accountId: widget.accountId, amcId: widget.amcId);

                  if (stat == null) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyWidget(
                        label: Text(
                          'This is so empty!\nAdd some transactions to see stats here.',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }

                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(create: (_) => AmcOverviewCubit(stat: stat)..getLatestPrice()),
                      BlocProvider(
                        create: (_) =>
                            TransactionsCubit(repository: TransactionRepository.instance)
                              ..fetchTransactions(accountId: widget.accountId, amcId: widget.amcId),
                      ),
                    ],
                    child: _AmcOverviewPageContent(),
                  );
                }

                return SliverToBoxAdapter(
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(color: context.colors.primary, size: 48.0),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // ),
    );
  }
}

class _AmcOverviewPageContent extends StatefulWidget {
  const _AmcOverviewPageContent({super.key});

  @override
  State<_AmcOverviewPageContent> createState() => _AmcOverviewPageContentState();
}

class _AmcOverviewPageContentState extends State<_AmcOverviewPageContent> {
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: <Widget>[
        // ~ AMC Details & Stats
        SliverToBoxAdapter(child: _AmcOverviewSection()),

        // ~ Holding Transactions Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 4.0),
            child: Text('Transactions', style: context.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
          ),
        ),

        // ~ Transactions list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          sliver: BlocBuilder<TransactionsCubit, TransactionsState>(
            builder: (context, trnState) {
              if (trnState.isError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Some error occurred! Try again later.',
                      style: TextStyle(color: context.colors.error),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }

              if (trnState.isLoaded) {
                if (trnState.transactions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyWidget(
                      label: Text(
                        'This is so empty.\n Add some transactions to see stats here.',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }

                final transactions = trnState.transactions;
                final itemCount = transactions.length;
                return SliverList.separated(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final trn = transactions[index];
                    return _buildTransaction(context, trn, isFirst: index == 0, isLast: index == itemCount - 1);
                  },
                  separatorBuilder: (_, _) => const Gap(2.0),
                );
              }

              final numTransactions = context.read<AmcOverviewCubit>().state.stat.numTransactions;
              return SliverToBoxAdapter(
                child: Skeletonizer(
                  child: Section(
                    tiles: List.generate(math.min(numTransactions, 3), (_) {
                      return const SectionTile(
                        title: Text('Loading...'),
                        subtitle: Text('Loading...'),
                        icon: Bone.circle(size: 32.0),
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      );
                    }),
                    margin: EdgeInsets.zero,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransaction(BuildContext context, InveslyTransaction trn, {bool? isFirst, bool? isLast}) {
    final textTheme = context.textTheme;
    BorderRadius tileRadius = iTileBorderRadius;

    if (isFirst ?? false) {
      tileRadius = tileRadius.copyWith(topLeft: iCardBorderRadius.topLeft, topRight: iCardBorderRadius.topRight);
    }

    if (isLast ?? false) {
      tileRadius = tileRadius.copyWith(
        bottomLeft: iCardBorderRadius.bottomLeft,
        bottomRight: iCardBorderRadius.bottomRight,
      );
    }

    return SectionTile(
      title: FormattedDate(
        date: trn.investedOn,
        style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
      ),
      subtitle: Text(
        '${trn.quantity?.toPrecision(2) ?? ''} units | ₹${trn.rate?.toPrecision(2)}',
        overflow: TextOverflow.ellipsis,
      ), // TODO: Fix this
      icon: PhysicalModel(
        shape: BoxShape.circle,
        color: trn.totalAmount.isNegative ? Colors.red.lighten(60) : Colors.teal.lighten(60),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            trn.totalAmount.isNegative ? Icons.south_east_rounded : Icons.north_east_rounded,
            color: trn.totalAmount.isNegative ? Colors.red : Colors.teal,
          ),
        ),
      ),
      secondaryIcon: BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: trn.totalAmount,
            privateMode: isPrivateMode,
            style: textTheme.titleLarge?.copyWith(color: trn.totalAmount > 0 ? Colors.teal : Colors.red),
          );
        },
      ),
      borderRadius: tileRadius,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    );
  }
}

class _AmcOverviewSection extends StatelessWidget {
  const _AmcOverviewSection({super.key});

  static const double _spacing = 2.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        spacing: _spacing,
        mainAxisSize: MainAxisSize.min,
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
                child: BlocSelector<AmcOverviewCubit, AmcOverviewState, AmcStat>(
                  selector: (state) => state.stat,
                  builder: (context, stat) {
                    final amc = stat.amc;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.0,
                      children: <Widget>[
                        // ~ Amc Name
                        Text(
                          amc.name,
                          style: textTheme.titleLarge,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),

                        // ~ Chips (tags)
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: <Widget>[
                            if (amc.genre != null)
                              SimpleChip(
                                title: Text(amc.genre!.title, overflow: TextOverflow.ellipsis),
                                color: context.colors.primary,
                                titleColor: context.colors.onPrimary,
                              ),

                            if (amc.tags != null && amc.tags!.isNotEmpty)
                              ...amc.tags!.map((tag) {
                                if (tag.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return SimpleChip(
                                  title: Text(tag, overflow: TextOverflow.ellipsis),
                                  color: context.colors.tertiary,
                                  titleColor: context.colors.onTertiary,
                                );
                              }),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          BlocSelector<AmcOverviewCubit, AmcOverviewState, LatestPriceStatus>(
            selector: (state) => state.ltpStatus,
            builder: (context, ltpStatus) {
              $logger.w('==== Rebuilding state because ltpStatus is updating ====');
              return Skeletonizer(
                enabled: [LatestPriceStatus.initial, LatestPriceStatus.loading].contains(ltpStatus),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: _spacing,
                  crossAxisSpacing: _spacing,
                  mainAxisExtent: 96.0,
                  children: <Widget>[
                    // ~ No. of units
                    Skeleton.keep(
                      child: _SectionWidget(
                        label: const Text('Available units', overflow: TextOverflow.ellipsis),
                        value: BlocSelector<AmcOverviewCubit, AmcOverviewState, AmcStat>(
                          selector: (state) => state.stat,
                          builder: (context, stat) {
                            return Text('${stat.totalQuantity.toPrecision(4)}', overflow: TextOverflow.ellipsis);
                          },
                        ),
                      ),
                    ),

                    // ~ Avg. price
                    Skeleton.keep(
                      child: _SectionWidget(
                        label: const Text('Average price', overflow: TextOverflow.ellipsis),
                        value: BlocSelector<AmcOverviewCubit, AmcOverviewState, AmcStat>(
                          selector: (state) => state.stat,
                          builder: (context, stat) {
                            return BlocSelector<AppCubit, AppState, bool>(
                              selector: (state) => state.isPrivateMode,
                              builder: (context, isPrivate) {
                                return CurrencyView(amount: stat.averageBuyPrice, privateMode: isPrivate);
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // ~ Invested amount
                    Skeleton.keep(
                      child: BlocSelector<AmcOverviewCubit, AmcOverviewState, AmcStat>(
                        selector: (state) => state.stat,
                        builder: (context, stat) {
                          return _SectionWidget(
                            label: const Text('Invested amount', overflow: TextOverflow.ellipsis),
                            value: BlocSelector<AppCubit, AppState, bool>(
                              selector: (state) => state.isPrivateMode,
                              builder: (context, isPrivate) {
                                return CurrencyView(amount: stat.totalInvested, privateMode: isPrivate);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // ~ Latest NAV (Mkt. price) sections
                    BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                      buildWhen: (prev, curr) {
                        return prev.stat != curr.stat || prev.ltp != curr.ltp;
                      },
                      builder: (context, state) {
                        final isError = state.isLtpError;
                        return _SectionWidget(
                          label: Skeleton.keep(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Latest NAV', overflow: TextOverflow.ellipsis),
                                FormattedDate(
                                  date: state.ltp?.date ?? DateTime.now(),
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                          value: () {
                            if (isError) return const Text('N/A', overflow: TextOverflow.ellipsis);

                            if (state.isLtpLoaded && state.ltp != null) {
                              return BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(amount: state.ltp!.price, privateMode: isPrivate);
                                },
                              );
                            }

                            return const Text('Loading...', overflow: TextOverflow.ellipsis);
                          }(),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : null,
                        );
                      },
                    ),

                    // ~ Current value
                    BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                      buildWhen: (prev, curr) {
                        return prev.stat != curr.stat || prev.ltp != curr.ltp;
                      },
                      builder: (context, state) {
                        final isError = state.isLtpError;
                        return _SectionWidget(
                          label: Skeleton.keep(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Current value', overflow: TextOverflow.ellipsis),
                                FormattedDate(
                                  date: state.ltp?.date ?? DateTime.now(),
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                          value: () {
                            if (isError) return const Text('N/A', overflow: TextOverflow.ellipsis);

                            if (state.isLtpLoaded && state.ltp != null) {
                              final color = (state.amountReturn?.isNegative ?? true) ? Colors.red : Colors.teal;

                              return BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivateMode) {
                                  return CurrencyView(
                                    amount: state.totalCurrentValue ?? 0.0,
                                    style: textTheme.headlineLarge?.copyWith(color: color),
                                    decimalsStyle: textTheme.headlineSmall?.copyWith(color: color),
                                    currencyStyle: textTheme.bodyMedium?.copyWith(color: color),
                                    privateMode: isPrivateMode,

                                    // compactView: snapshot.data! >= 1_00_00_000
                                  );
                                },
                              );
                            }

                            return const Text('Loading...', overflow: TextOverflow.ellipsis);
                          }(),
                          color: state.isLtpError ? colors.errorContainer : null,
                          valueColor: state.isLtpError ? colors.error : null,
                        );
                      },
                    ),

                    // ~ Amount return sections
                    BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                      buildWhen: (prev, curr) {
                        return prev.stat != curr.stat || prev.ltp != curr.ltp;
                      },
                      builder: (context, state) {
                        final isError = state.isLtpError;
                        return _SectionWidget(
                          label: Skeleton.keep(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Return', overflow: TextOverflow.ellipsis),
                                FormattedDate(
                                  date: state.ltp?.date ?? DateTime.now(),
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                          value: () {
                            if (isError) return const Text('N/A', overflow: TextOverflow.ellipsis);

                            if (state.isLtpLoaded && state.ltp != null) {
                              final returns = state.amountReturn;
                              return BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivateMode) {
                                  return CurrencyView(
                                    amount: returns ?? 0.0,
                                    privateMode: isPrivateMode,
                                    style: TextStyle(color: (returns?.isNegative ?? true) ? Colors.red : Colors.teal),
                                  );
                                },
                              );
                            }

                            return const Text('Loading...', overflow: TextOverflow.ellipsis);
                          }(),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : null,
                        );
                      },
                    ),

                    // ~ Percentage returns sections
                    BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                      buildWhen: (prev, curr) {
                        return prev.stat != curr.stat || prev.ltp != curr.ltp;
                      },
                      builder: (context, state) {
                        final isError = state.isLtpError;
                        return _SectionWidget(
                          label: Skeleton.keep(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text('Total returns', overflow: TextOverflow.ellipsis),
                                FormattedDate(
                                  date: state.ltp?.date ?? DateTime.now(),
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                          value: () {
                            if (isError) return Text('N/A', overflow: TextOverflow.ellipsis);

                            if (state.isLtpLoaded && state.ltp != null) {
                              final returns = state.percentageReturn;
                              return Text(
                                '${returns?.toPrecision(2) ?? 0}%',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(color: (returns?.isNegative ?? true) ? Colors.red : Colors.teal),
                              );
                            }

                            return const Text('Loading...', overflow: TextOverflow.ellipsis);
                          }(),
                          color: isError ? colors.errorContainer : null,
                          valueColor: isError ? colors.error : null,
                          borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                        );
                      },
                    ),

                    // ~ XIRR section
                    BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                      buildWhen: (prev, curr) {
                        return prev.stat != curr.stat || prev.ltp != curr.ltp;
                      },
                      builder: (context, amcState) {
                        final isLtpError = amcState.isLtpError;
                        return _SectionWidget(
                          label: Skeleton.keep(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('XIRR', overflow: TextOverflow.ellipsis),
                                FormattedDate(
                                  date: amcState.ltp?.date ?? DateTime.now(),
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                          value: () {
                            if (isLtpError) return Text('N/A', overflow: TextOverflow.ellipsis);

                            if (amcState.isLtpLoaded && amcState.ltp != null) {
                              return BlocBuilder<TransactionsCubit, TransactionsState>(
                                builder: (context, trnState) {
                                  if (trnState.isError) {
                                    return Text(
                                      'N/A',
                                      style: TextStyle(color: colors.error),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }

                                  if (trnState.isLoaded) {
                                    final transactionsForXirr = trnState.transactions
                                        .map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn))
                                        .toList();
                                    if (transactionsForXirr.isNotEmpty) {
                                      transactionsForXirr.add(
                                        xf.Transaction(
                                          -(amcState.totalCurrentValue!),
                                          amcState.ltp!.date ?? amcState.ltp!.fetchDate,
                                        ),
                                      );
                                    }
                                    double? xirr = 0.0;
                                    if (transactionsForXirr.isNotEmpty) {
                                      try {
                                        xirr = xf.XirrFlutter.withTransactionsAndGuess(
                                          transactionsForXirr,
                                          0.1,
                                        ).calculate()?.toPrecisionDouble(4);
                                      } catch (e) {
                                        debugPrint('Error calculating XIRR: $e');
                                      }
                                    }

                                    // Save xirr in database
                                    if (xirr != null) {
                                      final latestXirr = LatestXirr(value: xirr, date: DateTime.now().startOfDay);
                                      AmcRepository.instance.saveXirr(amcState.stat.amc, latestXirr);
                                    }

                                    return Text(
                                      xirr != null ? '${(xirr * 100).toPrecision(2)}%' : '0.00%',
                                      style: TextStyle(color: (xirr?.isNegative ?? true) ? Colors.red : Colors.teal),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }

                                  return LoadingAnimationWidget.staggeredDotsWave(
                                    size: 32.0,
                                    color: context.colors.primary,
                                  );
                                },
                              );
                            }

                            return const Text('Loading...', overflow: TextOverflow.ellipsis);
                          }(),
                          color: isLtpError ? colors.errorContainer : null,
                          valueColor: isLtpError ? colors.error : null,
                          borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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

    return SimpleCard(
      elevation: 0.0,
      color: color ?? theme.canvasColor.lighten(3),
      shadowColor: theme.colorScheme.shadow,
      borderRadius: borderRadius ?? iTileBorderRadius,
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
    );
  }
}
