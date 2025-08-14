import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/common_libs.dart';
part 'auth_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({required AuthenticationRepository repository})
    : _repository = repository,

      super(AuthenticationState.unknown());

  final AuthenticationRepository _repository;

  Future<void> _onLoginPressed() async {
    emit(AuthenticationState.unknown());

    final user = await _repository.signInGoogle();
    if (user != null) {
      emit(AuthenticationState.authenticated(user));
    } else {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onLogoutPressed() async {
    await _repository.signOutGoogle();
    emit(AuthenticationState.unknown());
  }
}
