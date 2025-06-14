part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({this.isOnboarded = false, this.isDarkMode = false, this.currentUserId, this.accentColor});

  final bool isOnboarded;
  final bool isDarkMode;
  final String? currentUserId;
  final int? accentColor;

  SettingsState copyWith({bool? isOnboarded, bool? isDarkMode, String? currentUserId, int? accentColor}) {
    return SettingsState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentUserId: currentUserId ?? this.currentUserId,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  List<Object?> get props => [isOnboarded, isDarkMode, currentUserId, accentColor];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOnboarded': isOnboarded,
      'isDarkMode': isDarkMode,
      'currentUserId': currentUserId,
      'accentColor': accentColor,
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      isOnboarded: map['isOnboarded'] as bool,
      isDarkMode: map['isDarkMode'] as bool,
      currentUserId: map['currentUserId'] as String?,
      accentColor: map['accentColor'] as int?,
    );
  }
}
