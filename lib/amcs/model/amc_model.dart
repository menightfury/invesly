// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

enum AmcGenre {
  mf('Mutual fund'),
  stock('Stock'),
  insurance('Insurance'),
  misc('Miscellaneous');

  const AmcGenre(this.title);

  final String title;

  static AmcGenre? fromName(String name) {
    return AmcGenre.values.firstWhereOrNull((e) => e.name == name);
  }

  static AmcGenre fromTitle(String title) {
    return AmcGenre.values.firstWhere((e) => e.title == title, orElse: () => AmcGenre.misc);
  }

  static AmcGenre fromIndex(int index) {
    if (index < 0 || index > AmcGenre.values.length - 1) {
      return AmcGenre.values.last; // set default genre to misc
    }

    return AmcGenre.values[index];
  }

  IconData get icon {
    return switch (this) {
      mf => Icons.pie_chart_rounded,
      stock => Icons.show_chart_rounded,
      insurance => Icons.security_rounded,
      misc => Icons.category_rounded,
    };
  }

  Color get color {
    return switch (this) {
      mf => Colors.blue,
      stock => Colors.green,
      insurance => Colors.orange,
      misc => Colors.grey,
    };
  }
}

// class AmcTag extends Equatable {
//   const AmcTag(this.tag);

//   final String tag;

//   Map<String, dynamic> toMap() {
//     return {'tag': tag};
//   }

//   factory AmcTag.fromMap(Map<String, dynamic> map) {
//     assert(map['tag'] != null, 'Tag must not be null');
//     return AmcTag(map['tag'] as String);
//   }

//   String toJson() => json.encode(toMap());

//   factory AmcTag.fromJson(String source) {
//     return AmcTag.fromMap(json.decode(source) as Map<String, dynamic>);
//   }

//   Set<String> get tags => {tag};

//   @override
//   List<Object?> get props => [tag];
// }

// class StockTag extends AmcTag {
//   const StockTag({required this.sector, this.industry}) : super(sector);

//   final String sector;
//   final String? industry;

//   @override
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{'sector': sector, 'industry': industry};
//   }

//   factory StockTag.fromMap(Map<String, dynamic> map) {
//     assert(map['sector'] != null, 'Sector must not be null');
//     return StockTag(sector: map['sector'] as String, industry: map['industry'] as String?);
//   }

//   factory StockTag.fromJson(String source) => StockTag.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   Set<String> get tags => {sector, ?industry};

//   @override
//   List<Object?> get props => [sector, industry];
// }

// class _MfTag extends AmcTag {
//   const _MfTag({required this.category, this.subCategory, this.plan, this.schemeType}) : super(category);

//   final String category;
//   final String? subCategory;
//   final String? plan;
//   final String? schemeType;

//   @override
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'category': category,
//       'sub_category': subCategory,
//       'plan': plan,
//       'scheme_type': schemeType,
//     };
//   }

//   factory _MfTag.fromMap(Map<String, dynamic> map) {
//     assert(map['category'] != null, 'Category must not be null');
//     // final category = MfCategory.fromTitle(map['category'] as String);
//     // assert(category != null, 'Invalid category value');

//     return _MfTag(
//       category: map['category'] as String,
//       // subCategory: map['sub_category'] != null ? MfSubCategory.fromTitle(map['sub_category'] as String) : null,
//       subCategory: map['sub_category'] as String?,
//       // plan: map['plan'] != null ? MfPlan.fromTitle(map['plan'] as String) : null,
//       plan: map['plan'] as String?,
//       // schemeType: map['scheme_type'] != null ? MfSchemeType.fromTitle(map['scheme_type'] as String) : null,
//       schemeType: map['scheme_type'] as String?,
//     );
//   }

//   factory _MfTag.fromJson(String source) => _MfTag.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   Set<String> get tags => {category, ?subCategory, ?plan, ?schemeType};

//   @override
//   List<Object?> get props => [category, subCategory, plan, schemeType];
// }

// class InsuranceTag extends AmcTag {
//   const InsuranceTag(this.plan) : super(plan);

//   final String plan;

//   @override
//   Map<String, dynamic> toMap() {
//     return {'plan': plan};
//   }

//   factory InsuranceTag.fromMap(Map<String, dynamic> map) {
//     assert(map['plan'] != null, 'Plan must not be null');
//     return InsuranceTag(map['plan'] as String);
//   }

//   factory InsuranceTag.fromJson(String source) => InsuranceTag.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   List<Object?> get props => [plan];
// }

abstract class InveslyAmc extends AmcInDb {
  InveslyAmc({required super.id, required super.name, required super.code, required super.isin, this.genre, this.tag})
    : super(genreCode: genre?.name, tagString: tag != null ? json.encode(tag) : null);

  /// Genre of the AMC i.e. mf, stock, insurance, misc etc.
  final AmcGenre? genre;

  /// tags is combination of sector, sub-sector, plan, scheme etc.,
  /// tags is saved in database as string separated by commas
  // final AmcTag? tag;
  final Map<String, dynamic>? tag;

  factory InveslyAmc.fromDb(AmcInDb amc) {
    AmcGenre? amcGenre;
    if (amc.genreCode?.isNotEmpty ?? false) {
      amcGenre = AmcGenre.fromName(amc.genreCode!);
    }

    // final tagString = amc.tagString;
    // AmcTag? tag;
    // if (amcGenre != null && (tagString?.isNotEmpty ?? false)) {
    //   tag = switch (amcGenre) {
    //     AmcGenre.mf => MfTag.fromJson(tagString!),
    //     AmcGenre.stock => StockTag.fromJson(tagString!),
    //     AmcGenre.insurance => InsuranceTag.fromJson(tagString!),
    //     _ => AmcTag.fromJson(tagString!),
    //   };
    // }

    // return InveslyAmc(
    //   id: amc.id,
    //   name: amc.name,
    //   code: amc.code,
    //   isin: amc.isin,
    //   genre: amcGenre,
    //   tag: tag,
    // );
    if (amcGenre == null) {
      return MiscAmcModel.fromDb(amc);
    }

    return switch (amcGenre) {
      AmcGenre.mf => MfAmcModel.fromDb(amc),
      AmcGenre.stock => StockAmcModel.fromDb(amc),
      AmcGenre.insurance => InsuranceAmcModel.fromDb(amc),
      _ => MiscAmcModel.fromDb(amc),
    };
  }

  String? get latestPriceUri;

  LatestPrice? toLatestPrice(Map<String, dynamic> response);

  Set<String> get tags => tag != null ? tag!.values.whereType<String>().toSet() : {};
}

class MfAmcModel extends InveslyAmc {
  MfAmcModel({
    required super.id,
    required super.name,
    required super.code,
    required super.isin,
    this.category,
    this.subCategory,
    this.plan,
    this.schemeType,
  }) : super(
         genre: AmcGenre.mf,
         tag: {'category': category, 'sub_category': subCategory, 'plan': plan, 'scheme_type': schemeType},
       );

  final String? category;
  final String? subCategory;
  final String? plan;
  final String? schemeType;

  factory MfAmcModel.fromDb(AmcInDb amc) {
    Map<String, dynamic>? tag;
    if (amc.tagString?.isNotEmpty ?? false) {
      tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    }

    return MfAmcModel(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      isin: amc.isin,
      category: tag?['category'] as String?,
      subCategory: tag?['sub_category'] as String?,
      plan: tag?['plan'] as String?,
      schemeType: tag?['scheme_type'] as String?,
    );
  }

  @override
  String? get latestPriceUri => 'https://api.mfapi.in/mf/$code/latest';

  @override
  LatestPrice? toLatestPrice(Map<String, dynamic> response) {
    final now = DateTime.now();
    // {
    //   "meta": {
    //     "fund_house": "Motilal Oswal Mutual Fund",
    //     "scheme_type": "Open Ended Schemes",
    //     ...
    //   },
    //   "data": [
    //     {
    //       "date": "16-01-2026",
    //       "nav": "112.07910"
    //     }
    //   ],
    //   "status": "SUCCESS"
    // }
    final data = (response['data'] as List<Object?>?)?.cast<Map<String, dynamic>>();
    if (data == null || data.isEmpty) {
      return null;
    }

    final latestEntry = data.first;
    final dateParts = latestEntry['date'].toString().split('-');
    final date = DateTime(
      int.tryParse(dateParts.length > 2 ? dateParts[2] : '') ?? now.year,
      int.tryParse(dateParts.length > 1 ? dateParts[1] : '') ?? now.month,
      int.tryParse(dateParts.isNotEmpty ? dateParts[0] : '') ?? now.day,
    );
    final nav = double.tryParse(latestEntry['nav'].toString());
    return nav != null ? LatestPrice(date: date, price: nav) : null;
  }
}

class StockAmcModel extends InveslyAmc {
  StockAmcModel({
    required super.id,
    required super.name,
    required super.code,
    required super.isin,
    this.sector,
    this.industry,
  }) : super(genre: AmcGenre.stock, tag: {'sector': sector, 'industry': industry});

  final String? sector;
  final String? industry;

  factory StockAmcModel.fromDb(AmcInDb amc) {
    Map<String, dynamic>? tag;
    if (amc.tagString?.isNotEmpty ?? false) {
      tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    }

    return StockAmcModel(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      isin: amc.isin,
      sector: tag?['sector'] as String?,
      industry: tag?['industry'] as String?,
    );
  }

  @override
  String? get latestPriceUri => 'https://www.nseindia.com/api/quote-equity?symbol=$code';

  @override
  LatestPrice? toLatestPrice(Map<String, dynamic> response) {
    final now = DateTime.now(); // TODO: get actual date from response if available
    // {
    // ...
    //   "priceInfo": {
    //       "lastPrice": 1168.4,
    //       "change": -36.799999999999955,
    //       "pChange": -3.053435114503813,
    //       "previousClose": 1205.2,
    //       "open": 1185.1,
    //       "close": 1161.3,
    //       "basePrice": 1205.2,
    //       ...
    //   },
    // ...
    // }
    final priceInfo = response['priceInfo'] as Map<String, dynamic>?;
    final price = priceInfo != null ? double.tryParse(priceInfo['lastPrice']?.toString() ?? '') : null;
    return price != null ? LatestPrice(date: now, price: price) : null;
  }
}

class InsuranceAmcModel extends InveslyAmc {
  InsuranceAmcModel({required super.id, required super.name, required super.code, required super.isin, this.plan})
    : super(genre: AmcGenre.insurance, tag: {'plan': plan});

  final String? plan;

  factory InsuranceAmcModel.fromDb(AmcInDb amc) {
    Map<String, dynamic>? tag;
    if (amc.tagString?.isNotEmpty ?? false) {
      tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    }

    return InsuranceAmcModel(id: amc.id, name: amc.name, code: amc.code, isin: amc.isin, plan: tag?['plan'] as String?);
  }

  @override
  String? get latestPriceUri => null; // Insurance AMC doesn't have a latest price API

  @override
  LatestPrice? toLatestPrice(Map<String, dynamic> response) => null; // Insurance AMC doesn't have a latest price API, so return null price
}

class MiscAmcModel extends InveslyAmc {
  MiscAmcModel({required super.id, required super.name, required super.code, required super.isin, super.tag})
    : super(genre: AmcGenre.misc);

  factory MiscAmcModel.fromDb(AmcInDb amc) {
    Map<String, dynamic>? tag;
    if (amc.tagString?.isNotEmpty ?? false) {
      tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    }

    return MiscAmcModel(id: amc.id, name: amc.name, code: amc.code, isin: amc.isin, tag: tag);
  }

  @override
  String? get latestPriceUri => null; // Misc AMC doesn't have a latest price API

  @override
  LatestPrice? toLatestPrice(Map<String, dynamic> response) => null; // Misc AMC doesn't have a latest price API, so return null
}

class AmcInDb extends InveslyDataModel {
  const AmcInDb({
    required super.id,
    required this.name,
    required this.code,
    required this.isin,
    this.genreCode,
    this.tagString,
  });

  final String name;
  final String code;
  final String isin;
  final String? genreCode;
  final String? tagString;

  @override
  List<Object?> get props => super.props..addAll([name, code, isin, genreCode, tagString]);
}

class AmcTable extends TableSchema<AmcInDb> {
  // Singleton pattern to ensure only one instance exists
  const AmcTable._() : super('amcs');
  static const instance = AmcTable._();
  factory AmcTable() => instance;

  TableColumn<String> get nameColumn => TableColumn('name', tableName, isUnique: true);
  TableColumn<String> get codeColumn => TableColumn('scheme_code', tableName, isUnique: true);
  TableColumn<String> get isinColumn => TableColumn('isin', tableName, isUnique: true);
  TableColumn<String> get genreColumn => TableColumn('genre', tableName, isNullable: true);
  TableColumn<String> get tagColumn => TableColumn('tag', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => super.columns..addAll([nameColumn, codeColumn, isinColumn, genreColumn, tagColumn]);

  @override
  Map<String, dynamic> fromModel(AmcInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      codeColumn.title: data.code,
      isinColumn.title: data.isin,
      genreColumn.title: data.genreCode,
      tagColumn.title: data.tagString,
    };
  }

  @override
  AmcInDb fromMap(Map<String, dynamic> map) {
    return AmcInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      code: map[codeColumn.title] as String,
      isin: map[isinColumn.title] as String,
      genreCode: map[genreColumn.title] as String?,
      tagString: map[tagColumn.title] as String?,
    );
  }
}

extension StringEscaped on String {
  String get escaped {
    return replaceAll(
          RegExp(r'[\s&().,\/]+', caseSensitive: false),
          '-',
        ) // replaces spaces, commas, dots, ampersands, parentheses and slashes with hyphens
        .replaceAll(RegExp(r'^-+|-+$', caseSensitive: false), '') // removes all leading and trailing hyphens
        .toLowerCase();
  }
}
