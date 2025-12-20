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

  void updateUser(InveslyUser? user) {
    emit(state.copyWith(user: () => user));
  }

  void updatePrimaryAccount(String? accountId) {
    emit(state.copyWith(primaryAccountId: () => accountId));
  }

  void updateThemeMode(bool isDarkMode) async {
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  void updateDynamicColorMode(bool isDynamic) async {
    emit(state.copyWith(isDynamicColor: isDynamic));
  }

  void updateAccentColor(int? color) async {
    emit(state.copyWith(accentColor: () => color));
  }

  void updatePrivateMode(bool value) {
    emit(state.copyWith(isPrivateMode: value));
  }

  void updateDateFormat(String dateFormat) {
    emit(state.copyWith(dateFormat: () => dateFormat));
  }

  void updateAmcSha(String? amcSha) {
    emit(state.copyWith(amcSha: () => amcSha));
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
