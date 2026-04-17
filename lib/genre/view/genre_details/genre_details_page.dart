import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/genre/view/genre_details/cubit/genre_details_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

class GenreDetailsPage extends StatelessWidget {
  const GenreDetailsPage({super.key, required this.genre});

  final AmcGenre genre;

  static Route<void> route(AmcGenre genre) {
    return MaterialPageRoute<void>(
      builder: (_) {
        return GenreDetailsPage(genre: genre);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return GenreDetailsCubit(trnRepository: TransactionRepository.instance, amcRepository: AmcRepository.instance);
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(genre.title), floating: true, snap: true),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    BlocSelector<AppCubit, AppState, String?>(
                      selector: (state) => state.primaryAccountId,
                      builder: (context, accountId) {
                        return _GenreDetailsPageContent(accountId: accountId);
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreDetailsPageContent extends StatefulWidget {
  const _GenreDetailsPageContent({super.key, this.accountId});

  final String? accountId;

  @override
  State<_GenreDetailsPageContent> createState() => _GenreDetailsPageContentState();
}

class _GenreDetailsPageContentState extends State<_GenreDetailsPageContent> {
  @override
  void initState() {
    super.initState();
    _getStats();
  }

  @override
  void didUpdateWidget(covariant _GenreDetailsPageContent oldWidget) {
    if (widget.accountId != oldWidget.accountId) {
      _getStats();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _getStats() {
    if (widget.accountId?.isEmpty ?? true) {
      return;
    }
    context.read<GenreDetailsCubit>().loadDetails(widget.accountId!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
      builder: (context, state) {
        final isError = state is GenreDetailsErrorState;
        final isLoading = state is GenreDetailsLoadingState;
        final stats = state is GenreDetailsLoadedState ? state.stats : null;
        final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalAmount);

        if (state is GenreDetailsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GenreDetailsErrorState) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is GenreDetailsLoadedState) {
          // final returns = state.totalInvested != null && totalCurrentValue != null
          //     ? totalCurrentValue - totalAmountInvested
          //     : 0.0;
          // final transactionsForXirr = trnState.transactions
          //     ?.map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn))
          //     .toList();
          // if (transactionsForXirr != null && transactionsForXirr.isNotEmpty) {
          //   transactionsForXirr.add(
          //     xf.Transaction(
          //       totalCurrentValue != null && totalCurrentValue > 0 ? -totalCurrentValue : -0.0,
          //       latestPrice?.date ?? DateTime.now(),
          //     ),
          //   );
          // }
          // final xirr = transactionsForXirr != null && transactionsForXirr.isNotEmpty
          //     ? xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate()
          //     : 0.0;

          return Skeletonizer(
            enabled: false, // TODO: isLoading,
            child: Column(
              spacing: 4.0,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ~ Current Value
                _SectionWidget(
                  label: FormattedDate(
                    date: DateTime.now(), // latestPrice?.date ?? DateTime.now(),
                    prefix: const Skeleton.keep(child: Text('Current value as of ')),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  value: BlocSelector<AppCubit, AppState, bool>(
                    selector: (state) => state.isPrivateMode,
                    builder: (context, isPrivateMode) {
                      return CurrencyView(amount: state.totalCurrentValue, privateMode: isPrivateMode);
                    },
                  ),
                  borderRadius: iCardBorderRadius.copyWith(
                    bottomLeft: iTileBorderRadius.bottomLeft,
                    bottomRight: iTileBorderRadius.bottomRight,
                  ),
                  // color: isError ? colors.errorContainer : null,
                  // valueColor: isError ? colors.error : null,
                ),

                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.0,
                  crossAxisSpacing: 4.0,
                  mainAxisExtent: 104.0,
                  children: <Widget>[
                    // ~ Holding count
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('No. of holdings')),
                      value: Text(
                        // state.holdingCount.toString(),
                        3.toString(),
                        textAlign: TextAlign.right,
                      ),
                      // color: isError ? colors.errorContainer : null,
                      // valueColor: isError ? colors.error : null,
                    ),

                    // ~ Invested amount section
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('Invested amount')),
                      value: BlocSelector<AppCubit, AppState, bool>(
                        selector: (state) => state.isPrivateMode,
                        builder: (context, isPrivateMode) {
                          return CurrencyView(amount: state.totalInvested, privateMode: isPrivateMode);
                        },
                      ),
                      // color: isError ? colors.errorContainer : null,
                      // valueColor: isError ? colors.error : null,
                    ),

                    // ~ Total returns sections
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('Total returns')),
                      value: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.isPrivateMode,
                            builder: (context, isPrivateMode) {
                              return CurrencyView(
                                // amount: returns,
                                amount: 0.0,
                                privateMode: isPrivateMode,
                                // style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
                                style: TextStyle(color: Colors.teal),
                              );
                            },
                          ),
                          Text(
                            // (totalAmountInvested?.isZero ?? true)
                            //     ? '0.00%'
                            //     : '${(returns / totalAmountInvested! * 100).toPrecision(2)}%',
                            '0.00%',
                            textAlign: TextAlign.right,
                            // style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
                            style: TextStyle(color: Colors.teal),
                          ),
                        ],
                      ),
                      // color: isError ? colors.errorContainer : null,
                      // valueColor: isError ? colors.error : Colors.teal.shade500,
                      borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                    ),

                    // ~ XIRR section
                    _SectionWidget(
                      label: const Skeleton.keep(child: Text('XIRR')),
                      value: Text(
                        // xirr != null ? '${(xirr * 100).toPrecision(2)}%' : '0.00%',
                        '0.00%',
                        textAlign: TextAlign.right,
                        // style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
                        style: TextStyle(color: Colors.teal),
                      ),
                      // color: isError ? colors.errorContainer : null,
                      // valueColor: isError ? colors.error : null,
                      borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                    ),
                  ],
                ),

                ColumnBuilder(
                  mainAxisSize: MainAxisSize.min,
                  itemBuilder: (context, index) {
                    final item = state.stats[index];
                    return _buildAmcItem(context, item);
                  },
                  itemCount: state.stats.length,
                ),
              ],
            ),
          );
        }

        return Center(child: const Text('No data available'));
      },
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount) {
    final theme = Theme.of(context);
    return SimpleCard(
      elevation: 0.0,
      child: SizedBox(
        height: 96.0,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(label, style: theme.textTheme.titleMedium),
              Align(
                alignment: Alignment.bottomRight,
                child: CurrencyView(
                  amount: amount,
                  style: theme.textTheme.headlineSmall,
                  decimalsStyle: theme.textTheme.titleMedium,
                  currencyStyle: theme.textTheme.titleMedium,
                  privateMode: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmcItem(BuildContext context, TransactionStat stat) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(stat.amc.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Text(
                  '${stat.numTransactions} transactions',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Invested', style: theme.textTheme.labelMedium),
                    CurrencyView(
                      amount: stat.totalAmount,
                      style: theme.textTheme.bodyLarge,
                      decimalsStyle: theme.textTheme.bodyMedium,
                      currencyStyle: theme.textTheme.bodyMedium,
                      privateMode: false,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('Current Value', style: theme.textTheme.labelMedium),
                    CurrencyView(
                      amount: stat.currentValue,
                      style: theme.textTheme.bodyLarge,
                      decimalsStyle: theme.textTheme.bodyMedium,
                      currencyStyle: theme.textTheme.bodyMedium,
                      privateMode: false,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.valueColor,
    this.borderRadius,
    this.contentSpacing,
  });

  final Widget label;
  final Widget value;
  final Color? color;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final double? contentSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelText = DefaultTextStyle(
      style: theme.textTheme.bodyMedium!,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      child: label,
    );

    final valueText = DefaultTextStyle(
      style: theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w600),
      textAlign: TextAlign.end,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      child: value,
    );

    return SimpleCard(
      elevation: 0.0,
      color: color ?? theme.canvasColor.lighten(3),
      shadowColor: theme.colorScheme.shadow,
      borderRadius: borderRadius ?? iTileBorderRadius,
      child: SizedBox(
        height: 96.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: contentSpacing ?? 0.0,
            children: <Widget>[
              labelText,
              Align(alignment: Alignment.bottomRight, child: valueText),
            ],
          ),
        ),
      ),
    );
  }
}
