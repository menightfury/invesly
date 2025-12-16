import 'package:invesly/common/extensions/iterable_extension.dart';
import 'package:invesly/common_libs.dart';

class SearchFilters extends Equatable {
  const SearchFilters({
    this.walletPks = const [],
    this.categoryPks = const [],
    this.subcategoryPks = const [],
    this.budgetPks = const [],
    this.excludedBudgetPks = const [],
    this.objectivePks = const [],
    this.objectiveLoanPks = const [],
    this.positiveCashFlow,
    this.amountRange,
    this.dateTimeRange,
    this.searchQuery,
    this.titleContains,
    this.noteContains,
  });

  final List<String> walletPks;
  final List<String> categoryPks;
  final List<String>? subcategoryPks;
  final List<String?> budgetPks;
  final List<String> excludedBudgetPks;
  final List<String?> objectivePks;
  final List<String?> objectiveLoanPks;
  final bool? positiveCashFlow;
  final RangeValues? amountRange;
  final DateTimeRange? dateTimeRange;
  final String? searchQuery;
  final String? titleContains;
  final String? noteContains;

  SearchFilters copyWith({
    List<String>? walletPks,
    List<String>? categoryPks,
    List<String>? subcategoryPks,
    List<String?>? budgetPks,
    List<String>? excludedBudgetPks,
    List<String?>? objectivePks,
    List<String?>? objectiveLoanPks,
    bool? positiveCashFlow,
    RangeValues? amountRange,
    DateTimeRange? dateTimeRange,
    bool forceSetDateTimeRange = false,
    String? searchQuery,
    String? titleContains,
    String? noteContains,
  }) {
    return SearchFilters(
      walletPks: walletPks ?? this.walletPks,
      categoryPks: categoryPks ?? this.categoryPks,
      subcategoryPks: subcategoryPks ?? this.subcategoryPks,
      budgetPks: budgetPks ?? this.budgetPks,
      excludedBudgetPks: excludedBudgetPks ?? this.excludedBudgetPks,
      objectivePks: objectivePks ?? this.objectivePks,
      objectiveLoanPks: objectiveLoanPks ?? this.objectiveLoanPks,
      positiveCashFlow: positiveCashFlow,
      amountRange: amountRange ?? this.amountRange,
      dateTimeRange: forceSetDateTimeRange == true ? dateTimeRange : (dateTimeRange ?? this.dateTimeRange),
      searchQuery: searchQuery ?? this.searchQuery,
      titleContains: titleContains ?? this.titleContains,
      noteContains: noteContains ?? this.noteContains,
    );
  }

  bool isClear({bool? ignoreDateTimeRange, bool? ignoreSearchQuery}) {
    return (walletPks.isEmpty &&
        categoryPks.isEmpty &&
        subcategoryPks?.isEmpty == true &&
        budgetPks.isEmpty &&
        excludedBudgetPks.isEmpty &&
        objectivePks.isEmpty &&
        objectiveLoanPks.isEmpty &&
        positiveCashFlow == null &&
        amountRange == null &&
        (ignoreDateTimeRange == true || dateTimeRange == null) &&
        (ignoreSearchQuery == true || searchQuery == null) &&
        titleContains == null &&
        noteContains == null);
  }

  // void loadFilterString(String? filterString, {bool skipDateTimeRange = false, bool skipSearchQuery = false}) {
  //   if (filterString == null) return;
  //   List<String> filterElements = filterString.split(":-:");

  //   for (int i = 0; i < filterElements.length; i += 2) {
  //     if (i >= filterElements.length - 1) break;
  //     String? key = filterElements.byIndexOrNull(i);
  //     String? value = filterElements.byIndexOrNull(i + 1);
  //     if (key == null || value == null) break;
  //     try {
  //       switch (key) {
  //         case 'walletPks':
  //           walletPks.add(value);
  //           break;
  //         case 'categoryPks':
  //           categoryPks.add(value);
  //           break;
  //         case 'subcategoryPks':
  //           if (value == "null") {
  //             subcategoryPks = null;
  //           } else {
  //             subcategoryPks?.add(value);
  //           }
  //           break;
  //         case 'budgetPks':
  //           if (value == "null") {
  //             budgetPks.add(null);
  //           } else {
  //             budgetPks.add(value);
  //           }
  //           break;
  //         case 'excludedBudgetPks':
  //           excludedBudgetPks.add(value);
  //           break;
  //         case 'objectivePks':
  //           if (value == "null") {
  //             objectivePks.add(null);
  //           } else {
  //             objectivePks.add(value);
  //           }
  //           break;
  //         case 'objectiveLoanPks':
  //           if (value == "null") {
  //             objectiveLoanPks.add(null);
  //           } else {
  //             objectiveLoanPks.add(value);
  //           }
  //           break;
  //         // case 'expenseIncome':
  //         //   expenseIncome.add(ExpenseIncome.values[int.parse(value)]);
  //         //   break;
  //         case 'positiveCashFlow':
  //           if (value == "null") {
  //             positiveCashFlow = null;
  //           } else {
  //             positiveCashFlow = bool.parse(value);
  //           }
  //           break;
  //         // case 'paidStatus':
  //         //   paidStatus.add(PaidStatus.values[int.parse(value)]);
  //         //   break;
  //         // case 'transactionTypes':
  //         //   if (value == "null") {
  //         //     transactionTypes.add(null);
  //         //   } else {
  //         //     transactionTypes.add(TransactionSpecialType.values[int.parse(value)]);
  //         //   }
  //         //   break;
  //         // case 'budgetTransactionFilters':
  //         //   budgetTransactionFilters.add(BudgetTransactionFilters.values[int.parse(value)]);
  //         //   break;
  //         // case 'methodAdded':
  //         //   methodAdded.add(MethodAdded.values[int.parse(value)]);
  //         //   break;
  //         case 'amountRange':
  //           if (value == "null") {
  //             amountRange = null;
  //           } else {
  //             value = value.replaceAll("RangeValues(", "");
  //             value = value.replaceAll(")", "");
  //             List<String> rangeValues = value.split(", ");
  //             amountRange = RangeValues(double.parse(rangeValues[0]), double.parse(rangeValues[1]));
  //           }
  //           break;
  //         case 'dateTimeRange':
  //           if (value == "null" || skipDateTimeRange) {
  //             dateTimeRange = null;
  //           } else {
  //             List<String> dateValues = value.split(" - ");
  //             dateTimeRange = DateTimeRange(start: DateTime.parse(dateValues[0]), end: DateTime.parse(dateValues[1]));
  //           }
  //           break;
  //         case 'searchQuery':
  //           if (value == "null" || value.trim() == "" || skipSearchQuery) {
  //             searchQuery = null;
  //           } else {
  //             searchQuery = value;
  //           }
  //           break;
  //         case 'titleContains':
  //           if (value == "null" || value.trim() == "") {
  //             titleContains = null;
  //           } else {
  //             titleContains = value;
  //           }
  //           break;
  //         case 'noteContains':
  //           if (value == "null" || value.trim() == "") {
  //             noteContains = null;
  //           } else {
  //             noteContains = value;
  //           }
  //           break;
  //         default:
  //           break;
  //       }
  //     } catch (e) {
  //       print(e.toString() + " error loading filter string " + key.toString() + " " + value.toString());
  //     }
  //   }
  // }

  // String getFilterString() {
  //   String outString = "";
  //   for (String element in walletPks) {
  //     outString += "walletPks:-:$element:-:";
  //   }
  //   for (String element in categoryPks) {
  //     outString += "categoryPks:-:$element:-:";
  //   }
  //   for (String element in subcategoryPks ?? []) {
  //     outString += "subcategoryPks:-:$element:-:";
  //   }
  //   if (subcategoryPks == null) {
  //     outString += "subcategoryPks:-:" + "null" + ":-:";
  //   }
  //   for (String? element in budgetPks) {
  //     outString += "budgetPks:-:$element:-:";
  //   }
  //   for (String? element in excludedBudgetPks) {
  //     outString += "excludedBudgetPks:-:$element:-:";
  //   }
  //   for (String? element in objectivePks) {
  //     outString += "objectivePks:-:$element:-:";
  //   }
  //   for (String? element in objectiveLoanPks) {
  //     outString += "objectiveLoanPks:-:$element:-:";
  //   }
  //   outString += "positiveCashFlow:-:$positiveCashFlow:-:";
  //   outString += "amountRange:-:$amountRange:-:";
  //   outString += "dateTimeRange:-:$dateTimeRange:-:";
  //   outString += "searchQuery:-:$searchQuery:-:";
  //   outString += "titleContains:-:$titleContains:-:";
  //   outString += "noteContains:-:$noteContains:-:";

  //   return outString;
  // }

  @override
  List<Object?> get props => [
    walletPks,
    categoryPks,
    subcategoryPks,
    budgetPks,
    excludedBudgetPks,
    objectivePks,
    objectiveLoanPks,
    positiveCashFlow,
    amountRange,
    dateTimeRange,
    searchQuery,
    titleContains,
    noteContains,
  ];
}
