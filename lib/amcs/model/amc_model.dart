// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

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

class StockTag extends AmcTag {
  const StockTag(this.sector) : super(sector);

  final String sector;

  @override
  Map<String, dynamic> toMap() {
    return {'sector': sector};
  }

  factory StockTag.fromMap(Map<String, dynamic> map) {
    assert(map['sector'] != null, 'Sector must not be null');
    return StockTag(map['sector'] as String);
  }

  factory StockTag.fromJson(String source) => StockTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  Set<String> get tags => {sector};

  @override
  List<Object?> get props => [sector];
}

class MfTag extends AmcTag {
  const MfTag(this.category, {this.subCategory, this.plan, this.schemeType}) : super(category);

  // final MfCategory category;
  // final MfSubCategory? subCategory;
  // final MfPlan? plan;
  // final MfSchemeType? schemeType;
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

  factory MfTag.fromMap(Map<String, dynamic> map) {
    assert(map['category'] != null, 'Category must not be null');
    // final category = MfCategory.fromTitle(map['category'] as String);
    // assert(category != null, 'Invalid category value');

    return MfTag(
      map['category'] as String,
      // subCategory: map['sub_category'] != null ? MfSubCategory.fromTitle(map['sub_category'] as String) : null,
      subCategory: map['sub_category'] as String?,
      // plan: map['plan'] != null ? MfPlan.fromTitle(map['plan'] as String) : null,
      plan: map['plan'] as String?,
      // schemeType: map['scheme_type'] != null ? MfSchemeType.fromTitle(map['scheme_type'] as String) : null,
      schemeType: map['scheme_type'] as String?,
    );
  }

  factory MfTag.fromJson(String source) => MfTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  Set<String> get tags => {
    category,
    if (subCategory != null) subCategory!,
    if (plan != null) plan!,
    if (schemeType != null) schemeType!,
  };

  @override
  List<Object?> get props => [category, subCategory, plan, schemeType];
}

class InsuranceTag extends AmcTag {
  const InsuranceTag(this.plan) : super(plan);

  final String plan;

  @override
  Map<String, dynamic> toMap() {
    return {'plan': plan};
  }

  factory InsuranceTag.fromMap(Map<String, dynamic> map) {
    assert(map['plan'] != null, 'Plan must not be null');
    return InsuranceTag(map['plan'] as String);
  }

  factory InsuranceTag.fromJson(String source) => InsuranceTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [plan];
}

class InveslyAmc extends AmcInDb {
  InveslyAmc({
    required super.id,
    required super.name,
    required super.code,
    required super.isin,
    this.genre,
    // required this.tags,
    this.tag,
  }) : super(genreCode: genre?.name, tagString: tag?.toJson());

  // InveslyAmc.stock({required super.name, required super.code, required super.isin, String? sector})
  //   : genre = AmcGenre.stock,
  //     tags = {sector},
  //     super(id: 'stock-${$uuid.v1()}');

  // InveslyAmc.insurance({required super.name, required super.code, required super.isin, String? plan})
  //   : genre = AmcGenre.insurance,
  //     tags = {plan},
  //     super(id: 'insurance-${$uuid.v1()}');

  // InveslyAmc.misc({required super.name, required super.code, required super.isin, String? tag})
  //   : genre = AmcGenre.misc,
  //     tags = {tag},
  //     super(id: 'misc-${$uuid.v1()}');

  /// Genre of the AMC i.e. mf, stock, insurance, misc etc.
  final AmcGenre? genre;

  /// tags is combination of sector, sub-sector, plan, scheme etc.,
  /// tags is saved in database as string separated by commas
  final AmcTag? tag;

  factory InveslyAmc.fromDb(AmcInDb amc) {
    // final tags = amc.tagsString?.split(';').map((tag) => tag.trim()).toList();
    AmcGenre? amcGenre;
    if (amc.genreCode?.isNotEmpty ?? false) {
      amcGenre = AmcGenre.fromName(amc.genreCode!);
    }
    final tagString = amc.tagString;
    AmcTag? tag;
    if (amcGenre != null && (tagString?.isNotEmpty ?? false)) {
      tag = switch (amcGenre) {
        AmcGenre.mf => MfTag.fromJson(tagString!),
        AmcGenre.stock => AmcTag.fromJson(tagString!),
        AmcGenre.insurance => AmcTag.fromJson(tagString!),
        _ => AmcTag.fromJson(tagString!),
      };
    }

    return InveslyAmc(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      isin: amc.isin,
      genre: amcGenre,
      // tags: tags,
      tag: tag,
    );
  }
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
  TableColumn<String> get codeColumn => TableColumn('code', tableName, isUnique: true);
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

// ~ Mutual Fund specific enums
// enum MfPlan {
//   growth('Growth'),
//   dividend('Dividend');

//   const MfPlan(this.title);

//   final String title;

//   static MfPlan? fromTitle(String plan) {
//     return MfPlan.values.firstWhereOrNull((e) => e.title == plan);
//   }
// }

// enum MfSchemeType {
//   direct('Direct'),
//   regular('Regular');

//   const MfSchemeType(this.title);

//   final String title;

//   static MfSchemeType? fromTitle(String type) {
//     return MfSchemeType.values.firstWhereOrNull((e) => e.title == type);
//   }
// }

// enum MfCategory {
//   equity('Equity'),
//   debt('Debt'),
//   hybrid('Hybrid'),
//   other('Other');

//   const MfCategory(this.title);

//   final String title;

//   static MfCategory? fromTitle(String category) {
//     return MfCategory.values.firstWhereOrNull((e) => e.title == category);
//   }
// }

// enum MfSubCategory {
//   large('Large cap'),
//   mid('Mid cap'),
//   largeMid('Large & Mid cap'),
//   small('Small cap'),
//   multiCap('Multi cap'),
//   focused('Focused'),
//   flexi('Flexi cap'),
//   sectoral('Sectoral/Thematic'),
//   eIndex('Index'),
//   hybrid('Balanced/Hybrid'),
//   etf('ETF'),
//   taxSaving('Tax Saving (ELSS)'),
//   other('Other');

//   const MfSubCategory(this.title);

//   final String title;

//   static MfSubCategory? fromTitle(String? subCategory) {
//     return MfSubCategory.values.firstWhereOrNull((e) => e.title == subCategory);
//   }
// }
