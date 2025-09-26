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
      mf => Icons.pie_chart,
      stock => Icons.show_chart,
      insurance => Icons.security,
      misc => Icons.category,
    };
  }
}

class InveslyAmc extends AmcInDb {
  InveslyAmc({required super.id, required super.name, this.genre, this.tags})
    : super(genreIndex: genre?.index, tagsString: tags?.join(','));

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

  TableColumn<String> get nameColumn => TableColumn('name', name);
  TableColumn<int> get genreColumn => TableColumn('genre', name, type: TableColumnType.integer, isNullable: true);
  TableColumn<String> get tagsColumn => TableColumn('tags', name, isNullable: true);

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
