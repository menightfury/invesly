import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/view/amc_overview/cubit/amc_overview_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/animations/fade_in.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';

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
    if (mounted) {
      context.read<TransactionsCubit>().fetchTransactions(accountId: accountId, amcId: widget.amcId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AmcOverviewCubit, AmcOverviewState>(
      builder: (context, amcState) {
        final latestPrice = amcState is AmcOverviewLoadedState && amcState.latestPrice != null
            ? amcState.latestPrice
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Holding details')),
          body: Stack(
            children: <Widget>[
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  // ~ Overview Section
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
                      final totalAmountInvested = trnState.transactions?.fold<double>(
                        0.0,
                        (v, el) => v + el.totalAmount,
                      );

                      final currentValue = totalUnits != null && (latestPrice?.$2?.isFinite ?? false)
                          ? totalUnits * latestPrice!.$2!
                          : null;

                      return Skeletonizer(
                        enabled: isLoading,
                        child: Column(
                          spacing: 4.0,
                          children: <Widget>[
                            PhysicalModel(
                              clipBehavior: Clip.antiAlias,
                              color: theme.colorScheme.primaryContainer.darken(3),
                              shadowColor: theme.colorScheme.shadow,
                              borderRadius: iCardBorderRadius.copyWith(
                                bottomLeft: iTileBorderRadius.bottomLeft,
                                bottomRight: iTileBorderRadius.bottomRight,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minHeight: 52.0, minWidth: double.infinity),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      amcState is AmcOverviewLoadedState && amcState.amc != null
                                          ? FadeIn(
                                              key: Key('amc_loaded'),
                                              child: Text(
                                                amcState.amc!.name,
                                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            )
                                          : Text(
                                              widget.amcId,
                                              style: textTheme.headlineMedium?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      const Gap(16.0),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: BlocSelector<AppCubit, AppState, bool>(
                                          selector: (state) => state.isPrivateMode,
                                          builder: (context, isPrivateMode) {
                                            return CurrencyView(
                                              amount:
                                                  (totalUnits?.isFinite ?? false) &&
                                                      (latestPrice?.$2?.isFinite ?? false)
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
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'Current value on March 19, 2026',
                                          style: textTheme.labelMedium?.copyWith(color: theme.disabledColor),
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Row(
                              spacing: 4.0,
                              children: <Widget>[
                                Expanded(
                                  child: _SectionWidget(
                                    label: const Text('No. of units'),
                                    value: totalUnits != null
                                        ? Text('$totalUnits')
                                        : const Text('...'), // TODO: Fix this
                                  ),
                                ),
                                Expanded(
                                  child: _SectionWidget(
                                    label: const Text('Invested amount'),
                                    value: BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.isPrivateMode,
                                      builder: (context, isPrivateMode) {
                                        return CurrencyView(amount: totalAmountInvested ?? 0.0);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                _SectionWidget(label: const Text('Mkt. price'), value: const Text('₹160.70')),
                                _SectionWidget(label: const Text('Avg. price'), value: const Text('₹140.00')),
                              ],
                            ),

                            Row(
                              children: <Widget>[
                                _SectionWidget(
                                  label: const Text('Total returns'),
                                  value: const Text('+ ₹1,035.00 (14.79%)'),
                                  valueColor: Colors.teal.shade500,
                                ),
                                _SectionWidget(
                                  label: const Text('XIRR'),
                                  value: const Text('+ 12.97%'),
                                  valueColor: Colors.teal.shade500,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Gap(20.0),

                  // ~ Holding Transactions Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                ],
              ),

              // ~ Buy/Sell Buttons
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: <Widget>[
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.borderRadius,
    this.padding,
    this.contentSpacing,
  });

  final Widget label;
  final Widget value;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? contentSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelText = DefaultTextStyle(
      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
      child: label,
    );

    final valueText = DefaultTextStyle(
      style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.secondary),
      child: value,
    );

    return PhysicalModel(
      // curve: Curves.fastOutSlowIn,
      // duration: 600.ms,
      clipBehavior: Clip.antiAlias,
      elevation: 0.0,
      color: theme.canvasColor.lighten(3),
      shadowColor: theme.colorScheme.shadow,
      borderRadius: borderRadius ?? iTileBorderRadius,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52.0),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: contentSpacing ?? 0.0,
            children: <Widget>[labelText, valueText],
          ),
        ),
      ),
    );
  }
}
