import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AmcOverviewPage extends StatelessWidget {
  const AmcOverviewPage(this.amcId, {super.key});

  final String amcId;

  @override
  Widget build(BuildContext context) {
    final trnRepository = TransactionRepository.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AmcOverviewCubit(repository: AmcRepository.instance)),
        BlocProvider(create: (context) => TransactionsCubit(repository: trnRepository)),
      ],
      child: _AmcOverviewScreen(amcId),
    );
  }
}

class _AmcOverviewScreen extends StatefulWidget {
  const _AmcOverviewScreen(this.amcId, {super.key});

  final String amcId;

  @override
  State<_AmcOverviewScreen> createState() => _AmcOverviewScreenState();
}

class _AmcOverviewScreenState extends State<_AmcOverviewScreen> {
  @override
  void initState() {
    super.initState();
    _getAmcOverview();
    _getStats();
  }

  @override
  void didUpdateWidget(covariant _AmcOverviewScreen oldWidget) {
    if (oldWidget.amcId != widget.amcId) {
      _getAmcOverview();
      _getStats();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _getAmcOverview() {
    context.read<AmcOverviewCubit>().fetchAmcOverview(widget.amcId);
  }

  void _getStats() {
    final accountId = context.read<AppCubit>().state.primaryAccountId;
    if (accountId?.isEmpty ?? true) {
      return;
    }
    context.read<TransactionsCubit>().fetchTransactions(accountId: accountId, amcId: widget.amcId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
      builder: (context, amcState) {
        final latestPrice = amcState is AmcOverviewLoadedState && amcState.latestPrice != null
            ? amcState.latestPrice
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Holding details')),
          body: Column(
            children: <Widget>[
              BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, trnState) {
                  final isError = trnState.isError;
                  final isLoading = !isError && trnState.isLoading;
                  // final stats = accountsState.isEmpty
                  //     ? <TransactionStat>[]
                  //     : statState is TransactionStatLoadedState
                  //     ? statState.stats
                  //     : null;
                  // final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalAmount);
                  final totalUnits = trnState.transactions?.fold<double>(0.0, (v, el) => v + el.quantity);
                  final totalAmountInvested = trnState.transactions?.fold<double>(0.0, (v, el) => v + el.totalAmount);

                  final currentValue = totalUnits != null && (latestPrice?.$2?.isFinite ?? false)
                      ? totalUnits * latestPrice!.$2!
                      : null;

                  return Skeletonizer(
                    enabled: isLoading,
                    child: Section(
                      title: amcState is AmcOverviewLoadedState && amcState.amc != null
                          ? FadeIn(key: Key('amc_loaded'), child: Text(amcState.amc!.name))
                          : Text(widget.amcId),
                      subTitle: Text('Overview'), // TODO: Show amc tags
                      tiles: <Widget>[
                        SectionTile(
                          title: const Text('No. of units'),
                          trailingIcon: totalUnits != null ? Text('$totalUnits') : const Text('...'), // TODO: Fix this
                        ),
                        SectionTile(
                          title: const Text('Current value'),
                          subtitle: latestPrice != null
                              ? FormattedDate(date: latestPrice.$1)
                              : FormattedDate(date: DateTime.now()),
                          trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivateMode) {
                              return CurrencyView(
                                amount: (totalUnits?.isFinite ?? false) && (latestPrice?.$2?.isFinite ?? false)
                                    ? totalUnits! * latestPrice!.$2!
                                    : 0.0,
                                integerStyle: textTheme.headlineLarge,
                                decimalsStyle: textTheme.headlineSmall,
                                currencyStyle: textTheme.bodyMedium,
                                privateMode: isPrivateMode,
                                // compactView: snapshot.data! >= 1_00_00_000
                              );
                            },
                          ),
                        ),
                        SectionTile(
                          title: const Text('Invested'),
                          trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivateMode) {
                              return CurrencyView(
                                amount: totalAmountInvested ?? 0.0,
                                integerStyle: textTheme.headlineLarge,
                                decimalsStyle: textTheme.headlineSmall,
                                currencyStyle: textTheme.bodyMedium,
                                privateMode: isPrivateMode,
                                // compactView: snapshot.data! >= 1_00_00_000
                              );
                            },
                          ),
                        ),
                        _buildDetailRow('Total returns', '+₹1,035.00 (14.79%)', valueColor: Colors.teal.shade500),
                        _buildDetailRow('1D returns', '+₹77.00 (0.97%)', valueColor: Colors.teal.shade500),
                        _buildDetailRow('Mkt. price', '₹160.70'),
                        _buildDetailRow('Avg. price', '₹140.00'),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ~ Holding Transactions Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Holding transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Avg price (Invested)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('50 qty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('08 Nov \'24', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹140.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          SizedBox(height: 4),
                          Text('(₹7,000.00)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Buy/Sell Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Sell', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Buy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return SectionTile(
      title: Text(label),
      trailingIcon: Text(value, style: TextStyle(color: valueColor ?? Colors.black)),
    );
  }
}
