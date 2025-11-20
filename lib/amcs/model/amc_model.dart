import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

enum AmcGenre {
  mf('Mutual fund'),
  stock('Stock'),
  insurance('Insurance'),
  misc('Miscellaneous');

  const AmcGenre(this.title);

  final String title;

  static AmcGenre fromTitle(String name) {
    return AmcGenre.values.firstWhere((e) => e.name == name, orElse: () => AmcGenre.misc);
  }

  static AmcGenre fromIndex(int? index) {
    if (index == null || index < 0 || index > AmcGenre.values.length - 1) {
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

// ~ Mutual Fund specific enums
enum MfPlan {
  growth('Growth'),
  dividend('Dividend');

  const MfPlan(this.title);

  final String title;

  static MfPlan fromTitle(String? name) {
    return MfPlan.values.firstWhere((e) => e.name == name, orElse: () => MfPlan.growth);
  }
}

enum MfSchemeType {
  direct('Direct'),
  regular('Regular');

  const MfSchemeType(this.title);

  final String title;

  static MfSchemeType fromTitle(String? name) {
    return MfSchemeType.values.firstWhere((e) => e.name == name, orElse: () => MfSchemeType.regular);
  }
}

enum MfCategory {
  equity('Equity'),
  debt('Debt'),
  hybrid('Hybrid'),
  other('Other');

  const MfCategory(this.title);

  final String title;

  static MfCategory fromTitle(String? name) {
    return MfCategory.values.firstWhere((e) => e.name == name, orElse: () => MfCategory.other);
  }
}

enum MfSubCategory {
  large('Large Cap'),
  mid('Mid Cap'),
  largeMid('Large & Mid Cap'),
  small('Small Cap'),
  multiCap('Multi Cap'),
  focused('Focused'),
  flexi('Flexi Cap'),
  sectoral('Sectoral/Thematic'),
  eIndex('Index'),
  hybrid('Balanced/Hybrid'),
  etf('ETF'),
  taxSaving('Tax Saving (ELSS)'),
  other('Other');

  const MfSubCategory(this.title);

  final String title;

  static MfSubCategory fromTitle(String? name) {
    return MfSubCategory.values.firstWhere((e) => e.name == name, orElse: () => MfSubCategory.other);
  }
}

class InveslyAmc extends AmcInDb {
  InveslyAmc({
    required super.id,
    required super.name,
    required super.code,
    required super.isin,
    this.genre,
    required this.tags,
  }) : super(genreIndex: genre?.index, tagsString: tags.join(';'));

  InveslyAmc.mf({
    required super.name,
    required super.code,
    required super.isin,
    MfCategory? category,
    MfSubCategory? subCategory,
    MfPlan? plan,
    MfSchemeType? schemeType,
  }) : genre = AmcGenre.mf,
       tags = {category?.title, subCategory?.title, plan?.title, schemeType?.title},
       super(id: 'mf-${$uuid.v1()}');

  InveslyAmc.stock({required super.name, required super.code, required super.isin, String? sector})
    : genre = AmcGenre.stock,
      tags = {sector},
      super(id: 'stock-${$uuid.v1()}');

  InveslyAmc.insurance({required super.name, required super.code, required super.isin, String? plan})
    : genre = AmcGenre.insurance,
      tags = {plan},
      super(id: 'insurance-${$uuid.v1()}');

  InveslyAmc.misc({required super.name, required super.code, required super.isin, String? tag})
    : genre = AmcGenre.misc,
      tags = {tag},
      super(id: 'misc-${$uuid.v1()}');

  /// Genre of the AMC i.e. mf, stock, insurance, misc etc.
  final AmcGenre? genre;

  /// tags is combination of sector, sub-sector, plan, scheme etc.,
  /// tags is saved in database as string separated by commas
  final Set<String?> tags;

  factory InveslyAmc.fromDb(AmcInDb amc) {
    final tags = amc.tagsString?.split(';').map((tag) => tag.trim()).toList();
    final amcGenre = AmcGenre.fromIndex(amc.genreIndex);
    return switch (amcGenre) {
      AmcGenre.mf => InveslyAmc.mf(
        name: amc.name,
        code: amc.code,
        isin: amc.isin,
        category: MfCategory.fromTitle(tags?[0]),
        subCategory: MfSubCategory.fromTitle(tags?[1]),
        plan: MfPlan.fromTitle(tags?[2]),
        schemeType: MfSchemeType.fromTitle(tags?[3]),
      ),
      AmcGenre.stock => InveslyAmc.stock(name: amc.name, code: amc.code, isin: amc.isin, sector: tags?.first),
      AmcGenre.insurance => InveslyAmc.insurance(name: amc.name, code: amc.code, isin: amc.isin, plan: tags?.first),
      _ => InveslyAmc.misc(name: amc.name, code: amc.code, isin: amc.isin, tag: tags?.first),
    };
    // return InveslyAmc(id: amc.id, name: amc.name, genre: AmcGenre.fromIndex(amc.genreIndex), tags: tags);
  }
}

class AmcInDb extends InveslyDataModel {
  const AmcInDb({
    required super.id,
    required this.name,
    required this.code,
    required this.isin,
    this.genreIndex,
    this.tagsString,
  });

  final String name;
  final String code;
  final String isin;
  final int? genreIndex;
  final String? tagsString;

  @override
  List<Object?> get props => super.props..addAll([name, code, isin, genreIndex, tagsString]);

  // Map<String, dynamic> toMap() {
  //   return {'id': id, 'name': name, 'genre': genreIndex, 'tags': tagsString};
  // }

  // factory AmcInDb.fromMap(Map<String, dynamic> map) {
  //   return AmcInDb(
  //     id: map['id'] as String,
  //     name: map['name'] as String,
  //     genreIndex: map['genre'] as int?,
  //     tagsString: map['tags'] as String?,
  //   );
  // }
}

class AmcTable extends TableSchema<AmcInDb> {
  // Singleton pattern to ensure only one instance exists
  const AmcTable._() : super('amcs');
  static const instance = AmcTable._();
  factory AmcTable() => instance;

  TableColumn<String> get nameColumn => TableColumn('name', tableName, isUnique: true);
  TableColumn<String> get codeColumn => TableColumn('code', tableName, isUnique: true);
  TableColumn<String> get isinColumn => TableColumn('isin', tableName, isUnique: true);
  TableColumn<int> get genreColumn => TableColumn('genre', tableName, type: TableColumnType.integer, isNullable: true);
  TableColumn<String> get tagsColumn => TableColumn('tags', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => super.columns..addAll([nameColumn, codeColumn, isinColumn, genreColumn, tagsColumn]);

  @override
  Map<String, dynamic> fromModel(AmcInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      codeColumn.title: data.code,
      isinColumn.title: data.isin,
      genreColumn.title: data.genreIndex,
      tagsColumn.title: data.tagsString,
    };
  }

  @override
  AmcInDb fromMap(Map<String, dynamic> map) {
    return AmcInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      code: map[codeColumn.title] as String,
      isin: map[isinColumn.title] as String,
      genreIndex: map[genreColumn.title] as int?,
      tagsString: map[tagsColumn.title] as String?,
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
