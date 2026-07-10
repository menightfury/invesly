// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'dashboard_cubit.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({this.status = DashboardStatus.initial, this.selectedGenre});

  final DashboardStatus status;
  final AmcGenre? selectedGenre;

  @override
  List<Object> get props => [status];

  DashboardState copyWith({DashboardStatus? status, AmcGenre? Function()? selectedGenre}) {
    return DashboardState(status: status ?? this.status, selectedGenre: selectedGenre?.call() ?? this.selectedGenre);
  }
}
