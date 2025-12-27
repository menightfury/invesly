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
// import 'package:invesly/common/presentations/widgets/single_digit_flip_counter.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/settings_screen.dart';
import 'package:invesly/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';
import 'package:invesly/transactions/transactions/transactions_page.dart';

part 'widgets/accounts.dart';
part 'widgets/genre_summeries_widget.dart';
part 'widgets/recent_transaction_widget.dart';
part 'widgets/spending_pie_chart.dart';
part 'widgets/transaction_stat.dart';
part 'widgets/mutualfund_widget.dart';
part 'widgets/stock_widget.dart';

enum _AccountsStatus {
  initial,
  loading,
  loaded,
  error;

  bool get isLoading => this == _AccountsStatus.initial || this == _AccountsStatus.loading;
  bool get isLoaded => this == _AccountsStatus.loaded;
  bool get isError => this == _AccountsStatus.error;
}

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
                  // BlocProvider(
                  //   create: (context) => DashboardCubit(
                  //     repository: context.read<TransactionRepository>(),
                  //   ), // TODO: Remove DashboardCubit completely
                  //   child:
                  _DashboardContents(),
                  // ),
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
  // @override
  // void initState() {
  //   super.initState();
  //   // context.read<DashboardCubit>().fetchTransactionStats(); // TODO: Remove dashboard cubit completely
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, accountsState) {
        final status = accountsState.isError
            ? _AccountsStatus.error
            : accountsState.isLoaded
            ? _AccountsStatus.loaded
            : _AccountsStatus.loading;

        return Column(
          spacing: 16.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _GenreSummeriesWidget(status),
            _MutualFundWidget(status),
            _StockWidget(status),
            _RecentTransactions(status),
          ],
        );
      },
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
