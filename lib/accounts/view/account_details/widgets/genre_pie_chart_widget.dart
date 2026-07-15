import 'package:invesly/accounts/view/account_details/cubit/account_details_cubit.dart';
import 'package:invesly/common/presentations/widgets/simple_card.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';

class GenrePieChartWidget extends StatefulWidget {
  const GenrePieChartWidget({super.key});

  @override
  State<GenrePieChartWidget> createState() => _GenrePieChartWidgetState();
}

class _GenrePieChartWidgetState extends State<GenrePieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailsCubit, AccountDetailsState>(
      builder: (context, state) {
        if (state.isError) {
          return SimpleCard(
            label: Text('Error loading chart', style: TextStyle(color: context.colors.error)),
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

        return SimpleCard(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 16.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Genre-wise Distribution',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              Center(
                child: SizedBox(
                  height: 280.0,
                  width: 280.0,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 50.0,
                      sections: _buildPieChartSections(state),
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, pieTouchResponse) {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            return;
                          }

                          if (event.runtimeType == FlTapDownEvent) {
                            setState(() {
                              if (touchedIndex != pieTouchResponse.touchedSection!.touchedSectionIndex) {
                                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                final genre = AmcGenre.fromIndex(touchedIndex);
                                context.read<AccountDetailsCubit>().selectGenre(genre);
                              } else {
                                touchedIndex = -1;
                                context.read<AccountDetailsCubit>().selectGenre(null);
                              }
                            });
                          }
                        },
                      ),
                    ),
                    duration: const Duration(milliseconds: 800),
                  ),
                ),
              ),
              const Divider(height: 8.0),
              _GenreLegend(),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(AccountDetailsState state) {
    return List.generate(AmcGenre.values.length, (i) {
      final genre = AmcGenre.fromIndex(i);
      final amount = state.getTotalInvestedByGenre(genre);
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 90.0 : 80.0;

      return PieChartSectionData(
        color: genre.color,
        value: amount > 0 ? amount : 0.01,
        showTitle: false,
        radius: radius,
        badgeWidget: amount > 0
            ? AnimatedScale(
                scale: isTouched ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(color: genre.color.withAlpha(200), shape: BoxShape.circle),
                  child: Center(child: Icon(genre.icon, size: 16.0, color: Colors.white)),
                ),
              )
            : null,
        badgePositionPercentageOffset: 0.98,
      );
    });
  }
}

class _GenreLegend extends StatelessWidget {
  const _GenreLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailsCubit, AccountDetailsState>(
      builder: (context, state) {
        return Column(
          spacing: 8.0,
          children: AmcGenre.values.map((genre) {
            final amount = state.getTotalInvestedByGenre(genre);
            final percentage = state.totalInvested > 0
                ? ((amount / state.totalInvested) * 100).toStringAsFixed(1)
                : '0.0';

            return Row(
              children: <Widget>[
                Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(color: genre.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8.0),
                Expanded(child: Text(genre.title, style: context.textTheme.bodySmall)),
                Text(
                  '$percentage%',
                  style: context.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}
