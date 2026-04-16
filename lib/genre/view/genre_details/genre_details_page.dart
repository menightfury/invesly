import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/genre/view/genre_details/cubit/genre_details_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(title: Text('${genre.title} details'), floating: true, snap: true,),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                BlocSelector<AppCubit, AppState, String?>(
                  selector: (state) => state.primaryAccountId,
                  builder: (context, accountId) {
                    return BlocProvider(
                      create: (context) => GenreDetailsCubit(
                        trnRepository: TransactionRepository.instance,
                        amcRepository: AmcRepository.instance,
                      ),
                      child: _GenreDetailsPageContent(accountId: accountId),
                    );
                  },
                ),
              ]),
            ),
          ],
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
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(context, 'Invested', state.totalInvested, theme),
                            _buildSummaryItem(context, 'Current Value', state.totalCurrentValue, theme),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('${state.totalTransactions} Total Transactions', style: theme.textTheme.labelLarge),
                      ],
                    ),
                  ),
                ),
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
          );
        }

        return Center(child: const Text('No data available'));
      },
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount, ThemeData theme) {
    return Column(
      spacing: amount,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        CurrencyView(
          amount: amount,
          style: theme.textTheme.headlineSmall,
          decimalsStyle: theme.textTheme.titleMedium,
          currencyStyle: theme.textTheme.titleMedium,
          privateMode: false,
        ),
      ],
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
