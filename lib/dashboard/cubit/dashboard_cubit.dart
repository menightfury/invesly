import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState());

  void updateSelectedGenre(AmcGenre? genre) {
    emit(state.copyWith(selectedGenre: () => genre));
  }
}
