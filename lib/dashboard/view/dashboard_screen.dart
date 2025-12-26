// ignore_for_file: unused_element

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:invesly/common/presentations/components/add_transaction_button.dart';
import 'package:invesly/common/presentations/widgets/circle_avatar.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common/presentations/widgets/single_digit_flip_counter.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/settings_screen.dart';
import 'package:invesly/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';
import 'package:invesly/transactions/transactions/transactions_page.dart';

part 'widgets/accounts.dart';
part 'widgets/categories_widget.dart';
part 'widgets/recent_transaction_widget.dart';
part 'widgets/spending_pie_chart.dart';
part 'widgets/transaction_stat.dart';

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
      body: SafeArea(
        child: BlocProvider(
          create: (context) => TransactionsCubit(repository: context.read<TransactionRepository>()),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                leading: Align(child: Image.asset('assets/images/app_icon/app_icon.png', height: 48.0)),
                titleSpacing: 0.0,
                actions: <Widget>[
                  // ~~~ User avatar ~~~
                  GestureDetector(
                    onTap: () => context.push(const SettingsScreen()),
                    child: BlocSelector<AppCubit, AppState, InveslyUser?>(
                      selector: (state) => state.user,
                      builder: (context, currentUser) {
                        return currentUser.isNotNullOrEmpty
                            ? InveslyUserCircleAvatar(user: currentUser!)
                            : CircleAvatar(child: const Icon(Icons.person_rounded));
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
                        BlocSelector<AppCubit, AppState, InveslyUser?>(
                          selector: (state) => state.user,
                          builder: (context, currentUser) {
                            return Text(
                              currentUser.isNotNullOrEmpty ? currentUser!.name : 'Investor',
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineMedium,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(16.0),

                  // ~~~ Accounts ~~~
                  _AccountsList(),
                  const Gap(16.0),

                  // ~~~ Stats, Recent transactions etc. ~~~
                  BlocProvider(
                    create: (context) => DashboardCubit(
                      repository: context.read<TransactionRepository>(),
                    ), // TODO: Remove DashboardCubit completely
                    child: _DashboardContents(),
                  ),
                  const Gap(80.0),
                ]),
              ),
            ],
          ),
        ),
      ),
      // ~~~ Add transaction button ~~~
      floatingActionButton: AddTransactionButton(scrollController: _scrollController),
    );
  }
}

class _DashboardContents extends StatefulWidget {
  const _DashboardContents({super.key});

  @override
  State<_DashboardContents> createState() => _DashboardContentsState();
}

class _DashboardContentsState extends State<_DashboardContents> {
  late final DateTimeRange<DateTime> dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);
    // final endOfMonth = DateTime(now.year, now.month + 1, 0);
    dateRange = DateTimeRange(start: startOfYear, end: now);
    context.read<DashboardCubit>().fetchTransactionStats(
      dateRange: dateRange,
      limit: 3,
    ); // TODO: Remove dashboard cubit completely
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _CategoriesWidget(),
        BlocSelector<AppCubit, AppState, String?>(
          selector: (state) => state.primaryAccountId,
          builder: (context, primaryAccountId) {
            // fetch recent transactions
            context.read<TransactionsCubit>().fetchTransactions(
              // dateRange: dateRange,
              accountId: primaryAccountId,
              limit: 3,
            );
            return _RecentTransactions(period: dateRange);
          },
        ),
      ],
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
