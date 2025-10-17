part of '../dashboard_screen.dart';

class _SpendingPieChart extends StatefulWidget {
  const _SpendingPieChart({super.key});

  @override
  State<_SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<_SpendingPieChart> {
  int touchedIndex = -1;
  bool scaleIn = false;
  int showLabels = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        scaleIn = true;
      });
    });
    // Future.delayed(Duration(milliseconds: 500), () async {
    //   int numCategories = (await database.getAllCategories()).length;
    //   for (int i = 1; i <= numCategories + 25; i++) {
    //     await Future.delayed(const Duration(milliseconds: 70));
    //     if (mounted) {
    //       setState(() {
    //         showLabels = showLabels + 1;
    //       });
    //     }
    //   }
    // });
  }

  // void setTouchedIndex(int index) {
  //   setState(() {
  //     touchedIndex = index;
  //   });
  // }

  // void setTouchedCategoryPk(String? categoryPk) {
  //   if (categoryPk == null) return;
  //   int index = 0;
  //   bool found = false;
  //   for (CategoryWithTotal category in widget.data) {
  //     if (category.category.categoryPk == categoryPk) {
  //       found = true;
  //       break;
  //     }
  //     index++;
  //   }
  //   if (found == false) {
  //     setTouchedIndex(-1);
  //   } else {
  //     setTouchedIndex(index);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: const Text('Categories'),
      icon: const Icon(Icons.pie_chart_rounded),
      tiles: [
        BlocSelector<AppCubit, AppState, String?>(
          selector: (state) => state.primaryAccountId,
          builder: (context, accountId) {
            return BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, dashboardState) {
                final isError = dashboardState.isError;
                final isLoading = dashboardState.isLoading;
                if (dashboardState is DashboardLoadedState) {
                  $logger.i(dashboardState.stats);
                }
                // final stats = dashboardState is DashboardLoadedState
                //     ? dashboardState.stats.firstWhereOrNull((stat) => stat.amcGenre == genre)
                //     : null;
                final stats = dashboardState is DashboardLoadedState
                    ? dashboardState.stats.where((stat) => stat.accountId == accountId).toList()
                    : null;
                final totalAmount = stats?.fold<double>(0, (v, el) => v + el.totalAmount);
                return SectionTile(
                  title: SizedBox(
                    height: 256.0,
                    child: Stack(
                      children: <Widget>[
                        stats == null
                            ? Skeleton(color: isError ? context.colors.error : null)
                            : PieChart(
                                PieChartData(
                                  centerSpaceRadius: 0,
                                  sections: _buildSections(stats),
                                  borderData: FlBorderData(show: false),
                                  // pieTouchData: PieTouchData(
                                  //   touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  //     // print(event.runtimeType);
                                  //     setState(() {
                                  //       if (!event.isInterestedForInteractions ||
                                  //           pieTouchResponse == null ||
                                  //           pieTouchResponse.touchedSection == null) {
                                  //         return;
                                  //       }
                                  //       if (event.runtimeType == FlTapDownEvent &&
                                  //           touchedIndex != pieTouchResponse.touchedSection!.touchedSectionIndex) {
                                  //         touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  //         // print("TOUCHED");
                                  //         // print(touchedIndex);
                                  //         // print(widget.data);
                                  //         widget.setSelectedCategory(
                                  //           widget.data[touchedIndex].category.categoryPk,
                                  //           widget.data[touchedIndex].category,
                                  //         );
                                  //       } else if (event.runtimeType == FlTapDownEvent) {
                                  //         touchedIndex = -1;
                                  //         widget.setSelectedCategory("-1", null);
                                  //       } else if (event.runtimeType == FlLongPressMoveUpdate) {
                                  //         touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  //         widget.setSelectedCategory(
                                  //           widget.data[touchedIndex].category.categoryPk,
                                  //           widget.data[touchedIndex].category,
                                  //         );
                                  //       }
                                  //     });
                                  //   },
                                  // ),
                                ),
                                duration: Duration(milliseconds: 1300),
                                curve: ElasticOutCurve(0.6),
                              ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Total investment'),
                              totalAmount == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.isPrivateMode,
                                      builder: (context, isPrivateMode) {
                                        return CurrencyView(
                                          amount: totalAmount,
                                          integerStyle: textTheme.headlineLarge,
                                          decimalsStyle: textTheme.headlineSmall,
                                          currencyStyle: textTheme.bodyMedium,
                                          privateMode: isPrivateMode,
                                          // compactView: snapshot.data! >= 1_00_00_000
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12.0,
                      children: AmcGenre.values
                          .map((genre) => _buildLegendItem(context, genre.title, genre.color))
                          .toList(growable: false),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: <Widget>[
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
      ],
    );
  }

  T? nullIfIndexOutOfRange<T>(List<T> list, int index) {
    if (index < 0 || index >= list.length) {
      return null;
    } else {
      return list[index];
    }
  }

  List<PieChartSectionData> _buildSections(List<TransactionStat> stats) {
    final totalAmount = stats.fold<double>(0, (v, el) => v + el.totalAmount);
    double totalPercentAccumulated = 0;
    return List.generate(AmcGenre.values.length, (i) {
      final genre = AmcGenre.getByIndex(i);
      final stat = stats.singleWhereOrNull((stat) => stat.amcGenre == genre);
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 106.0 : 100.0;
      final widgetScale = isTouched ? 1.3 : 1.0;

      // bool isTouchingSameColorSection = false;
      // if (nullIfIndexOutOfRange(stats, i - 1)?.category?.colour == stats[i].category.colour ||
      //     nullIfIndexOutOfRange(stats, i + 1)?.category?.colour == stats[i].category.colour) {
      //   isTouchingSameColorSection = true;
      // }
      // final Color color = dynamicPastel(
      //   context,
      //   HexColor(stats[i].category.colour, defaultColor: Theme.of(context).colorScheme.primary),
      //   amountLight:
      //       0.3 +
      //       (isTouchingSameColorSection && i % 3 == 0 ? 0.2 : 0) +
      //       (isTouchingSameColorSection && i % 3 == 1 ? 0.35 : 0),
      //   amountDark:
      //       0.1 +
      //       (isTouchingSameColorSection && i % 3 == 0 ? 0.2 : 0) +
      //       (isTouchingSameColorSection && i % 3 == 1 ? 0.35 : 0),
      // );
      final percent = ((stat?.totalAmount ?? 0.0) / totalAmount * 100).abs();
      totalPercentAccumulated += percent;
      return PieChartSectionData(
        color: genre.color,
        // value: stat.totalAmount == 0 ? 5 : (stats[i].total / widget.totalSpent).abs(),
        value: stat?.totalAmount,
        title: '',
        radius: radius,
        // badgeWidget: _Badge(
        //   totalPercentAccumulated: totalPercentAccumulated,
        //   showLabels: i < showLabels,
        //   scale: widgetScale,
        //   color: genre.color,
        //   iconName: genre.title,
        //   categoryColor: genre.color,
        //   // emojiIconName: stats[i].category.emojiIconName,
        //   percent: percent,
        //   isTouched: isTouched,
        // ),
        titlePositionPercentageOffset: 1.4,
        badgePositionPercentageOffset: .98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final double scale;
  final Color color;
  final String iconName;
  final String? emojiIconName;
  final double percent;
  final bool isTouched;
  final bool showLabels;
  final Color categoryColor;
  final double totalPercentAccumulated;

  const _Badge({
    super.key,
    required this.scale,
    required this.color,
    required this.iconName,
    this.emojiIconName,
    required this.percent,
    required this.isTouched,
    required this.showLabels,
    required this.categoryColor,
    required this.totalPercentAccumulated,
  });

  @override
  Widget build(BuildContext context) {
    bool showIcon = percent.abs() < 5;
    return AnimatedScale(
      curve: showIcon ? Curves.easeInOutCubicEmphasized : ElasticOutCurve(0.6),
      duration: showIcon ? Duration(milliseconds: 700) : Duration(milliseconds: 1300),
      scale: showIcon && isTouched == false ? 0 : (showLabels || isTouched ? (showIcon ? 1 : scale) : 0),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(iconName),
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
          ),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: scale == 1 ? 0 : 1,
                child: Center(
                  child: Transform.translate(
                    offset: Offset(
                      0.0,
                      // Prevent overlapping labels when displayed on top
                      // Divider percent by 2, because the label is in the middle
                      // This means any label location that is past 50% will change orientation
                      totalPercentAccumulated - percent / 2 < 50 ? -34 : 34,
                    ),
                    child: IntrinsicWidth(
                      child: Container(
                        height: 20,
                        padding: EdgeInsetsDirectional.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(5),
                          border: Border.all(color: color, width: 1.5),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Center(
                          child: Text(
                            // convertToPercent(percent),
                            percent.toCompact(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Container(
              //   decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
              //   child: Center(
              //     child: Container(
              //       decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
              //       padding: EdgeInsetsDirectional.all(8),
              //       child: emojiIconName != null ? Container() : CacheCategoryIcon(iconName: iconName, size: 34),
              //     ),
              //   ),
              // ),
              // emojiIconName != null ? EmojiIcon(emojiIconName: emojiIconName, size: 34 * 0.7) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
