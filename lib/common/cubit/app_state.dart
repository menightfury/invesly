part of 'app_cubit.dart';

class AppState extends Equatable {
  const AppState({
    this.isOnboarded = false,
    this.isDarkMode = false,
    this.user,
    this.primaryAccountId,
    this.isDynamicColor = true,
    this.accentColor,
    this.isPrivateMode = false,
    // this.gapiAccessToken,
    this.dateFormat,
    this.amcSha,
    this.currency,
  });

  final bool isOnboarded;
  final bool isDarkMode;
  final InveslyUser? user;
  final String? primaryAccountId;
  final int? accentColor;
  final bool isDynamicColor;
  // final AccessToken? gapiAccessToken;
  final String? dateFormat;

  /// AMC SHAs received from github releases - Used to check if the local AMC list is recent or not
  final String? amcSha;

  final Currency? currency;

  /// Hide all currency values
  final bool isPrivateMode;

  AppState copyWith({
    bool? isOnboarded,
    bool? isDarkMode,
    InveslyUser? Function()? user,
    String? Function()? primaryAccountId,
    bool? isDynamicColor,
    int? Function()? accentColor,
    bool? isPrivateMode,
    // AccessToken? Function()? gapiAccessToken,
    String? Function()? dateFormat,
    String? Function()? amcSha,
    Currency? Function()? currency,
  }) {
    return AppState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      user: user != null ? user() : this.user,
      primaryAccountId: primaryAccountId != null ? primaryAccountId() : this.primaryAccountId,
      isDynamicColor: isDynamicColor ?? this.isDynamicColor,
      accentColor: accentColor != null ? accentColor() : this.accentColor,
      isPrivateMode: isPrivateMode ?? this.isPrivateMode,
      // gapiAccessToken: gapiAccessToken != null ? gapiAccessToken() : this.gapiAccessToken,
      dateFormat: dateFormat != null ? dateFormat() : this.dateFormat,
      amcSha: amcSha != null ? amcSha() : this.amcSha,
      currency: currency != null ? currency() : this.currency,
    );
  }

  @override
  List<Object?> get props => [
    isOnboarded,
    isDarkMode,
    user,
    primaryAccountId,
    isDynamicColor,
    accentColor,
    isPrivateMode,
    // gapiAccessToken,
    dateFormat,
    amcSha,
    currency,
  ];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOnboarded': isOnboarded,
      'isDarkMode': isDarkMode,
      'user': user?.toJson(),
      'primaryAccountId': primaryAccountId,
      'isDynamicColor': isDynamicColor,
      'accentColor': accentColor,
      'isPrivateMode': isPrivateMode,
      // 'gapiAccessToken': gapiAccessToken?.toJson(),
      'dateFormat': dateFormat,
      'amcShas': amcSha,
      'currency': currency?.toMap(),
    };
  }

  factory AppState.fromMap(Map<String, dynamic> map) {
    return AppState(
      isOnboarded: map['isOnboarded'] as bool,
      isDarkMode: map['isDarkMode'] as bool,
      user: map['user'] != null ? InveslyUser.fromJson(map['user'] as String) : null,
      primaryAccountId: map['primaryAccountId'] as String?,
      isDynamicColor: map['isDynamicColor'] as bool,
      accentColor: map['accentColor'] as int?,
      isPrivateMode: map['isPrivateMode'] as bool,
      // gapiAccessToken: map['gapiAccessToken'] != null
      //     ? AccessToken.fromJson(map['gapiAccessToken'] as Map<String, dynamic>)
      //     : null,
      dateFormat: map['dateFormat'] as String?,
      amcSha: map['amcShas'] as String?,
      currency: map['currency'] != null ? Currency.fromMap(map['currency']) : null,
    );
  }

  @override
  String toString() =>
      'SettingsState(isOnboarded: $isOnboarded, isDarkMode: $isDarkMode, user: $user, '
      'primaryAccountId: $primaryAccountId, isDynamicColor: $isDynamicColor, accentColor: $accentColor, '
      'isPrivateMode: $isPrivateMode, dateFormat: $dateFormat, amcShas: $amcSha)';
}
