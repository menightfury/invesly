import 'dart:math';
import 'dart:ui' as math;

import 'package:flutter/material.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common/presentations/animations/animatedCircularProgress.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/widgets/tappable.dart';

class CategoryEntry extends StatelessWidget {
  const CategoryEntry({
    super.key,
    required this.genre,
    required this.transactionCount,
    required this.categorySpent,
    required this.totalSpent,
    required this.selected,
    required this.allSelected,
    // required this.onTap,
    // this.onLongPress,
    this.extraText,
    this.todayPercent,
    this.useHorizontalPaddingConstrained = true,
    this.getPercentageAfterText,
    this.percentageOffset = 0,
  });

  final AmcGenre genre;
  final int transactionCount;
  final double totalSpent;
  final double categorySpent;
  final bool selected;
  final bool allSelected;
  // final Function(TransactionCategory category, CategoryBudgetLimit? categoryBudgetLimit) onTap;
  // final Function(TransactionCategory category, CategoryBudgetLimit? categoryBudgetLimit)? onLongPress;
  final String? extraText;
  final double? todayPercent;
  final bool useHorizontalPaddingConstrained;
  final String Function(double categorySpent)? getPercentageAfterText;
  final double percentageOffset;

  @override
  Widget build(BuildContext context) {
    Widget component;
    double categoryLimitAmount = 0;
    bool hasSubCategories = false;
    double percentSpentWithCategoryLimit = (categorySpent / totalSpent).abs();
    double percentSpent = percentSpentWithCategoryLimit;

    double amountSpent = categorySpent.abs();
    double spendingLimit = 0;
    bool isOverspent = categorySpent.abs() > categoryLimitAmount;
    component = Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 0),
      child: Builder(
        builder: (context) {
          Widget mainCategoryWidget = Padding(
            padding: EdgeInsetsDirectional.only(start: 20, end: 25, top: 8, bottom: 8),
            child: Row(
              children: [
                CategoryIconPercent(
                  genre: genre,
                  percent: percentSpentWithCategoryLimit * 100,
                  percentageOffset: percentageOffset,
                  progressBackgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  size: 28,
                  insetPadding: 18,
                ),
                Container(width: 15),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(genre.name)),
                            SizedBox(width: 10),
                            categorySpent == 0
                                ? SizedBox.shrink()
                                : Transform.translate(
                                    offset: Offset(3, 0),
                                    child: Transform.rotate(
                                      angle: categorySpent >= 0 ? pi : 0,
                                      child: Icon(
                                        Icons.arrow_drop_down_rounded,
                                        // color: showIncomeExpenseIcons
                                        //     ? categorySpent > 0
                                        //           ? getColor(context, "incomeAmount")
                                        //           : getColor(context, "expenseAmount")
                                        //     : getColor(context, "black"),
                                      ),
                                    ),
                                  ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  amountSpent.toString(),
                                  // fontWeight: FontWeight.bold,
                                  // fontSize: 20,
                                  // textColor: isOverspent
                                  //     ? overSpentColor ?? getColor(context, "expenseAmount")
                                  //     : showIncomeExpenseIcons && categorySpent != 0
                                  //     ? categorySpent > 0
                                  //           ? getColor(context, "incomeAmount")
                                  //           : getColor(context, "expenseAmount")
                                  //     : getColor(context, "black"),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 1),
                        Row(
                          children: [
                            Expanded(
                              child:
                                  // categoryBudgetLimit != null ?
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(top: 3, end: 13, bottom: 3),
                                    child: ThinProgress(
                                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                      color: Theme.of(context).colorScheme.primary,
                                      progress: percentSpent,
                                      dotProgress: todayPercent == null ? null : (todayPercent ?? 0) / 100,
                                    ),
                                  ),
                              // : Builder(
                              //     builder: (context) {
                              //       String percentString = convertToPercent(
                              //         percentSpent * 100,
                              //         useLessThanZero: true,
                              //       );
                              //       String text =
                              //           percentString +
                              //           (isSubcategory
                              //               ? "of-category".toLowerCase()
                              //               : getPercentageAfterText == null
                              //               ? ""
                              //               : getPercentageAfterText!(categorySpent));

                              //       return Text(
                              //         text,
                              //         // fontSize: 14,
                              //         // textColor: selected
                              //         //     ? getColor(context, "black").withOpacity(0.4)
                              //         //     : getColor(context, "textLight"),
                              //       );
                              //     },
                              //   ),
                            ),
                            Text(
                              max(transactionCount, 0).toString() +
                                  (transactionCount == 1 ? "transaction" : "transactions"),
                              // fontSize: 14,
                              // textColor: selected
                              //     ? getColor(context, "black").withOpacity(0.4)
                              //     : getColor(context, "textLight"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          return mainCategoryWidget;
        },
      ),
    );
    return AnimatedExpanded(
      expand: !(!selected && !allSelected),
      duration: Duration(milliseconds: 650),
      sizeCurve: Curves.easeInOutCubic,
      child: Tappable(
        // borderRadius: 0,
        // onTap: () {
        //   onTap(genre, categoryBudgetLimit);
        // },
        // onLongPress: onLongPress != null
        //     ? () => onLongPress!(genre, categoryBudgetLimit)
        //     : () => pushRoute(
        //         context,
        //         AddCategoryPage(category: genre, routesToPopAfterDelete: RoutesToPopAfterDelete.One),
        //       ),
        color: Colors.transparent,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: allSelected
              ? 1
              : selected
              ? 1
              : 0.3,
          child: AnimatedContainer(
            decoration: BoxDecoration(
              color: selected && hasSubCategories == false
                  ? Theme.of(context).colorScheme.primary.withAlpha(80)
                  : Colors.transparent,
            ),
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 500),
            child: component,
          ),
        ),
      ),
    );
  }
}

class CategoryIconPercent extends StatelessWidget {
  CategoryIconPercent({
    Key? key,
    required this.genre,
    this.size = 30,
    required this.percent,
    this.insetPadding = 23,
    required this.progressBackgroundColor,
    required this.percentageOffset,
  }) : super(key: key);

  final AmcGenre genre;
  final double size;
  final double percent;
  final double insetPadding;
  final Color progressBackgroundColor;
  final double percentageOffset;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).colorScheme.primary;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        // Padding(
        //   padding: EdgeInsetsDirectional.all(insetPadding / 2),
        //   child: SimpleShadow(
        //     child: Image.asset(
        //       "assets/categories/" + (category.iconName ?? ""),
        //       width: size - 3,
        //     ),
        //     opacity: 0.8,
        //     color: HexColor(category.colour),
        //     offset: Offset(0, 0),
        //     sigma: 1,
        //   ),
        // ),
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light ? backgroundColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              height: size + insetPadding,
              width: size + insetPadding,
              padding: EdgeInsetsDirectional.all(10),
            ),
            Icon(genre.icon, size: size * 0.92),
          ],
        ),

        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Container(
            key: ValueKey(progressBackgroundColor.toString()),
            height: size + insetPadding,
            width: size + insetPadding,
            child: AnimatedCircularProgress(
              rotationOffsetPercent: percentageOffset,
              percent: math.clampDouble(percent / 100, 0, 1),
              backgroundColor: progressBackgroundColor,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class ThinProgress extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final double progress;
  final double? dotProgress;

  const ThinProgress({required this.color, required this.backgroundColor, required this.progress, this.dotProgress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, boxConstraints) {
        double x = boxConstraints.maxWidth * (dotProgress ?? 0);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadiusDirectional.circular(100),
              child: Stack(
                children: [
                  Container(color: backgroundColor, height: 5),
                  AnimatedFractionallySizedBox(
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubicEmphasized,
                    widthFactor: progress,
                    child: ClipRRect(
                      borderRadius: BorderRadiusDirectional.circular(100),
                      child: Container(color: color, height: 5),
                    ),
                  ),
                ],
              ),
            ),
            if (dotProgress != null && dotProgress! >= 0 && dotProgress! <= 1)
              PositionedDirectional(
                start: x - 5,
                top: -3 / 2,
                child: Container(
                  height: 8,
                  width: 4,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadiusDirectional.circular(100)),
                ),
              ),
          ],
        );
      },
    );
  }
}
