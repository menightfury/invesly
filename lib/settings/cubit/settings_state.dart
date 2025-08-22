part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.isOnboarded = false,
    this.isDarkMode = false,
    this.currentUser,
    this.currentAccountId,
    this.isDynamicColor = true,
    this.accentColor,
    this.isPrivateMode = false,
    this.gapiAccessToken,
  });

  final bool isOnboarded;
  final bool isDarkMode;
  final InveslyUser? currentUser;
  final String? currentAccountId;
  final int? accentColor;
  final bool isDynamicColor;
  final AccessToken? gapiAccessToken;

  /// Hide all currency values
  final bool isPrivateMode;

  SettingsState copyWith({
    bool? isOnboarded,
    bool? isDarkMode,
    InveslyUser? currentUser,
    String? currentAccountId,
    bool? isDynamicColor,
    int? accentColor,
    bool? isPrivateMode,
    AccessToken? gapiAccessToken,
  }) {
    return SettingsState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentUser: currentUser ?? this.currentUser,
      currentAccountId: currentAccountId ?? this.currentAccountId,
      isDynamicColor: isDynamicColor ?? this.isDynamicColor,
      accentColor: accentColor ?? this.accentColor,
      isPrivateMode: isPrivateMode ?? this.isPrivateMode,
      gapiAccessToken: gapiAccessToken ?? this.gapiAccessToken,
    );
  }

  @override
  List<Object?> get props => [
    isOnboarded,
    isDarkMode,
    currentUser,
    currentAccountId,
    isDynamicColor,
    accentColor,
    isPrivateMode,
    gapiAccessToken,
  ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOnboarded': isOnboarded,
      'isDarkMode': isDarkMode,
      'currentUser': currentUser?.toJson(),
      'currentAccountId': currentAccountId,
      'isDynamicColor': isDynamicColor,
      'accentColor': accentColor,
      'isPrivateMode': isPrivateMode,
      'gapiAccessToken': gapiAccessToken?.toJson(),
    };
  }

  factory SettingsState.fromMap(Map<String, dynamic> map) {
    return SettingsState(
      isOnboarded: map['isOnboarded'] as bool,
      isDarkMode: map['isDarkMode'] as bool,
      currentUser: map['currentUser'] != null ? InveslyUser.fromJson(map['currentUser'] as String) : null,
      currentAccountId: map['currentAccountId'] as String?,
      isDynamicColor: map['isDynamicColor'] as bool,
      accentColor: map['accentColor'] as int?,
      isPrivateMode: map['isPrivateMode'] as bool,
      gapiAccessToken: map['gapiAccessToken'] != null
          ? AccessToken.fromJson(map['gapiAccessToken'] as Map<String, dynamic>)
          : null,
    );
  }
}
