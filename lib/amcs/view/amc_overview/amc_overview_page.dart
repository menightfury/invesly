import 'dart:async';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/components/add_transaction_button.dart';
import 'package:invesly/stat/cubit/stat_cubit.dart';
import 'package:invesly/stat/model/stat_repository.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'package:invesly/stat/model/stat_model.dart';
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
                    return AmcOverviewCubit(repository: AmcRepository.instance, amcId: widget.amcId)..getAmcDetails();
                  },
                ),
                BlocProvider(
                  create: (_) {
                    return TransactionsCubit(repository: TransactionRepository.instance)
                      ..fetchTransactions(accountId: widget.accountId, amcId: widget.amcId);
                  },
                ),
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

class _AmcOverviewSection extends StatelessWidget {
  const _AmcOverviewSection({this.stat, super.key});

  final InveslyStat? stat; // This is required only when transaction state becomes error

  static const double _spacing = 2.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

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
          BlocBuilder<TransactionsCubit, TransactionsState>(
            builder: (context, trnState) {
              // $logger.w('==== Rebuilding state because ltpStatus is updating ====');
              return Skeletonizer(
                enabled: trnState.isLoading,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: _spacing,
                  crossAxisSpacing: _spacing,
                  mainAxisExtent: 104.0,
                  children: <Widget>[
                    // ~ No. of units
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('Available units', overflow: TextOverflow.ellipsis)),
                      value: () {
                        if (trnState.isError) {
                          return Text('${stat?.totalQnty.toPrecision(4) ?? "N/A"}', overflow: TextOverflow.ellipsis);
                        }
                        if (trnState.isLoaded) {
                          return Text('${trnState.totalQuantity.toPrecision(4)}', overflow: TextOverflow.ellipsis);
                        }
                        return const Text('Loading...');
                      }(),
                      color: trnState.isError ? colors.errorContainer : null,
                      valueColor: trnState.isError ? colors.error : null,
                    ),

                    // ~ Avg. price
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('Average price', overflow: TextOverflow.ellipsis)),
                      value: () {
                        if (trnState.isError) {
                          if (stat == null) return Text('N/A', overflow: TextOverflow.ellipsis);

                          return BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivate) {
                              return CurrencyView(amount: stat!.averageBuyPrice, privateMode: isPrivate);
                            },
                          );
                        }
                        if (trnState.isLoaded) {
                          return BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivate) {
                              return CurrencyView(amount: trnState.averageBuyPrice, privateMode: isPrivate);
                            },
                          );
                        }
                        return const Text('Loading...');
                      }(),
                      color: trnState.isError ? colors.errorContainer : null,
                      valueColor: trnState.isError ? colors.error : null,
                    ),

                    // ~ Invested amount
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('Invested amount', overflow: TextOverflow.ellipsis)),
                      value: () {
                        if (trnState.isError) {
                          if (stat == null) return Text('N/A', overflow: TextOverflow.ellipsis);

                          return BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivate) {
                              return CurrencyView(amount: stat!.totalInvested, privateMode: isPrivate);
                            },
                          );
                        }
                        if (trnState.isLoaded) {
                          return BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivate) {
                              return CurrencyView(amount: trnState.totalInvested, privateMode: isPrivate);
                            },
                          );
                        }
                        return const Text('Loading...');
                      }(),
                      color: trnState.isError ? colors.errorContainer : null,
                      valueColor: trnState.isError ? colors.error : null,
                    ),

                    // ~ Latest NAV (Mkt. price) sections
                    BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
                      buildWhen: (prev, curr) => prev.ltp != curr.ltp,
                      builder: (context, state) {
                        final isError = state.isLtpError;
                        return _SectionWidget(
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Skeleton.keep(child: Text('Latest NAV', overflow: TextOverflow.ellipsis)),
                              FormattedDate(
                                date: state.ltp?.date ?? DateTime.now(),
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                              ),
                            ],
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
                      buildWhen: (prev, curr) => prev.ltp != curr.ltp,
                      builder: (context, state) {
                        final isError = state.isLtpError;
                        return _SectionWidget(
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Skeleton.keep(child: Text('Current value', overflow: TextOverflow.ellipsis)),
                              FormattedDate(
                                date: state.ltp?.date ?? DateTime.now(),
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                              ),
                            ],
                          ),
                          value: () {
                            if (isError) return const Text('N/A', overflow: TextOverflow.ellipsis);

                            if (state.isLtpLoaded && state.ltp != null) {
                              final ltp = state.ltp!.price;
                              if (trnState.isError) {
                                if (stat == null) return Text('N/A', overflow: TextOverflow.ellipsis);

                                return BlocSelector<AppCubit, AppState, bool>(
                                  selector: (state) => state.isPrivateMode,
                                  builder: (context, isPrivate) {
                                    return CurrencyView(
                                      amount: stat!.totalQnty * ltp,
                                      style: textTheme.headlineLarge,
                                      decimalsStyle: textTheme.headlineSmall,
                                      currencyStyle: textTheme.bodyMedium,
                                      privateMode: isPrivate,
                                    );
                                  },
                                );
                              }
                              if (trnState.isLoaded) {
                                return BlocSelector<AppCubit, AppState, bool>(
                                  selector: (state) => state.isPrivateMode,
                                  builder: (context, isPrivate) {
                                    return CurrencyView(
                                      amount: trnState.totalQuantity * ltp,
                                      style: textTheme.headlineLarge,
                                      decimalsStyle: textTheme.headlineSmall,
                                      currencyStyle: textTheme.bodyMedium,
                                      privateMode: isPrivate,
                                    );
                                  },
                                );
                              }
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
                        return prev.amcId != curr.amcId || prev.ltp != curr.ltp;
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
                        return prev.amcId != curr.amcId || prev.ltp != curr.ltp;
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
                        return prev.amcId != curr.amcId || prev.ltp != curr.ltp;
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
                                      StatRepository.instance.saveXirr(amcState.amcId, xirr);
                                    }

                                    return Text(
                                      xirr != null ? '${(xirr * 100).toPrecision(2)}%' : 'N/A',
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
                account = accountsState.accounts.firstWhereOrNull((a) => a.id == snapshot.accountId);
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


// class _AmcOverviewPageContentState extends State<_AmcOverviewPageContent> {
//   @override
//   void initState() {
//     super.initState();
//     _getAmcOverview();
//     _getStats();
//   }

//   @override
//   void didUpdateWidget(covariant _AmcOverviewPageContent oldWidget) {
//     if (oldWidget.amcId != widget.amcId) {
//       _getAmcOverview();
//       _getStats();
//     }
//     super.didUpdateWidget(oldWidget);
//   }

//   void _getAmcOverview() {
//     context.read<AmcOverviewCubit>().fetchAmcOverview(widget.amcId);
//   }

//   void _getStats() {
//     if (widget.accountId?.isEmpty ?? true) {
//       return;
//     }

//     if (mounted) {
//       context.read<TransactionsCubit>().fetchTransactions(accountId: widget.accountId, amcId: widget.amcId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final textTheme = context.textTheme;
//     const spacing = 2.0;

//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: CustomScrollView(
//                 slivers: <Widget>[
//                   SliverAppBar(title: const Text('Holding details'), floating: true, snap: true),

//                   // ~ AMC Details & Stats
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
//                         builder: (context, amcState) {
//                           final isAmcLoading = amcState is AmcOverviewLoadingState;
//                           return Column(
//                             spacing: spacing,
//                             children: <Widget>[
//                               // ~ AMC Details
//                               SimpleCard(
//                                 color: colors.primaryContainer.darken(3.0),
//                                 elevation: 0.0,
//                                 borderRadius: iCardBorderRadius.copyWith(
//                                   bottomLeft: iTileBorderRadius.bottomLeft,
//                                   bottomRight: iTileBorderRadius.bottomRight,
//                                 ),
//                                 child: ConstrainedBox(
//                                   constraints: const BoxConstraints(minHeight: 52.0, minWidth: double.infinity),
//                                   child: Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       spacing: 12.0,
//                                       children: <Widget>[
//                                         // ~ Amc Name
//                                         amcState is AmcOverviewLoadedState && amcState.amc != null
//                                             ? FadeIn(
//                                                 key: Key('amc_loaded'),
//                                                 child: Text(
//                                                   amcState.amc!.name,
//                                                   style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
//                                                   textAlign: TextAlign.start,
//                                                   overflow: TextOverflow.ellipsis,
//                                                   maxLines: 2,
//                                                 ),
//                                               )
//                                             : Text(
//                                                 widget.amcId,
//                                                 style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
//                                                 textAlign: TextAlign.start,
//                                                 overflow: TextOverflow.ellipsis,
//                                                 maxLines: 2,
//                                               ),

//                                         // ~ Chips - if Error
//                                         if (amcState.isError)
//                                           SimpleChip(
//                                             title: const Text('Error loading AMC details'),
//                                             color: context.colors.error,
//                                             titleColor: context.colors.onError,
//                                           ),

//                                         // ~ Chips (tags) - otherwise
//                                         if (!amcState.isError)
//                                           Skeletonizer(
//                                             enabled: amcState.isLoading || amcState.isInitial,
//                                             child: Wrap(
//                                               spacing: 6.0,
//                                               runSpacing: 4.0,
//                                               children: <Widget>[
//                                                 Skeleton.leaf(
//                                                   child: SimpleChip(
//                                                     title: Text(
//                                                       amcState is AmcOverviewLoadedState
//                                                           ? (amcState.amc?.genre ?? AmcGenre.misc).title
//                                                           : 'Loading...', // 'Loading...' text will be replaced by shimmer effect when skeletonizer is enabled
//                                                     ),
//                                                     color: context.colors.primary,
//                                                     titleColor: context.colors.onPrimary,
//                                                   ),
//                                                 ),

//                                                 ..._buildAmcTags(amcState),
//                                               ],
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               // ~ Stats Section
//                               BlocBuilder<TransactionsCubit, TransactionsState>(
//                                 builder: (context, trnState) {
//                                   final isTrnError = trnState.isError;
//                                   final isTrnLoading = trnState.isLoading;
//                                   final latestPrice = amcState is AmcOverviewLoadedState ? amcState.amc?.ltp : null;
//                                   final amcTrn =
//                                       trnState.isLoaded && amcState is AmcOverviewLoadedState && amcState.amc != null
//                                       ? AmcTransaction(amc: amcState.amc, transactions: trnState.transactions)
//                                       : null;

//                                   return Skeletonizer(
//                                     enabled: isTrnLoading,
//                                     child: Column(
//                                       spacing: spacing,
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: <Widget>[
//                                         GridView.count(
//                                           shrinkWrap: true,
//                                           physics: const NeverScrollableScrollPhysics(),
//                                           crossAxisCount: 2,
//                                           mainAxisSpacing: spacing,
//                                           crossAxisSpacing: spacing,
//                                           mainAxisExtent: 104.0,
//                                           children: <Widget>[
//                                             // ~ No. of units section
//                                             _SectionWidget(
//                                               label: const Skeleton.keep(child: Text('No. of units')),
//                                               value: isTrnLoading
//                                                   ? const Text('Loading...')
//                                                   : Text('${amcTrn?.totalUnits.toPrecision(4)}'),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                             ),

//                                             // ~ Avg. price section
//                                             _SectionWidget(
//                                               label: const Skeleton.keep(child: Text('Avg. price')),
//                                               value: isTrnLoading
//                                                   ? const Text('Loading...')
//                                                   : BlocSelector<AppCubit, AppState, bool>(
//                                                       selector: (state) => state.isPrivateMode,
//                                                       builder: (context, isPrivateMode) {
//                                                         return CurrencyView(
//                                                           amount: amcTrn?.averageBuyPrice ?? 0.0,
//                                                           privateMode: isPrivateMode,
//                                                         );
//                                                       },
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                             ),

//                                             // ~ Invested amount section
//                                             _SectionWidget(
//                                               label: const Skeleton.keep(child: Text('Invested amount')),
//                                               value: isTrnLoading
//                                                   ? const Text('Loading...')
//                                                   : BlocSelector<AppCubit, AppState, bool>(
//                                                       selector: (state) => state.isPrivateMode,
//                                                       builder: (context, isPrivateMode) {
//                                                         return CurrencyView(
//                                                           amount: amcTrn?.totalInvested ?? 0,
//                                                           privateMode: isPrivateMode,
//                                                         );
//                                                       },
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                             ),

//                                             // ~ Current value
//                                             _SectionWidget(
//                                               label: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: <Widget>[
//                                                   const Skeleton.keep(child: Text('Current value')),
//                                                   isTrnLoading
//                                                       ? const Text('Loading...')
//                                                       : FormattedDate(
//                                                           date: latestPrice?.date ?? DateTime.now(),
//                                                           overflow: TextOverflow.ellipsis,
//                                                           style: textTheme.labelSmall?.copyWith(
//                                                             color: context.theme.disabledColor,
//                                                           ),
//                                                         ),
//                                                 ],
//                                               ),
//                                               value: isTrnLoading
//                                                   ? Text('Loading...')
//                                                   : BlocSelector<AppCubit, AppState, bool>(
//                                                       selector: (state) => state.isPrivateMode,
//                                                       builder: (context, isPrivateMode) {
//                                                         return CurrencyView(
//                                                           amount: amcTrn?.totalCurrentValue ?? 0.0,
//                                                           style: textTheme.headlineLarge,
//                                                           decimalsStyle: textTheme.headlineSmall,
//                                                           currencyStyle: textTheme.bodyMedium,
//                                                           privateMode: isPrivateMode,
//                                                           // compactView: snapshot.data! >= 1_00_00_000
//                                                         );
//                                                       },
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                             ),

//                                             // ~ Latest NAV (Mkt. price) sections
//                                             _SectionWidget(
//                                               label: Column(
//                                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                                 children: <Widget>[
//                                                   const Skeleton.keep(child: Text('Latest NAV')),
//                                                   isAmcLoading
//                                                       ? const Text('Loading...')
//                                                       : FormattedDate(
//                                                           date: latestPrice?.date ?? DateTime.now(),
//                                                           overflow: TextOverflow.ellipsis,
//                                                           style: textTheme.labelSmall?.copyWith(
//                                                             color: context.theme.disabledColor,
//                                                           ),
//                                                         ),
//                                                 ],
//                                               ),
//                                               value: isAmcLoading
//                                                   ? const Text('Loading...')
//                                                   : BlocSelector<AppCubit, AppState, bool>(
//                                                       selector: (state) => state.isPrivateMode,
//                                                       builder: (context, isPrivateMode) {
//                                                         return CurrencyView(
//                                                           amount: latestPrice?.price ?? 0.0,
//                                                           privateMode: isPrivateMode,
//                                                         );
//                                                       },
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                             ),

//                                             // ~ Amount return sections
//                                             _SectionWidget(
//                                               label: const Skeleton.keep(child: Text('Return')),
//                                               value: isTrnLoading
//                                                   ? const Text('Loading...')
//                                                   : BlocSelector<AppCubit, AppState, bool>(
//                                                       selector: (state) => state.isPrivateMode,
//                                                       builder: (context, isPrivateMode) {
//                                                         final returns = amcTrn?.amountReturn;
//                                                         return CurrencyView(
//                                                           amount: returns ?? 0.0,
//                                                           privateMode: isPrivateMode,
//                                                           style: TextStyle(
//                                                             color: returns?.isNegative ?? true
//                                                                 ? Colors.red
//                                                                 : Colors.teal,
//                                                           ),
//                                                         );
//                                                       },
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                             ),

//                                             // ~ Percentage returns sections
//                                             _SectionWidget(
//                                               label: const Skeleton.keep(child: Text('Total returns')),
//                                               value: isTrnLoading
//                                                   ? const Text('Loading...')
//                                                   : Text(
//                                                       '${amcTrn?.percentageReturn?.toPrecision(2) ?? 0}%',
//                                                       textAlign: TextAlign.right,
//                                                       style: TextStyle(
//                                                         color: amcTrn?.percentageReturn?.isNegative ?? true
//                                                             ? Colors.red
//                                                             : Colors.teal,
//                                                       ),
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                               borderRadius: iTileBorderRadius.copyWith(
//                                                 bottomLeft: iCardBorderRadius.bottomLeft,
//                                               ),
//                                             ),

//                                             // ~ XIRR section
//                                             _SectionWidget(
//                                               label: const Skeleton.keep(child: Text('XIRR')),
//                                               value: isTrnLoading
//                                                   ? const Text('Loading...')
//                                                   : Text(
//                                                       '${((amcTrn?.xirr ?? 0) * 100).toPrecision(2)}%',
//                                                       style: TextStyle(
//                                                         color: amcTrn?.xirr?.isNegative ?? true
//                                                             ? Colors.red
//                                                             : Colors.teal,
//                                                       ),
//                                                     ),
//                                               color: isTrnError ? colors.errorContainer : null,
//                                               valueColor: isTrnError ? colors.error : null,
//                                               borderRadius: iTileBorderRadius.copyWith(
//                                                 bottomRight: iCardBorderRadius.bottomRight,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                   ),

//                   // ~ Holding Transactions Section
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: const Text('Transactions'),
//                     ),
//                   ),

//                   SliverPadding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     sliver: BlocBuilder<TransactionsCubit, TransactionsState>(
//                       builder: (context, trnState) {
//                         final isLoading = trnState.isLoading;
//                         final isError = trnState.isError;
//                         final isLoaded = trnState.isLoaded;

//                         if (isError) {
//                           return SliverToBoxAdapter(
//                             child: Center(
//                               child: Text(
//                                 'Some error occurred! Try again later.',
//                                 style: TextStyle(color: context.colors.error),
//                               ),
//                             ),
//                           );
//                         }

//                         if (isLoaded && trnState.transactions.isEmpty) {
//                           return SliverToBoxAdapter(
//                             child: Center(
//                               child: EmptyWidget(
//                                 label: Text('This is so empty.\n Add some transactions to see stats here.'),
//                               ),
//                             ),
//                           );
//                         }

//                         final transactions = trnState.transactions;
//                         return SliverSkeletonizer(
//                           enabled: isLoading,
//                           child: SliverList.separated(
//                             itemCount: isLoaded ? transactions.length : 2, // Show 2 skeleton cards while loading
//                             itemBuilder: (context, index) {
//                               final trn = isLoaded ? transactions[index] : null;
//                               return _buildTransaction(trn);
//                             },
//                             separatorBuilder: (_, _) => const Gap(2.0),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const InveslyDivider(),
//             // ~ Buy/Sell Buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Row(
//                 spacing: 16.0,
//                 children: <Widget>[
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepOrange,
//                         foregroundColor: Colors.white,
//                       ),
//                       child: const Text('Sell'),
//                     ),
//                   ),

//                   Expanded(
//                     child: TextButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal.shade500,
//                         foregroundColor: Colors.white,
//                       ),
//                       child: const Text('Buy'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransaction(InveslyTransaction? trn) {
//     final textTheme = context.textTheme;

//     return SectionTile(
//       title: trn != null ? Text('${trn.quantity} units @ ₹${(trn.rate).toPrecision(2)}') : const Text('Loading...'),
//       subtitle: trn != null
//           ? FormattedDate(
//               date: trn.investedOn,
//               style: textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
//             )
//           : const Text('Loading...'),
//       icon: PhysicalModel(
//         shape: BoxShape.circle,
//         color: (trn?.totalAmount.isNegative ?? false) ? Colors.red.shade50 : Colors.teal.shade50,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: trn != null
//               ? Icon(
//                   trn.totalAmount.isNegative ? Icons.south_east_rounded : Icons.north_east_rounded,
//                   color: trn.totalAmount.isNegative ? Colors.red : Colors.teal,
//                 )
//               : const Bone.icon(),
//         ),
//       ),
//       secondaryIcon: trn != null
//           ? BlocSelector<AppCubit, AppState, bool>(
//               selector: (state) => state.isPrivateMode,
//               builder: (context, isPrivateMode) {
//                 return CurrencyView(
//                   amount: trn.totalAmount,
//                   privateMode: isPrivateMode,
//                   style: textTheme.titleLarge?.copyWith(color: trn.totalAmount > 0 ? Colors.teal : Colors.red),
//                 );
//               },
//             )
//           : Text('Loading...', style: textTheme.titleLarge),
//     );
//   }
// }



