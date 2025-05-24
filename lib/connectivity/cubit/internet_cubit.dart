import 'package:invesly/common_libs.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  InternetCubit() : super(InternetInitialState());

  // void updateConnectivityStatus(List<ConnectivityResult> result) {
  //   if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
  //     emit(InternetSuccessState());
  //   } else {
  //     emit(InternetFailureState());
  //   }
  // }
}
