// spell-checker: disable
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';

// delete accounts in production mode
final _account1 = AccountInDb(id: 'satyajyoti_biswas', name: 'Satyajyoti Biswas', avatarIndex: 2);
final _account2 = AccountInDb(id: 'jhuma_mondal', name: 'Jhuma Mondal', avatarIndex: 1);
final initialAccounts = [_account1, _account2];

final initialAmcs = [
  // ~ Mutual funds
  InveslyAmc(
    id: 'aditya-birla-sunlife-mf-equity-focused-growth-direct',
    name: 'Aditya Birla Sunlife',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Focused'},
  ),
  InveslyAmc(
    id: 'aditya-birla-sunlife-mf-equity-focused-growth-regular',
    name: 'Aditya Birla Sunlife',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Focused'},
  ),
  InveslyAmc(
    id: 'aditya-birla-sunlife-mf-equity-largecap-growth-direct',
    name: 'Aditya Birla Sunlife',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Largecap'},
  ),
  InveslyAmc(
    id: 'aditya-birla-sunlife-mf-equity-largecap-growth-regular',
    name: 'Aditya Birla Sunlife',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Largecap'},
  ),
  InveslyAmc(
    id: 'aditya-birla-sunlife-frontline-mf-equity-largecap-growth-direct',
    name: 'Aditya Birla Sunlife Frontline',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Largecap'},
  ),
  InveslyAmc(
    id: 'aditya-birla-sunlife-frontline-mf-equity-largecap-growth-regular',
    name: 'Aditya Birla Sunlife Frontline',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Largecap'},
  ),
  InveslyAmc(
    id: 'axis-mf-equity-midcap-growth-direct',
    name: 'Axis',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Midcap'},
  ),
  InveslyAmc(
    id: 'axis-mf-equity-midcap-growth-regular',
    name: 'Axis',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Midcap'},
  ),
  InveslyAmc(
    id: 'axis-mf-equity-smallcap-growth-direct',
    name: 'Axis',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Smallcap'},
  ),
  InveslyAmc(
    id: 'axis-mf-equity-smallcap-growth-regular',
    name: 'Axis',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Smallcap'},
  ),
  InveslyAmc(
    id: 'axis-growth-opportunities-mf-equity-large-midcap-growth-direct',
    name: 'Axis Growth Opportunities',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Large & Midcap'},
  ),
  InveslyAmc(
    id: 'axis-growth-opportunities-mf-equity-large-midcap-growth-regular',
    name: 'Axis Growth Opportunities',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Large & Midcap'},
  ),
  InveslyAmc(
    id: 'hsbc-lt-mf-equity-smallcap-growth-direct',
    name: 'HSBC (L&T)',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Smallcap'},
  ),
  InveslyAmc(
    id: 'hsbc-lt-mf-equity-smallcap-growth-regular',
    name: 'HSBC (L&T)',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Smallcap'},
  ),
  InveslyAmc(
    id: 'kotak-emerging-mf-equity-midcap-growth-direct',
    name: 'Kotak Emerging',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Midcap'},
  ),
  InveslyAmc(
    id: 'kotak-emerging-mf-equity-midcap-growth-regular',
    name: 'Kotak Emerging',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Midcap'},
  ),
  InveslyAmc(
    id: 'kotak-mf-equity-flexicap-growth-regular',
    name: 'Kotak',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Flexicap'},
  ),
  InveslyAmc(
    id: 'lic-mf-equity-largecap-growth-regular',
    name: 'LIC',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Regular', 'Equity', 'Largecap'},
  ),
  InveslyAmc(
    id: 'lic-infrastructural-mf-equity-sectoral-growth-direct',
    name: 'LIC infrastructural',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Sectoral'},
  ),
  InveslyAmc(
    id: 'motilal-oswal-mf-equity-midcap-growth-direct',
    name: 'Motilal Oswal',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Midcap'},
  ),
  InveslyAmc(
    id: 'parag-parikh-mf-equity-flexicap-growth-direct',
    name: 'Parag Parikh',
    genre: AmcGenre.mf,
    tags: {'Growth', 'Direct', 'Equity', 'Flexicap'},
  ),

  // ~ Stocks
  InveslyAmc(
    id: 'adani-power-ltd-stock-power-generation-and-distribution',
    name: 'Adani Power Ltd.',
    genre: AmcGenre.stock,
    tags: {'Power Generation and Distribution'},
  ),

  // ~ Insurance
  InveslyAmc(
    id: 'lic-insurance-new-endowment-plan-814',
    name: 'LIC',
    genre: AmcGenre.insurance,
    tags: {'New Endowment Plan (814)'},
  ),

  // ~ Miscellaneous
  InveslyAmc(
    id: 'post-office-misc-nsc-national-savings-certificate',
    name: 'Post Office',
    genre: AmcGenre.misc,
    tags: {'SC (National Savings Certificate)'},
  ),
];
