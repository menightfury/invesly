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
            SliverAppBar(title: Text('${genre.title} details')),
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
    return BlocBuilder<GenreDetailsCubit, GenreDetailsState>(
      builder: (context, state) {
        if (state is GenreDetailsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GenreDetailsErrorState) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is GenreDetailsLoadedState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(padding: const EdgeInsets.all(16.0), child: _buildSummary(context, state)),
              ColumnBuilder(
                mainAxisSize: MainAxisSize.min,
                itemBuilder: (context, index) {
                  final item = state.detailsList[index];
                  return _buildAmcItem(context, item);
                },
                itemCount: state.detailsList.length,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
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
