import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/common_libs.dart';
part 'auth_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({required AuthenticationRepository repository})
    : _repository = repository,
      super(AuthenticationState.initial());

  final AuthenticationRepository _repository;

  Future<void> signin() async {
    emit(AuthenticationState.loading());

    try {
      final user = await _repository.signInGoogle();
      if (user != null) {
        emit(AuthenticationState.authenticated(user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    } catch (err) {
      emit(AuthenticationState.error(err.toString()));
    }
  }

  Future<void> signout() async {
    await _repository.signOutGoogle();
    emit(AuthenticationState.unauthenticated());
  }
}
