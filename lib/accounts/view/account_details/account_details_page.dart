import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/view/account_details/cubit/account_details_cubit.dart';
import 'package:invesly/accounts/view/account_details/widgets/account_net_worth_widget.dart';
import 'package:invesly/accounts/view/account_details/widgets/genre_investment_breakdown_widget.dart';
import 'package:invesly/accounts/view/account_details/widgets/genre_pie_chart_widget.dart';
import 'package:invesly/accounts/view/widgets/account_picker_widget.dart';
import 'package:invesly/stat/cubit/stat_cubit.dart';
import 'package:invesly/stat/model/stat_repository.dart';
import 'package:invesly/common_libs.dart';

part 'widgets/account_details_header.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage(this.account, {super.key});

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
    final statCubit = context.read<StatCubit>();
    if (!statCubit.state.isLoaded) {
      statCubit.fetchAllStats();
    }
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
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                snap: true,
                title: Text(widget.account.name),
                actions: <Widget>[_AccountPickerWidget()],
                actionsPadding: const EdgeInsets.only(right: 16.0),
              ),
              // const SliverGap(16.0),

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
      ),
    );
  }
}

class _AccountPickerWidget extends StatelessWidget {
  const _AccountPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountDetailsCubit, AccountDetailsState, int?>(
      selector: (state) => state.activeAccountId,
      builder: (context, activeAccountId) {
        final accountsState = context.read<AccountsCubit>().state;
        final accounts = (accountsState is AccountsLoadedState) ? accountsState.accounts : null;
        final account = activeAccountId != null && accounts != null && accounts.isNotEmpty
            ? accounts.firstWhereOrNull((a) => a.id == activeAccountId)
            : null;

        return AccountPickerWidget(
          accountId: activeAccountId,
          onPickup: (value) => context.read<AccountDetailsCubit>().updateActiveAccountId(value.id),
          avatar: account?.icon.buildWidget(
            context,
            color: account.color,
            backgroundColor: account.color?.withAlpha(0x33),
          ),
          child: Text(account?.name ?? activeAccountId?.toString() ?? 'Select account'),
        );
      },
    );
  }
}
