part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final bool isOnboarded;
  final bool isDarkMode;

  const SettingsState({this.isOnboarded = false, this.isDarkMode = false});

  @override
  List<Object?> get props => [isOnboarded, isDarkMode];

  SettingsState copyWith({bool? initialized, bool? isOnboarded, bool? isDarkMode}) {
    return SettingsState(isOnboarded: isOnboarded ?? this.isOnboarded, isDarkMode: isDarkMode ?? this.isDarkMode);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'isOnboarded': isOnboarded, 'isDarkMode': isDarkMode};
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(isOnboarded: map['isOnboarded'] as bool, isDarkMode: map['isDarkMode'] as bool);
  }
}
