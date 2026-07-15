import 'package:invesly/accounts/view/account_details/cubit/account_details_cubit.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';

class AccountNetWorthWidget extends StatelessWidget {
  const AccountNetWorthWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailsCubit, AccountDetailsState>(
      builder: (context, state) {
        if (state.isError) {
          return SimpleCard(
            label: Text('Error loading net worth', style: TextStyle(color: context.colors.error)),
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
          return SimpleCard(
            label: Text('No investments yet', style: TextStyle(color: context.colors.onSurfaceVariant)),
            padding: const EdgeInsets.all(20.0),
          );
        }

        return SimpleCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Net Worth', style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
              CurrencyView(
                amount: state.totalInvested,
                style: context.textTheme.displayMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 8.0),
              _GenreBreakdownRow(genre: AmcGenre.mf, amount: state.getTotalInvestedByGenre(AmcGenre.mf)),
              _GenreBreakdownRow(genre: AmcGenre.stock, amount: state.getTotalInvestedByGenre(AmcGenre.stock)),
              _GenreBreakdownRow(genre: AmcGenre.insurance, amount: state.getTotalInvestedByGenre(AmcGenre.insurance)),
              _GenreBreakdownRow(genre: AmcGenre.misc, amount: state.getTotalInvestedByGenre(AmcGenre.misc)),
            ],
          ),
        );
      },
    );
  }
}

class _GenreBreakdownRow extends StatelessWidget {
  const _GenreBreakdownRow({super.key, required this.genre, required this.amount});

  final AmcGenre genre;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final percentage = amount > 0
        ? '${((amount / context.read<AccountDetailsCubit>().state.totalInvested) * 100).toStringAsFixed(1)}%'
        : '0%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Row(
            spacing: 8.0,
            children: <Widget>[
              Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(color: genre.color, shape: BoxShape.circle),
              ),
              Flexible(
                child: Text(genre.title, style: context.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        Row(
          spacing: 8.0,
          children: <Widget>[
            CurrencyView(amount: amount, style: context.textTheme.bodySmall),
            Text(percentage, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }
}
