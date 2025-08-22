part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  // const AuthState._({this.status = AuthStatus.initial, this.user, this.accessToken, this.errorMessage});
  const AuthState();

  // const AuthState.initial() : this._();

  // const AuthState.loading() : this._(status: AuthStatus.loading);

  // const AuthState.authenticated(GoogleSignInAccount user, AccessToken accessToken)
  //   : this._(status: AuthStatus.authenticated, user: user, accessToken: accessToken);

  // const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  // const AuthState.error(String message) : this._(status: AuthStatus.error, errorMessage: message);

  // final AuthStatus status;
  // final GoogleSignInAccount? user;
  // final AccessToken? accessToken;
  // final String? errorMessage;

  @override
  // List<Object?> get props => [status, user, accessToken, errorMessage];
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthenticatedState extends AuthState {
  const AuthenticatedState({required this.user, required this.accessToken});

  final GoogleSignInAccount user;
  final AccessToken accessToken;
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthErrorState extends AuthState {
  const AuthErrorState(this.message);

  final String message;
}
