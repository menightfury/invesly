// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_page.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/components/add_transaction_button.dart';
// import 'package:invesly/common/presentations/widgets/single_digit_flip_counter.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/settings_page.dart';
import 'package:invesly/genre/view/genre_details/genre_details_page.dart';
import 'package:invesly/transactions/transaction_stat/cubit/transaction_stat_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';
import 'package:invesly/transactions/transactions/transactions_page.dart';

part 'widgets/accounts.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAndUpdateAmcData(context);
  }

  // check amc status is latest or not
  Future<void> _checkAndUpdateAmcData(BuildContext context) async {
    final appState = context.read<AppCubit>().state;
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse('https://api.github.com/repos/menightfury/invesly-data/contents/amcs.json'),
      );

      // If the server did return a 200 OK response, parse the JSON.
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final sha = decoded['sha'] as String?;
        final url = decoded['download_url'] as String?;
        if (sha != null && sha != appState.amcSha && url != null) {
          // If sha is not same, it means amcs in remote location have changed
          // Fetch and update amcs
          final amcs = await AmcRepository.instance.getAmcsFromNetwork(client, url);
          $logger.w(amcs);
          // write amcs to database
          if (amcs != null && amcs.isNotEmpty) {
            await AmcRepository.instance.saveAmcs(amcs);
          }
          if (!context.mounted) {
            return;
          }
          // update amc sha key in app state
          context.read<AppCubit>().updateAmcSha(sha);
        }
      }
    } catch (e) {
      $logger.e('Failed to fetch amc data', error: e);
    } finally {
      client.close();
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
          slivers: [
            SliverAppBar(
              leading: Align(child: Image.asset('assets/images/app_icon/app_icon.png', height: 48.0)),
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
                MultiBlocProvider(
                  providers: [
                    BlocProvider(create: (context) => TransactionsCubit(repository: trnRepository)),
                    BlocProvider(create: (context) => TransactionStatCubit(trnRepository: trnRepository)),
                  ],
                  child: BlocSelector<AppCubit, AppState, String?>(
                    selector: (state) => state.primaryAccountId,
                    builder: (context, accountId) {
                      return _DashboardScreenContent(accountId: accountId);
                    },
                  ),
                ),

                const Gap(80.0),
              ]),
            ),
          ],
        ),
      ),
      // ~~~ Add transaction button ~~~
      floatingActionButton: AddTransactionButton(scrollController: _scrollController),
    );
  }
}

class _DashboardScreenContent extends StatefulWidget {
  const _DashboardScreenContent({super.key, this.accountId});

  final String? accountId;

  @override
  State<_DashboardScreenContent> createState() => _DashboardScreenContentState();
}

class _DashboardScreenContentState extends State<_DashboardScreenContent> {
  @override
  void initState() {
    super.initState();
    _getStats();
  }

  @override
  void didUpdateWidget(covariant _DashboardScreenContent oldWidget) {
    if (widget.accountId != oldWidget.accountId) {
      _getStats();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _getStats() {
    if (widget.accountId?.isEmpty ?? true) {
      return;
    }
    context.read<TransactionStatCubit>().fetchTransactionStats(widget.accountId!);
    context.read<TransactionsCubit>().fetchTransactions(accountId: widget.accountId, limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16.0,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _GenreSummariesWidget(),
        ...AmcGenre.values.map((genre) => _IndividualGenreWidget(genre)),
        _RecentTransactions(),
      ],
    );
  }
}

// class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
//   const EmptyAppBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(0.0);
// }

enum _DashboardState { loading, loaded, error }
