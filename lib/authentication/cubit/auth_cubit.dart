import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/common_libs.dart';
part 'auth_state.dart';

// Auth means Authentication and Authorization :)
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository}) : _repository = repository, super(const AuthInitialState());

  final AuthRepository _repository;

  Future<void> signin() async {
    emit(const AuthLoadingState());

    try {
      final user = await _repository.signInWithGoogle();
      if (user != null) {
        final accessToken = await _repository.getAccessToken(user);
        // final files = await _repository.getDriveFiles(accessToken);
        emit(AuthenticatedState(user: user, accessToken: accessToken));
      } else {
        emit(const UnauthenticatedState());
      }
    } catch (err) {
      emit(AuthErrorState(err.toString()));
    }
  }

  Future<void> signout() async {
    await _repository.signOut();
    emit(const UnauthenticatedState());
  }
}
