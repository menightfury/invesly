// ignore_for_file: unused_element

import 'package:flutter/rendering.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common_libs.dart';
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
        if (state is UsersErrorState) {
          context.go(AppRouter.error);
        } else if (state is UsersLoadedState && state.hasNoUser) {
          context.go(AppRouter.editUser);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<UsersCubit, UsersState>(
            builder: (context, state) {
              if (state is UsersLoadedState) {
                final users = state.users;

                return SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ~~~ Greeting message ~~~
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(DateTime.now().greetingsMsg, style: textTheme.headlineMedium),
                      ),

                      // // ~~~ Add user button ~~~
                      // IconButton(
                      //   onPressed: () => context.push(AppRouter.editUser),
                      //   icon: Icon(Icons.add_circle_outline_rounded),
                      //   tooltip: 'Add user',
                      // ),

                      // ~~~ Transactions Stats ~~~
                      BlocProvider(
                        create: (context) => DashboardCubit(repository: context.read<TransactionRepository>()),
                        child: _DashboardContents(users),
                      ),
                      const SizedBox(height: 56.0),
                    ],
                  ),
                );
              }

              // ~~~ User not loaded state ~~~
              return const Center(child: CircularProgressIndicator());
            },
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
  const _DashboardContents(this.users, {super.key});

  final List<InveslyUser> users;

  @override
  State<_DashboardContents> createState() => _DashboardContentsState();
}

class _DashboardContentsState extends State<_DashboardContents> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().fetchTransactionStats();
  }

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardErrorState) {
          return const PMErrorWidget();
        }

        if (state is DashboardLoadedState) {
          final stats = state.summaries;
          final totalAmount = stats.fold<double>(0, (v, el) => v + el.totalAmount);
          final recentTransactions = state.recentTransactions;

          return Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TransactionStatsWidget(stats, widget.users),

              _RecentTransactions(recentTransactions: recentTransactions),
            ],
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({super.key, required this.recentTransactions});

  final List<InveslyTransaction> recentTransactions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        spacing: 8.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Recent transactions', style: Theme.of(context).textTheme.headlineSmall),
          ColumnBuilder(
            itemBuilder: (context, index) {
              final rt = recentTransactions[index];
              return ListTile(
                title: Text(rt.amc?.name ?? 'NULL'),
                subtitle: Text(
                  rt.userId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                trailing: Text('Rs. ${rt.totalAmount}'),
                onTap: () {},
                contentPadding: EdgeInsets.zero,
              );
            },
            itemCount: recentTransactions.length,
          ),
        ],
      ),
    );
  }
}

class _TransactionStatsWidget extends StatefulWidget {
  const _TransactionStatsWidget(this.stats, this.users, {super.key});

  final List<TransactionStat> stats;
  final List<InveslyUser> users;

  @override
  State<_TransactionStatsWidget> createState() => _TransactionStatsWidgetState();
}

class _TransactionStatsWidgetState extends State<_TransactionStatsWidget> {
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0, viewportFraction: 0.9);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // grouping stats based on user_id
    final statsMap = groupBy(widget.stats, (stat) => stat.userId);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 280.0,
      child: PageView.builder(
        clipBehavior: Clip.none,
        controller: _pageController,
        itemBuilder: (context, index) {
          final statEntry = statsMap.entries.elementAt(index);
          final user = widget.users.firstWhereOrNull((u) => u.id == statEntry.key);
          final totalAmount = statEntry.value.fold<double>(0, (v, el) => v + el.totalAmount);

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, _) {
              double scale = 1.0;
              double itemOffset = 0.0;
              double page = _pageController.initialPage.toDouble();
              final position = _pageController.position;
              if (position.hasPixels && position.hasContentDimensions) {
                page = _pageController.page ?? page;
              }
              itemOffset = page - index;

              final num t = (1 - (itemOffset.abs() * 0.6)).clamp(0.3, 1.0);
              scale = Curves.easeOut.transform(t as double);

              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation: 3.0,
                  borderRadius: BorderRadius.circular(12.0),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16.0,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 32.0,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  spacing: 4.0,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(user?.name ?? statEntry.key, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(
                                      totalAmount.toCompact(),
                                      style: textTheme.headlineLarge?.copyWith(fontSize: 24.0),
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                backgroundImage: user != null ? AssetImage(user.avatar) : null,
                                child: user == null ? Icon(Icons.person_pin) : null,
                              ),
                            ],
                          ),

                          ColumnBuilder(
                            mainAxisSize: MainAxisSize.min,

                            itemCount: AmcGenre.values.length,
                            itemBuilder: (context, index) {
                              final genre = AmcGenre.values[index];
                              final stat = statEntry.value.firstWhereOrNull((el) => el.amcGenre == genre);
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(genre.title),
                                      Text('${stat?.numTransactions ?? 0} transactions', style: textTheme.labelSmall),
                                    ],
                                  ),
                                  Text(
                                    '${stat?.totalAmount ?? 0}',
                                    style: textTheme.headlineLarge?.copyWith(fontSize: 16.0),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        itemCount: statsMap.length,
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
