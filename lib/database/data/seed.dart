// spell-checker: disable
// import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';

// delete accounts in production mode
// final _account1 = AccountInDb(id: 'satyajyoti_biswas', name: 'Satyajyoti Biswas', avatarIndex: 2);
// final _account2 = AccountInDb(id: 'jhuma_mondal', name: 'Jhuma Mondal', avatarIndex: 1);
// final initialAccounts = [_account1, _account2];

final initialAmcs = [
  // ~ Mutual funds
  InveslyAmc.mf(
    // id: 'aditya-birla-sunlife-mf-equity-focused-growth-direct',
    name: 'Aditya Birla Sunlife Mutual Fund',
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
