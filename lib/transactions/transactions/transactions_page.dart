import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:invesly/common/presentations/components/add_transaction_button.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/transactions/cubit/transactions_cubit.dart';
import 'package:invesly/transactions/transactions/filter_transactions_model.dart';

// int roundToNearestNextFifthYear(int year) {
//   return (((year + 5) / 5).ceil()) * 5;
// }

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({this.initialFilters, super.key});

  final FilterTransactionsModel? initialFilters;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsCubit>().fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return TransactionsCubit(
          repository: context.read<TransactionRepository>(),
          initialFilters: widget.initialFilters,
        );
      },
      child: _PageContent(),
    );
  }
}

class _PageContent extends StatefulWidget {
  const _PageContent({this.initialFilters, super.key});

  final FilterTransactionsModel? initialFilters;

  @override
  State<_PageContent> createState() => __PageContentState();
}

class __PageContentState extends State<_PageContent> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  //   _scrollListener(position) {
  //     double percent = position / (MediaQuery.paddingOf(context).top + 65 + 50);
  //     if (percent >= 0 && percent <= 1) {
  //       _animationControllerSearch.value = 1 - percent;
  //     }
  //   }
  late AnimationController _animationControllerSearch;
  //   final _debouncer = Debouncer(milliseconds: 500);
  late FilterTransactionsModel searchFilters;
  TextEditingController searchInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionsCubit>().fetchTransactions();
    searchFilters = widget.initialFilters != null ? widget.initialFilters! : FilterTransactionsModel();
    //     if (widget.initialFilters == null) {
    //       searchFilters.loadFilterString(
    //         appStateSettings["searchTransactionsSetFiltersString"],
    //         skipDateTimeRange: false,
    //         skipSearchQuery: true,
    //       );

    _animationControllerSearch = AnimationController(vsync: this, value: 1);
  }

  Future<void> selectFilters(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.65,
          minChildSize: 0.45,
          initialChildSize: 0.65,
          builder: (context, scrollController) {
            return TransactionFiltersSelection(
              // setSearchFilters: setSearchFilters,
              selectedFilter: searchFilters,
              // clearSearchFilters: clearSearchFilters,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchInputController.dispose();
    super.dispose();
  }

  //   void setSearchFilters(SearchFilters searchFilters) {
  //     this.searchFilters = searchFilters;
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
    return Scaffold(
      // scrollToTopButton: true,
      // scrollToBottomButton: true,
      // dragDownToDismiss: true,
      // onScroll: _scrollListener,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              title: const Text('All transactions'),
              actions: <Widget>[
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: IconButton(
                    key: ValueKey(searchFilters.isClear(ignoreDateTimeRange: true)),
                    color: searchFilters.isClear(ignoreDateTimeRange: true) ? null : context.colors.tertiaryContainer,
                    onPressed: () => selectFilters(context),
                    icon: Icon(
                      Icons.filter_alt_rounded,
                      color: searchFilters.isClear(ignoreDateTimeRange: true)
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
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),
                  child: BlocBuilder<TransactionsCubit, TransactionsState>(
                    builder: (context, state) {
                      return AppliedFilterChips(
                        searchFilter: searchFilters,
                        // openFiltersSelection: () => selectFilters(context),
                        // clearSearchFilters: clearSearchFilters,
                      );
                    },
                  ),
                ),

                // ~ Results
                BlocBuilder<TransactionsCubit, TransactionsState>(
                  builder: (context, state) {
                    if (state.isError) {
                      return Center(
                        child: Text(state.errorMsg ?? 'Some error has been occurred! Please refresh again.'),
                      );
                    }

                    // Grouping transactions by month
                    final groupTransactions = state.transactions?.groupListsBy<DateTime>(
                      (rt) => DateTime(rt.investedOn.year, rt.investedOn.month),
                    );
                    $logger.d(groupTransactions);

                    // if (rts.isEmpty) {
                    //   groupedTiles = [
                    //     SectionTile(
                    //       title: Center(child: Text('Oops! This is so empty', style: context.textTheme.titleLarge)),
                    //       subtitle: Center(
                    //         child: Text(
                    //           'No transactions have been found for this month.\nAdd a few transactions.',
                    //           textAlign: TextAlign.center,
                    //           style: context.textTheme.bodySmall,
                    //         ),
                    //       ),
                    //       contentSpacing: 12.0,
                    //     ),
                    //   ];
                    // }

                    return Column(
                      children: <Widget>[
                        ...List.generate(groupTransactions?.length ?? 2, (index) {
                          // dummy quantity for shimmer effect
                          final gtEntry = groupTransactions?.entries.elementAt(index);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                child: gtEntry != null ? Text(gtEntry.key.toReadable()) : Skeleton(),
                              ),
                              Section(
                                tiles: List.generate(gtEntry?.value.length ?? 4, (i) {
                                  // dummy quantity for shimmer effect
                                  final trn = gtEntry?.value.elementAt(i);
                                  return SectionTile(
                                    icon: trn != null
                                        ? CircleAvatar(
                                            backgroundColor: trn.transactionType.color(context).withAlpha(30),
                                            child: Icon(
                                              trn.transactionType.icon,
                                              color: trn.transactionType.color(context),
                                            ),
                                          )
                                        : Skeleton(height: 24.0, width: 24.0, shape: CircleBorder()),
                                    title: trn != null
                                        ? Text(trn.amc?.name ?? 'NULL', style: context.textTheme.bodyMedium)
                                        : Skeleton(height: 24.0),
                                    subtitle: trn != null ? Text(trn.investedOn.toReadable()) : Skeleton(height: 12.0),
                                    trailingIcon: trn != null
                                        ? BlocSelector<AppCubit, AppState, bool>(
                                            selector: (state) => state.isPrivateMode,
                                            builder: (context, isPrivateMode) {
                                              return CurrencyView(
                                                amount: trn.totalAmount,
                                                integerStyle: context.textTheme.headlineSmall?.copyWith(
                                                  color: trn.transactionType.color(context),
                                                ),
                                                privateMode: isPrivateMode,
                                              );
                                            },
                                          )
                                        : Skeleton(height: 24.0),
                                    onTap: () {},
                                  );
                                }),
                              ),
                            ],
                          );
                        }),
                        Tappable(
                          onTap: () => selectDateRange(context),
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsetsDirectional.only(start: 10, end: 10, top: 10, bottom: 8),
                            child: Text(
                              'All time',
                              // searchFilters.dateTimeRange == null
                              //     ? 'all-time'
                              //     : getWordedDateShortMore(
                              //             searchFilters.dateTimeRange?.start ?? DateTime.now(),
                              //             includeYear: true,
                              //           ) +
                              //           " – " +
                              //           getWordedDateShortMore(
                              //             searchFilters.dateTimeRange?.end ?? DateTime.now(),
                              //             includeYear: true,
                              //           ),
                              style: context.textTheme.bodySmall?.copyWith(color: context.theme.disabledColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 56.0),
              ]),
            ),
          ],
        ),
      ),
      // ~~~ Add transaction button ~~~
      floatingActionButton: AddTransactionButton(scrollController: _scrollController),
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

class HighlightStringInList extends TextEditingController {
  final Pattern pattern;

  HighlightStringInList({String? initialText}) : pattern = RegExp(r'\b[^,]+(?=|$)') {
    text = initialText ?? '';
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (text.contains(", ") == false) return TextSpan(style: style, text: text);
    List<InlineSpan> children = [];
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        children.add(
          TextSpan(
            text: match[0] ?? "",
            style: TextStyle(color: context.colors.onPrimary, backgroundColor: context.colors.primary.withAlpha(256)),
          ),
        );
        return match[0] ?? "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return text;
      },
    );
    return TextSpan(style: style, children: children);
  }
}

class TransactionFiltersSelection extends StatefulWidget {
  const TransactionFiltersSelection({this.selectedFilter, this.setSearchFilters, this.clearSearchFilters, super.key});

  final FilterTransactionsModel? selectedFilter;
  final Function(FilterTransactionsModel searchFilters)? setSearchFilters;
  final Function()? clearSearchFilters;

  @override
  State<TransactionFiltersSelection> createState() => _TransactionFiltersSelectionState();
}

class _TransactionFiltersSelectionState extends State<TransactionFiltersSelection> {
  late FilterTransactionsModel? selectedFilter = widget.selectedFilter;
  late ScrollController titleContainsScrollController = ScrollController();
  late TextEditingController titleContainsController = HighlightStringInList(
    initialText: selectedFilter?.titleContains,
  );

  // void setSearchFilters() {
  //   widget.setSearchFilters(selectedFilters);
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    final accountsCubit = context.read<AccountsCubit>();
    if (accountsCubit.state is! AccountsLoadedState) {
      accountsCubit.fetchAccounts();
    }
  }

  @override
  void dispose() {
    titleContainsController.dispose();
    titleContainsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // ~ Accounts
        BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, state) {
            final isLoading = state.isLoading;
            final isError = state.isError;
            final accounts = state.isLoaded ? (state as AccountsLoadedState).accounts : null;

            // return SingleChildScrollView(
            //   padding: const EdgeInsets.only(bottom: 16.0),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: List.generate(
            //       accounts?.length ?? 2, // dummy count for shimmer effect
            //       (index) {
            //         final account = accounts?.elementAt(index);
            //         return Shimmer(
            //           isLoading: isLoading,
            //           child: ListTile(
            //             leading: CircleAvatar(foregroundImage: account != null ? AssetImage(account.avatarSrc) : null),
            //             title: isLoading || isError
            //                 ? Skeleton(height: 24.0, color: isError ? context.colors.error : null)
            //                 : Text(account?.name ?? ''),
            //             trailing:  selectedFilter.accounts.contains(account)  ? const Icon(Icons.check_rounded) : null,
            //             onTap: account != null ? () => widget.onPickup?.call(account) : null,
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // );

            return Shimmer(
              isLoading: isLoading,
              child: InveslyChoiceChips<String>(
                options: List.generate(accounts?.length ?? 2, (index) {
                  final account = accounts?.elementAt(index);
                  return InveslyChipData(
                    label: account != null
                        ? Text(account.name)
                        : Skeleton(color: isError ? context.colors.error : null),
                    icon: CircleAvatar(foregroundImage: account != null ? AssetImage(account.avatarSrc) : null),
                    value: account?.id ?? '',
                  );
                }),
                selected: accounts?.map((acc) => acc.id).toSet(),
                wrapped: false,
              ),
            );
          },
        ),
        //   SelectCategory(
        //     horizontalList: true,
        //     showSelectedAllCategoriesIfNoneSelected: true,
        //     addButton: false,
        //     selectedCategories: selectedFilters.subcategoryPks,
        //     setSelectedCategories: (List<String>? categories) {
        //       selectedFilters.subcategoryPks = categories ?? [];
        //       setSearchFilters();
        //     },
        //     mainCategoryPks: selectedFilters.categoryPks,
        //     forceSelectAllToFalse: selectedFilters.subcategoryPks == null,
        //     header: [
        //       SelectedCategoryHorizontalExtraButton(
        //         label: "none".tr(),
        //         onTap: () {
        //           selectedFilters.subcategoryPks = null;
        //           setSearchFilters();
        //         },
        //         isOutlined: selectedFilters.subcategoryPks == null,
        //         icon: appStateSettings["outlinedIcons"] ? Icons.block_outlined : Icons.block_rounded,
        //       ),
        //     ],
        //   ),
        //   StreamBuilder<RangeValues>(
        //     stream: database.getHighestLowestAmount(SearchFilters(dateTimeRange: selectedFilters.dateTimeRange)),
        //     builder: ((context, snapshot) {
        //       if (snapshot.hasData) {
        //         RangeValues rangeLimit = RangeValues(
        //           (snapshot.data?.start ?? -0.00000001),
        //           (snapshot.data?.end ?? 0.00000001),
        //         );
        //         if ((selectedFilters.amountRange?.start ?? 0) < rangeLimit.start ||
        //             (selectedFilters.amountRange?.end ?? 0) > rangeLimit.end) {
        //           selectedFilters.amountRange = rangeLimit;
        //         }
        //         if (selectedFilters.amountRange?.end == rangeLimit.end &&
        //             selectedFilters.amountRange?.start == rangeLimit.start) {
        //           selectedFilters.amountRange = null;
        //         }
        //         return AmountRangeSlider(
        //           rangeLimit: rangeLimit,
        //           initialRange: selectedFilters.amountRange,
        //           onChange: (RangeValues rangeValue) {
        //             if (rangeLimit == rangeValue)
        //               selectedFilters.amountRange = null;
        //             else
        //               selectedFilters.amountRange = rangeValue;
        //           },
        //         );
        //       }
        //       return SizedBox.shrink();
        //     }),
        //   ),
        //   SizedBox(height: 10),
        //   SelectChips(
        //     items: ExpenseIncome.values,
        //     getLabel: (ExpenseIncome item) {
        //       return item == ExpenseIncome.expense
        //           ? "expense".tr()
        //           : item == ExpenseIncome.income
        //           ? "income".tr()
        //           : "";
        //     },
        //     getCustomBorderColor: (ExpenseIncome item) {
        //       Color? customBorderColor;
        //       if (item == ExpenseIncome.expense) {
        //         customBorderColor = getColor(context, "expenseAmount");
        //       } else if (item == ExpenseIncome.income) {
        //         customBorderColor = getColor(context, "incomeAmount");
        //       }
        //       if (customBorderColor == null) return null;
        //       return dynamicPastel(context, lightenPastel(customBorderColor, amount: 0.3), amount: 0.4);
        //     },
        //     onSelected: (ExpenseIncome item) {
        //       if (selectedFilters.expenseIncome.contains(item)) {
        //         selectedFilters.expenseIncome.remove(item);
        //       } else {
        //         selectedFilters.expenseIncome.add(item);
        //       }
        //       setSearchFilters();
        //     },
        //     getSelected: (ExpenseIncome item) {
        //       return selectedFilters.expenseIncome.contains(item);
        //     },
        //   ),
        //   SelectChips(
        //     items: [null, ...TransactionSpecialType.values],
        //     getLabel: (TransactionSpecialType? item) {
        //       return transactionTypeDisplayToEnum[item]?.toString().toLowerCase().tr() ?? "";
        //     },
        //     getCustomBorderColor: (TransactionSpecialType? item) {
        //       Color? customBorderColor;
        //       if (item == TransactionSpecialType.credit) {
        //         customBorderColor = getColor(context, "unPaidUpcoming");
        //       } else if (item == TransactionSpecialType.debt) {
        //         customBorderColor = getColor(context, "unPaidOverdue");
        //       }
        //       if (customBorderColor == null) return null;
        //       return dynamicPastel(context, lightenPastel(customBorderColor, amount: 0.3), amount: 0.4);
        //     },
        //     onSelected: (TransactionSpecialType? item) {
        //       if (selectedFilters.transactionTypes.contains(item)) {
        //         selectedFilters.transactionTypes.remove(item);
        //       } else {
        //         selectedFilters.transactionTypes.add(item);
        //       }
        //       setSearchFilters();
        //     },
        //     getSelected: (TransactionSpecialType? item) {
        //       return selectedFilters.transactionTypes.contains(item);
        //     },
        //   ),
        //   SelectChips(
        //     items: PaidStatus.values,
        //     getLabel: (PaidStatus item) {
        //       return item == PaidStatus.paid
        //           ? "paid".tr()
        //           : item == PaidStatus.notPaid
        //           ? "not-paid".tr()
        //           : item == PaidStatus.skipped
        //           ? "skipped".tr()
        //           : "";
        //     },
        //     onSelected: (PaidStatus item) {
        //       if (selectedFilters.paidStatus.contains(item)) {
        //         selectedFilters.paidStatus.remove(item);
        //       } else {
        //         selectedFilters.paidStatus.add(item);
        //       }
        //       setSearchFilters();
        //     },
        //     getSelected: (PaidStatus item) {
        //       return selectedFilters.paidStatus.contains(item);
        //     },
        //   ),
        //   if (appStateSettings["showMethodAdded"] == true)
        //     StreamBuilder<List<MethodAdded?>>(
        //       stream: database.watchAllDistinctMethodAdded(),
        //       builder: (context, snapshot) {
        //         if (snapshot.data == null || (snapshot.data?.length ?? 0) <= 1) return SizedBox.shrink();
        //         List<MethodAdded?> possibleMethodAdded = snapshot.data ?? [];
        //         return SelectChips(
        //           items: possibleMethodAdded,
        //           getLabel: (MethodAdded? item) {
        //             return item?.name.capitalizeFirst ?? 'Default';
        //           },
        //           onSelected: (MethodAdded? item) {
        //             if (selectedFilters.methodAdded.contains(item)) {
        //               selectedFilters.methodAdded.remove(item);
        //             } else {
        //               selectedFilters.methodAdded.add(item);
        //             }
        //             setSearchFilters();
        //           },
        //           getSelected: (MethodAdded? item) {
        //             return selectedFilters.methodAdded.contains(item);
        //           },
        //         );
        //       },
        //     ),

        //   SelectChips(
        //     items: Provider.of<AllWallets>(context).list,
        //     onLongPress: (TransactionWallet? item) {
        //       pushRoute(
        //         context,
        //         AddWalletPage(wallet: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
        //       );
        //     },
        //     getLabel: (TransactionWallet item) {
        //       return getWalletStringName(Provider.of<AllWallets>(context), item);
        //     },
        //     onSelected: (TransactionWallet item) {
        //       if (selectedFilters.walletPks.contains(item.walletPk)) {
        //         selectedFilters.walletPks.remove(item.walletPk);
        //       } else {
        //         selectedFilters.walletPks.add(item.walletPk);
        //       }
        //       setSearchFilters();
        //     },
        //     getSelected: (TransactionWallet item) {
        //       return selectedFilters.walletPks.contains(item.walletPk);
        //     },
        //     getCustomBorderColor: (TransactionWallet item) {
        //       return dynamicPastel(
        //         context,
        //         lightenPastel(HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary), amount: 0.3),
        //         amount: 0.4,
        //       );
        //     },
        //   ),

        //   StreamBuilder<List<Budget>>(
        //     stream: database.watchAllAddableBudgets(),
        //     builder: (context, snapshot) {
        //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
        //       if (snapshot.hasData) {
        //         return Column(
        //           children: [
        //             // SelectChips(
        //             //   items: <BudgetTransactionFilters>[
        //             //     BudgetTransactionFilters.addedToOtherBudget,
        //             //     ...(appStateSettings["sharedBudgets"]
        //             //         ? [BudgetTransactionFilters.sharedToOtherBudget]
        //             //         : []),
        //             //   ],
        //             //   getLabel: (BudgetTransactionFilters item) {
        //             //     return item == BudgetTransactionFilters.addedToOtherBudget
        //             //         ? "added-to-other-budgets".tr()
        //             //         : item == BudgetTransactionFilters.sharedToOtherBudget
        //             //             ? "shared-to-other-budgets".tr()
        //             //             : "";
        //             //   },
        //             //   onSelected: (BudgetTransactionFilters item) {
        //             //     if (selectedFilters.budgetTransactionFilters
        //             //         .contains(item)) {
        //             //       selectedFilters.budgetTransactionFilters.remove(item);
        //             //     } else {
        //             //       selectedFilters.budgetTransactionFilters.add(item);
        //             //     }
        //             //     setSearchFilters();
        //             //   },
        //             //   getSelected: (BudgetTransactionFilters item) {
        //             //     return selectedFilters.budgetTransactionFilters
        //             //         .contains(item);
        //             //   },
        //             // ),
        //             SelectChips(
        //               items: [null, ...snapshot.data!],
        //               onLongPress: (Budget? item) {
        //                 pushRoute(
        //                   context,
        //                   AddBudgetPage(budget: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
        //                 );
        //               },
        //               getLabel: (Budget? item) {
        //                 if (item == null) return "no-budget".tr();
        //                 return item.name;
        //               },
        //               onSelected: (Budget? item) {
        //                 if (selectedFilters.budgetPks.contains(item?.budgetPk)) {
        //                   selectedFilters.budgetPks.remove(item?.budgetPk);
        //                 } else {
        //                   selectedFilters.budgetPks.add(item?.budgetPk);
        //                 }
        //                 setSearchFilters();
        //               },
        //               getSelected: (Budget? item) {
        //                 return selectedFilters.budgetPks.contains(item?.budgetPk);
        //               },
        //               getCustomBorderColor: (Budget? item) {
        //                 if (item == null) return null;
        //                 return dynamicPastel(
        //                   context,
        //                   lightenPastel(
        //                     HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
        //                     amount: 0.3,
        //                   ),
        //                   amount: 0.4,
        //                 );
        //               },
        //             ),
        //           ],
        //         );
        //       } else {
        //         return SizedBox.shrink();
        //       }
        //     },
        //   ),
        //   StreamBuilder<List<Budget>>(
        //     stream: database.watchAllExcludedTransactionsBudgetsInUse(),
        //     builder: (context, snapshot) {
        //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
        //       if (snapshot.hasData) {
        //         return Column(
        //           children: [
        //             SelectChips(
        //               items: snapshot.data!,
        //               onLongPress: (Budget? item) {
        //                 pushRoute(
        //                   context,
        //                   AddBudgetPage(budget: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
        //                 );
        //               },
        //               getLabel: (Budget item) {
        //                 return "excluded-from".tr() + " " + item.name;
        //               },
        //               onSelected: (Budget item) {
        //                 if (selectedFilters.excludedBudgetPks.contains(item.budgetPk)) {
        //                   selectedFilters.excludedBudgetPks.remove(item.budgetPk);
        //                 } else {
        //                   selectedFilters.excludedBudgetPks.add(item.budgetPk);
        //                 }
        //                 setSearchFilters();
        //               },
        //               getSelected: (Budget item) {
        //                 return selectedFilters.excludedBudgetPks.contains(item.budgetPk);
        //               },
        //               getCustomBorderColor: (Budget? item) {
        //                 if (item == null) return null;
        //                 return dynamicPastel(
        //                   context,
        //                   lightenPastel(
        //                     HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
        //                     amount: 0.3,
        //                   ),
        //                   amount: 0.4,
        //                 );
        //               },
        //             ),
        //           ],
        //         );
        //       } else {
        //         return SizedBox.shrink();
        //       }
        //     },
        //   ),

        //   StreamBuilder<List<Objective>>(
        //     stream: database.watchAllObjectives(objectiveType: ObjectiveType.goal, archivedLast: true),
        //     builder: (context, snapshot) {
        //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
        //       if (snapshot.hasData) {
        //         return SelectChips(
        //           items: [null, ...snapshot.data!],
        //           onLongPress: (Objective? item) {
        //             pushRoute(
        //               context,
        //               AddObjectivePage(objective: item, routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete),
        //             );
        //           },
        //           getLabel: (Objective? item) {
        //             if (item == null) return "no-goal".tr();
        //             return item.name;
        //           },
        //           onSelected: (Objective? item) {
        //             if (selectedFilters.objectivePks.contains(item?.objectivePk)) {
        //               selectedFilters.objectivePks.remove(item?.objectivePk);
        //             } else {
        //               selectedFilters.objectivePks.add(item?.objectivePk);
        //             }
        //             setSearchFilters();
        //           },
        //           getSelected: (Objective? item) {
        //             return selectedFilters.objectivePks.contains(item?.objectivePk);
        //           },
        //           getCustomBorderColor: (Objective? item) {
        //             if (item == null) return null;
        //             return dynamicPastel(
        //               context,
        //               lightenPastel(
        //                 HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
        //                 amount: 0.3,
        //               ),
        //               amount: 0.4,
        //             );
        //           },
        //         );
        //       } else {
        //         return SizedBox.shrink();
        //       }
        //     },
        //   ),

        //   StreamBuilder<List<Objective>>(
        //     stream: database.watchAllObjectives(objectiveType: ObjectiveType.loan, archivedLast: true),
        //     builder: (context, snapshot) {
        //       if (snapshot.data != null && snapshot.data!.length <= 0) return SizedBox.shrink();
        //       if (snapshot.hasData) {
        //         return SelectChips(
        //           items: [null, ...snapshot.data!],
        //           onLongPress: (Objective? item) {
        //             pushRoute(
        //               context,
        //               AddObjectivePage(
        //                 objective: item,
        //                 routesToPopAfterDelete: RoutesToPopAfterDelete.PreventDelete,
        //                 objectiveType: ObjectiveType.loan,
        //               ),
        //             );
        //           },
        //           getLabel: (Objective? item) {
        //             if (item == null) return "no-loan".tr();
        //             return item.name;
        //           },
        //           onSelected: (Objective? item) {
        //             if (selectedFilters.objectiveLoanPks.contains(item?.objectivePk)) {
        //               selectedFilters.objectiveLoanPks.remove(item?.objectivePk);
        //             } else {
        //               selectedFilters.objectiveLoanPks.add(item?.objectivePk);
        //             }
        //             setSearchFilters();
        //           },
        //           getSelected: (Objective? item) {
        //             return selectedFilters.objectiveLoanPks.contains(item?.objectivePk);
        //           },
        //           getCustomBorderColor: (Objective? item) {
        //             if (item == null) return null;
        //             return dynamicPastel(
        //               context,
        //               lightenPastel(
        //                 HexColor(item.colour, defaultColor: Theme.of(context).colorScheme.primary),
        //                 amount: 0.3,
        //               ),
        //               amount: 0.4,
        //             );
        //           },
        //         );
        //       } else {
        //         return SizedBox.shrink();
        //       }
        //     },
        //   ),

        //   // SelectChips(
        //   //   items: MethodAdded.values,
        //   //   getLabel: (item) {
        //   //     return item == MethodAdded.csv
        //   //         ? "CSV"
        //   //         : item == MethodAdded.shared
        //   //             ? "Shared"
        //   //             : item == MethodAdded.email
        //   //                 ? "Email"
        //   //                 : "";
        //   //   },
        //   //   onSelected: (item) {
        //   //     if (selectedFilters.methodAdded.contains(item)) {
        //   //       selectedFilters.methodAdded.remove(item);
        //   //     } else {
        //   //       selectedFilters.methodAdded.add(item);
        //   //     }
        //   //     setSearchFilters();
        //   //   },
        //   //   getSelected: (item) {
        //   //     return selectedFilters.methodAdded.contains(item);
        //   //   },
        //   // ),
        //   SizedBox(height: 5),
        //   Padding(
        //     padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
        //     child: Column(
        //       children: [
        //         TitleInput(
        //           maxLines: 5,
        //           resizePopupWhenChanged: false,
        //           titleInputController: titleContainsController,
        //           titleInputScrollController: titleContainsScrollController,
        //           padding: EdgeInsetsDirectional.zero,
        //           setSelectedCategory: (_) {},
        //           setSelectedSubCategory: (_) {},
        //           alsoSearchCategories: false,
        //           setSelectedTitle: (String value) {
        //             if (value.trim() == "") {
        //               selectedFilters.titleContains = null;
        //             } else {
        //               selectedFilters.titleContains = value.trim();
        //             }
        //           },
        //           showCategoryIconForRecommendedTitles: false,
        //           unfocusWhenRecommendedTapped: false,
        //           onNewRecommendedTitle: () {},
        //           onRecommendedTitleTapped: (TransactionAssociatedTitleWithCategory title) async {
        //             List<String> splitTitles = titleContainsController.text.trim().replaceAll(", ", ",").split(",");
        //             if (splitTitles.length <= 0) return;
        //             splitTitles.last = title.title.title;
        //             titleContainsController.text = splitTitles.join(", ") + ", ";

        //             if (titleContainsController.text == "") {
        //               selectedFilters.titleContains = null;
        //             } else {
        //               selectedFilters.titleContains = titleContainsController.text.trim();
        //             }

        //             // Scroll to the end of the text input
        //             titleContainsController.selection = TextSelection.fromPosition(
        //               TextPosition(offset: titleContainsController.text.length),
        //             );
        //             Future.delayed(Duration(milliseconds: 50), () {
        //               // delay cannot be zero
        //               titleContainsScrollController.animateTo(
        //                 titleContainsScrollController.position.maxScrollExtent,
        //                 curve: Curves.easeInOutCubicEmphasized,
        //                 duration: Duration(milliseconds: 500),
        //               );
        //             });
        //           },
        //           textToSearchFilter: (String text) {
        //             return (text.split(",").lastOrNull ?? "").trim();
        //           },
        //           getTextToExclude: (String text) {
        //             text = text.trim().replaceAll(", ", ",");
        //             return (text.split(","));
        //           },
        //           handleOnRecommendedTitleTapped: false,
        //           onSubmitted: (_) {},
        //           autoFocus: false,
        //           labelText: "title-contains".tr() + "...",
        //         ),
        //         SizedBox(height: 7),
        //         TextInput(
        //           maxLines: 5,
        //           padding: EdgeInsetsDirectional.zero,
        //           labelText: "notes-contain".tr() + "...",
        //           onChanged: (value) {
        //             if (value.trim() == "") {
        //               selectedFilters.noteContains = null;
        //             } else {
        //               selectedFilters.noteContains = value.trim();
        //             }
        //           },
        //           initialValue: selectedFilters.noteContains,
        //           icon: appStateSettings["outlinedIcons"] ? Icons.sticky_note_2_outlined : Icons.sticky_note_2_rounded,
        //         ),
        //       ],
        //     ),
        //   ),

        //   Padding(
        //     padding: const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
        //     child: Row(
        //       children: [
        //         Flexible(
        //           child: Button(
        //             expandedLayout: true,
        //             label: "reset".tr(),
        //             onTap: () {
        //               widget.clearSearchFilters();
        //               popRoute(context);
        //             },
        //             color: Theme.of(context).colorScheme.tertiaryContainer,
        //             textColor: Theme.of(context).colorScheme.onTertiaryContainer,
        //           ),
        //         ),
        //         SizedBox(width: 13),
        //         Flexible(
        //           child: Button(
        //             expandedLayout: true,
        //             label: "apply".tr(),
        //             onTap: () {
        //               popRoute(context);
        //             },
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}

class AppliedFilterChips extends StatelessWidget {
  const AppliedFilterChips({required this.searchFilter, this.openFiltersSelection, this.clearSearchFilters, super.key});

  final FilterTransactionsModel searchFilter;
  final VoidCallback? openFiltersSelection;
  final VoidCallback? clearSearchFilters;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    // Title contains
    if (searchFilter.titleContains != null) {
      children.add(
        AppliedFilterChip(
          label: 'Title contains: ${searchFilter.titleContains}',
          openFiltersSelection: openFiltersSelection,
        ),
      );
    }

    // Accounts
    if (searchFilter.accounts.isNotEmpty) {
      children.add(
        SingleChildScrollView(
          // padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: searchFilter.accounts.map((acc) {
              return AppliedFilterChip(
                label: acc.name,
                customBorderColor: Theme.of(context).colorScheme.primary,
                openFiltersSelection: openFiltersSelection,
              );
            }).toList(),
          ),
        ),
      );
    }

    // AMCGenres
    if (searchFilter.amcGenres.isNotEmpty) {
      children.add(
        SingleChildScrollView(
          // padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: searchFilter.amcGenres.map((genre) {
              return AppliedFilterChip(
                label: genre.name,
                customBorderColor: genre.color,
                openFiltersSelection: openFiltersSelection,
              );
            }).toList(),
          ),
        ),
      );
    }

    // AMCs
    if (searchFilter.amcs.isNotEmpty) {
      children.add(
        SingleChildScrollView(
          // padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: searchFilter.amcs.map((amc) {
              return AppliedFilterChip(
                label: amc.name,
                customBorderColor: Theme.of(context).colorScheme.secondary,
                openFiltersSelection: openFiltersSelection,
              );
            }).toList(),
          ),
        ),
      );
    }

    // Amount range
    if (searchFilter.amountRange != null) {
      children.add(
        AppliedFilterChip(
          label: '${searchFilter.amountRange!.start} - ${searchFilter.amountRange!.end}',
          openFiltersSelection: openFiltersSelection,
        ),
      );
    }

    // Transaction types
    if (searchFilter.transactionTypes.isNotEmpty) {
      children.add(
        SingleChildScrollView(
          // padding: EdgeInsetsDirectional.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: searchFilter.amcGenres.map((type) {
              return AppliedFilterChip(
                label: type.name,
                customBorderColor: type.color,
                openFiltersSelection: openFiltersSelection,
              );
            }).toList(),
          ),
        ),
      );
    }

    // Date and time range
    if (searchFilter.dateTimeRange != null) {
      children.add(
        AppliedFilterChip(
          label: '${searchFilter.dateTimeRange!.start.toReadable()} - ${searchFilter.dateTimeRange!.end.toReadable()}',
          openFiltersSelection: openFiltersSelection,
        ),
      );
    }

    // Notes contains
    if (searchFilter.noteContains != null) {
      children.add(
        AppliedFilterChip(
          label: 'Title contains: ${searchFilter.noteContains}',
          openFiltersSelection: openFiltersSelection,
        ),
      );
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text('Filters', overflow: TextOverflow.ellipsis)),
            IconButton(icon: Icon(Icons.close_rounded), iconSize: 14, onPressed: clearSearchFilters),
          ],
        ),
        AnimatedSwitcher(
          duration: 300.ms,
          child: children.isNotEmpty
              ? Column(
                  children: children.map((child) {
                    return AnimatedSize(curve: Curves.easeInOutCubicEmphasized, duration: 1000.ms, child: child);
                  }).toList(),
                )
              : SizedBox(),
        ),
      ],
    );
  }
}

class AppliedFilterChip extends StatelessWidget {
  const AppliedFilterChip({
    required this.label,
    this.openFiltersSelection,
    this.icon,
    this.customBorderColor,
    super.key,
  });

  final Color? customBorderColor;
  final String label;
  final IconData? icon;
  final VoidCallback? openFiltersSelection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 4.0),
      child: Tappable(
        onTap: openFiltersSelection,
        // borderRadius: 8,
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
        child: Container(
          padding: EdgeInsetsDirectional.only(start: 14, end: 14, top: 7, bottom: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(8),
            border: Border.all(
              color: customBorderColor == null
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : customBorderColor!.withOpacity(0.4),
            ),
          ),
          child: Row(
            children: [
              icon == null
                  ? SizedBox.shrink()
                  : Padding(padding: const EdgeInsetsDirectional.only(end: 5.0), child: Icon(icon, size: 23.0)),
              Text(label, style: TextStyle(fontSize: 14.0)),
              // Padding(
              //   padding: EdgeInsetsDirectional.only(start: 4.5),
              //   child: Opacity(
              //     opacity: 0.6,
              //     child: Icon(
              //       Icons.close,
              //       size: 14,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
