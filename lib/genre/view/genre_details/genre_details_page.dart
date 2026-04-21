import 'dart:math' as math;

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/amcs/model/amc_stat_model.dart';
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
        return GenreDetailsCubit(amcRepository: AmcRepository.instance);
      },
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(title: Text(genre.title), floating: true, snap: true),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: BlocSelector<AppCubit, AppState, String?>(
                  selector: (state) => state.primaryAccountId,
                  builder: (context, accountId) {
                    return _GenreDetailsPageContent(accountId: accountId);
                  },
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
    final colors = theme.colorScheme;

    return BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
      builder: (context, genreDetailsState) {
        final isError = genreDetailsState is GenreDetailsErrorState;
        final isLoading = genreDetailsState is GenreDetailsLoadingState;

        return Skeletonizer(
          enabled: isLoading,
          child: SliverList(
            delegate: SliverChildListDelegate.fixed(<Widget>[
              // ~ Current Value
              _SectionWidget(
                label: FormattedDate(
                  date: DateTime.now(),
                  prefix: const Skeleton.keep(child: Text('Current value as of ')),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                value: _buildTotalCurrentAmount(context, genreDetailsState),
                borderRadius: iCardBorderRadius.copyWith(
                  bottomLeft: iTileBorderRadius.bottomLeft,
                  bottomRight: iTileBorderRadius.bottomRight,
                ),
                color: isError ? colors.errorContainer : null,
                valueColor: isError ? colors.error : null,
              ),

              const Gap(4.0),

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
                    value: _buildHoldingCount(context, genreDetailsState),
                    color: isError ? colors.errorContainer : null,
                    valueColor: isError ? colors.error : null,
                  ),

                  // ~ Invested amount section
                  _SectionWidget(
                    label: const Skeleton.keep(child: Text('Invested amount')),
                    value: _buildTotalInvestedAmount(context, genreDetailsState),
                    color: isError ? colors.errorContainer : null,
                    valueColor: isError ? colors.error : null,
                  ),

                  // ~ Total returns sections
                  _SectionWidget(
                    label: const Skeleton.keep(child: Text('Total returns')),
                    value: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        _buildAmountReturns(context, genreDetailsState),
                        _buildPercentageReturns(context, genreDetailsState),
                      ],
                    ),
                    // color: isError ? colors.errorContainer : null,
                    // valueColor: isError ? colors.error : Colors.teal.shade500,
                    borderRadius: iTileBorderRadius.copyWith(bottomLeft: iCardBorderRadius.bottomLeft),
                  ),

                  // ~ XIRR section
                  _SectionWidget(
                    label: const Skeleton.keep(child: Text('XIRR')),
                    value: _buildXirr(context, genreDetailsState),
                    color: isError ? colors.errorContainer : null,
                    valueColor: isError ? colors.error : null,
                    borderRadius: iTileBorderRadius.copyWith(bottomRight: iCardBorderRadius.bottomRight),
                  ),
                ],
              ),

              const Gap(4.0),

              Text('Holdings', style: theme.textTheme.titleMedium),

              _buildHoldings(context, genreDetailsState),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildHoldings(BuildContext context, GenreDetailsState genreDetailsState) {
    final theme = Theme.of(context);

    if (genreDetailsState is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (genreDetailsState is GenreDetailsLoadedState) {
      return ColumnBuilder(
        mainAxisSize: MainAxisSize.min,
        spacing: 4.0,
        itemBuilder: (context, index) {
          final stat = genreDetailsState.stats[index];
          return SimpleCard(
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
                        child: Text(
                          stat.amc.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
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
          ;
        },
        itemCount: genreDetailsState.stats.length,
      );
    }
    return const Text('Loading...');
  }

  Widget _buildHoldingCount(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      return Text(state.stats.length.toString(), textAlign: TextAlign.right);
    }

    return const Text('Loading...');
  }

  Widget _buildTotalCurrentAmount(BuildContext context, GenreDetailsState state) {
    final textTheme = Theme.of(context).textTheme;
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: state.totalCurrentValue,
            style: textTheme.headlineLarge,
            decimalsStyle: textTheme.headlineSmall,
            currencyStyle: textTheme.bodyMedium,
            privateMode: isPrivateMode,
          );
        },
      );
    }

    return const Text('Loading...');
  }

  Widget _buildTotalInvestedAmount(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(amount: state.totalInvested, privateMode: isPrivateMode);
        },
      );
    }

    return const Text('Loading...');
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

  Widget _buildAmountReturns(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      final returns = state.totalCurrentValue - state.totalInvested;

      return BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: returns,
            privateMode: isPrivateMode,
            style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
          );
        },
      );
    }

    return const Text('Loading...');
  }

  Widget _buildPercentageReturns(BuildContext context, GenreDetailsState state) {
    if (state is GenreDetailsErrorState) {
      return Text('Error loading data');
    }

    if (state is GenreDetailsLoadedState) {
      final returns = (state.totalCurrentValue / state.totalInvested - 1.0) * 100;

      return Text(
        '${returns.toPrecision(2)}%',
        textAlign: TextAlign.right,
        style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
      );
    }

    return const Text('Loading...');
  }

  Widget _buildXirr(BuildContext context, GenreDetailsState state) {
    return const Text('Loading...');
    // if (state is GenreDetailsErrorState) {
    //   return Text('Error loading data');
    // }

    // if (state is GenreDetailsLoadedState) {
    //   final transactionsForXirr = state.stats.map((stat) => xf.Transaction(stat.totalAmount, stat.investedOn)).toList();
    //   if (transactionsForXirr.isNotEmpty) {
    //     transactionsForXirr.add(
    //       xf.Transaction(
    //         state.totalCurrentValue > 0 ? -(state.totalCurrentValue) : -0.0,
    //         latestPrice?.date ?? DateTime.now(),
    //       ),
    //     );
    //   }
    //   final xirr = transactionsForXirr != null && transactionsForXirr.isNotEmpty
    //       ? xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate()
    //       : 0.0;
    //   return Text(
    //     // xirr != null ? '${(xirr * 100).toPrecision(2)}%' : '0.00%',
    //     '0.00%',
    //     textAlign: TextAlign.right,
    //     // style: TextStyle(color: returns < 0 ? Colors.red : Colors.teal),
    //     style: TextStyle(color: Colors.teal),
    //   );
    // }

    // return const Text('Loading...');
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
