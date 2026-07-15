import 'package:invesly/accounts/view/account_details/cubit/account_details_cubit.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';

class GenreInvestmentBreakdownWidget extends StatelessWidget {
  const GenreInvestmentBreakdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailsCubit, AccountDetailsState>(
      builder: (context, state) {
        if (state.isError) {
          return SimpleCard(
            label: Text('Error loading breakdown', style: TextStyle(color: context.colors.error)),
            color: context.colors.errorContainer,
            padding: const EdgeInsets.all(20.0),
          );
        }

        if (state.isLoading) {
          return SimpleCard(
            padding: const EdgeInsets.all(20.0),
            child: LoadingAnimationWidget.staggeredDotsWave(color: context.colors.primary, size: 48.0),
          );
        }

        if (state.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          spacing: 8.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Breakdown by Genre',
              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            ...AmcGenre.values.map((genre) {
              final amount = state.getTotalInvestedByGenre(genre);
              final percentage = state.totalInvested > 0
                  ? ((amount / state.totalInvested) * 100).toStringAsFixed(1)
                  : '0.0';
              final investmentCount = state.stats.where((stat) => stat.amc.genre == genre).length;

              return _GenreCard(
                genre: genre,
                amount: amount,
                percentage: double.parse(percentage),
                investmentCount: investmentCount,
              );
            }),
          ],
        );
      },
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    super.key,
    required this.genre,
    required this.amount,
    required this.percentage,
    required this.investmentCount,
  });

  final AmcGenre genre;
  final double amount;
  final double percentage;
  final int investmentCount;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 12.0,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: genre.color.withAlpha(50), shape: BoxShape.circle),
                child: Icon(genre.icon, color: genre.color, size: 20.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2.0,
                  children: <Widget>[
                    Text(genre.title, style: context.textTheme.labelLarge?.copyWith(color: genre.color)),
                    Text(
                      '$investmentCount investment${investmentCount != 1 ? 's' : ''}',
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                spacing: 2.0,
                children: <Widget>[
                  CurrencyView(
                    amount: amount,
                    style: context.textTheme.labelLarge?.copyWith(color: genre.color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: genre.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: context.textTheme.bodySmall?.copyWith(color: genre.color, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _PercentageBar(percentage: percentage),
        ],
      ),
    );
  }
}

class _PercentageBar extends StatelessWidget {
  const _PercentageBar({super.key, required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: LinearProgressIndicator(
        value: percentage / 100.0,
        minHeight: 4.0,
        backgroundColor: context.colors.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary.withAlpha(150)),
      ),
    );
  }
}
