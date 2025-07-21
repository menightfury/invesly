part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isOnboarded = false,
    this.isDarkMode = false,
    this.currentUserId,
    this.isDynamicColor = false,
    this.accentColor,
    this.isPrivateMode = true,
  });

  final bool isOnboarded;
  final bool isDarkMode;
  final String? currentUserId;
  final int? accentColor;
  final bool isDynamicColor;

  /// Hide all currency values
  final bool isPrivateMode;

  SettingsState copyWith({
    bool? isOnboarded,
    bool? isDarkMode,
    String? currentUserId,
    bool? isDynamicColor,
    int? accentColor,
    bool? isPrivateMode,
  }) {
    return SettingsState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentUserId: currentUserId ?? this.currentUserId,
      isDynamicColor: isDynamicColor ?? this.isDynamicColor,
      accentColor: accentColor ?? this.accentColor,
      isPrivateMode: isPrivateMode ?? this.isPrivateMode,
    );
  }

  @override
  List<Object?> get props => [isOnboarded, isDarkMode, currentUserId, isDynamicColor, accentColor, isPrivateMode];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOnboarded': isOnboarded,
      'isDarkMode': isDarkMode,
      'currentUserId': currentUserId,
      'isDynamicColor': isDynamicColor,
      'accentColor': accentColor,
      'isPrivateMode': isPrivateMode,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      isOnboarded: map['isOnboarded'] as bool,
      isDarkMode: map['isDarkMode'] as bool,
      currentUserId: map['currentUserId'] as String?,
      isDynamicColor: map['isDynamicColor'] as bool,
      accentColor: map['accentColor'] as int?,
      isPrivateMode: map['isPrivateMode'] as bool,
    );
  }
}
