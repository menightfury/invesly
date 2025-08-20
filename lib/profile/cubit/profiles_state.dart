part of 'profiles_cubit.dart';

sealed class ProfilesState extends Equatable {
  const ProfilesState();

  @override
  List<Object?> get props => [];
}

class ProfilesInitialState extends ProfilesState {
  const ProfilesInitialState();
}

class ProfilesLoadingState extends ProfilesState {
  const ProfilesLoadingState();
}

class ProfilesErrorState extends ProfilesState {
  const ProfilesErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object> get props => [errorMsg];
}

class ProfilesLoadedState extends ProfilesState {
  const ProfilesLoadedState(this.profiles);

  final List<InveslyProfile> profiles;

  bool get hasNoProfiles => profiles.isEmpty;

  InveslyProfile? getProfile(String profileId) {
    return profiles.firstWhereOrNull((profile) => profile.id == profileId);
  }

  bool hasProfile(String profileId) => getProfile(profileId) != null;

  @override
  List<Object> get props => [profiles];
}
