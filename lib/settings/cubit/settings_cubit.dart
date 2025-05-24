import 'package:invesly/common_libs.dart';

part 'settings_state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void initialize() {
    emit(state.copyWith(initialized: true));
  }

  void onboardingComplete() {
    emit(state.copyWith(isOnboarded: true));
  }

  // void saveCurrentUser(InveslyUser user) {
  //   emit(state.copyWith(currentUser: user));
  // }

  void setDarkTheme(bool status) async {
    emit(state.copyWith(isDarkMode: status));
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
