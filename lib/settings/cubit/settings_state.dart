part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isOnboarded = false,
    this.isDarkMode = false,
    this.currentUser,
    this.currentUserId,
    this.isDynamicColor = true,
    this.accentColor,
    this.isPrivateMode = false,
  });

  final bool isOnboarded;
  final bool isDarkMode;
  final InveslyUser? currentUser;
  final String? currentUserId;
  final int? accentColor;
  final bool isDynamicColor;

  /// Hide all currency values
  final bool isPrivateMode;

  SettingsState copyWith({
    bool? isOnboarded,
    bool? isDarkMode,
    InveslyUser? currentUser,
    String? currentUserId,
    bool? isDynamicColor,
    int? accentColor,
    bool? isPrivateMode,
  }) {
    return SettingsState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentUser: currentUser ?? this.currentUser,
      currentUserId: currentUserId ?? this.currentUserId,
      isDynamicColor: isDynamicColor ?? this.isDynamicColor,
      accentColor: accentColor ?? this.accentColor,
      isPrivateMode: isPrivateMode ?? this.isPrivateMode,
    );
  }

  @override
  List<Object?> get props => [
    isOnboarded,
    isDarkMode,
    currentUser,
    currentUserId,
    isDynamicColor,
    accentColor,
    isPrivateMode,
  ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOnboarded': isOnboarded,
      'isDarkMode': isDarkMode,
      'currentUser': currentUser?.toJson(),
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
      currentUser: map['currentUser'] != null ? InveslyUser.fromJson(map['currentUser'] as String) : null,
      currentUserId: map['currentUserId'] as String?,
      isDynamicColor: map['isDynamicColor'] as bool,
      accentColor: map['accentColor'] as int?,
      isPrivateMode: map['isPrivateMode'] as bool,
    );
  }
}
