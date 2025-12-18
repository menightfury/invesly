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
import 'package:invesly/common/presentations/animations/scroll_to_hide.dart';
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:invesly/common/presentations/widgets/circle_avatar.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/settings_screen.dart';
import 'package:invesly/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_screen.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
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
  void initState() {
    super.initState();
    context.read<AccountsCubit>().fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Scaffold(
      body: SafeArea(
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
                  create: (context) => DashboardCubit(repository: context.read<TransactionRepository>()),
                  child: _DashboardContents(),
                ),
                const Gap(80.0),
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
          child: const Padding(padding: EdgeInsets.only(left: 8.0), child: Text('New transaction')),
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
          icon: const Icon(Icons.warning_amber_rounded),
          content: const Text(
            'You must have at least one no-archived account before you can start creating transactions',
          ),
          confirmText: 'Continue',
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
    context.read<DashboardCubit>().fetchTransactionStats(dateRange: dateRange, limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _CategoriesWidget(),

        BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
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
