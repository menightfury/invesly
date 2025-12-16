import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions_filter/cubit/transactions_filter_cubit.dart';
import 'package:invesly/transactions/transactions_filter/search_filters_model.dart';

// int roundToNearestNextFifthYear(int year) {
//   return (((year + 5) / 5).ceil()) * 5;
// }

class TransactionsFilterPage extends StatefulWidget {
  const TransactionsFilterPage({this.initialFilters, super.key});

  final SearchFilters? initialFilters;

  @override
  State<TransactionsFilterPage> createState() => _TransactionsFilterPageState();
}

class _TransactionsFilterPageState extends State<TransactionsFilterPage> {
  //   _scrollListener(position) {
  //     double percent = position / (MediaQuery.paddingOf(context).top + 65 + 50);
  //     if (percent >= 0 && percent <= 1) {
  //       _animationControllerSearch.value = 1 - percent;
  //     }
  //   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // scrollToTopButton: true,
      // scrollToBottomButton: true,
      // dragDownToDismiss: true,
      // onScroll: _scrollListener,
      body: SafeArea(
        child: BlocProvider(
          create: (context) => TransactionsFilterCubit(repository: context.read<TransactionRepository>()),
          child: _PageContent(),
        ),
      ),
    );
  }
}

class _PageContent extends StatefulWidget {
  const _PageContent({this.initialFilters, super.key});

  final SearchFilters? initialFilters;

  @override
  State<_PageContent> createState() => __PageContentState();
}

class __PageContentState extends State<_PageContent> with TickerProviderStateMixin {
  //   void refreshState() {
  //     setState(() {});
  //   }

  late AnimationController _animationControllerSearch;
  //   final _debouncer = Debouncer(milliseconds: 500);
  late SearchFilters searchFilters;
  TextEditingController searchInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionsFilterCubit>().fetchTransactions();
    searchFilters = widget.initialFilters != null ? widget.initialFilters! : SearchFilters();
    //     if (widget.initialFilters == null) {
    //       searchFilters.loadFilterString(
    //         appStateSettings["searchTransactionsSetFiltersString"],
    //         skipDateTimeRange: false,
    //         skipSearchQuery: true,
    //       );

    _animationControllerSearch = AnimationController(vsync: this, value: 1);
  }

  @override
  void dispose() {
    searchInputController.dispose();
    super.dispose();
  }

  Future<void> selectFilters(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox.shrink();
        // PopupFramework(
        //   title: 'Filters',
        //   hasPadding: false,
        //   child: TransactionFiltersSelection(
        //     setSearchFilters: setSearchFilters,
        //     searchFilters: searchFilters,
        //     clearSearchFilters: clearSearchFilters,
        //   ),
        // );
      },
    );
    Future.delayed(Duration(milliseconds: 250), () {
      // updateSettings("searchTransactionsSetFiltersString", searchFilters.getFilterString(), updateGlobalState: false);
      setState(() {});
    });
  }

  //   void setSearchFilters(SearchFilters searchFilters) {
  //     this.searchFilters = searchFilters;
  //   }

  //   void clearSearchFilters() {
  //     // Don't change the DateTime selected, as its handles separately
  //     DateTimeRange? dateTimeRange = searchFilters.dateTimeRange;
  //     // Only clear the search query if there are special filters
  //     // identified within the search query
  //     String? savedSearchQuery;
  //     ParsedDateTimeQuery? parsedDateTimeQuery = searchFilters.searchQuery == null
  //         ? null
  //         : parseSearchQueryForDateTimeText(searchFilters.searchQuery ?? "");
  //     (double, double)? bounds = searchFilters.searchQuery == null
  //         ? null
  //         : parseSearchQueryForAmountText(searchFilters.searchQuery ?? "");
  //     if (parsedDateTimeQuery != null || bounds != null) {
  //       savedSearchQuery = null;
  //       // setTextInput(searchInputController, "");
  //     } else {
  //       savedSearchQuery = searchFilters.searchQuery;
  //     }
  //     searchFilters.clearSearchFilters();
  //     searchFilters.dateTimeRange = dateTimeRange;
  //     searchFilters.searchQuery = savedSearchQuery;
  //     // updateSettings("searchTransactionsSetFiltersString", null, updateGlobalState: false);
  //     setState(() {});
  //   }

  Future<void> selectDateRange(BuildContext context) async {
    // final DateTimeRangeOrAllTime? picked = await showCustomDateRangePicker(
    //   context,
    //   DateTimeRangeOrAllTime(allTime: searchFilters.dateTimeRange == null, dateTimeRange: searchFilters.dateTimeRange),
    //   initialEntryMode: DatePickerEntryMode.input,
    //   allTimeButton: true,
    // );
    // if (picked != null) {
    //   if (searchFilters.dateTimeRange != picked.dateTimeRange)
    //     Future.delayed(Duration(milliseconds: 175), () {
    //       setState(() {
    //         searchFilters.dateTimeRange = picked.dateTimeRange;
    //       });
    //       updateSettings(
    //         "searchTransactionsSetFiltersString",
    //         searchFilters.getFilterString(),
    //         updateGlobalState: false,
    //       );
    //     });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: const Text('All transactions'),
          actions: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: IconButton(
                key: ValueKey((searchFilters.dateTimeRange == null).toString()),
                color: searchFilters.dateTimeRange == null ? null : context.colors.tertiaryContainer,
                onPressed: () => selectDateRange(context),
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: searchFilters.dateTimeRange == null ? null : context.colors.onTertiaryContainer,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: IconButton(
                key: ValueKey(searchFilters.isClear(ignoreDateTimeRange: true, ignoreSearchQuery: true)),
                color: searchFilters.isClear(ignoreDateTimeRange: true, ignoreSearchQuery: true)
                    ? null
                    : context.colors.tertiaryContainer,
                onPressed: () => selectFilters(context),
                icon: Icon(
                  Icons.filter_alt_rounded,
                  color: searchFilters.isClear(ignoreDateTimeRange: true, ignoreSearchQuery: true)
                      ? null
                      : context.colors.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),

        SliverList(
          delegate: SliverChildListDelegate.fixed([
            // ~ Applied Filter Chips
            // Padding(
            //   padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),
            //   child: AppliedFilterChips(
            //     searchFilters: searchFilters,
            //     openFiltersSelection: () => selectFilters(context),
            //     clearSearchFilters: clearSearchFilters,
            //     // openSelectDate: () => selectDateRange(context),
            //   ),
            // ),

            // ~ Results
            BlocBuilder<TransactionsFilterCubit, TransactionsFilterState>(
              builder: (context, state) {
                late final List<Widget> tiles;

                if (state.isLoaded) {
                  final rts = state.transactions;
                  if (rts.isEmpty) {
                    tiles = [
                      SectionTile(
                        title: Center(child: Text('Oops! This is so empty', style: context.textTheme.titleLarge)),
                        subtitle: Center(
                          child: Text(
                            'No transactions have been found for this month.\nAdd a few transactions.',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall,
                          ),
                        ),
                        contentSpacing: 12.0,
                      ),
                    ];
                  } else {
                    tiles = rts.map((rt) {
                      return SectionTile(
                        icon: Icon(rt.transactionType.icon),
                        title: Text(rt.amc?.name ?? 'NULL', style: context.textTheme.bodyMedium),
                        subtitle: Text(rt.investedOn.toReadable()),
                        trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                          selector: (state) => state.isPrivateMode,
                          builder: (context, isPrivateMode) {
                            return CurrencyView(
                              amount: rt.totalAmount,
                              integerStyle: context.textTheme.headlineSmall?.copyWith(
                                color: rt.transactionType.color(context),
                              ),
                              privateMode: isPrivateMode,
                            );
                          },
                        ),
                        onTap: () {},
                      );
                    }).toList();
                  }
                } else {
                  tiles = [SectionTile(title: CircularProgressIndicator())];
                }

                return Column(
                  children: <Widget>[
                    Section(
                      title: const Text('Recent Transactions'),
                      // subTitle: Text('From ${dateRange.start.toReadable()} to ${dateRange.end.toReadable()}'),
                      icon: const Icon(Icons.swap_vert_rounded),
                      tiles: tiles,
                    ),
                    // Tappable(
                    //       // borderRadius: 10,
                    //       onTap: () => selectDateRange(context),
                    //       color: Colors.transparent,
                    //       child: Padding(
                    //         padding: const EdgeInsetsDirectional.only(start: 10, end: 10, top: 10, bottom: 8),
                    //         child: Text(
                    //           'All time',
                    //           // searchFilters.dateTimeRange == null
                    //           //     ? 'all-time'
                    //           //     : getWordedDateShortMore(
                    //           //             searchFilters.dateTimeRange?.start ?? DateTime.now(),
                    //           //             includeYear: true,
                    //           //           ) +
                    //           //           " – " +
                    //           //           getWordedDateShortMore(
                    //           //             searchFilters.dateTimeRange?.end ?? DateTime.now(),
                    //           //             includeYear: true,
                    //           //           ),
                    //           // fontSize: 13,
                    //           textAlign: TextAlign.center,
                    //           // textColor: getColor(context, "textLight"),
                    //         ),
                    //       ),
                    //     );
                  ],
                );
              },
            ),
            const SizedBox(height: 56.0),
          ]),
        ),
      ],
    );
  }
}

(double, double)? parseSearchQueryForAmountText(String searchQuery) {
  final String query = searchQuery.trim();
  final double? number = double.tryParse(query)?.abs();

  if (number == null) return null;

  // final bool isWholeNumber = query.contains(getDecimalSeparator()) == false;
  final bool isWholeNumber = query.contains('.') == false;
  final double lowerBound;
  final double upperBound;

  if (isWholeNumber) {
    lowerBound = number.toInt().toDouble();
    upperBound = number.toInt().toDouble() + 1;
  } else {
    final int decimalPlaces = query.split('.')[1].length;
    final double step = 1 / pow(10, decimalPlaces);
    lowerBound = number;
    upperBound = number + step;
  }

  return (lowerBound, upperBound);
}

final localizedMonthNames = <String>[];
ParsedDateTimeQuery? parseSearchQueryForDateTimeText(String searchQuery) {
  ParsedDateTimeQuery parsed = ParsedDateTimeQuery();
  final List<String> words = searchQuery.toLowerCase().split(' ');
  for (String word in words) {
    if (localizedMonthNames.contains(word)) {
      parsed.month = localizedMonthNames.indexOf(word) + 1;
    } else {
      int? intNumber = int.tryParse(word);
      if (intNumber != null) {
        if (intNumber >= 1 && intNumber <= 31) {
          parsed.day = intNumber;
        } else if (intNumber >= 1000 && intNumber <= 9999) {
          parsed.year = intNumber;
        }
      }
    }
  }
  // Require a month name to start a successful parse
  if (parsed.month == null) return null;

  return parsed;
}

class ParsedDateTimeQuery {
  int? year;
  int? day;
  int? month;
  ParsedDateTimeQuery({this.year, this.day, this.month});

  @override
  String toString() {
    final yearStr = year != null ? 'Year: $year' : 'null';
    final monthStr = month != null ? 'Month: $month' : 'null';
    final dayStr = day != null ? 'Day: $day' : 'null';

    return '$yearStr, $monthStr, $dayStr';
  }

  String formatDate(String locale) {
    final now = DateTime.now();

    int? finalYear = year ?? now.year;
    int? finalMonth = month ?? 1;
    int? finalDay = day ?? 1;

    DateTime date = DateTime(finalYear, finalMonth, finalDay);
    DateFormat formatter;

    if (year != null && month != null && day != null) {
      formatter = DateFormat.yMMMMd(locale);
    } else if (year != null && month != null) {
      formatter = DateFormat.yMMMM(locale);
    } else if (year != null && day != null) {
      // This should never happen, since a month should always be required
      formatter = DateFormat.yMd(locale);
    } else if (month != null && day != null) {
      formatter = DateFormat.MMMMd(locale);
    } else if (year != null) {
      formatter = DateFormat.y(locale);
    } else if (month != null) {
      formatter = DateFormat.MMMM(locale);
    } else if (day != null) {
      formatter = DateFormat.d(locale);
    } else {
      return "";
    }

    return formatter.format(date);
  }
}

// We need to create separate date time ranges because doing something like
// dayExpression = dateTime.day.equals(day);
// Won't work as data stored directly in the database uses different time zone
List<DateTimeRange> createDateTimeRanges(ParsedDateTimeQuery? parsed) {
  if (parsed == null) return [];
  List<DateTimeRange> ranges = [];

  int? year = parsed.year;
  int? month = parsed.month;
  int? day = parsed.day;

  if (year != null) {
    if (month != null) {
      if (day != null) {
        // Exact date
        final startDate = DateTime(year, month, day);
        final endDate = DateTime(year, month, day + 1).subtract(Duration(milliseconds: 1));
        ranges.add(DateTimeRange(start: startDate, end: endDate));
      } else {
        // Full month
        final startDate = DateTime(year, month, 1);
        final endDate = DateTime(year, month + 1, 1);
        ranges.add(DateTimeRange(start: startDate, end: endDate));
      }
    } else {
      // Full year
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year + 1, 1, 1);
      ranges.add(DateTimeRange(start: startDate, end: endDate));
    }
  } else if (month != null) {
    final startDate = DateTime.now();
    if (day != null) {
      // No year, month provided, day is not null
      for (int i = -200; i < 100; i++) {
        final rangeStart = DateTime(startDate.year + i, month, day);
        final rangeEnd = DateTime(startDate.year + i, month, day + 1).subtract(Duration(milliseconds: 1));
        ranges.add(DateTimeRange(start: rangeStart, end: rangeEnd));
      }
    } else {
      // No year, month provided, day is null
      for (int i = -200; i < 100; i++) {
        final rangeStart = DateTime(startDate.year + i, month, 1);
        final rangeEnd = DateTime(startDate.year + i, month + 1, 0);
        ranges.add(DateTimeRange(start: rangeStart, end: rangeEnd));
      }
    }
  }

  return ranges;
}

// class HighlightStringInList extends TextEditingController {
//   final Pattern pattern;

//   HighlightStringInList({String? initialText}) : pattern = RegExp(r'\b[^,]+(?=|$)') {
//     this.text = initialText ?? '';
//   }

//   @override
//   TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
//     if (text.contains(", ") == false) return TextSpan(style: style, text: text);
//     List<InlineSpan> children = [];
//     text.splitMapJoin(
//       pattern,
//       onMatch: (Match match) {
//         children.add(
//           TextSpan(
//             text: match[0] ?? "",
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.onPrimary,
//               backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//             ),
//           ),
//         );
//         return match[0] ?? "";
//       },
//       onNonMatch: (String text) {
//         children.add(TextSpan(text: text, style: style));
//         return text;
//       },
//     );
//     return TextSpan(style: style, children: children);
//   }
// }

// class TransactionFiltersSelection extends StatefulWidget {
//   const TransactionFiltersSelection({
//     required this.searchFilters,
//     required this.setSearchFilters,
//     required this.clearSearchFilters,
//     super.key,
//   });

//   final SearchFilters searchFilters;
//   final Function(SearchFilters searchFilters) setSearchFilters;
//   final Function() clearSearchFilters;

//   @override
//   State<TransactionFiltersSelection> createState() => _TransactionFiltersSelectionState();
// }

// class _TransactionFiltersSelectionState extends State<TransactionFiltersSelection> {
//   late SearchFilters selectedFilters = widget.searchFilters;
//   late ScrollController titleContainsScrollController = ScrollController();
//   late TextEditingController titleContainsController = HighlightStringInList(
//     initialText: selectedFilters.titleContains,
//   );

//   void setSearchFilters() {
//     widget.setSearchFilters(selectedFilters);
//     setState(() {});
//   }

//   @override
//   void dispose() {
//     titleContainsController.dispose();
//     titleContainsScrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         //   SelectCategory(
//         //     horizontalList: true,
//         //     showSelectedAllCategoriesIfNoneSelected: true,
//         //     addButton: false,
//         //     selectedCategories: selectedFilters.categoryPks,
//         //     setSelectedCategories: (List<String>? categories) async {
//         //       selectedFilters.categoryPks = categories ?? [];
//         //       if (selectedFilters.categoryPks.length <= 0) selectedFilters.subcategoryPks = [];

//         //       // Remove any subcategories that are selected that no longer
//         //       // have the primary category selected
//         //       for (String subCategoryPk in ([...selectedFilters.subcategoryPks ?? []])) {
//         //         TransactionCategory subCategory = await database.getCategoryInstance(subCategoryPk);
//         //         if ((categories ?? []).contains(subCategory.mainCategoryPk) == false) {
//         //           (selectedFilters.subcategoryPks ?? []).remove(subCategoryPk);
//         //         }
//         //       }

//         //       setSearchFilters();
//         //     },
//         //   ),
//         //   SelectCategory(
//         //     horizontalList: true,
//         //     showSelectedAllCategoriesIfNoneSelected: true,
//         //     addButton: false,
//         //     selectedCategories: selectedFilters.subcategoryPks,
//         //     setSelectedCategories: (List<String>? categories) {
//         //       selectedFilters.subcategoryPks = categories ?? [];
//         //       setSearchFilters();
//         //     },
//         //     mainCategoryPks: selectedFilters.categoryPks,
//         //     forceSelectAllToFalse: selectedFilters.subcategoryPks == null,
//         //     header: [
//         //       SelectedCategoryHorizontalExtraButton(
//         //         label: "none".tr(),
//         //         onTap: () {
//         //           selectedFilters.subcategoryPks = null;
//         //           setSearchFilters();
//         //         },
//         //         isOutlined: selectedFilters.subcategoryPks == null,
//         //         icon: appStateSettings["outlinedIcons"] ? Icons.block_outlined : Icons.block_rounded,
//         //       ),
//         //     ],
//         //   ),
//         //   StreamBuilder<RangeValues>(
//         //     stream: database.getHighestLowestAmount(SearchFilters(dateTimeRange: selectedFilters.dateTimeRange)),
//         //     builder: ((context, snapshot) {
//         //       if (snapshot.hasData) {
//         //         RangeValues rangeLimit = RangeValues(
//         //           (snapshot.data?.start ?? -0.00000001),
//         //           (snapshot.data?.end ?? 0.00000001),
//         //         );
//         //         if ((selectedFilters.amountRange?.start ?? 0) < rangeLimit.start ||
//         //             (selectedFilters.amountRange?.end ?? 0) > rangeLimit.end) {
//         //           selectedFilters.amountRange = rangeLimit;
//         //         }
//         //         if (selectedFilters.amountRange?.end == rangeLimit.end &&
//         //             selectedFilters.amountRange?.start == rangeLimit.start) {
//         //           selectedFilters.amountRange = null;
//         //         }
//         //         return AmountRangeSlider(
//         //           rangeLimit: rangeLimit,
//         //           initialRange: selectedFilters.amountRange,
//         //           onChange: (RangeValues rangeValue) {
//         //             if (rangeLimit == rangeValue)
//         //               selectedFilters.amountRange = null;
//         //             else
//         //               selectedFilters.amountRange = rangeValue;
//         //           },
//         //         );
//         //       }
//         //       return SizedBox.shrink();
//         //     }),
//         //   ),
//         //   SizedBox(height: 10),
//         //   SelectChips(
//         //     items: ExpenseIncome.values,
//         //     getLabel: (ExpenseIncome item) {
//         //       return item == ExpenseIncome.expense
//         //           ? "expense".tr()
//         //           : item == ExpenseIncome.income
//         //           ? "income".tr()
//         //           : "";
//         //     },
//         //     getCustomBorderColor: (ExpenseIncome item) {
//         //       Color? customBorderColor;
//         //       if (item == ExpenseIncome.expense) {
//         //         customBorderColor = getColor(context, "expenseAmount");
//         //       } else if (item == ExpenseIncome.income) {
//         //         customBorderColor = getColor(context, "incomeAmount");
//         //       }
//         //       if (customBorderColor == null) return null;
//         //       return dynamicPastel(context, lightenPastel(customBorderColor, amount: 0.3), amount: 0.4);
//         //     },
//         //     onSelected: (ExpenseIncome item) {
//         //       if (selectedFilters.expenseIncome.contains(item)) {
//         //         selectedFilters.expenseIncome.remove(item);
//         //       } else {
//         //         selectedFilters.expenseIncome.add(item);
//         //       }
//         //       setSearchFilters();
//         //     },
//         //     getSelected: (ExpenseIncome item) {
//         //       return selectedFilters.expenseIncome.contains(item);
//         //     },
//         //   ),
//         //   SelectChips(
//         //     items: [null, ...TransactionSpecialType.values],
//         //     getLabel: (TransactionSpecialType? item) {
//         //       return transactionTypeDisplayToEnum[item]?.toString().toLowerCase().tr() ?? "";
//         //     },
//         //     getCustomBorderColor: (TransactionSpecialType? item) {
//         //       Color? customBorderColor;
//         //       if (item == TransactionSpecialType.credit) {
//         //         customBorderColor = getColor(context, "unPaidUpcoming");
//         //       } else if (item == TransactionSpecialType.debt) {
//         //         customBorderColor = getColor(context, "unPaidOverdue");
//         //       }
//         //       if (customBorderColor == null) return null;
//         //       return dynamicPastel(context, lightenPastel(customBorderColor, amount: 0.3), amount: 0.4);
//         //     },
//         //     onSelected: (TransactionSpecialType? item) {
//         //       if (selectedFilters.transactionTypes.contains(item)) {
//         //         selectedFilters.transactionTypes.remove(item);
//         //       } else {
//         //         selectedFilters.transactionTypes.add(item);
//         //       }
//         //       setSearchFilters();
//         //     },
//         //     getSelected: (TransactionSpecialType? item) {
//         //       return selectedFilters.transactionTypes.contains(item);
//         //     },
//         //   ),
//         //   SelectChips(
//         //     items: PaidStatus.values,
//         //     getLabel: (PaidStatus item) {
//         //       return item == PaidStatus.paid
//         //           ? "paid".tr()
//         //           : item == PaidStatus.notPaid
//         //           ? "not-paid".tr()
//         //           : item == PaidStatus.skipped
//         //           ? "skipped".tr()
//         //           : "";
//         //     },
//         //     onSelected: (PaidStatus item) {
//         //       if (selectedFilters.paidStatus.contains(item)) {
//         //         selectedFilters.paidStatus.remove(item);
//         //       } else {
//         //         selectedFilters.paidStatus.add(item);
//         //       }
//         //       setSearchFilters();
//         //     },
//         //     getSelected: (PaidStatus item) {
//         //       return selectedFilters.paidStatus.contains(item);
//         //     },
//         //   ),
//         //   if (appStateSettings["showMethodAdded"] == true)
//         //     StreamBuilder<List<MethodAdded?>>(
//         //       stream: database.watchAllDistinctMethodAdded(),
//         //       builder: (context, snapshot) {
//         //         if (snapshot.data == null || (snapshot.data?.length ?? 0) <= 1) return SizedBox.shrink();
//         //         List<MethodAdded?> possibleMethodAdded = snapshot.data ?? [];
//         //         return SelectChips(
//         //           items: possibleMethodAdded,
//         //           getLabel: (MethodAdded? item) {
//         //             return item?.name.capitalizeFirst ?? 'Default';
//         //           },
//         //           onSelected: (MethodAdded? item) {
//         //             if (selectedFilters.methodAdded.contains(item)) {
//         //               selectedFilters.methodAdded.remove(item);
//         //             } else {
//         //               selectedFilters.methodAdded.add(item);
//         //             }
//         //             setSearchFilters();
//         //           },
//         //           getSelected: (MethodAdded? item) {
//         //             return selectedFilters.methodAdded.contains(item);
//         //           },
//         //         );
//         //       },
//         //     ),

//         //   SelectChips(
//         //     items: Provider.of<AllWallets>(context).list,
//         //     onLongPress: (TransactionWallet? item) {
//         //       pushRoute(
//         //         context,
//         //         AddWalletPage(wallet: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
//         //       );
//         //     },
//         //     getLabel: (TransactionWallet item) {
//         //       return getWalletStringName(Provider.of<AllWallets>(context), item);
//         //     },
//         //     onSelected: (TransactionWallet item) {
//         //       if (selectedFilters.walletPks.contains(item.walletPk)) {
//         //         selectedFilters.walletPks.remove(item.walletPk);
//         //       } else {
//         //         selectedFilters.walletPks.add(item.walletPk);
//         //       }
//         //       setSearchFilters();
//         //     },
//         //     getSelected: (TransactionWallet item) {
//         //       return selectedFilters.walletPks.contains(item.walletPk);
//         //     },
//         //     getCustomBorderColor: (TransactionWallet item) {
//         //       return dynamicPastel(
//         //         context,
//         //         lightenPastel(HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary), amount: 0.3),
//         //         amount: 0.4,
//         //       );
//         //     },
//         //   ),

//         //   StreamBuilder<List<Budget>>(
//         //     stream: database.watchAllAddableBudgets(),
//         //     builder: (context, snapshot) {
//         //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
//         //       if (snapshot.hasData) {
//         //         return Column(
//         //           children: [
//         //             // SelectChips(
//         //             //   items: <BudgetTransactionFilters>[
//         //             //     BudgetTransactionFilters.addedToOtherBudget,
//         //             //     ...(appStateSettings["sharedBudgets"]
//         //             //         ? [BudgetTransactionFilters.sharedToOtherBudget]
//         //             //         : []),
//         //             //   ],
//         //             //   getLabel: (BudgetTransactionFilters item) {
//         //             //     return item == BudgetTransactionFilters.addedToOtherBudget
//         //             //         ? "added-to-other-budgets".tr()
//         //             //         : item == BudgetTransactionFilters.sharedToOtherBudget
//         //             //             ? "shared-to-other-budgets".tr()
//         //             //             : "";
//         //             //   },
//         //             //   onSelected: (BudgetTransactionFilters item) {
//         //             //     if (selectedFilters.budgetTransactionFilters
//         //             //         .contains(item)) {
//         //             //       selectedFilters.budgetTransactionFilters.remove(item);
//         //             //     } else {
//         //             //       selectedFilters.budgetTransactionFilters.add(item);
//         //             //     }
//         //             //     setSearchFilters();
//         //             //   },
//         //             //   getSelected: (BudgetTransactionFilters item) {
//         //             //     return selectedFilters.budgetTransactionFilters
//         //             //         .contains(item);
//         //             //   },
//         //             // ),
//         //             SelectChips(
//         //               items: [null, ...snapshot.data!],
//         //               onLongPress: (Budget? item) {
//         //                 pushRoute(
//         //                   context,
//         //                   AddBudgetPage(budget: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
//         //                 );
//         //               },
//         //               getLabel: (Budget? item) {
//         //                 if (item == null) return "no-budget".tr();
//         //                 return item.name;
//         //               },
//         //               onSelected: (Budget? item) {
//         //                 if (selectedFilters.budgetPks.contains(item?.budgetPk)) {
//         //                   selectedFilters.budgetPks.remove(item?.budgetPk);
//         //                 } else {
//         //                   selectedFilters.budgetPks.add(item?.budgetPk);
//         //                 }
//         //                 setSearchFilters();
//         //               },
//         //               getSelected: (Budget? item) {
//         //                 return selectedFilters.budgetPks.contains(item?.budgetPk);
//         //               },
//         //               getCustomBorderColor: (Budget? item) {
//         //                 if (item == null) return null;
//         //                 return dynamicPastel(
//         //                   context,
//         //                   lightenPastel(
//         //                     HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
//         //                     amount: 0.3,
//         //                   ),
//         //                   amount: 0.4,
//         //                 );
//         //               },
//         //             ),
//         //           ],
//         //         );
//         //       } else {
//         //         return SizedBox.shrink();
//         //       }
//         //     },
//         //   ),
//         //   StreamBuilder<List<Budget>>(
//         //     stream: database.watchAllExcludedTransactionsBudgetsInUse(),
//         //     builder: (context, snapshot) {
//         //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
//         //       if (snapshot.hasData) {
//         //         return Column(
//         //           children: [
//         //             SelectChips(
//         //               items: snapshot.data!,
//         //               onLongPress: (Budget? item) {
//         //                 pushRoute(
//         //                   context,
//         //                   AddBudgetPage(budget: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
//         //                 );
//         //               },
//         //               getLabel: (Budget item) {
//         //                 return "excluded-from".tr() + " " + item.name;
//         //               },
//         //               onSelected: (Budget item) {
//         //                 if (selectedFilters.excludedBudgetPks.contains(item.budgetPk)) {
//         //                   selectedFilters.excludedBudgetPks.remove(item.budgetPk);
//         //                 } else {
//         //                   selectedFilters.excludedBudgetPks.add(item.budgetPk);
//         //                 }
//         //                 setSearchFilters();
//         //               },
//         //               getSelected: (Budget item) {
//         //                 return selectedFilters.excludedBudgetPks.contains(item.budgetPk);
//         //               },
//         //               getCustomBorderColor: (Budget? item) {
//         //                 if (item == null) return null;
//         //                 return dynamicPastel(
//         //                   context,
//         //                   lightenPastel(
//         //                     HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
//         //                     amount: 0.3,
//         //                   ),
//         //                   amount: 0.4,
//         //                 );
//         //               },
//         //             ),
//         //           ],
//         //         );
//         //       } else {
//         //         return SizedBox.shrink();
//         //       }
//         //     },
//         //   ),

//         //   StreamBuilder<List<Objective>>(
//         //     stream: database.watchAllObjectives(objectiveType: ObjectiveType.goal, archivedLast: true),
//         //     builder: (context, snapshot) {
//         //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
//         //       if (snapshot.hasData) {
//         //         return SelectChips(
//         //           items: [null, ...snapshot.data!],
//         //           onLongPress: (Objective? item) {
//         //             pushRoute(
//         //               context,
//         //               AddObjectivePage(objective: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
//         //             );
//         //           },
//         //           getLabel: (Objective? item) {
//         //             if (item == null) return "no-goal".tr();
//         //             return item.name;
//         //           },
//         //           onSelected: (Objective? item) {
//         //             if (selectedFilters.objectivePks.contains(item?.objectivePk)) {
//         //               selectedFilters.objectivePks.remove(item?.objectivePk);
//         //             } else {
//         //               selectedFilters.objectivePks.add(item?.objectivePk);
//         //             }
//         //             setSearchFilters();
//         //           },
//         //           getSelected: (Objective? item) {
//         //             return selectedFilters.objectivePks.contains(item?.objectivePk);
//         //           },
//         //           getCustomBorderColor: (Objective? item) {
//         //             if (item == null) return null;
//         //             return dynamicPastel(
//         //               context,
//         //               lightenPastel(
//         //                 HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
//         //                 amount: 0.3,
//         //               ),
//         //               amount: 0.4,
//         //             );
//         //           },
//         //         );
//         //       } else {
//         //         return SizedBox.shrink();
//         //       }
//         //     },
//         //   ),

//         //   StreamBuilder<List<Objective>>(
//         //     stream: database.watchAllObjectives(objectiveType: ObjectiveType.loan, archivedLast: true),
//         //     builder: (context, snapshot) {
//         //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
//         //       if (snapshot.hasData) {
//         //         return SelectChips(
//         //           items: [null, ...snapshot.data!],
//         //           onLongPress: (Objective? item) {
//         //             pushRoute(
//         //               context,
//         //               AddObjectivePage(
//         //                 objective: item,
//         //                 routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete,
//         //                 objectiveType: ObjectiveType.loan,
//         //               ),
//         //             );
//         //           },
//         //           getLabel: (Objective? item) {
//         //             if (item == null) return "no-loan".tr();
//         //             return item.name;
//         //           },
//         //           onSelected: (Objective? item) {
//         //             if (selectedFilters.objectiveLoanPks.contains(item?.objectivePk)) {
//         //               selectedFilters.objectiveLoanPks.remove(item?.objectivePk);
//         //             } else {
//         //               selectedFilters.objectiveLoanPks.add(item?.objectivePk);
//         //             }
//         //             setSearchFilters();
//         //           },
//         //           getSelected: (Objective? item) {
//         //             return selectedFilters.objectiveLoanPks.contains(item?.objectivePk);
//         //           },
//         //           getCustomBorderColor: (Objective? item) {
//         //             if (item == null) return null;
//         //             return dynamicPastel(
//         //               context,
//         //               lightenPastel(
//         //                 HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
//         //                 amount: 0.3,
//         //               ),
//         //               amount: 0.4,
//         //             );
//         //           },
//         //         );
//         //       } else {
//         //         return SizedBox.shrink();
//         //       }
//         //     },
//         //   ),

//         //   // SelectChips(
//         //   //   items: MethodAdded.values,
//         //   //   getLabel: (item) {
//         //   //     return item == MethodAdded.csv
//         //   //         ? "CSV"
//         //   //         : item == MethodAdded.shared
//         //   //             ? "Shared"
//         //   //             : item == MethodAdded.email
//         //   //                 ? "Email"
//         //   //                 : "";
//         //   //   },
//         //   //   onSelected: (item) {
//         //   //     if (selectedFilters.methodAdded.contains(item)) {
//         //   //       selectedFilters.methodAdded.remove(item);
//         //   //     } else {
//         //   //       selectedFilters.methodAdded.add(item);
//         //   //     }
//         //   //     setSearchFilters();
//         //   //   },
//         //   //   getSelected: (item) {
//         //   //     return selectedFilters.methodAdded.contains(item);
//         //   //   },
//         //   // ),
//         //   SizedBox(height: 5),
//         //   Padding(
//         //     padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
//         //     child: Column(
//         //       children: [
//         //         TitleInput(
//         //           maxLines: 5,
//         //           resizePopupWhenChanged: false,
//         //           titleInputController: titleContainsController,
//         //           titleInputScrollController: titleContainsScrollController,
//         //           padding: EdgeInsetsDirectional.zero,
//         //           setSelectedCategory: (_) {},
//         //           setSelectedSubCategory: (_) {},
//         //           alsoSearchCategories: false,
//         //           setSelectedTitle: (String value) {
//         //             if (value.trim() == "") {
//         //               selectedFilters.titleContains = null;
//         //             } else {
//         //               selectedFilters.titleContains = value.trim();
//         //             }
//         //           },
//         //           showCategoryIconForRecommendedTitles: false,
//         //           unfocusWhenRecommendedTapped: false,
//         //           onNewRecommendedTitle: () {},
//         //           onRecommendedTitleTapped: (TransactionAssociatedTitleWithCategory title) async {
//         //             List<String> splitTitles = titleContainsController.text.trim().replaceAll(", ", ",").split(",");
//         //             if (splitTitles.length <= 0) return;
//         //             splitTitles.last = title.title.title;
//         //             titleContainsController.text = splitTitles.join(", ") + ", ";

//         //             if (titleContainsController.text == "") {
//         //               selectedFilters.titleContains = null;
//         //             } else {
//         //               selectedFilters.titleContains = titleContainsController.text.trim();
//         //             }

//         //             // Scroll to the end of the text input
//         //             titleContainsController.selection = TextSelection.fromPosition(
//         //               TextPosition(offset: titleContainsController.text.length),
//         //             );
//         //             Future.delayed(Duration(milliseconds: 50), () {
//         //               // delay cannot be zero
//         //               titleContainsScrollController.animateTo(
//         //                 titleContainsScrollController.position.maxScrollExtent,
//         //                 curve: Curves.easeInOutCubicEmphasized,
//         //                 duration: Duration(milliseconds: 500),
//         //               );
//         //             });
//         //           },
//         //           textToSearchFilter: (String text) {
//         //             return (text.split(",").lastOrNull ?? "").trim();
//         //           },
//         //           getTextToExclude: (String text) {
//         //             text = text.trim().replaceAll(", ", ",");
//         //             return (text.split(","));
//         //           },
//         //           handleOnRecommendedTitleTapped: false,
//         //           onSubmitted: (_) {},
//         //           autoFocus: false,
//         //           labelText: "title-contains".tr() + "...",
//         //         ),
//         //         SizedBox(height: 7),
//         //         TextInput(
//         //           maxLines: 5,
//         //           padding: EdgeInsetsDirectional.zero,
//         //           labelText: "notes-contain".tr() + "...",
//         //           onChanged: (value) {
//         //             if (value.trim() == "") {
//         //               selectedFilters.noteContains = null;
//         //             } else {
//         //               selectedFilters.noteContains = value.trim();
//         //             }
//         //           },
//         //           initialValue: selectedFilters.noteContains,
//         //           icon: appStateSettings["outlinedIcons"] ? Icons.sticky_note_2_outlined : Icons.sticky_note_2_rounded,
//         //         ),
//         //       ],
//         //     ),
//         //   ),

//         //   Padding(
//         //     padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
//         //     child: Row(
//         //       children: [
//         //         Flexible(
//         //           child: Button(
//         //             expandedLayout: true,
//         //             label: "reset".tr(),
//         //             onTap: () {
//         //               widget.clearSearchFilters();
//         //               popRoute(context);
//         //             },
//         //             color: Theme.of(context).colorScheme.tertiaryContainer,
//         //             textColor: Theme.of(context).colorScheme.onTertiaryContainer,
//         //           ),
//         //         ),
//         //         SizedBox(width: 13),
//         //         Flexible(
//         //           child: Button(
//         //             expandedLayout: true,
//         //             label: "apply".tr(),
//         //             onTap: () {
//         //               popRoute(context);
//         //             },
//         //           ),
//         //         ),
//         //       ],
//         //     ),
//         //   ),
//       ],
//     );
//   }
// }

// class AppliedFilterChips extends StatelessWidget {
//   const AppliedFilterChips({
//     required this.searchFilters,
//     required this.openFiltersSelection,
//     required this.clearSearchFilters,
//     this.openSelectDate,
//     this.padding = const EdgeInsetsDirectional.only(bottom: 8.0),
//     super.key,
//   });
//   final SearchFilters searchFilters;
//   final Function openFiltersSelection;
//   final Function clearSearchFilters;
//   final Function? openSelectDate;
//   final EdgeInsetsDirectional padding;

//   Future<List<Widget>> getSearchFilterWidgets(BuildContext context) async {
//     AllWallets allWallets = Provider.of<AllWallets>(context);
//     List<Widget> out = [];
//     // Title contains
//     if (searchFilters.titleContains != null) {
//       out.add(
//         AppliedFilterChip(
//           label: "title-contains".tr() + ": " + (searchFilters.titleContains ?? ""),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Notes contains
//     if (searchFilters.noteContains != null) {
//       out.add(
//         AppliedFilterChip(
//           label: "notes-contain".tr() + ": " + (searchFilters.noteContains ?? ""),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Categories
//     for (TransactionCategory category in await database.getAllCategories(
//       categoryFks: searchFilters.categoryPks,
//       allCategories: false,
//     )) {
//       out.add(
//         AppliedFilterChip(
//           label: category.name,
//           customBorderColor: HexColor(category.colour, defaultColor: Theme.of(context).colorScheme.primary),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     for (TransactionCategory category in await database.getAllCategories(
//       categoryFks: searchFilters.subcategoryPks,
//       allCategories: false,
//       includeSubCategories: true,
//     )) {
//       out.add(
//         AppliedFilterChip(
//           label: category.name,
//           customBorderColor: HexColor(category.colour, defaultColor: Theme.of(context).colorScheme.primary),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     if (searchFilters.subcategoryPks == null) {
//       out.add(AppliedFilterChip(label: "no-subcategory".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     // Amount range
//     if (searchFilters.amountRange != null) {
//       out.add(
//         AppliedFilterChip(
//           label:
//               convertToMoney(allWallets, searchFilters.amountRange!.start) +
//               " – " +
//               convertToMoney(allWallets, searchFilters.amountRange!.end),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Expense Income
//     if (searchFilters.expenseIncome.contains(ExpenseIncome.expense)) {
//       out.add(
//         AppliedFilterChip(
//           label: "expense".tr(),
//           customBorderColor: getColor(context, "expenseAmount"),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     if (searchFilters.expenseIncome.contains(ExpenseIncome.income)) {
//       out.add(
//         AppliedFilterChip(
//           label: "income".tr(),
//           customBorderColor: getColor(context, "incomeAmount"),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Cash Flow
//     if (searchFilters.positiveCashFlow == false) {
//       out.add(
//         AppliedFilterChip(
//           label: "outgoing".tr(),
//           customBorderColor: getColor(context, "expenseAmount"),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     } else if (searchFilters.positiveCashFlow == true) {
//       out.add(
//         AppliedFilterChip(
//           label: "incoming".tr(),
//           customBorderColor: getColor(context, "incomeAmount"),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Transaction Types
//     for (TransactionSpecialType? transactionType in searchFilters.transactionTypes) {
//       Color? customBorderColor;
//       if (transactionType == TransactionSpecialType.credit) {
//         customBorderColor = getColor(context, "unPaidUpcoming");
//       } else if (transactionType == TransactionSpecialType.debt) {
//         customBorderColor = getColor(context, "unPaidOverdue");
//       }
//       out.add(
//         AppliedFilterChip(
//           label: transactionTypeDisplayToEnum[transactionType]?.toString().toLowerCase().tr() ?? "default".tr(),
//           customBorderColor: customBorderColor,
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Paid status
//     if (searchFilters.paidStatus.contains(PaidStatus.paid)) {
//       out.add(AppliedFilterChip(label: "paid".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     if (searchFilters.paidStatus.contains(PaidStatus.notPaid)) {
//       out.add(AppliedFilterChip(label: "not-paid".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     if (searchFilters.paidStatus.contains(PaidStatus.skipped)) {
//       out.add(AppliedFilterChip(label: "skipped".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     // Budget Transaction Filters
//     if (searchFilters.budgetTransactionFilters.contains(BudgetTransactionFilters.sharedToOtherBudget)) {
//       out.add(AppliedFilterChip(label: "added-to-other-budgets".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     if (searchFilters.budgetTransactionFilters.contains(BudgetTransactionFilters.addedToOtherBudget)) {
//       out.add(AppliedFilterChip(label: "added-to-other-budgets".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     // Wallets
//     for (String walletPk in searchFilters.walletPks) {
//       out.add(
//         AppliedFilterChip(
//           label: getWalletStringName(Provider.of<AllWallets>(context, listen: false), allWallets.indexedByPk[walletPk]),
//           customBorderColor: HexColor(
//             allWallets.indexedByPk[walletPk]?.colour,
//             defaultColor: Theme.of(context).colorScheme.primary,
//           ),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }
//     // Budgets
//     for (Budget budget in await database.getAllBudgets()) {
//       if (searchFilters.budgetPks.contains(budget.budgetPk))
//         out.add(
//           AppliedFilterChip(
//             label: budget.name,
//             customBorderColor: HexColor(budget.colour, defaultColor: Theme.of(context).colorScheme.primary),
//             openFiltersSelection: openFiltersSelection,
//           ),
//         );
//     }
//     // Excluded Budgets
//     for (Budget budget in await database.getAllBudgets()) {
//       if (searchFilters.excludedBudgetPks.contains(budget.budgetPk))
//         out.add(
//           AppliedFilterChip(
//             label: "excluded-from".tr() + ": " + budget.name,
//             customBorderColor: HexColor(budget.colour, defaultColor: Theme.of(context).colorScheme.primary),
//             openFiltersSelection: openFiltersSelection,
//           ),
//         );
//     }
//     if (searchFilters.budgetPks.contains(null)) {
//       out.add(AppliedFilterChip(label: "no-budget".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     // Objectives
//     for (Objective objective in await database.getAllObjectives(objectiveType: ObjectiveType.goal)) {
//       if (searchFilters.objectivePks.contains(objective.objectivePk))
//         out.add(
//           AppliedFilterChip(
//             label: objective.name,
//             customBorderColor: HexColor(objective.colour, defaultColor: Theme.of(context).colorScheme.primary),
//             openFiltersSelection: openFiltersSelection,
//           ),
//         );
//     }
//     if (searchFilters.objectivePks.contains(null)) {
//       out.add(AppliedFilterChip(label: "no-goal".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     // Loan Objectives
//     for (Objective objective in await database.getAllObjectives(objectiveType: ObjectiveType.loan)) {
//       if (searchFilters.objectiveLoanPks.contains(objective.objectivePk))
//         out.add(
//           AppliedFilterChip(
//             label: objective.name,
//             customBorderColor: HexColor(objective.colour, defaultColor: Theme.of(context).colorScheme.primary),
//             openFiltersSelection: openFiltersSelection,
//           ),
//         );
//     }
//     if (searchFilters.objectiveLoanPks.contains(null)) {
//       out.add(AppliedFilterChip(label: "no-loan".tr(), openFiltersSelection: openFiltersSelection));
//     }
//     // Date and time range
//     if (out.length > 0 && openSelectDate != null && searchFilters.dateTimeRange != null) {
//       out.add(
//         AppliedFilterChip(
//           label:
//               getWordedDateShortMore(
//                 searchFilters.dateTimeRange!.start,
//                 includeYear: searchFilters.dateTimeRange!.start != DateTime.now().year,
//               ) +
//               " – " +
//               getWordedDateShortMore(
//                 searchFilters.dateTimeRange!.end,
//                 includeYear: searchFilters.dateTimeRange!.end != DateTime.now().year,
//               ),
//           openFiltersSelection: () => {openSelectDate!()},
//         ),
//       );
//     }
//     // Date from search text
//     ParsedDateTimeQuery? parsedDateTimeQuery = searchFilters.searchQuery == null
//         ? null
//         : parseSearchQueryForDateTimeText(searchFilters.searchQuery ?? "");
//     if (parsedDateTimeQuery != null) {
//       out.add(
//         AppliedFilterChip(
//           customBorderColor: Theme.of(context).colorScheme.tertiary,
//           label: parsedDateTimeQuery.formatDate(context.locale.toString()),
//           openFiltersSelection: () => {openSelectDate!()},
//         ),
//       );
//     }
//     // Amount from search text
//     (double, double)? bounds = searchFilters.searchQuery == null
//         ? null
//         : parseSearchQueryForAmountText(searchFilters.searchQuery ?? "");
//     if (bounds != null) {
//       double lowerBound = bounds.$1;
//       out.add(
//         AppliedFilterChip(
//           customBorderColor: Theme.of(context).colorScheme.tertiary,
//           label: "= " + lowerBound.toString(),
//           openFiltersSelection: () => {openSelectDate!()},
//         ),
//       );
//     }

//     // Method Added
//     for (MethodAdded? methodAdded in searchFilters.methodAdded) {
//       out.add(
//         AppliedFilterChip(
//           label: methodAdded?.name.toString().capitalizeFirst ?? "default".tr(),
//           openFiltersSelection: openFiltersSelection,
//         ),
//       );
//     }

//     return out;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         openFiltersSelection();
//       },
//       child: FutureBuilder(
//         future: getSearchFilterWidgets(context),
//         builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
//           return AnimatedSize(
//             curve: Curves.easeInOutCubicEmphasized,
//             duration: Duration(milliseconds: 1000),
//             child: snapshot.hasData && snapshot.data != null && snapshot.data!.length > 0
//                 ? Padding(
//                     padding: padding,
//                     child: SingleChildScrollView(
//                       padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
//                       scrollDirection: Axis.horizontal,
//                       child: AnimatedSwitcher(
//                         duration: 300.ms,
//                         // clipBehavior: Clip.none,
//                         child: Row(
//                           key: ValueKey(snapshot.data.toString()),
//                           children: [
//                             SizedBox(width: 5),
//                             IconButton(
//                               icon: Icon(Icons.close_rounded),
//                               iconSize: 14,
//                               // scale: 1.5,
//                               onPressed: () => clearSearchFilters(),
//                             ),
//                             const SizedBox(width: 2),
//                             ...(snapshot.data ?? []),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 : SizedBox.shrink(),
//           );
//         },
//       ),
//     );
//   }
// }

// class AppliedFilterChip extends StatelessWidget {
//   const AppliedFilterChip({
//     required this.label,
//     required this.openFiltersSelection,
//     this.icon,
//     this.customBorderColor,
//     super.key,
//   });
//   final Color? customBorderColor;
//   final String label;
//   final IconData? icon;
//   final Function openFiltersSelection;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
//       child: Tappable(
//         onTap: () {
//           openFiltersSelection();
//         },
//         // borderRadius: 8,
//         color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
//         child: Container(
//           padding: EdgeInsetsDirectional.only(start: 14, end: 14, top: 7, bottom: 7),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadiusDirectional.circular(8),
//             border: Border.all(
//               color: customBorderColor == null
//                   ? Theme.of(context).colorScheme.secondaryContainer
//                   : customBorderColor!.withOpacity(0.4),
//             ),
//           ),
//           child: Row(
//             children: [
//               icon == null
//                   ? SizedBox.shrink()
//                   : Padding(padding: const EdgeInsetsDirectional.only(end: 5.0), child: Icon(icon, size: 23.0)),
//               Text(label, style: TextStyle(fontSize: 14.0)),
//               // Padding(
//               //   padding: EdgeInsetsDirectional.only(start: 4.5),
//               //   child: Opacity(
//               //     opacity: 0.6,
//               //     child: Icon(
//               //       Icons.close,
//               //       size: 14,
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
