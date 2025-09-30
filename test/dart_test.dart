// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:invesly/common/extensions/num_extension.dart';

void main() async {
  print('importing starts ======');
  const _fields = {
    TransactionField.amount: 1,
    TransactionField.quantity: 6,
    TransactionField.account: 1,
    TransactionField.amc: 4,
    TransactionField.type: 7,
    TransactionField.date: 3,
    TransactionField.notes: 5,
  };

  final csvRows = _csvData;
  final dateNow = DateTime.now();
  final amountColumnIndex = _fields[TransactionField.amount];
  final qntyColumnIndex = _fields[TransactionField.quantity];
  final accountColumnIndex = _fields[TransactionField.account];
  final amcColumnIndex = _fields[TransactionField.amc];
  final typeColumnIndex = _fields[TransactionField.amount];
  final dateColumnIndex = _fields[TransactionField.date];
  final noteColumnIndex = _fields[TransactionField.notes];

  // Cache of accounts and amcs
  final existingAccounts = <String, AccountInDb>{};
  final existingAmcs = <String, AmcInDb>{};

  final errors = <int, List<TransactionField>>{}; // { rowNumber : [ Errors ] }

  final transactionsToInsert = <TransactionInDb>[];
  for (var i = 0; i < csvRows.length; i++) {
    final row = csvRows[i];
    // Resolve type
    // The type can be integer (i.e. 0 for investment and 1 for redemption, 2 for dividend) or
    // can be one character (like I, R, D) or can be string (Investment, Redemption or Divident)
    // TransactionType? type = TransactionType.invested;
    // final rawType = typeColumnIndex == null ? null : row[typeColumnIndex];
    // if (rawType is int) {
    //   type = TransactionType.fromInt(rawType);
    // } else if (rawType is String) {
    //   type = rawType.length == 1 ? TransactionType.fromChar(rawType) : TransactionType.fromString(rawType);
    // }

    // Resolve amount
    final totalAmount = amountColumnIndex == null ? null : double.tryParse(row[amountColumnIndex].toString());
    if (totalAmount == null) {
      errors[i] = [...?errors[i], TransactionField.amount];
    }

    // Resolve quantity
    final quantity = qntyColumnIndex == null ? null : double.tryParse(row[qntyColumnIndex].toString());

    // Resolve account
    // distinguish between accountIdOrName = null and account = null
    // (i.e. accountIdOrName is provided but account not exists)
    final accountIdOrName = accountColumnIndex == null ? null : row[accountColumnIndex].toString().trim().toLowerCase();
    String? accountId;
    if (accountIdOrName != null && accountIdOrName.isNotEmpty) {
      // Look for account in cache first
      if (existingAccounts.containsKey(accountIdOrName)) {
        accountId = existingAccounts[accountIdOrName]!.id;
      } else {
        // Look for account in database
        // final account = await _accountRepository.getAccount(accountIdOrName);
        final account = await Future.delayed(
          5.ms,
          () => initialAccounts.firstWhereOrNull(
            (a) => a.name.toLowerCase() == accountIdOrName || a.id.toLowerCase() == accountIdOrName,
          ),
        );
        if (account == null) {
          // accountIdOrName is provided but account not exists
          // show modal to select one of the accounts or to add a new account with that name
          errors[i] = [...?errors[i], TransactionField.account];
        } else {
          // add fetched account to `existingAccounts` cache for future
          existingAccounts[account.id] = account;
          accountId = account.id;
        }
      }
    }

    // Resolve amc
    final amcIdOrName = amcColumnIndex == null ? null : row[amcColumnIndex].toString().trim();
    String? amcId;
    if (amcIdOrName != null && amcIdOrName.isNotEmpty) {
      // Look for amc in cache first
      if (existingAmcs.containsKey(amcIdOrName)) {
        amcId = existingAmcs[amcIdOrName]!.id;
      } else {
        // Look for amc in database
        // final amc = await _amcRepository.getAmc(amcIdOrName);
        final amc = await Future.delayed(5.ms, () => initialAmcs.firstWhereOrNull((a) => a.id == amcIdOrName));
        if (amc == null) {
          // amcIdOrName is provided but amc not exists
          // show modal to select one of the amcs or to add a new amc with that name
          errors[i] = [...?errors[i], TransactionField.amc];
        } else {
          // add fetched amc to `existingAmcs` cache for future
          existingAmcs[amc.id] = amc;
          amcId = amc.id;
        }
      }
    }

    // Resolve date
    late final DateTime date;
    if (dateColumnIndex != null) {
      date = DateFormat('d-M-yyyy').tryParse(row[dateColumnIndex].toString()) ?? dateNow;
    } else {
      date = dateNow;
    }

    // Resolve note
    final note = noteColumnIndex == null ? null : row[noteColumnIndex].toString();

    // if (errors[i]?.isEmpty ?? true) {
    //   transactionsToInsert.add(
    //     TransactionInDb(
    //       id: $uuid.v1(),
    //       accountId: accountId!,
    //       date: date.millisecondsSinceEpoch,
    //       quantity: quantity ?? 0.0,
    //       totalAmount: totalAmount ?? 0.0,
    //       amcId: amcId,
    //       note: (note?.isEmpty ?? true) ? null : note,
    //     ),
    //   );
    // }
  }

  print(errors);

  print('importing completed ===========');
}

// ==== DATA FROM CSV FILE ====
// id, account, amount, date, amc, notes, quantity, type
const _csvData = [
  [1, 'satyajyoti biswas', 1000, '3-16-2025', 'Thoughtblab', 'Proin eu mi. Nulla ac enim. In er ac neque.', 67, 0],
  [2, 'jhuma mondal', 1546, '10-11-2024', 'Omba', 'Maecenas ut massa quis augu. commodo placerat.', 66, 0],
  [3, 'satyajyoti_Biswas', 2160, '6-11-2025', 'Blogspan', 'Curabitur gravidant eget, tempus vel, pede.', 41, 0],
  [4, 'Satyajyoti Biswas', 1256, '3-22-2025', 'Quimba', 'Integer ac leo. Pellentesque u Donec vitae nisi.', 12, 1],
  [5, 'Jhuma Mondal', 1423, '10-9-2024', 'Blogtag', 'Etiam vel augue. Vestibulum  auctor gravida sem.', 31, 0],
  [6, 'Jhuma Mondal', 986, '1-21-2025', 'Oodoo', 'Phasellus sit amet erats euinteger non velit.', 37, 0],
  [7, 'Jhuma mondal', 346.50, '9-5-2025', 'Youbridge', 'Integer ac leo. Pelvel, dapibus at, diam.', 36, 0],
  [8, 'Jhuma_Mondal', 789.45, '6-10-2025', 'Oyondu', 'In hac habitasse plateatortor quis turpis', 63, 1],
  [9, 'Satyajyoti Biswas', 9765.54, '11-2-2024', 'Yakitri', 'Quisque id justo en dignissim vestibulum', 68, 0],
  [10, 'Satyajyoti Biswas', 1334.56, '1-19-2025', 'Topicshots', 'Vestibulum quam landit non,', 68, 1],
  [11, 'Jhuma_mondal', 765.25, '9-27-2025', 'Aimbu', 'In quis justo. aliquam lacust dui.', 93, 1],
  [12, 'Satyajyoti Biswas', 7946.25, '10-14-2024', 'Feedmix', 'Aenean fermentum. Dassa tecies eu, nibh.', 80, 1],
  [13, 'Jhuma Mondal', 35.26, '11-13-2024', 'Bluezoom', 'Fusce consequc nislu est congue elementum.', 79, 1],
  [14, 'Jhuma Mondal', 78.21, '10-1-2024', 'Devpoint', 'Pellentesque at nulla. in ulputate luctus.', 3, 0],
  [15, 'Satyajyoti Biswas', 235.14, '9-7-2025', 'Flashset', 'Vestibulum quam lacinia sapien quis libero.', 30, 1],
  [16, 'Jhuma Mondal', 987.32, '1-15-2025', 'Yakitri', 'Nam ultrices, libero nons at, diam.', 68, 0],
  [17, 'Jhuma Mondal', 965.23, '10-1-2024', 'Zoomdog', 'Suspendisse potenti. In platea dictumst.', 93, 0],
  [18, 'Wainwright Learmount', 741.23, '3-6-2025', 'Jaxnation', 'Fusce consequat. Nulla nisl. Nunc nisl.', 31, 1],
  [19, 'Jhuma Mondal', 965.23, '6-2-2025', 'Divavu', 'Donec diam neque,  ac neque.', 67, 1],
  [20, 'Enrichetta Swyre', 785.23, '10-11-2024', 'Youbridge', 'Aenean fermentum. Aliquam erat volutpat.', 40, 1],
];

// ==== DATA AVAILABLE IN DATABASE ====
final initialAccounts = [
  AccountInDb(id: 'satyajyoti_biswas', name: 'Satyajyoti Biswas', avatarIndex: 2),
  AccountInDb(id: 'jhuma_mondal', name: 'Jhuma Mondal', avatarIndex: 1),
];
final initialAmcs = [
  // ~ Mutual funds
  AmcInDb(
    id: 'aditya-birla-sunlife-mf-equity-focused-growth-direct',
    name: 'Aditya Birla Sunlife',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Focused'},
  ),
  AmcInDb(
    id: 'aditya-birla-sunlife-mf-equity-focused-growth-regular',
    name: 'Aditya Birla Sunlife',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Focused'},
  ),
  AmcInDb(
    id: 'aditya-birla-sunlife-mf-equity-largecap-growth-direct',
    name: 'Aditya Birla Sunlife',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Largecap'},
  ),
  AmcInDb(
    id: 'aditya-birla-sunlife-mf-equity-largecap-growth-regular',
    name: 'Aditya Birla Sunlife',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Largecap'},
  ),
  AmcInDb(
    id: 'aditya-birla-sunlife-frontline-mf-equity-largecap-growth-direct',
    name: 'Aditya Birla Sunlife Frontline',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Largecap'},
  ),
  AmcInDb(
    id: 'aditya-birla-sunlife-frontline-mf-equity-largecap-growth-regular',
    name: 'Aditya Birla Sunlife Frontline',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Largecap'},
  ),
  AmcInDb(
    id: 'axis-mf-equity-midcap-growth-direct',
    name: 'Axis',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Midcap'},
  ),
  AmcInDb(
    id: 'axis-mf-equity-midcap-growth-regular',
    name: 'Axis',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Midcap'},
  ),
  AmcInDb(
    id: 'axis-mf-equity-smallcap-growth-direct',
    name: 'Axis',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Smallcap'},
  ),
  AmcInDb(
    id: 'axis-mf-equity-smallcap-growth-regular',
    name: 'Axis',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Smallcap'},
  ),
  AmcInDb(
    id: 'axis-growth-opportunities-mf-equity-large-midcap-growth-direct',
    name: 'Axis Growth Opportunities',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Large & Midcap'},
  ),
  AmcInDb(
    id: 'axis-growth-opportunities-mf-equity-large-midcap-growth-regular',
    name: 'Axis Growth Opportunities',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Large & Midcap'},
  ),
  AmcInDb(
    id: 'hsbc-lt-mf-equity-smallcap-growth-direct',
    name: 'HSBC (L&T)',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Smallcap'},
  ),
  AmcInDb(
    id: 'hsbc-lt-mf-equity-smallcap-growth-regular',
    name: 'HSBC (L&T)',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Smallcap'},
  ),
  AmcInDb(
    id: 'kotak-emerging-mf-equity-midcap-growth-direct',
    name: 'Kotak Emerging',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Midcap'},
  ),
  AmcInDb(
    id: 'kotak-emerging-mf-equity-midcap-growth-regular',
    name: 'Kotak Emerging',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Midcap'},
  ),
  AmcInDb(
    id: 'kotak-mf-equity-flexicap-growth-regular',
    name: 'Kotak',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Flexicap'},
  ),
  AmcInDb(
    id: 'lic-mf-equity-largecap-growth-regular',
    name: 'LIC',
    genreIndex: 0,
    tags: {'Growth', 'Regular', 'Equity', 'Largecap'},
  ),
  AmcInDb(
    id: 'lic-infrastructural-mf-equity-sectoral-growth-direct',
    name: 'LIC infrastructural',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Sectoral'},
  ),
  AmcInDb(
    id: 'motilal-oswal-mf-equity-midcap-growth-direct',
    name: 'Motilal Oswal',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Midcap'},
  ),
  AmcInDb(
    id: 'parag-parikh-mf-equity-flexicap-growth-direct',
    name: 'Parag Parikh',
    genreIndex: 0,
    tags: {'Growth', 'Direct', 'Equity', 'Flexicap'},
  ),

  // ~ Stocks
  AmcInDb(
    id: 'adani-power-ltd-stock-power-generation-and-distribution',
    name: 'Adani Power Ltd.',
    genreIndex: 1,
    tags: {'Power Generation and Distribution'},
  ),

  // ~ Insurance
  AmcInDb(id: 'lic-insurance-new-endowment-plan-814', name: 'LIC', genreIndex: 2, tags: {'New Endowment Plan (814)'}),

  // ~ Miscellaneous
  AmcInDb(
    id: 'post-office-misc-nsc-national-savings-certificate',
    name: 'Post Office',
    genreIndex: 3,
    tags: {'SC (National Savings Certificate)'},
  ),
];

// ==== MODELS ====
enum TransactionField { amount, quantity, account, amc, type, date, notes }

class TransactionInDb {
  const TransactionInDb({
    required this.id,
    required this.accountId,
    this.amcId,
    this.quantity = 0.0,
    this.totalAmount = 0.0,
    required this.date,
    this.note,
  });

  final String id;
  final String accountId;
  final String? amcId;
  final double quantity;
  final double totalAmount;
  final int date;
  final String? note;
}

class AccountInDb {
  const AccountInDb({required this.id, required this.name, required this.avatarIndex});

  final String id;
  final String name;
  final int avatarIndex;
}

class AmcInDb {
  const AmcInDb({required this.id, required this.name, this.genreIndex, this.tags});

  final String id;
  final String name;
  final int? genreIndex;
  final Set<String>? tags;
}
