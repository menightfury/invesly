import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
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
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';

class AmcOverviewPage extends StatefulWidget {
  const AmcOverviewPage({super.key, required this.amcId, required this.accountId});

  final String amcId;
  final int accountId;

  @override
  State<AmcOverviewPage> createState() => _AmcOverviewPageState();
}

class _AmcOverviewPageState extends State<AmcOverviewPage> {
  late final ScrollController _scrollController;
  InveslyStat? stat; // for Fallback

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // final statCubit = context.read<StatCubit>();
    // if (!statCubit.state.isLoaded) {
    //   statCubit.fetchAllStats();
    // }
    // This is required to display data when getting transaction details fails
    final statState = context.read<StatCubit>().state;
    if (statState is StatLoadedState) {
      stat = statState.getStat(accountId: widget.accountId, amcId: widget.amcId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            const SliverAppBar(
              title: Text('Holding details', overflow: TextOverflow.ellipsis),
              floating: true,
              snap: true,
            ),

            // ~ Content
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) {
                    return AmcOverviewCubit(
                      amcRepository: AmcRepository.instance,
                      trnRepository: TransactionRepository.instance,
                      accountId: widget.accountId,
                      amcId: widget.amcId,
                    )..fetchOverview();
                  },
                ),
                // BlocProvider(
                //   create: (_) {
                //     return TransactionsCubit(repository: TransactionRepository.instance)
                //       ..fetchTransactions(accountId: widget.accountId, amcId: widget.amcId);
                //   },
                // ),
              ],
              child: SliverMainAxisGroup(
                slivers: <Widget>[
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
                  SliverPadding(padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0), sliver: _Transactions()),

                  // ~ Space in bottom
                  const SliverToBoxAdapter(child: SizedBox(height: 64.0)),
                ],
              ),
            ),
          ],
        ),
      ),

      // ~~~ Add transaction button ~~~
      floatingActionButton: AddTransactionButton(scrollController: _scrollController),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _AmcOverviewSection extends StatefulWidget {
  const _AmcOverviewSection({super.key, this.stat});

  final InveslyStat? stat; // This is required only when transaction state becomes error

  @override
  State<_AmcOverviewSection> createState() => _AmcOverviewSectionState();
}

class _AmcOverviewSectionState extends State<_AmcOverviewSection> {
  static const double _spacing = 2.0;

  // @override
  // void initState() {
  //   super.initState();
  //   final amcCubit = context.read<AmcOverviewCubit>();
  //   amcCubit.getLatestPrice();
  // }

  // @override
  // void didUpdateWidget(covariant _AmcOverviewSection oldWidget) {
  //   final amcCubit = context.read<AmcOverviewCubit>();
  //   if(amcCubit.state.amc)
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final now = DateTime.now();

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
                child: BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                  buildWhen: (prev, curr) => prev.amc != curr.amc,
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.0,
                      children: <Widget>[
                        // ~ Amc Name
                        state.amc != null
                            ? FadeIn(
                                key: Key('amc_loaded'),
                                child: Text(
                                  state.amc!.name,
                                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              )
                            : Text(
                                state.amcId,
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                        // ~ Chips
                        _buildTags(context),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // ~ Stats Section
          // BlocBuilder<TransactionsCubit, TransactionsState>(
          //   builder: (context, trnState) {
          //     return
          BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
            // buildWhen: (prev, curr) => prev.ltp != curr.ltp,
            builder: (context, amcState) {
              final isError = amcState.isLtpError;

              final totalQnty = amcState.isLoaded ? amcState.totalQnty : widget.stat?.totalQnty;
              final avgBuyPrice = amcState.isLoaded ? amcState.averageBuyPrice : widget.stat?.averageBuyPrice;
              final totalInvested = amcState.isLoaded ? amcState.totalInvested : widget.stat?.totalInvested;

              final ltp = amcState.ltp?.price;
              final currentValue = amcState.isLoaded
                  ? amcState.currentValue
                  : ltp != null && totalQnty != null
                  ? ltp * totalQnty
                  : null;
              final amountReturn = currentValue != null && totalInvested != null ? currentValue - totalInvested : null;
              final perReturn = amountReturn != null && totalInvested != null && totalInvested > 0
                  ? amountReturn / totalInvested
                  : null;

              final color = (amountReturn?.isNegative ?? true) ? Colors.red : Colors.teal;

              return Skeletonizer(
                enabled: amcState.isLoading,
                child: GridView.count(
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
                        label: const Text('Available units', overflow: TextOverflow.ellipsis),
                        value: Text('${totalQnty?.toPrecision(4) ?? "N/A"}', overflow: TextOverflow.ellipsis),
                        color: amcState.isError ? colors.errorContainer : null,
                        valueColor: amcState.isError ? colors.error : null,
                      ),
                    ),

                    // ~ Avg. price
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('Average price', overflow: TextOverflow.ellipsis)),
                      value: avgBuyPrice != null
                          ? BlocSelector<AppCubit, AppState, bool>(
                              selector: (state) => state.isPrivateMode,
                              builder: (context, isPrivate) {
                                return CurrencyView(amount: avgBuyPrice, privateMode: isPrivate);
                              },
                            )
                          : const Text('N/A', overflow: TextOverflow.ellipsis),
                      color: amcState.isError ? colors.errorContainer : null,
                      valueColor: amcState.isError ? colors.error : null,
                    ),

                    // ~ Invested amount
                    Skeleton.leaf(
                      child: _SectionWidget(
                        label: const Text('Invested amount', overflow: TextOverflow.ellipsis),
                        value: totalInvested != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(amount: totalInvested, privateMode: isPrivate);
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: amcState.isError ? colors.errorContainer : null,
                        valueColor: amcState.isError ? colors.error : null,
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
                              date: amcState.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: ltp != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(amount: ltp, privateMode: isPrivate);
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: amcState.isLtpError ? colors.errorContainer : null,
                        valueColor: amcState.isLtpError ? colors.error : null,
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
                              date: amcState.ltp?.date ?? now,
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
                                    amount: currentValue,
                                    privateMode: isPrivate,
                                    style: textTheme.headlineLarge?.copyWith(color: color),
                                    decimalsStyle: textTheme.headlineSmall?.copyWith(color: color),
                                    currencyStyle: textTheme.bodyMedium,
                                  );
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: isError ? colors.errorContainer : null,
                        valueColor: isError ? colors.error : null,
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
                              date: amcState.ltp?.date ?? now,
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
                                    amount: amountReturn,
                                    privateMode: isPrivate,
                                    style: TextStyle(color: color),
                                  );
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: isError ? colors.errorContainer : null,
                        valueColor: isError ? colors.error : null,
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
                              date: amcState.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: perReturn != null
                            ? BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivate) {
                                  return CurrencyView(
                                    amount: perReturn,
                                    privateMode: isPrivate,
                                    style: TextStyle(color: color),
                                  );
                                },
                              )
                            : const Text('N/A', overflow: TextOverflow.ellipsis),
                        color: isError ? colors.errorContainer : null,
                        valueColor: isError ? colors.error : null,
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
                              date: amcState.ltp?.date ?? now,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                            ),
                          ],
                        ),
                        value: () {
                          if (isError) return Text('N/A', overflow: TextOverflow.ellipsis);

                          double? xirr;
                          if (amcState.isLoaded && amcState.transactions.isNotEmpty) {
                            final transactionsForXirr = amcState.transactions
                                .map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn))
                                .toList();
                            if (transactionsForXirr.isNotEmpty && amcState.ltp != null && currentValue != null) {
                              transactionsForXirr.add(
                                xf.Transaction(-currentValue, amcState.ltp!.date ?? amcState.ltp!.fetchDate),
                              );
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

                            // ~ Save data in database
                            // final stat = StatInDb(
                            //   accountId: widget.accountId,
                            //   amcId: widget.amcId,
                            //   numTrns: trnState.transactions.length,
                            //   totalQnty: totalQnty ?? 0.0,
                            //   totalInvested: totalInvested ?? 0.0,
                            //   totalRedeemed: trnState.totalRedeemed,
                            //   xirr: xirr,
                            // );
                            // StatRepository.instance.saveXirr(stat, xirr);

                            return Text(
                              xirr != null ? '${(xirr * 100).toPrecision(2)}%' : 'N/A',
                              style: TextStyle(color: (xirr?.isNegative ?? true) ? Colors.red : Colors.teal),
                              overflow: TextOverflow.ellipsis,
                            );
                          }

                          return const Text('Loading...', overflow: TextOverflow.ellipsis);
                        }(),
                        color: isError ? colors.errorContainer : null,
                        valueColor: isError ? colors.error : null,
                        borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                      ),
                    ),
                  ],
                ),
              );
            },
            //   );
            // },
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    final state = context.read<AmcOverviewCubit>().state;

    // ~ if Error
    if (state.isError) {
      return SimpleChip(
        color: context.colors.error,
        titleColor: context.colors.onError,
        child: const Text('Error loading AMC details'),
      );
    }

    // ~ otherwise
    if (state.isLoaded && state.amc != null) {
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
          return Skeleton.leaf(
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
  const _Transactions({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: <Widget>[
        BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, trnState) {
            // ~ Error state
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

            // ~ Loaded state
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

            // ~ Loading state
            final statState = context.read<StatCubit>().state;
            final numTrns = statState is StatLoadedState ? statState.stats.length : 3;
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

    return SectionTile(
      title: FormattedDate(date: trn.investedOn),
      subtitle: Text(
        '${trn.quantity?.toPrecision(2) ?? ''} units | ₹${trn.rate?.toPrecision(2)}',
        overflow: TextOverflow.ellipsis,
      ), // TODO: Fix this
      icon: PhysicalModel(
        shape: BoxShape.circle,
        color: trn.totalAmount.isNegative ? Colors.red.lighten(75) : Colors.teal.lighten(75),
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
