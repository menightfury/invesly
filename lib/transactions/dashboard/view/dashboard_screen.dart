// ignore_for_file: unused_element

import 'package:flutter/rendering.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/users/model/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> isFloatingButtonExtended = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      bool shouldExtendButton =
          _scrollController.offset <= 10 || _scrollController.position.userScrollDirection != ScrollDirection.reverse;

      if (isFloatingButtonExtended.value != shouldExtendButton) {
        isFloatingButtonExtended.value = shouldExtendButton;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<UsersCubit, UsersState>(
      listener: (context, state) {
        if (state is UsersLoadedState && state.hasNoUser && context.read<SettingsCubit>().state.currentUserId == null) {
          context.go(AppRouter.editUser);
        }
        // if (state is UsersErrorState) {
        //   context.go(AppRouter.error);
        // } else if (state is UsersLoadedState && state.hasNoUser) {
        //   context.go(AppRouter.editUser);
        // }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: BlocSelector<SettingsCubit, SettingsState, String?>(
              selector: (state) => state.currentUserId,
              builder: (context, userId) {
                final usersState = context.read<UsersCubit>().state;
                final users = usersState is UsersLoadedState ? usersState.users : <InveslyUser>[];
                final currentUser =
                    users.isEmpty ? null : users.firstWhere((u) => u.id == userId, orElse: () => users.first);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ~~~ Greeting message ~~~
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(DateTime.now().greetingsMsg, style: textTheme.headlineSmall),
                              Text(currentUser?.name ?? 'Investor', style: textTheme.headlineMedium),
                            ],
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => context.push(AppRouter.settings),
                            icon: CircleAvatar(
                              backgroundImage: currentUser != null ? AssetImage(currentUser.avatar) : null,
                              child: currentUser == null ? Icon(Icons.person_pin) : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ~~~ Dashboard contents ~~~
                    BlocProvider(
                      create: (context) => DashboardCubit(repository: context.read<TransactionRepository>()),
                      child: _DashboardContents(currentUser, key: ValueKey<String?>(currentUser?.id)),
                    ),

                    // const SizedBox(height: 56.0),
                  ],
                );
              },
            ),
          ),
        ),
        floatingActionButton: ValueListenableBuilder(
          valueListenable: isFloatingButtonExtended,
          builder: (context, isExtended, _) {
            return NewTransactionButton(isExtended: isExtended);
          },
        ),
      ),
    );
  }
}

class NewTransactionButton extends StatelessWidget {
  const NewTransactionButton({super.key, this.isExtended = true});

  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: null,
      onPressed: () => context.push(AppRouter.editTransaction),
      icon: const Icon(Icons.add_rounded),
      extendedPadding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      extendedIconLabelSpacing: isExtended ? 8 : 0,
      label: AnimatedExpanded(expand: isExtended, child: Text('New transaction')),
    );
  }
}

class _DashboardContents extends StatefulWidget {
  const _DashboardContents(this.user, {super.key});

  final InveslyUser? user;

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
    final textTheme = Theme.of(context).textTheme;

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
                // ~~~ Total amount ~~~
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoadedState) {
                      final totalAmount = state.summaries.fold<double>(0, (v, el) => v + el.totalAmount);
                      return Text(
                        totalAmount.toCompact(),
                        style: textTheme.headlineLarge?.copyWith(fontSize: 48.0, height: 1.5),
                      );
                    }
                    return Text('Loading...');
                  },
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Rs. 0.0', style: textTheme.headlineSmall?.copyWith(fontSize: 13.0)),
                      TextSpan(text: ' invested this month'),
                    ],
                    style: TextStyle(fontSize: 13.0),
                  ),
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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      spacing: 8.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Recent transactions', style: Theme.of(context).textTheme.headlineSmall),
        ),
        BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoadedState) {
              final recentTransactions = state.recentTransactions;
              return ColumnBuilder(
                itemBuilder: (context, index) {
                  final rt = recentTransactions[index];
                  return ListTile(
                    leading:
                        rt.transactionType == TransactionType.invested
                            ? Icon(Icons.north_east_rounded)
                            : Icon(Icons.south_west_rounded), // TODO: Icon of AmcGenre
                    title: Text(rt.amc?.name ?? 'NULL', style: textTheme.bodyMedium),
                    subtitle: Text(
                      rt.investedOn.toReadable(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall,
                    ),
                    trailing: Text(
                      'Rs. ${rt.totalAmount}',
                      style: textTheme.headlineSmall?.copyWith(
                        color: rt.transactionType == TransactionType.invested ? Colors.deepOrange : Colors.teal,
                      ),
                    ),
                    onTap: () {},
                  );
                },
                itemCount: recentTransactions.length,
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
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
    final textTheme = Theme.of(context).textTheme;
    // final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 120.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final genre = AmcGenre.getByIndex(index);

          return Material(
            borderRadius: BorderRadius.circular(8.0),
            elevation: 3.0,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 160.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(genre.title, style: textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                    const Gap(8.0),
                    BlocBuilder<DashboardCubit, DashboardState>(
                      builder: (context, state) {
                        if (state is DashboardLoadedState) {
                          final stats = state.summaries.firstWhereOrNull((stat) => stat.amcGenre == genre);

                          return Text(stats?.totalAmount.toCompact() ?? '0.0', style: textTheme.headlineMedium);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: AmcGenre.values.length,
        separatorBuilder: (_, _) => SizedBox(width: 16.0),
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
        separatorBuilder: (_, __) => const SizedBox(width: 16.0),
      ),
    );
  }
}
