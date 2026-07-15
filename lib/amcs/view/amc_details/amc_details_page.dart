import 'package:invesly/stat/model/stat_repository.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_page.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_details/cubit/amc_details_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/components/add_transaction_button.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common/presentations/widgets/simple_chip.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/stat/cubit/stat_cubit.dart';
import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

class AmcOverviewPage extends StatefulWidget {
  const AmcOverviewPage({super.key, required this.amcId, required this.accountId});

  final String amcId;
  final int accountId;

  @override
  State<AmcOverviewPage> createState() => _AmcOverviewPageState();
}

class _AmcOverviewPageState extends State<AmcOverviewPage> {
  late final ScrollController _scrollController;
  late final InveslyStat? stat; // This is required only when transaction state becomes error

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final statState = context.read<StatCubit>().state;
    if (statState.isLoaded) {
      stat = statState.getStat(accountId: widget.accountId, amcId: widget.amcId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return AmcOverviewCubit(
          amcRepository: AmcRepository.instance,
          trnRepository: TransactionRepository.instance,
          accountId: widget.accountId,
          amcId: widget.amcId,
        )..fetchOverview();
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              const SliverAppBar(
                title: Text('Holding details', overflow: TextOverflow.ellipsis),
                floating: true,
                snap: true,
              ),

              // ~ AMC Details & Stats
              SliverToBoxAdapter(child: _AmcOverviewSection(stat: stat)),

              // ~ Transactions title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 4.0),
                  child: Text('Transactions', style: context.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
                ),
              ),

              // ~ Transactions list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                sliver: _Transactions(stat: stat),
              ),

              // ~ Space in bottom
              const SliverGap(64.0),
            ],
          ),
        ),

        // ~~~ Add transaction button ~~~
        floatingActionButton: Builder(
          builder: (context) {
            return AddTransactionButton(
              scrollController: _scrollController,
              onPressed: () {
                final state = context.read<AmcOverviewCubit>().state;
                context.push(EditTransactionPage(initialAccountId: state.accountId, initialAmc: state.amc));
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _AmcOverviewSection extends StatelessWidget {
  const _AmcOverviewSection({super.key, this.stat});

  final InveslyStat? stat;

  static const double _spacing = 2.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
        builder: (context, state) {
          double? totalQnty = stat?.totalQnty,
              avgBuyPrice = stat?.averageBuyPrice,
              totalInvested = stat?.totalInvested,
              ltp,
              currentValue,
              amountReturn,
              perReturn,
              xirr;

          if (state.isTrnLoaded) {
            totalQnty = state.totalQnty;
            avgBuyPrice = state.averageBuyPrice;
            totalInvested = state.totalInvested;

            if (state.isLtpLoaded && state.ltp != null) {
              ltp = state.ltp!.price;
              currentValue = state.currentValue;
              amountReturn = state.amountReturn;
              perReturn = state.perReturn;

              if (state.transactions.isNotEmpty) {
                final transactionsForXirr = state.transactions
                    .map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn))
                    .toList();
                if (transactionsForXirr.isNotEmpty && currentValue != null) {
                  transactionsForXirr.add(xf.Transaction(-currentValue, state.ltp!.date ?? state.ltp!.fetchDate));
                }
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
              }
            }

            // ~ Save data in database if calculated data is different from stat of StatTable
            final nStat = StatInDb(
              accountId: state.accountId,
              amcId: state.amcId,
              numTrns: state.transactions.length,
              totalQnty: state.totalQnty,
              totalInvested: state.totalInvested,
              totalRedeemed: state.totalRedeemed,
              xirr: xirr,
            );

            if (nStat.accountId != stat?.accountId ||
                nStat.amcId != stat?.amcId ||
                nStat.numTrns != stat?.numTrns ||
                nStat.totalQnty != stat?.totalQnty ||
                nStat.totalInvested != stat?.totalInvested ||
                nStat.totalRedeemed != stat?.totalRedeemed ||
                nStat.xirr != stat?.xirr) {
              $logger.i('Saving new stat for $nStat');
              StatRepository.instance.saveStat(nStat);
            }
          }

          final color = amountReturn != null
              ? amountReturn.isNegative
                    ? Colors.red
                    : Colors.teal
              : null;

          return Skeletonizer(
            enabled: state.isTrnLoading || state.isAmcLoading || state.isLtpLoading,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12.0,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // ~ Amc Name
                          state.isAmcLoaded
                              ? FadeIn(
                                  key: Key('amc_loaded'),
                                  child: Text(
                                    state.amc?.name ?? stat?.amc.name ?? state.amcId,
                                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                )
                              : Bone.text(),
                          // ~ Chips
                          _buildTags(context),
                        ],
                      ),
                    ),
                  ),
                ),

                // ~ Stats Section
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: _spacing,
                  crossAxisSpacing: _spacing,
                  mainAxisExtent: 104.0,
                  children: <Widget>[
                    // ~ No. of units
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: const Text('Available units', overflow: TextOverflow.ellipsis, maxLines: 1),
                        value: Text('${totalQnty?.toPrecision(4) ?? "N/A"}', overflow: TextOverflow.ellipsis),
                        color: (state.isTrnError && totalQnty == null) ? colors.errorContainer : null,
                        valueColor: (state.isTrnError && totalQnty == null) ? colors.error : null,
                      ),
                    ),

                    // ~ Avg. price
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: const Text('Average price', overflow: TextOverflow.ellipsis),
                        value: avgBuyPrice != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(amount: avgBuyPrice!, privateMode: isPrivate);
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: (state.isTrnError && avgBuyPrice == null) ? colors.errorContainer : null,
                        valueColor: (state.isTrnError && avgBuyPrice == null) ? colors.error : null,
                      ),
                    ),

                    // ~ Invested amount
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: const Text('Invested amount', overflow: TextOverflow.ellipsis),
                        value: totalInvested != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(amount: totalInvested!, privateMode: isPrivate);
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: (state.isTrnError && totalInvested == null) ? colors.errorContainer : null,
                        valueColor: (state.isTrnError && totalInvested == null) ? colors.error : null,
                      ),
                    ),

                    // ~ Latest NAV (Mkt. price) sections
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('Latest NAV', overflow: TextOverflow.ellipsis),
                            FormattedDate(
                              date: state.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: ltp != null
                            ? CurrencyView(amount: ltp)
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: state.isLtpError ? colors.errorContainer : null,
                        valueColor: state.isLtpError ? colors.error : null,
                      ),
                    ),

                    // ~ Current value
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('Current value', overflow: TextOverflow.ellipsis),
                            FormattedDate(
                              date: state.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: currentValue != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(
                                    amount: currentValue!,
                                    privateMode: isPrivate,
                                    style: textTheme.headlineLarge?.copyWith(color: color),
                                    decimalsStyle: textTheme.headlineSmall?.copyWith(color: color),
                                    currencyStyle: textTheme.bodyMedium,
                                  );
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: (state.isLtpError && currentValue == null) ? colors.errorContainer : null,
                        valueColor: (state.isLtpError && currentValue == null) ? colors.error : null,
                      ),
                    ),

                    // ~ Amount return sections
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('Return', overflow: TextOverflow.ellipsis),
                            FormattedDate(
                              date: state.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: amountReturn != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(
                                    amount: amountReturn!,
                                    privateMode: isPrivate,
                                    style: TextStyle(color: color),
                                  );
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: (state.isLtpError && amountReturn == null) ? colors.errorContainer : null,
                        valueColor: (state.isLtpError && amountReturn == null) ? colors.error : null,
                      ),
                    ),

                    // ~ Percentage returns sections
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('Total returns', overflow: TextOverflow.ellipsis),
                            FormattedDate(
                              date: state.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: Text(
                          perReturn?.toPrecisionString(2) ?? 'N/A',
                          style: TextStyle(color: color),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        color: (state.isLtpError && perReturn == null) ? colors.errorContainer : null,
                        valueColor: (state.isLtpError && perReturn == null) ? colors.error : null,
                        borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                      ),
                    ),

                    // ~ XIRR section
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text('XIRR', overflow: TextOverflow.ellipsis),
                            FormattedDate(
                              date: state.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: Text(
                          xirr != null ? '${(xirr * 100).toPrecision(2)}%' : 'N/A',
                          style: TextStyle(color: xirr != null ? color : null),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        color: (state.isLtpError && xirr == null) ? colors.errorContainer : null,
                        valueColor: (state.isLtpError && xirr == null) ? colors.error : null,
                        borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        //   );
        // },
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    final state = context.read<AmcOverviewCubit>().state;

    // ~ if Error
    if (state.isAmcError) {
      return SimpleChip(
        color: context.colors.error,
        titleColor: context.colors.onError,
        child: const Text('Error loading AMC details'),
      );
    }

    // ~ otherwise
    if (state.isAmcLoaded && state.amc != null) {
      final amc = state.amc!;
      return Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: <Widget>[
          BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountsState) {
              InveslyAccount? account;
              if (accountsState is AccountsLoadedState && accountsState.accounts.isNotEmpty) {
                account = accountsState.accounts.firstWhereOrNull((a) => a.id == state.accountId);
              }
              if (account == null) return SizedBox.shrink();

              return SimpleChip(
                color: context.colors.primary,
                titleColor: context.colors.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                icon: Icon(Icons.account_circle_rounded, size: 16.0, color: context.colors.onPrimary),
                child: Text(account.name, overflow: TextOverflow.ellipsis),
              );
            },
          ),

          if (amc.genre != null)
            SimpleChip(
              color: context.colors.tertiary,
              titleColor: context.colors.onTertiary,
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(amc.genre!.title, overflow: TextOverflow.ellipsis),
            ),

          if (amc.tags != null && amc.tags!.isNotEmpty)
            ...amc.tags!.map((tag) {
              if (tag.isEmpty) {
                return const SizedBox.shrink();
              }

              return SimpleChip(
                color: context.colors.tertiary,
                titleColor: context.colors.onTertiary,
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(tag, overflow: TextOverflow.ellipsis),
              );
            }),
        ],
      );
    }

    // ~ Loading
    return Skeletonizer(
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: List.generate(3, (_) {
          return const Skeleton.leaf(
            child: SimpleChip(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text('Loading..', overflow: TextOverflow.ellipsis),
            ),
          );
        }),
      ),
    );
  }
}

class _Transactions extends StatelessWidget {
  const _Transactions({super.key, this.stat});

  final InveslyStat? stat;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: <Widget>[
        BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
          builder: (context, state) {
            // ~ Error state
            if (state.isTrnError) {
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

            // ~ Loaded state
            if (state.isTrnLoaded) {
              final transactions = state.transactions;
              if (transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyWidget(
                    label: Text(
                      'This is so empty.\n Add some transactions to see stats here.',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }

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

            // ~ Loading state
            final numTrns = stat?.numTrns ?? 3;
            return SliverToBoxAdapter(
              child: Skeletonizer(
                child: Section(
                  tiles: List.generate(numTrns, (_) {
                    return const SectionTile(
                      title: Text('Loading...'),
                      subtitle: Text('Loading...'),
                      icon: Bone.circle(size: 40.0),
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    );
                  }),
                  margin: EdgeInsets.zero,
                ),
              ),
            );
          },
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

    final color = trn.totalAmount.isNegative ? Colors.red : Colors.teal;

    return SectionTile(
      title: FormattedDate(date: trn.investedOn),
      subtitle: Text(
        '${trn.quantity?.toPrecision(2) ?? ''} units | ₹${trn.rate?.toPrecision(2)}',
        overflow: TextOverflow.ellipsis,
      ),
      icon: PhysicalModel(
        shape: BoxShape.circle,
        color: color.lighten(75),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(trn.totalAmount.isNegative ? Icons.south_east_rounded : Icons.north_east_rounded, color: color),
        ),
      ),
      secondaryIcon: BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: trn.totalAmount,
            privateMode: isPrivateMode,
            style: textTheme.titleLarge?.copyWith(color: color),
          );
        },
      ),
      borderRadius: tileRadius,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      onTap: () => context.push(EditTransactionPage(initialTransaction: trn)),
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
      color: color ?? theme.canvasColor,
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
