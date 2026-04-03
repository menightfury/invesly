import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/genre/view/genre_details/cubit/genre_details_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class GenreDetailsPage extends StatelessWidget {
  const GenreDetailsPage._({super.key, required this.genre, required this.stats});

  final AmcGenre genre;
  final List<TransactionStat> stats;

  static Route<void> route(AmcGenre genre, List<TransactionStat> stats) {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (context) => GenreDetailsCubit(repository: AmcRepository.instance)..loadDetails(stats),
        child: GenreDetailsPage._(genre: genre, stats: stats),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${genre.title} Details')),
      body: BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
        builder: (context, state) {
          if (state is GenreDetailsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GenreDetailsErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is GenreDetailsLoadedState) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.all(16.0), child: _buildSummary(context, state)),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = state.detailsList[index];
                    return _buildAmcItem(context, item);
                  }, childCount: state.detailsList.length),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummary(BuildContext context, GenreDetailsLoadedState state) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
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
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, double amount, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
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

  Widget _buildAmcItem(BuildContext context, AmcGenreDetailsStat item) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.stat.amc.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${item.stat.numTransactions} trns',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invested', style: theme.textTheme.labelMedium),
                    CurrencyView(
                      amount: item.stat.totalAmount,
                      style: theme.textTheme.bodyLarge,
                      decimalsStyle: theme.textTheme.bodyMedium,
                      currencyStyle: theme.textTheme.bodyMedium,
                      privateMode: false,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Current Value', style: theme.textTheme.labelMedium),
                    CurrencyView(
                      amount: item.currentValue,
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
