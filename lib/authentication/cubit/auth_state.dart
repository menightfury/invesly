part of 'auth_cubit.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._({this.status = AuthenticationStatus.initial, this.user, this.errorMessage});

  const AuthenticationState.initial() : this._();

  const AuthenticationState.loading() : this._(status: AuthenticationStatus.loading);

  const AuthenticationState.authenticated(GoogleSignInAccount user)
    : this._(status: AuthenticationStatus.authenticated, user: user); // TODO: `user` should be InveslyUser

  const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);

  const AuthenticationState.error(String message) : this._(status: AuthenticationStatus.error, errorMessage: message);

  final AuthenticationStatus status;
  final GoogleSignInAccount? user;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
