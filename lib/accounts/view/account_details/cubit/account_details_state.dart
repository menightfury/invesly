// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'account_details_cubit.dart';

enum AccountDetailsStatus { initial, loading, loaded, error }

class AccountDetailsState extends Equatable {
  const AccountDetailsState({
    this.status = AccountDetailsStatus.initial,
    this.activeAccountId,
    this.stats = const <InveslyStat>[],
    this.totalInvested = 0.0,
    this.selectedGenre,
  });

  final AccountDetailsStatus status;
  final int? activeAccountId;
  final List<InveslyStat> stats;
  final double totalInvested;
  final AmcGenre? selectedGenre;

  double getTotalInvestedByGenre(AmcGenre genre) {
    return stats.where((stat) => stat.amc.genre == genre).fold<double>(0, (v, el) => v + el.totalInvested);
  }

  @override
  List<Object?> get props => [status, activeAccountId, stats, totalInvested, selectedGenre];

  AccountDetailsState copyWith({
    AccountDetailsStatus? status,
    int? activeAccountId,
    List<InveslyStat>? stats,
    double? totalInvested,
    AmcGenre? selectedGenre,
  }) {
    return AccountDetailsState(
      status: status ?? this.status,
      activeAccountId: activeAccountId ?? this.activeAccountId,
      stats: stats ?? this.stats,
      totalInvested: totalInvested ?? this.totalInvested,
      selectedGenre: selectedGenre ?? this.selectedGenre,
    );
  }
}

extension AccountDetailsStateX on AccountDetailsState {
  bool get isInitial => status == AccountDetailsStatus.initial;
  bool get isLoading => status == AccountDetailsStatus.loading;
  bool get isLoaded => status == AccountDetailsStatus.loaded;
  bool get isError => status == AccountDetailsStatus.error;

  bool get isNotEmpty => isLoaded && stats.isNotEmpty;
  bool get isEmpty => isLoaded && stats.isEmpty;
}
