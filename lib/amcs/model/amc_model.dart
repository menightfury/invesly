import 'package:flutter/material.dart';
import 'package:invesly/database/table_schema.dart';

enum AmcGenre {
  mf('Mutual fund'),
  stock('Stock'),
  insurance('Insurance'),
  misc('Miscellaneous');

  const AmcGenre(this.title);

  final String title;

  static AmcGenre findByName(String name) {
    return AmcGenre.values.firstWhere((e) => e.name == name, orElse: () => AmcGenre.misc);
  }

  static AmcGenre getByIndex(int? index) {
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

  static MfPlan findByName(String name) {
    return MfPlan.values.firstWhere((e) => e.name == name, orElse: () => MfPlan.growth);
  }
}

enum MfScheme {
  direct('Direct'),
  regular('Regular');

  const MfScheme(this.title);

  final String title;

  static MfScheme findByName(String name) {
    return MfScheme.values.firstWhere((e) => e.name == name, orElse: () => MfScheme.regular);
  }
}

enum MfCategory {
  eLarge('Equity Large Cap'),
  eMid('Equity Mid Cap'),
  eLargeMid('Equity Large & Mid Cap'),
  eSmall('Equity Small Cap'),
  eMultiCap('Equity Multi Cap'),
  eFocused('Equity Focused'),
  eFlexi('Equity Flexi Cap'),
  eSectoral('Equity Sectoral/Thematic'),
  eIndex('Equity Index'),
  eHybrid('Balanced/Hybrid'),
  etf('ETF'),
  taxSaving('Tax Saving (ELSS)'),
  other('Other');

  const MfCategory(this.title);

  final String title;

  static MfCategory findByName(String name) {
    return MfCategory.values.firstWhere((e) => e.name == name, orElse: () => MfCategory.other);
  }
}

class InveslyAmc extends AmcInDb {
  InveslyAmc({required super.id, required super.name, this.genre, this.tags})
    : super(genreIndex: genre?.index, tagsString: tags?.join(';'));

  InveslyAmc.mf({required super.name, required MfCategory category, required MfPlan plan, required MfScheme scheme})
    : genre = AmcGenre.mf,
      tags = {category.title, plan.title, scheme.title},
      super(id: '${name.escaped}-mf-${category.title.escaped}-${plan.title.escaped}-${scheme.title.escaped}');

  InveslyAmc.stock({required super.name, required String sector})
    : genre = AmcGenre.stock,
      tags = {sector},
      super(id: '${name.escaped}-stock-${sector.escaped}');

  InveslyAmc.insurance({required super.name, required String plan})
    : genre = AmcGenre.insurance,
      tags = {plan},
      super(id: '${name.escaped}-insurance-${plan.escaped}');

  InveslyAmc.misc({required super.name, required String tag})
    : genre = AmcGenre.misc,
      tags = {tag},
      super(id: '${name.escaped}-misc-${tag.escaped}');

  /// Genre of the AMC i.e. mf, stock, insurance, misc etc.
  final AmcGenre? genre;

  /// tags is combination of sector, sub-sector, plan, scheme etc.,
  /// tags is saved in database as string separated by commas
  final Set<String>? tags;

  factory InveslyAmc.fromDb(AmcInDb amc) {
    final tags = amc.tagsString?.split(',').map((tag) => tag.trim()).toSet();
    return InveslyAmc(id: amc.id, name: amc.name, genre: AmcGenre.getByIndex(amc.genreIndex), tags: tags);
  }
}

class AmcInDb extends InveslyDataModel {
  const AmcInDb({required super.id, required this.name, this.genreIndex, this.tagsString});

  final String name;
  final int? genreIndex;
  final String? tagsString;

  @override
  List<Object?> get props => super.props..addAll([name, genreIndex, tagsString]);
}

class AmcTable extends TableSchema<AmcInDb> {
  // Singleton pattern to ensure only one instance exists
  const AmcTable._() : super('amcs');
  static const _i = AmcTable._();
  factory AmcTable() => _i;

  TableColumn<String> get nameColumn => TableColumn('name', tableName);
  TableColumn<int> get genreColumn => TableColumn('genre', tableName, type: TableColumnType.integer, isNullable: true);
  TableColumn<String> get tagsColumn => TableColumn('tags', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => super.columns..addAll([nameColumn, genreColumn, tagsColumn]);

  @override
  Map<String, dynamic> decode(AmcInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      genreColumn.title: data.genreIndex,
      tagsColumn.title: data.tagsString,
    };
  }

  @override
  AmcInDb encode(Map<String, dynamic> map) {
    return AmcInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
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
