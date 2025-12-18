import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class FilterTransactionsModel extends Equatable {
  const FilterTransactionsModel({
    this.titleContains,
    this.accounts = const [],
    this.amcGenres = const [],
    this.amcs = const [],
    this.amountRange,
    this.transactionTypes = const [],
    this.dateTimeRange,
    this.noteContains,
  });

  final String? titleContains;
  final List<InveslyAccount> accounts;
  final List<AmcGenre> amcGenres;
  final List<InveslyAmc> amcs;
  final RangeValues? amountRange;
  final List<TransactionType> transactionTypes;
  final DateTimeRange? dateTimeRange;
  final String? noteContains;

  FilterTransactionsModel copyWith({
    String? titleContains,
    List<InveslyAccount>? accounts,
    List<AmcGenre>? amcGenres,
    List<InveslyAmc>? amcs,
    RangeValues? amountRange,
    List<TransactionType>? transactionTypes,
    DateTimeRange? dateTimeRange,
    String? noteContains,
  }) {
    return FilterTransactionsModel(
      titleContains: titleContains ?? this.titleContains,
      accounts: accounts ?? this.accounts,
      amcGenres: amcGenres ?? this.amcGenres,
      amcs: amcs ?? this.amcs,
      amountRange: amountRange ?? this.amountRange,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      dateTimeRange: dateTimeRange ?? this.dateTimeRange,
      noteContains: noteContains ?? this.noteContains,
    );
  }

  bool isClear({bool? ignoreDateTimeRange}) {
    return (titleContains == null &&
        accounts.isEmpty &&
        amcs.isEmpty &&
        amountRange == null &&
        (ignoreDateTimeRange == true || dateTimeRange == null) &&
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
  List<Object?> get props => [titleContains, accounts, amcs, amountRange, dateTimeRange, noteContains];
}
