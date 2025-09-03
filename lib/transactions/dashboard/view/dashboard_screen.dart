// ignore_for_file: unused_element

import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/authentication/user_model.dart';

import 'package:invesly/common/presentations/animations/scroll_to_hide.dart';
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/settings/settings_screen.dart';
import 'package:invesly/transactions/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_screen_classic.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              leading: Align(child: Image.asset('assets/images/app_icon/app_icon.png', height: 32.0)),
              titleSpacing: 0.0,
              actions: <Widget>[
                // ~~~ User avatar ~~~
                GestureDetector(
                  onTap: () => context.push(const SettingsScreen()),
                  child: BlocSelector<SettingsCubit, SettingsState, InveslyUser?>(
                    selector: (state) => state.currentUser,
                    builder: (context, currentUser) {
                      final user = currentUser ?? InveslyUser.empty();
                      return GoogleUserCircleAvatar(identity: user);
                    },
                  ),
                ),
              ],
              actionsPadding: EdgeInsets.only(right: 16.0),
            ),

            SliverList(
              delegate: SliverChildListDelegate.fixed([
                // ~~~ Greetings ~~~
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        DateTime.now().greetingsMsg,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall,
                      ),
                      BlocSelector<SettingsCubit, SettingsState, InveslyUser?>(
                        selector: (state) => state.currentUser,
                        builder: (context, currentUser) {
                          return Text(
                            currentUser?.name ?? 'Investor',
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineMedium,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Gap(16.0),

                // ~~~ Accounts, Stats, Recent transactions etc. ~~~
                BlocProvider(
                  create: (context) => DashboardCubit(repository: context.read<TransactionRepository>()),
                  child: _DashboardContents(),
                ),
                const Gap(40.0),
              ]),
            ),
          ],
        ),
      ),
      // ~~~ Add transaction button ~~~
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _handleNewTransactionPressed(context),
        icon: const Icon(Icons.add_rounded),
        extendedPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 16.0),
        extendedIconLabelSpacing: 0.0,
        label: ScrollToHide(
          scrollController: _scrollController,
          hideAxis: Axis.horizontal,
          child: Padding(padding: const EdgeInsets.only(left: 8.0), child: Text('New transaction')),
        ),
      ),
    );
  }

  void _handleNewTransactionPressed(BuildContext context) async {
    final accountsState = context.read<AccountsCubit>().state;

    // Load accounts if not loaded
    if (accountsState is AccountsInitialState) {
      await context.read<AccountsCubit>().fetchAccounts();
    }
    if (!context.mounted) return;
    if (accountsState is AccountsErrorState) {
      // showErrorDialog(context);
      return;
    }
    if (accountsState is AccountsLoadedState) {
      if (accountsState.accounts.isEmpty) {
        final confirmed = await showConfirmDialog(
          context,
          title: 'Oops!',
          icon: Icon(Icons.warning_amber_rounded),
          content: Text('You must have at least one no-archived account before you can start creating transactions'),
          confirmationText: 'Continue',
        );

        if (!context.mounted) return;
        if (confirmed ?? false) {
          context.push(const EditAccountScreen());
        }
        return;
      }

      context.push(const EditTransactionScreen());
    }
  }
}

class Skeleton extends StatelessWidget {
  const Skeleton({super.key, this.height = 16.0, this.width = double.infinity, this.color = Colors.white});

  final double height, width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16.0)),
      child: SizedBox(width: width, height: height),
    );
  }
}

class _DashboardContents extends StatefulWidget {
  const _DashboardContents({super.key});

  @override
  State<_DashboardContents> createState() => _DashboardContentsState();
}

class _DashboardContentsState extends State<_DashboardContents> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().fetchAccounts();
    context.read<DashboardCubit>().fetchTransactionStats();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[_AccountsList(), _AmcGenreList(), _RecentTransactions()],
    );
  }
}

class _AccountsList extends StatelessWidget {
  const _AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SizedBox(
      height: 112.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountState) {
              return BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, dashboardState) {
                  final isError = accountState.isError || dashboardState.isError;
                  final isLoading = accountState.isLoading || dashboardState.isLoading;
                  final accounts = accountState.isLoaded ? (accountState as AccountsLoadedState).accounts : null;
                  final totalAmount = dashboardState is DashboardLoadedState
                      ? dashboardState.stats.fold<double>(0, (v, el) => v + el.totalAmount)
                      : null;

                  return Row(
                    spacing: 8.0,
                    children: <Widget>[
                      // ~~~ Accounts ~~~
                      // dummy count for shimmer effect
                      ...List.generate(accounts?.length ?? 1, (index) {
                        final account = accounts?.elementAt(index);

                        return BlocSelector<SettingsCubit, SettingsState, bool>(
                          selector: (state) => state.currentAccountId == account?.id,
                          builder: (context, isCurrentAccount) {
                            $logger.i('rebuilding $account');
                            return Tappable(
                              // onTap: isLoading ? null : () => RouteUtils.pushRoute(
                              //   context,
                              //   AccountDetailsPage(
                              //     account: account,
                              //     accountIconHeroTag: 'dashboard-page__account-icon-${account.id}',
                              //   ),
                              // ),
                              width: 160.0,
                              childAlignment: Alignment.centerLeft,
                              border: BorderSide(color: isCurrentAccount ? context.colors.primary : Colors.black),
                              content: Shimmer(
                                isLoading: isLoading,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4.0,
                                  children: <Widget>[
                                    account == null
                                        ? Skeleton(color: isError ? context.colors.error : null)
                                        : Text(account.name, overflow: TextOverflow.ellipsis),

                                    totalAmount == null
                                        ? Skeleton(color: isError ? context.colors.error : null)
                                        : BlocSelector<SettingsCubit, SettingsState, bool>(
                                            selector: (state) => state.isPrivateMode,
                                            builder: (context, isPrivateMode) {
                                              return CurrencyView(
                                                amount: totalAmount,
                                                integerStyle: textTheme.headlineLarge,
                                                decimalsStyle: textTheme.headlineSmall,
                                                currencyStyle: textTheme.bodyMedium,
                                                privateMode: isPrivateMode,
                                                // compactView: snapshot.data! >= 10000000
                                              );
                                            },
                                          ),
                                    Spacer(),
                                    Text('5 transactions', style: textTheme.labelMedium),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      // ~~~ Add account ~~~
                      Tappable(
                        onTap: () => context.push(const EditAccountScreen()),
                        color: Colors.grey.shade100,
                        width: 160.0,
                        border: BorderSide(color: Colors.grey.shade500, width: 1.0),
                        content: Shimmer(
                          isLoading: isLoading,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4.0,
                            children: <Widget>[
                              isLoading
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Icon(Icons.format_list_bulleted_add, color: Colors.grey.shade500),
                              isLoading
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Text('Create account', style: TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AmcGenreList extends StatelessWidget {
  const _AmcGenreList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Investment genres', style: context.textTheme.headlineSmall),
            leading: const Icon(Icons.swap_vert_rounded),
          ),
          // InveslyDivider.dashed(dashWidth: 2.0, thickness: 2.0),
          ColumnBuilder(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.0,
            itemCount: AmcGenre.values.length,
            itemBuilder: (context, index) {
              final genre = AmcGenre.getByIndex(index);
              late final BorderRadius borderRadius;
              if (index == 0) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(20.0), bottom: Radius.circular(4.0));
              } else if (index == AmcGenre.values.length - 1) {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(4.0), bottom: Radius.circular(20.0));
              } else {
                borderRadius = const BorderRadius.all(Radius.circular(4.0));
              }

              return Tappable(
                onTap: () {},
                borderRadius: borderRadius,
                childAlignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                content: Stack(
                  children: <Widget>[
                    Positioned(
                      right: -12.0,
                      top: -12.0,
                      child: Icon(genre.icon, size: 64.0, color: context.colors.secondary.withAlpha(50)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(genre.title, overflow: TextOverflow.ellipsis),
                          BlocBuilder<DashboardCubit, DashboardState>(
                            builder: (context, state) {
                              if (state is DashboardLoadedState) {
                                final stats = state.stats.firstWhereOrNull((stat) => stat.amcGenre == genre);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  spacing: 8.0,
                                  children: <Widget>[
                                    Text(
                                      '${stats?.numTransactions ?? 0} transactions',
                                      style: context.textTheme.labelSmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: BlocSelector<SettingsCubit, SettingsState, bool>(
                                        selector: (state) => state.isPrivateMode,
                                        builder: (context, isPrivateMode) {
                                          return CurrencyView(
                                            amount: stats?.totalAmount ?? 0.0,
                                            integerStyle: context.textTheme.headlineMedium,
                                            decimalsStyle: context.textTheme.headlineSmall?.copyWith(fontSize: 13.0),
                                            currencyStyle: context.textTheme.bodySmall,
                                            privateMode: isPrivateMode,
                                          );
                                        },
                                      ),
                                      // child: Text(
                                      //   stats?.totalAmount.toCompact() ?? '0.0',
                                      //   style: context.textTheme.,
                                      //   overflow: TextOverflow.ellipsis,
                                      // ),
                                    ),
                                  ],
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                        ],
                      ),
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

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(16.0),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text('Recent transactions', style: context.textTheme.headlineSmall),
              leading: Icon(Icons.swap_vert_rounded),
            ),
            InveslyDivider.dashed(dashWidth: 2.0, thickness: 2.0),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoadedState) {
                  final rts = state.recentTransactions;
                  if (rts.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Center(
                        child: Column(
                          spacing: 16.0,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Oops! This is so empty', style: context.textTheme.titleLarge),
                            Text(
                              'No transactions have been found.\nAdd a few transactions.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ColumnBuilder(
                    itemBuilder: (context, index) {
                      final rt = rts[index];
                      return ListTile(
                        leading: Icon(rt.transactionType.icon),
                        title: Text(rt.amc?.name ?? 'NULL', style: context.textTheme.bodyMedium),
                        subtitle: Text(
                          rt.investedOn.toReadable(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelSmall,
                        ),
                        trailing: BlocSelector<SettingsCubit, SettingsState, bool>(
                          selector: (state) => state.isPrivateMode,
                          builder: (context, isPrivateMode) {
                            return CurrencyView(
                              amount: rt.totalAmount,
                              integerStyle: context.textTheme.headlineSmall?.copyWith(
                                color: rt.transactionType.color(context),
                              ),
                              privateMode: isPrivateMode,
                            );
                          },
                        ),
                        onTap: () {},
                      );
                    },
                    itemCount: rts.length,
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSummeryWidget extends StatelessWidget {
  const _TransactionSummeryWidget({
    super.key,
    required this.genre,
    this.totalInvestedAmount = 0.0,
    this.transactions = const [],
  });

  final AmcGenre genre;
  final double totalInvestedAmount;
  final List<TransactionStat> transactions;

  @override
  Widget build(BuildContext context) {
    final totalGenreAmount = transactions.isEmpty ? 0.0 : transactions.fold<double>(0, (v, el) => v + el.totalAmount);
    double share = 0.0;
    if (totalGenreAmount > 0 && totalInvestedAmount > 0) {
      share = totalGenreAmount / totalInvestedAmount;
    }
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // $logger.f(transactions);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // ~ Heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: <Widget>[
              const Icon(Icons.trending_up_rounded, color: Colors.lightBlue, size: 32.0),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(genre.title, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text(totalGenreAmount.toCompact(), style: textTheme.headlineMedium),
                  ],
                ),
              ),
              if (share > 0)
                CircularPercentIndicator(
                  percent: share,
                  radius: 40.0,
                  lineWidth: 16.0,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animateFromLastPercent: true,
                  progressColor: colorScheme.primary,
                  backgroundColor: colorScheme.secondary,
                  center: Text('${(share * 100).toCompact()} %'),
                ),
            ],
          ),
        ),

        // ~ Lists
        buildTransactionList(context, totalGenreAmount),
      ],
    );
  }

  Widget buildTransactionList(BuildContext context, double totalClassAmount) {
    if (transactions.isEmpty) {
      return EmptyWidget(height: 160.0, label: 'No transactions in ${genre.title.toLowerCase()}');
    }

    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 240.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final genre = transaction.amcGenre;
          final shareWithinClass = transaction.totalAmount / totalClassAmount;
          final overallShare = transaction.totalAmount / totalInvestedAmount;

          // final tags = [amc.plan, amc.sector, amc.subSector].whereNotNull().toList(growable: false);
          // final tags = genre.tags?.toList() ?? <String>[];

          return Material(
            elevation: 1.0,
            borderRadius: BorderRadius.circular(12.0),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: SizedBox(
                    width: 160.0,
                    height: 192.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // ~ Amc name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(genre.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 4.0),

                        // ~ Amc tags like plan, scheme, sector, sub_sector etc.
                        // SizedBox(
                        //   height: 24.0,
                        //   child: ListView.separated(
                        //     scrollDirection: Axis.horizontal,
                        //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        //     separatorBuilder: (_, __) => const SizedBox(width: 8.0),
                        //     itemBuilder: (context, i) {
                        //       final tag = tags[i];
                        //       return Center(
                        //         child: ConstrainedBox(
                        //           constraints: const BoxConstraints(maxWidth: 96.0),
                        //           child: Material(
                        //             color: const Color.fromARGB(255, 5, 60, 141),
                        //             shape: const StadiumBorder(),
                        //             child: Padding(
                        //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        //               child: Text(
                        //                 tag,
                        //                 style: textTheme.labelSmall?.copyWith(color: Colors.white),
                        //                 overflow: TextOverflow.ellipsis,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     itemCount: tags.length,
                        //   ),
                        // ),
                        const SizedBox(height: 16.0),
                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: <Widget>[
                              // ~ Amount
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  transaction.totalAmount.toCompact(),
                                  textAlign: TextAlign.right,
                                  style: textTheme.headlineSmall,
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // ~ % Share within genre
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(transaction.amcGenre.title, style: textTheme.labelSmall),
                                      Text('${(shareWithinClass * 100).toCompact()}%', style: textTheme.labelSmall),
                                    ],
                                  ),
                                  LinearPercentIndicator(
                                    percent: shareWithinClass.isNegative ? 0.0 : shareWithinClass,
                                    backgroundColor: Colors.teal.withAlpha(50),
                                    progressColor: Colors.teal,
                                    lineHeight: 4.0,
                                    padding: EdgeInsets.zero,
                                    barRadius: const Radius.circular(8.0),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),

                              // ~ % Overall share
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Total', style: textTheme.labelSmall),
                                        Text('${(overallShare * 100).toCompact()}%', style: textTheme.labelSmall),
                                      ],
                                    ),
                                  ),
                                  LinearPercentIndicator(
                                    percent: overallShare.isNegative ? 0.0 : overallShare,
                                    backgroundColor: Colors.teal.withAlpha(50),
                                    progressColor: Colors.teal,
                                    lineHeight: 4.0,
                                    padding: EdgeInsets.zero,
                                    barRadius: const Radius.circular(8.0),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 16.0),
      ),
    );
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => const Size.fromHeight(0.0);
}
