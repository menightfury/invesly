// ignore_for_file: unused_element

import 'package:animate_do/animate_do.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/authentication/user_model.dart';

import 'package:invesly/common/presentations/animations/scroll_to_hide.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/cubit/database_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/settings/settings_screen.dart';
import 'package:invesly/transactions/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_screen_classic.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    context.read<DatabaseCubit>().loadDatabase().then((_) {
      context.read<AccountsCubit>().fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: BlocBuilder<DatabaseCubit, DatabaseState>(
          builder: (context, state) {
            if (state is DatabaseError) {
              return Center(child: Text('Error: ${state.message}', style: textTheme.bodyLarge));
            }

            if (state is DatabaseLoaded) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    leading: Align(child: Image.asset('assets/images/app_icon/app_icon.png', height: 32.0)),
                    // title:
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
                      // BlocSelector<SettingsCubit, SettingsState, String?>(
                      //   selector: (state) => state.currentAccountId,
                      //   builder: (context, currentAccountId) {
                      //     final accountsState = context.read<AccountsCubit>().state;
                      //     final accounts =
                      //         accountsState is AccountsLoadedState ? accountsState.accounts : <InveslyAccount>[];
                      //     final currentAccount =
                      //         accounts.isEmpty
                      //             ? null
                      //             : accounts.firstWhere((a) => a.id == currentAccountId, orElse: () => accounts.first);

                      //     return IconButton(
                      //       padding: EdgeInsets.zero,
                      //       onPressed: () => context.push(const SettingsScreen()),
                      //       icon: CircleAvatar(
                      //         backgroundImage: currentAccount != null ? AssetImage(currentAccount.avatar) : null,
                      //         child: currentAccount == null ? Icon(Icons.person_pin) : null,
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                    actionsPadding: EdgeInsets.only(right: 16.0),
                  ),

                  SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      // ~~~ Greetings ~~~
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
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
                          ],
                        ),
                      ),

                      const Gap(16.0),

                      // ~~~ Accounts ~~~
                      AccountsList(),

                      BlocSelector<SettingsCubit, SettingsState, String?>(
                        selector: (state) => state.currentAccountId,
                        builder: (context, currentAccountId) {
                          final usersState = context.read<AccountsCubit>().state;
                          final users = usersState is AccountsLoadedState ? usersState.accounts : <InveslyAccount>[];
                          final currentUser = users.isEmpty
                              ? null
                              : users.firstWhere((u) => u.id == currentAccountId, orElse: () => users.first);
                          return BlocProvider(
                            create: (context) => DashboardCubit(repository: context.read<TransactionRepository>()),
                            child: _DashboardContents(currentUser, key: ValueKey<String?>(currentUser?.id)),
                          );
                        },
                      ),
                      SizedBox(height: 80.0), // ! for testing
                    ]),
                  ),
                ],
              );
            }

            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16.0,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  Text('Database loading...', style: textTheme.bodyLarge),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _handlePressed(context),
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

  void _handlePressed(BuildContext context) async {
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

class AccountsList extends StatelessWidget {
  const AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BlocBuilder<AccountsCubit, AccountsState>(
          // stream: AccountService.instance.getAccounts(predicate: (acc, curr) => acc.closingDate.isNull()),
          builder: (context, state) {
            if (state is AccountsErrorState) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is AccountsLoadedState) {
              final accounts = state.accounts;
              return Row(
                spacing: 8.0,
                children: <Widget>[
                  // ~~~ Accounts ~~~
                  ...List.generate(accounts.length, (index) {
                    final account = accounts.elementAt(index);

                    return Tappable(
                      // onTap: () => RouteUtils.pushRoute(
                      //       context,
                      //       AccountDetailsPage(
                      //         account: account,
                      //         accountIconHeroTag: 'dashboard-page__account-icon-${account.id}',
                      //       ),
                      //     ),
                      // bgColor: Theme.of(context).cardColor,
                      // borderRadius: BorderRadius.circular(16.0),
                      // padding: const EdgeInsets.all(16.0),
                      // leading: Hero(
                      //   tag: 'dashboard-page__account-icon-${account.id}',
                      //   child: account.displayIcon(context, size: 28),
                      // ),
                      width: 120.0,
                      height: 80.0,
                      border: BorderSide(color: context.colors.primary, width: 1.0),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4.0,
                        children: <Widget>[
                          Text(account.name),
                          Row(
                            children: [
                              // StreamBuilder(
                              //   initialData: 0.0,
                              //   stream: AccountService.instance.getAccountMoney(account: account),
                              //   builder: (context, snapshot) {
                              //     return CurrencyDisplayer(
                              //       amountToConvert: snapshot.data!,
                              //       currency: account.currency,
                              //       compactView: snapshot.data! >= 10000000,
                              //       integerStyle: Theme.of(
                              //         context,
                              //       ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                              //     );
                              //   },
                              // ),
                              CurrencyView(
                                amount: 500.0,
                                compactView: true,
                                integerStyle: context.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              // StreamBuilder(
                              //   initialData: 0.0,
                              //   stream: AccountService.instance.getAccountsMoneyVariation(
                              //     accounts: [account],
                              //     startDate: dateRangeService.startDate,
                              //     endDate: dateRangeService.endDate,
                              //     convertToPreferredCurrency: false,
                              //   ),
                              //   builder: (context, snapshot) {
                              //     return TrendingValue(percentage: snapshot.data!, decimalDigits: 0);
                              //   },
                              // ),
                            ],
                          ),
                          Spacer(),
                          Text('5 transactions', style: context.textTheme.labelSmall),
                        ],
                      ),
                    );
                  }),

                  // ~~~ Add account ~~~
                  Tappable(
                    onTap: () => context.push(const EditAccountScreen()),
                    color: Colors.grey.shade100,
                    width: 120.0,
                    height: 80.0,
                    border: BorderSide(color: Colors.grey.shade500, width: 1.0),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4.0,
                      children: [
                        Icon(Icons.format_list_bulleted_add, color: Colors.grey.shade500),
                        Text('Create account', style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class ShakeTestWidget extends StatefulWidget {
  const ShakeTestWidget({super.key});

  @override
  State<ShakeTestWidget> createState() => _ShakeTestWidgetState();
}

class _ShakeTestWidgetState extends State<ShakeTestWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 1.seconds);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _controller.forward();
        if (_controller.status == AnimationStatus.completed) {
          _controller.reset();
        }
      },
      child: ShakeX(child: Text('This is shaking...')),
    );
  }
}

class _DashboardContents extends StatefulWidget {
  const _DashboardContents(this.user, {super.key});

  final InveslyAccount? user;

  @override
  State<_DashboardContents> createState() => _DashboardContentsState();
}

class _DashboardContentsState extends State<_DashboardContents> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().fetchTransactionStats(widget.user?.id);
  }

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: <Widget>[
                Text('Total investment', style: context.textTheme.bodySmall),
                // ~~~ Total amount ~~~
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoadedState) {
                      final totalAmount = state.summaries.fold<double>(0, (v, el) => v + el.totalAmount);
                      // return Text(totalAmount.toCompact(), style: textTheme.headlineLarge?.copyWith(fontSize: 48.0));
                      return BlocSelector<SettingsCubit, SettingsState, bool>(
                        selector: (state) => state.isPrivateMode,
                        builder: (context, isPrivateMode) {
                          return CurrencyView(
                            amount: totalAmount,
                            integerStyle: textTheme.headlineLarge?.copyWith(fontSize: 48.0),
                            decimalsStyle: textTheme.headlineSmall?.copyWith(fontSize: 24.0),
                            currencyStyle: textTheme.bodyMedium,
                            privateMode: isPrivateMode,
                          );
                        },
                      );
                    }
                    return Text('Loading...');
                  },
                ),
                // Text.rich(
                //   TextSpan(
                //     children: [
                //       TextSpan(text: 'Rs. 0.0', style: context.textTheme.headlineSmall?.copyWith(fontSize: 13.0)),
                //       TextSpan(text: ' invested this month'),
                //     ],
                //     style: context.textTheme.bodySmall,
                //   ),
                // ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BlocSelector<SettingsCubit, SettingsState, bool>(
                      selector: (state) => state.isPrivateMode,
                      builder: (context, isPrivateMode) {
                        return CurrencyView(
                          // amount: totalAmount,
                          amount: 510.0, // TODO:
                          integerStyle: context.textTheme.labelSmall,
                          privateMode: isPrivateMode,
                        );
                      },
                    ),
                    Text(' invested this month', style: context.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ),
        ),

        _TransactionStatsWidget(),

        _RecentTransactions(),
      ],
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

class _TransactionStatsWidget extends StatefulWidget {
  const _TransactionStatsWidget({super.key});

  @override
  State<_TransactionStatsWidget> createState() => _TransactionStatsWidgetState();
}

class _TransactionStatsWidgetState extends State<_TransactionStatsWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final genre = AmcGenre.getByIndex(index);

          return Material(
            borderRadius: BorderRadius.circular(16.0),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 160.0,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment(1.25, -1.5),
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
                              final stats = state.summaries.firstWhereOrNull((stat) => stat.amcGenre == genre);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                spacing: 20.0,
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
            ),
          );
        },
        itemCount: AmcGenre.values.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.0),
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
