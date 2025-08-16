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

// final class AuthenticationInitialState extends AuthenticationState {
//   const AuthenticationInitialState() : super._(status: AuthenticationStatus.unknown);
// }

// final class AuthenticationStateUnauthenticated extends AuthenticationState {
//   const AuthenticationStateUnauthenticated() : super._(status: AuthenticationStatus.unauthenticated);

//   @override
//   List<Object?> get props => [status];
// }

// final class AuthenticationStateUnknown extends AuthenticationState {
//   const AuthenticationStateUnknown() : super._(status: AuthenticationStatus.unknown);

//   @override
//   List<Object?> get props => [status];
// }

// final class AuthenticationStateAuthenticated extends AuthenticationState {
//   const AuthenticationStateAuthenticated(GoogleSignInAccount user)
//     : super._(status: AuthenticationStatus.authenticated, user: user);

//   @override
//   List<Object?> get props => [status, user];
// }

// final class AuthenticationStateError extends AuthenticationState {
//   const AuthenticationStateError() : super._(status: AuthenticationStatus.error);

//   @override
//   List<Object?> get props => [status];
// }
