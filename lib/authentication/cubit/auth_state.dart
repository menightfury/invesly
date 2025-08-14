part of 'auth_cubit.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._({this.status = AuthenticationStatus.unknown, this.user});

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(GoogleSignInAccount user)
    : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated() : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final GoogleSignInAccount? user;

  @override
  List<Object?> get props => [status, user];
}
