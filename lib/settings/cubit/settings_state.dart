part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({this.isOnboarded = false, this.isDarkMode = false, this.currentUserId});

  final bool isOnboarded;
  final bool isDarkMode;
  final String? currentUserId;

  SettingsState copyWith({bool? isOnboarded, bool? isDarkMode, String? currentUserId}) {
    return SettingsState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  List<Object?> get props => [isOnboarded, isDarkMode, currentUserId];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'isOnboarded': isOnboarded, 'isDarkMode': isDarkMode, 'currentUserId': currentUserId};
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      isOnboarded: map['isOnboarded'] as bool,
      isDarkMode: map['isDarkMode'] as bool,
      currentUserId: map['currentUserId'] as String?,
    );
  }
}
