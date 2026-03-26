// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

abstract class AmcGenre extends Equatable {
  const AmcGenre({required this.code, required this.title, required this.icon, required this.color});

  final String code;
  final String title;
  final IconData icon;
  final Color color;

  /// tags is a map of key-value pairs that contain all the relevant information about the AMC based on its genre
  Map<String, String?> get tags;

  /// tagString is the JSON string representation of the tags map, which can be stored in the database
  String get tagString => json.encode(tags);

  static AmcGenre? fromCode(String code) {
    return AmcGenre.values.firstWhereOrNull((e) => e.code == code);
  }

  factory AmcGenre.fromMap(Map<String, dynamic> map) {
    assert(map['code'] != null, 'Genre code must not be null');
    final code = map['code'] as String;
    final genre = AmcGenre.fromCode(code);
    if (genre == null) {
      throw ArgumentError('Invalid genre code: $code');
    }
    return genre;
  }

  // static AmcGenre fromTitle(String title) {
  //   return AmcGenre.values.firstWhere((e) => e.title == title, orElse: () => AmcGenre.misc);
  // }

  // static AmcGenre fromIndex(int index) {
  //   if (index < 0 || index > AmcGenre.values.length - 1) {
  //     return AmcGenre.values.last; // set default genre to misc
  //   }

  //   return AmcGenre.values[index];
  // }

  @override
  List<Object?> get props => [title, icon, color];
}

class StockTag extends AmcGenre {
  const StockTag({this.sector, this.industry})
    : super(code: 'stock', title: 'Stock', icon: Icons.show_chart_rounded, color: Colors.teal);

  final String? sector;
  final String? industry;

  factory StockTag.fromMap(Map<String, dynamic> map) {
    return StockTag(
      sector: map['sector'] != null ? map['sector'] as String : null,
      industry: map['industry'] != null ? map['industry'] as String : null,
    );
  }

  factory StockTag.fromJson(String source) => StockTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  Map<String, String?> get tags => {'sector': sector, 'industry': industry};

  @override
  List<Object?> get props => super.props..addAll([sector, industry]);
}

class MfTag extends AmcGenre {
  const MfTag({this.category, this.subCategory, this.plan, this.schemeType})
    : super(code: 'mf', title: 'Mutual Fund', icon: Icons.pie_chart_rounded, color: Colors.blue);

  final String? category;
  final String? subCategory;
  final String? plan;
  final String? schemeType;

  @override
  Map<String, String?> get tags {
    return <String, String?>{
      'category': category,
      'sub_category': subCategory,
      'plan': plan,
      'scheme_type': schemeType,
    };
  }

  factory MfTag.fromMap(Map<String, dynamic> map) {
    return MfTag(
      category: map['category'] != null ? map['category'] as String : null,
      subCategory: map['sub_category'] != null ? map['sub_category'] as String : null,
      plan: map['plan'] != null ? map['plan'] as String : null,
      schemeType: map['scheme_type'] != null ? map['scheme_type'] as String : null,
    );
  }

  factory MfTag.fromJson(String source) => MfTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => super.props..addAll([category, subCategory, plan, schemeType]);
}

class InsuranceTag extends AmcGenre {
  const InsuranceTag({this.plan})
    : super(code: 'insurance', title: 'Insurance', icon: Icons.security_rounded, color: Colors.orange);

  final String? plan;

  @override
  Map<String, String?> get tags => {'plan': plan};

  factory InsuranceTag.fromMap(Map<String, dynamic> map) {
    return InsuranceTag(plan: map['plan'] != null ? map['plan'] as String : null);
  }

  factory InsuranceTag.fromJson(String source) => InsuranceTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => super.props..add(plan);
}

class MiscellaneousTag extends AmcGenre {
  const MiscellaneousTag({this.tag})
    : super(code: 'misc', title: 'Miscellaneous', icon: Icons.category_rounded, color: Colors.grey);

  final String? tag;

  @override
  Map<String, String?> get tags => {'tag': tag};

  factory MiscellaneousTag.fromMap(Map<String, dynamic> map) {
    return MiscellaneousTag(tag: map['tag'] != null ? map['tag'] as String : null);
  }

  factory MiscellaneousTag.fromJson(String source) =>
      MiscellaneousTag.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => super.props..add(tag);
}

class InveslyAmc extends AmcInDb {
  InveslyAmc({
    required super.id,
    required super.name,
    required super.code,
    required super.isin,
    required this.genre,
    // required this.tags,
    // this.tag,
  }) : super(genreCode: genre.code, tagString: genre.tagString);

  /// Genre of the AMC i.e. mf, stock, insurance, misc etc.
  final AmcGenre genre;

  /// tags is combination of sector, sub-sector, plan, scheme etc.,
  /// tags is saved in database as string separated by commas
  // final AmcTag? tag;

  factory InveslyAmc.fromDb(AmcInDb amc) {
    // final tags = amc.tagsString?.split(';').map((tag) => tag.trim()).toList();
    late final AmcGenre amcGenre;
    if (amc.genreCode?.isNotEmpty ?? false) {
      amcGenre = switch (amc.genreCode) {
        'mf' => amc.tagString != null ? MfTag.fromJson(amc.tagString!) : MfTag(),
        'stock' => amc.tagString != null ? StockTag.fromJson(amc.tagString!) : StockTag(),
        'insurance' => amc.tagString != null ? InsuranceTag.fromJson(amc.tagString!) : InsuranceTag(),
        _ => amc.tagString != null ? MiscellaneousTag.fromJson(amc.tagString!) : MiscellaneousTag(),
      };
      // amcGenre = AmcGenre.fromCode(amc.genreCode!);
    }
    final tagString = amc.tagString;
    // AmcTag? tag;
    // if (amcGenre != null && (tagString?.isNotEmpty ?? false)) {
    //   tag = switch (amcGenre) {
    //     AmcGenre.mf => MfTag.fromJson(tagString!),
    //     AmcGenre.stock => StockTag.fromJson(tagString!),
    //     AmcGenre.insurance => InsuranceTag.fromJson(tagString!),
    //     _ => AmcTag.fromJson(tagString!),
    //   };
    // }

    return InveslyAmc(
      id: amc.id,
      name: amc.name,
      code: amc.code,
      isin: amc.isin,
      genre: amcGenre,
      // tags: tags,
      // tag: tag,
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

  /// scheme code for mutual funds, stock code for stocks, plan name for insurance etc.
  final String code;

  /// ISIN is unique for all types of AMCs, so it can be used to identify an AMC across genres
  final String isin;

  /// genre code is the name of the genre enum value, e.g. 'mf', 'stock', 'insurance', 'misc' etc.
  final String? genreCode;

  /// tag string is the JSON string representation of the tag object, which contains all the
  /// relevant information about the AMC based on its genre
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
