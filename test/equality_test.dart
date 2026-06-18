// ignore_for_file: avoid_print

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/stat/model/stat_model.dart';

void main() {
  final statInDb = StatInDb(
    accountId: 2,
    amcId: 'Launchpad',
    numTrns: 5,
    totalQnty: 1,
    totalInvested: 5000,
    totalRedeemed: 1000,
  );

  final statInDb2 = StatInDb(
    accountId: 2,
    amcId: 'Launchpad',
    numTrns: 5,
    totalQnty: 1,
    totalInvested: 5000,
    totalRedeemed: 1000,
  );

  final inveslyStat = InveslyStat(
    accountId: 2,
    amc: MfAmcModel(id: 'Launchpad', name: 'Launchpad', code: 'Launchpad'),
    numTrns: 5,
    totalQnty: 1,
    totalInvested: 5000,
    totalRedeemed: 1000,
  );

  print(statInDb == statInDb2);
  print(statInDb == inveslyStat);
}
