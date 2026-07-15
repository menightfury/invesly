import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/view/account_details/cubit/account_details_cubit.dart';
import 'package:invesly/accounts/view/account_details/widgets/account_net_worth_widget.dart';
import 'package:invesly/accounts/view/account_details/widgets/genre_investment_breakdown_widget.dart';
import 'package:invesly/accounts/view/account_details/widgets/genre_pie_chart_widget.dart';
import 'package:invesly/stat/model/stat_repository.dart';
import 'package:invesly/common_libs.dart';

part 'widgets/account_details_header.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key, required this.account});

  final InveslyAccount account;

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AccountDetailsCubit(repository: StatRepository.instance)..fetchAccountStats(widget.account.id),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // ~~~ Header with back button and account info ~~~
            SliverAppBar(
              pinned: true,
              leading: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Align(child: Icon(Icons.arrow_back_rounded)),
              ),
              title: Text(widget.account.name, style: context.textTheme.headlineSmall),
              centerTitle: false,
            ),

            const SliverGap(16.0),

            // ~~~ Account Details Content ~~~
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverMainAxisGroup(
                slivers: <Widget>[
                  // ~~~ Net Worth Section ~~~
                  SliverToBoxAdapter(child: _AccountDetailsHeader(account: widget.account)),

                  const SliverGap(24.0),

                  // ~~~ Net Worth Display ~~~
                  SliverToBoxAdapter(child: AccountNetWorthWidget()),

                  const SliverGap(24.0),

                  // ~~~ Pie Chart ~~~
                  SliverToBoxAdapter(child: GenrePieChartWidget()),

                  const SliverGap(24.0),

                  // ~~~ Genre-wise Investment Breakdown ~~~
                  SliverToBoxAdapter(child: GenreInvestmentBreakdownWidget()),

                  const SliverGap(80.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
