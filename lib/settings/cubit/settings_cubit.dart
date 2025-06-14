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

  void saveCurrentUser(String userId) {
    emit(state.copyWith(currentUserId: userId));
  }

  void setDarkTheme(bool isDarkMode) async {
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  void setAccentColor(int? color) async {
    // if color is null, set null explicitly
    final color = Person copyWith({String? Function()? name}) =>
      Person(name != null ? name() : this.name);
    if (color == null) {
      emit(state.copyWith(accentColor: ));
    }
    emit(state.copyWith(accentColor: isDarkMode));
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
