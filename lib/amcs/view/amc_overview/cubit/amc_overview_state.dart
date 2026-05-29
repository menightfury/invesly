// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

class AmcOverviewState extends Equatable {
  const AmcOverviewState({this.status = LatestPriceStatus.initial, this.stat, this.errorMsg});

  final LatestPriceStatus status;
  final AmcStat? stat;
  final String? errorMsg;

  @override
  List<Object?> get props => [status, stat, errorMsg];

  AmcOverviewState copyWith({LatestPriceStatus? status, AmcStat? stat, String? errorMsg}) {
    return AmcOverviewState(
      status: status ?? this.status,
      stat: stat ?? this.stat,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isLtpLoading => status == LatestPriceStatus.loading;
  bool get isLtpLoaded => status == LatestPriceStatus.loaded;
  bool get isLtpError => status == LatestPriceStatus.error;
}
