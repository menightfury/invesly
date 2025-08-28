import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';

part 'settings_state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

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
  SettingsState fromJson(Map<String, dynamic> json) {
    return SettingsState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return state.toMap();
  }
}
