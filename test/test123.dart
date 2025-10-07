// ignore_for_file: avoid_print

void main() {
  final initialAmcs = [
    // ~ Mutual funds
    InveslyAmc.mf(
      // id: 'aditya-birla-sunlife-mf-equity-focused-growth-direct',
      name: 'Aditya Birla Sunlife',
      category: MfCategory.eFocused,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'aditya-birla-sunlife-mf-equity-focused-growth-regular',
      name: 'Aditya Birla Sunlife',
      category: MfCategory.eFocused,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'aditya-birla-sunlife-mf-equity-largecap-growth-direct',
      name: 'Aditya Birla Sunlife',
      category: MfCategory.eLarge,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'aditya-birla-sunlife-mf-equity-largecap-growth-regular',
      name: 'Aditya Birla Sunlife',
      category: MfCategory.eLarge,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'aditya-birla-sunlife-frontline-mf-equity-largecap-growth-direct',
      name: 'Aditya Birla Sunlife Frontline',
      category: MfCategory.eLarge,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'aditya-birla-sunlife-frontline-mf-equity-largecap-growth-regular',
      name: 'Aditya Birla Sunlife Frontline',
      category: MfCategory.eLarge,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'axis-mf-equity-midcap-growth-direct',
      name: 'Axis',
      category: MfCategory.eMid,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'axis-mf-equity-midcap-growth-regular',
      name: 'Axis',
      category: MfCategory.eMid,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'axis-mf-equity-smallcap-growth-direct',
      name: 'Axis',
      category: MfCategory.eSmall,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'axis-mf-equity-smallcap-growth-regular',
      name: 'Axis',
      category: MfCategory.eSmall,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'axis-growth-opportunities-mf-equity-large-midcap-growth-direct',
      name: 'Axis Growth Opportunities',
      category: MfCategory.eLargeMid,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'axis-growth-opportunities-mf-equity-large-midcap-growth-regular',
      name: 'Axis Growth Opportunities',
      category: MfCategory.eLargeMid,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'hsbc-lt-mf-equity-smallcap-growth-direct',
      name: 'HSBC (L&T)',
      category: MfCategory.eSmall,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'hsbc-lt-mf-equity-smallcap-growth-regular',
      name: 'HSBC (L&T)',
      category: MfCategory.eSmall,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'kotak-emerging-mf-equity-midcap-growth-direct',
      name: 'Kotak Emerging',
      category: MfCategory.eMid,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'kotak-emerging-mf-equity-midcap-growth-regular',
      name: 'Kotak Emerging',
      category: MfCategory.eMid,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'kotak-mf-equity-flexicap-growth-regular',
      name: 'Kotak',
      category: MfCategory.eFlexi,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'lic-mf-equity-largecap-growth-regular',
      name: 'LIC',
      category: MfCategory.eLarge,
      plan: MfPlan.growth,
      scheme: MfScheme.regular,
    ),
    InveslyAmc.mf(
      // id: 'lic-infrastructural-mf-equity-sectoral-growth-direct',
      name: 'LIC infrastructural',
      category: MfCategory.eSectoral,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'motilal-oswal-mf-equity-midcap-growth-direct',
      name: 'Motilal Oswal',
      category: MfCategory.eMid,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),
    InveslyAmc.mf(
      // id: 'parag-parikh-mf-equity-flexicap-growth-direct',
      name: 'Parag Parikh',
      category: MfCategory.eFlexi,
      plan: MfPlan.growth,
      scheme: MfScheme.direct,
    ),

    // ~ Stocks
    InveslyAmc.stock(
      // id: 'adani-power-ltd-stock-power-generation-and-distribution',
      name: 'Adani Power Ltd.',
      sector: 'Power Generation and Distribution',
    ),

    // ~ Insurance
    InveslyAmc.insurance(
      // id: 'lic-insurance-new-endowment-plan-814',
      name: 'LIC',
      plan: 'New Endowment Plan (814)',
    ),

    // ~ Miscellaneous
    InveslyAmc.misc(
      // id: 'post-office-misc-nsc-national-savings-certificate',
      name: 'Post Office',
      tag: 'NSC (National Savings Certificate)',
    ),
  ];

  for (final amc in initialAmcs) {
    print('${amc.id}\n');
  }
}

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

class AmcInDb {
  const AmcInDb({required this.id, required this.name, this.genreIndex, this.tagsString});

  final String id;
  final String name;
  final int? genreIndex;
  final String? tagsString;
}

extension StringEscaped on String {
  String get escaped {
    return replaceAll(
          RegExp(r'[\s&().\/]+', caseSensitive: false),
          '-',
        ) // removes spaces, ampersands, parentheses and slashes
        .replaceAll(RegExp(r'^-+|-+$', caseSensitive: false), '') // removes all leading and trailing hyphens
        .toLowerCase();
  }
}
