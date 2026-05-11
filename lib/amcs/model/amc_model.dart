// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/amcs/model/latest_xirr_model.dart';
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
      mf => Color(0xFF00296B),
      stock => Color(0xFF386641),
      insurance => Color(0xFFFB5607),
      misc => Color(0xFF3A0CA3),
    };
  }
}

class AmcTag extends Equatable {
  const AmcTag(this.tag);

  final String tag;

  Map<String, dynamic> toMap() {
    return {'tag': tag};
  }

  factory AmcTag.fromMap(Map<String, dynamic> map) {
    assert(map['tag'] != null, 'Tag must not be null');
    return AmcTag(map['tag'] as String);
  }

  String toJson() => json.encode(toMap());

  factory AmcTag.fromJson(String source) {
    return AmcTag.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  Set<String> get tags => {tag};

  @override
  List<Object?> get props => [tag];
}

class StockAmcTag extends AmcTag {
  const StockAmcTag({required this.sector, this.industry}) : super(sector);

  final String sector;
  final String? industry;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'sector': sector, 'industry': industry};
  }

  factory StockAmcTag.fromMap(Map<String, dynamic> map) {
    assert(map['sector'] != null, 'Sector must not be null');
    return StockAmcTag(sector: map['sector'] as String, industry: map['industry'] as String?);
  }

  factory StockAmcTag.fromJson(String source) => StockAmcTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  Set<String> get tags => {sector, ?industry};

  @override
  List<Object?> get props => [sector, industry];
}

class MfAmcTag extends AmcTag {
  const MfAmcTag({required this.category, this.subCategory, this.plan, this.schemeType}) : super(category);

  final String category;
  final String? subCategory;
  final String? plan;
  final String? schemeType;

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category,
      'sub_category': subCategory,
      'plan': plan,
      'scheme_type': schemeType,
    };
  }

  factory MfAmcTag.fromMap(Map<String, dynamic> map) {
    assert(map['category'] != null, 'Category must not be null');

    return MfAmcTag(
      category: map['category'] as String,
      subCategory: map['sub_category'] as String?,
      plan: map['plan'] as String?,
      schemeType: map['scheme_type'] as String?,
    );
  }

  factory MfAmcTag.fromJson(String source) => MfAmcTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  Set<String> get tags => {category, ?subCategory, ?plan, ?schemeType};

  @override
  List<Object?> get props => [category, subCategory, plan, schemeType];
}

class InsuranceAmcTag extends AmcTag {
  const InsuranceAmcTag(this.plan) : super(plan);

  final String plan;

  @override
  Map<String, dynamic> toMap() {
    return {'plan': plan};
  }

  factory InsuranceAmcTag.fromMap(Map<String, dynamic> map) {
    assert(map['plan'] != null, 'Plan must not be null');
    return InsuranceAmcTag(map['plan'] as String);
  }

  factory InsuranceAmcTag.fromJson(String source) =>
      InsuranceAmcTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [plan];
}

abstract class InveslyAmc extends AmcInDb {
  InveslyAmc({
    required super.id,
    required super.name,
    required super.code,
    this.genre,
    AmcTag? amcTag,
    this.ltp,
    this.xirr,
  }) : _amcTag = amcTag,
       super(genreCode: genre?.name, tagString: amcTag?.toJson(), ltpString: ltp?.toJson(), xirrString: xirr?.toJson());

  // InveslyAmc.misc() = MiscAmcModel;

  /// Genre of the AMC i.e. mf, stock, insurance, misc etc.
  final AmcGenre? genre;

  /// tags is combination of sector, sub-sector, plan, scheme etc.,
  /// tags is saved in database as string separated by commas
  final AmcTag? _amcTag;
  // final Map<String, dynamic>? tag;

  /// Latest price of the AMC, if available.
  final LatestPrice? ltp;

  /// Latest calculated xirr
  final LatestXirr? xirr;

  factory InveslyAmc.fromDb(AmcInDb amc) {
    AmcGenre? amcGenre;
    if (amc.genreCode?.isNotEmpty ?? false) {
      amcGenre = AmcGenre.fromName(amc.genreCode!);
    }
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

  LatestPrice? fromLtpMap(Map<String, dynamic> response);

  Set<String>? get tags => _amcTag?.tags;
  // Set<String> get tags => tag != null ? tag!.values.whereType<String>().toSet() : {};

  InveslyAmc copyWith({LatestPrice? ltp, LatestXirr? xirr});
}

class MfAmcModel extends InveslyAmc {
  MfAmcModel({
    required super.id,
    required super.name,
    required super.code,
    // this.category,
    // this.subCategory,
    // this.plan,
    // this.schemeType,
    this.amcTag,
    super.ltp,
    super.xirr,
  }) : super(
         genre: AmcGenre.mf,
         //  amcTag: {'category': category, 'sub_category': subCategory, 'plan': plan, 'scheme_type': schemeType},
         amcTag: amcTag,
       );

  // final String? category;
  // final String? subCategory;
  // final String? plan;
  // final String? schemeType;
  final MfAmcTag? amcTag;

  factory MfAmcModel.fromDb(AmcInDb amc) {
    // Map<String, dynamic>? tag;
    // if (amc.tagString?.isNotEmpty ?? false) {
    //   tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    // }
    MfAmcTag? amcTag;
    if (amc.tagString?.isNotEmpty ?? false) {
      amcTag = MfAmcTag.fromJson(amc.tagString!);
    }

    LatestPrice? ltp;
    if (amc.ltpString?.isNotEmpty ?? false) {
      ltp = LatestPrice.fromJson(amc.ltpString!);
    }

    LatestXirr? xirr;
    if (amc.xirrString?.isNotEmpty ?? false) {
      xirr = LatestXirr.fromJson(amc.xirrString!);
    }

    return MfAmcModel(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      // category: tag?['category'] as String?,
      // subCategory: tag?['sub_category'] as String?,
      // plan: tag?['plan'] as String?,
      // schemeType: tag?['scheme_type'] as String?,
      amcTag: amcTag,
      ltp: ltp,
      xirr: xirr,
    );
  }

  @override
  String? get latestPriceUri => 'https://api.mfapi.in/mf/$code/latest';

  @override
  LatestPrice? fromLtpMap(Map<String, dynamic> response) {
    final today = DateTime.now().startOfDay;
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
    final date = DateFormat('dd-MM-yyyy').tryParse(latestEntry['date'].toString()) ?? today;
    final nav = double.tryParse(latestEntry['nav'].toString());
    return nav != null ? LatestPrice(date: date, price: nav, fetchDate: today) : null;
  }

  @override
  MfAmcModel copyWith({LatestPrice? ltp, LatestXirr? xirr}) {
    return MfAmcModel(id: id, name: name, code: code, amcTag: amcTag, ltp: ltp ?? this.ltp, xirr: xirr ?? this.xirr);
  }
}

class StockAmcModel extends InveslyAmc {
  StockAmcModel({
    required super.id,
    required super.name,
    required super.code,
    // this.sector,
    // this.industry,
    this.amcTag,
    super.ltp,
    super.xirr,
  }) : super(
         genre: AmcGenre.stock,
         // amcTag: {'sector': sector, 'industry': industry},
         amcTag: amcTag,
       );

  // final String? sector;
  // final String? industry;
  final StockAmcTag? amcTag;

  factory StockAmcModel.fromDb(AmcInDb amc) {
    // Map<String, dynamic>? tag;
    // if (amc.tagString?.isNotEmpty ?? false) {
    //   tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    // }
    StockAmcTag? amcTag;
    if (amc.tagString?.isNotEmpty ?? false) {
      // tag = json.decode(amc.tagString!) as Map<String, dynamic>;
      amcTag = StockAmcTag.fromJson(amc.tagString!);
    }
    LatestPrice? ltp;
    if (amc.ltpString?.isNotEmpty ?? false) {
      ltp = LatestPrice.fromJson(amc.ltpString!);
    }

    LatestXirr? xirr;
    if (amc.xirrString?.isNotEmpty ?? false) {
      xirr = LatestXirr.fromJson(amc.xirrString!);
    }

    return StockAmcModel(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      // sector: tag?['sector'] as String?,
      // industry: tag?['industry'] as String?,
      amcTag: amcTag,
      ltp: ltp,
      xirr: xirr,
    );
  }

  @override
  String? get latestPriceUri => 'https://www.nseindia.com/api/quote-equity?symbol=$code';

  @override
  LatestPrice? fromLtpMap(Map<String, dynamic> response) {
    final today = DateTime.now().startOfDay;
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
    return price != null
        ? LatestPrice(
            date: today, // TODO: get actual date from response if available
            price: price,
            fetchDate: today,
          )
        : null;
  }

  @override
  StockAmcModel copyWith({LatestPrice? ltp, LatestXirr? xirr}) {
    return StockAmcModel(
      id: id,
      name: name,
      code: code,
      // sector: tag != null ? tag['sector'] as String? : sector,
      // industry: tag != null ? tag['industry'] as String? : industry,
      amcTag: amcTag,
      ltp: ltp ?? this.ltp,
      xirr: xirr ?? this.xirr,
    );
  }
}

class InsuranceAmcModel extends InveslyAmc {
  InsuranceAmcModel({
    required super.id,
    required super.name,
    required super.code,
    // this.plan,
    this.amcTag,
    super.ltp,
    super.xirr,
  }) : super(
         genre: AmcGenre.insurance,
         //amcTag: {'plan': plan}
         amcTag: amcTag,
       );

  // final String? plan;
  final InsuranceAmcTag? amcTag;

  factory InsuranceAmcModel.fromDb(AmcInDb amc) {
    // Map<String, dynamic>? tag;
    // if (amc.tagString?.isNotEmpty ?? false) {
    //   tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    // }

    InsuranceAmcTag? amcTag;
    if (amc.tagString?.isNotEmpty ?? false) {
      amcTag = InsuranceAmcTag.fromJson(amc.tagString!);
    }

    LatestPrice? ltp;
    if (amc.ltpString?.isNotEmpty ?? false) {
      ltp = LatestPrice.fromJson(amc.ltpString!);
    }

    LatestXirr? xirr;
    if (amc.xirrString?.isNotEmpty ?? false) {
      xirr = LatestXirr.fromJson(amc.xirrString!);
    }

    return InsuranceAmcModel(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      // plan: tag?['plan'] as String?,
      amcTag: amcTag,
      ltp: ltp,
      xirr: xirr,
    );
  }

  @override
  String? get latestPriceUri => null; // Insurance AMC doesn't have a latest price API

  @override
  LatestPrice? fromLtpMap(Map<String, dynamic> response) => null; // Insurance AMC doesn't have a latest price API, so return null price

  @override
  InsuranceAmcModel copyWith({LatestPrice? ltp, LatestXirr? xirr}) {
    return InsuranceAmcModel(
      id: id,
      name: name,
      code: code,
      // plan: tag != null ? tag['plan'] as String? : plan,
      amcTag: amcTag,
      ltp: ltp ?? this.ltp,
      xirr: xirr ?? this.xirr,
    );
  }
}

class MiscAmcModel extends InveslyAmc {
  MiscAmcModel({required super.id, required super.name, required super.code, this.amcTag, super.ltp, super.xirr})
    : super(genre: AmcGenre.misc, amcTag: amcTag);

  MiscAmcModel.empty({String? id, String? name, String? code, this.amcTag, super.ltp, super.xirr})
    : super(id: id ?? 'na', name: name ?? 'Not available', code: code ?? 'na', genre: AmcGenre.misc, amcTag: amcTag);

  final AmcTag? amcTag;

  factory MiscAmcModel.fromDb(AmcInDb amc) {
    // Map<String, dynamic>? tag;
    // if (amc.tagString?.isNotEmpty ?? false) {
    //   tag = json.decode(amc.tagString!) as Map<String, dynamic>;
    // }
    AmcTag? amcTag;
    if (amc.tagString?.isNotEmpty ?? false) {
      amcTag = AmcTag.fromJson(amc.tagString!);
    }

    LatestPrice? ltp;
    if (amc.ltpString?.isNotEmpty ?? false) {
      ltp = LatestPrice.fromJson(amc.ltpString!);
    }

    LatestXirr? xirr;
    if (amc.xirrString?.isNotEmpty ?? false) {
      xirr = LatestXirr.fromJson(amc.xirrString!);
    }

    return MiscAmcModel(id: amc.id, name: amc.name, code: amc.code, amcTag: amcTag, ltp: ltp, xirr: xirr);
  }

  @override
  String? get latestPriceUri => null; // Misc AMC doesn't have a latest price API

  @override
  LatestPrice? fromLtpMap(Map<String, dynamic> response) => null; // Misc AMC doesn't have a latest price API, so return null

  @override
  MiscAmcModel copyWith({LatestPrice? ltp, LatestXirr? xirr}) {
    return MiscAmcModel(id: id, name: name, code: code, amcTag: amcTag, ltp: ltp ?? this.ltp, xirr: xirr ?? this.xirr);
  }
}

class AmcInDb extends InveslyDataModel {
  const AmcInDb({
    required super.id,
    required this.name,
    required this.code,
    this.genreCode,
    this.tagString,
    this.ltpString,
    this.xirrString,
  });

  final String name;
  final String code;
  final String? genreCode;
  final String? tagString;
  final String? ltpString;
  final String? xirrString;

  @override
  List<Object?> get props => super.props..addAll([name, code, genreCode, tagString, ltpString, xirrString]);
}

class AmcTable extends TableSchema<AmcInDb> {
  // Singleton pattern to ensure only one instance exists
  const AmcTable._() : super('amcs');
  static const instance = AmcTable._();
  factory AmcTable() => instance;

  TableColumn<String> get nameColumn => TableColumn('name', tableName, isUnique: true);
  TableColumn<String> get codeColumn => TableColumn('scheme_code', tableName, isUnique: true);
  TableColumn<String> get genreColumn => TableColumn('genre', tableName, isNullable: true);
  TableColumn<String> get tagColumn => TableColumn('tag', tableName, isNullable: true);
  TableColumn<String> get ltpColumn => TableColumn('ltp', tableName, isNullable: true);
  TableColumn<String> get xirrColumn => TableColumn('xirr', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns {
    return super.columns..addAll([nameColumn, codeColumn, genreColumn, tagColumn, ltpColumn, xirrColumn]);
  }

  @override
  Map<String, dynamic> fromModel(AmcInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      codeColumn.title: data.code,
      genreColumn.title: data.genreCode,
      tagColumn.title: data.tagString,
      ltpColumn.title: data.ltpString,
      xirrColumn.title: data.xirrString,
    };
  }

  @override
  AmcInDb fromMap(Map<String, dynamic> map) {
    return AmcInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      code: map[codeColumn.title] as String,
      genreCode: map[genreColumn.title] as String?,
      tagString: map[tagColumn.title] as String?,
      ltpString: map[ltpColumn.title] as String?,
      xirrString: map[xirrColumn.title] as String?,
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
