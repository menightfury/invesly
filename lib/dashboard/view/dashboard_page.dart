// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:math' as math;

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_page.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/view/account_details/account_details_page.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/dashboard/cubit/dashboard_cubit.dart';
import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/components/add_transaction_button.dart';
import 'package:invesly/connectivity/internet_aware_http_client.dart';
// import 'package:invesly/common/presentations/widgets/single_digit_flip_counter.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/settings_page.dart';
import 'package:invesly/genre/view/genre_details/genre_details_page.dart';
import 'package:invesly/stat/cubit/stat_cubit.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_page.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';
import 'package:invesly/transactions/transactions/transactions_page.dart';

part 'widgets/accounts_list_widget.dart';
part 'widgets/genre_summeries_widget.dart';
part 'widgets/recent_transaction_widget.dart';
part 'widgets/spending_pie_chart.dart';
part 'widgets/transaction_summery.dart';
part 'widgets/individual_genre_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final statCubit = context.read<StatCubit>();
    if (!statCubit.state.isLoaded) {
      statCubit.fetchAllStats();
    }
    _checkAndUpdateAmcData(context);
  }

  // check amc status is latest or not
  Future<void> _checkAndUpdateAmcData(BuildContext context) async {
    final appState = context.read<AppCubit>().state;
    final client = InternetAwareHttpClient();

    try {
      final response = await client.get(
        Uri.parse('https://api.github.com/repos/menightfury/invesly-data/contents/amcs.json'),
      );

      final amcRepository = AmcRepository.instance;
      // If the server did return a 200 OK response, parse the JSON.
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final sha = decoded['sha'] as String?;
        final url = decoded['download_url'] as String?;
        if (sha != null && sha != appState.amcSha && url != null) {
          // If sha is not same, it means amcs in remote location have changed
          // Fetch and update amcs
          final amcs = await amcRepository.getAmcsFromNetwork(client, url);
          $logger.w(amcs);
          // write amcs to database
          if (amcs != null && amcs.isNotEmpty) {
            await amcRepository.saveAmcs(amcs);
          }
          if (!context.mounted) {
            return;
          }
          // update amc sha key in app state
          context.read<AppCubit>().updateAmcSha(sha);
        }
      }
    } on NetworkException catch (e) {
      $logger.e('Network error: Failed to fetch amc data: $e');
    } catch (e) {
      $logger.e('Failed to fetch amc data', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final trnRepository = TransactionRepository.instance;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              leading: Align(child: Image.asset('assets/images/icon/icon.png', height: 48.0)),
              titleSpacing: 0.0,
              actions: <Widget>[
                // ~~~ User avatar ~~~
                GestureDetector(
                  onTap: () => context.push(const SettingsPage()),
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

            // ~~~ Greetings ~~~
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(DateTime.now().greetingsMsg, overflow: TextOverflow.ellipsis, style: textTheme.headlineSmall),
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
            ),

            const SliverGap(16.0),

            // ~~~ Accounts, Stats, Recent transactions etc. ~~~
            MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => TransactionsCubit(repository: trnRepository)),
                BlocProvider(create: (context) => DashboardCubit()),
              ],
              child: _DashboardScreenContent(),
            ),

            const SliverGap(80.0),
          ],
        ),
      ),
      // ~~~ Add transaction button ~~~
      floatingActionButton: AddTransactionButton(
        scrollController: _scrollController,
        onPressed: () {
          context.push(EditTransactionPage(initialAccountId: context.read<AppCubit>().state.primaryAccountId));
        },
      ),
    );
  }
}

class _DashboardScreenContent extends StatefulWidget {
  const _DashboardScreenContent({super.key, this.accountId});

  final int? accountId;

  @override
  State<_DashboardScreenContent> createState() => _DashboardScreenContentState();
}

class _DashboardScreenContentState extends State<_DashboardScreenContent> {
  @override
  void initState() {
    super.initState();
    _getTransactions();
  }

  void _getTransactions() {
    // if (widget.accountId == null) {
    //   return;
    // }
    context.read<TransactionsCubit>().fetchTransactions(accountId: widget.accountId, limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _AccountsList()), // Depends on Accounts State & Stat State
        const SliverGap(16.0),

        SliverToBoxAdapter(child: _GenreSummariesWidget()), // Depends on Stat State
        const SliverGap(16.0),

        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16.0,
            children: AmcGenre.values.map((genre) => _IndividualGenreWidget(genre)).toList(),
          ),
        ), // Depends on Stat State
        const SliverGap(16.0),

        SliverToBoxAdapter(child: _RecentTransactions()), // Depends on Transactions State
      ],
    );
  }
}
