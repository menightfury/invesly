import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';

part 'app_state.dart';

class AppCubit extends HydratedCubit<AppState> {
  AppCubit() : super(const AppState());

  // void initialize() {
  //   emit(state.copyWith(initialized: true));
  // }

  void completeOnboarding() {
    emit(state.copyWith(isOnboarded: true));
  }

  void saveCurrentUser(InveslyUser user) {
    emit(state.copyWith(currentUser: user));
  }

  void saveCurrentAccount(String accountId) {
    emit(state.copyWith(currentAccountId: accountId));
  }

  void setDarkTheme(bool isDarkMode) async {
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  void setDynamicColorMode(bool isDynamic) async {
    emit(state.copyWith(isDynamicColor: isDynamic));
  }

  void setAccentColor(int color) async {
    emit(state.copyWith(accentColor: color));
  }

  void setPrivateMode(bool value) {
    emit(state.copyWith(isPrivateMode: value));
  }

  void saveGapiAccessToken(AccessToken accessToken) {
    emit(state.copyWith(gapiAccessToken: accessToken));
  }

  @override
  AppState fromJson(Map<String, dynamic> json) {
    return AppState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(AppState state) {
    return state.toMap();
  }
}
