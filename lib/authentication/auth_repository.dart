import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/servicecontrol/v2.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:invesly/common_libs.dart';
import 'package:invesly/connectivity/internet_aware_http_client.dart';
import 'package:invesly/connectivity/connectivity_extension.dart';

// Auth means Authentication and Authorization
class AuthRepository {
  // Singleton pattern
  AuthRepository._()
    : _connectivity = Connectivity(),
      _googleSignIn = GoogleSignIn.instance,
      _scopes = const <String>[
        // See https://github.com/flutter/flutter/issues/155490 and https://github.com/flutter/flutter/issues/155429
        // Once an account is logged in with these scopes, they are not needed
        // So we will keep these to apply for all users to prevent errors, especially on silent sign in
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/userinfo.email',
        drive.DriveApi.driveAppdataScope,
        drive.DriveApi.driveFileScope,
      ];
  factory AuthRepository.initialize() => _instance;
  static final AuthRepository _instance = AuthRepository._();
  static AuthRepository get instance => _instance;

  final Connectivity _connectivity;
  final GoogleSignIn _googleSignIn;
  final List<String> _scopes;

  drive.DriveApi? _driveApi;
  Future<GoogleSignInAccount?> signInWithGoogle({bool? waitForCompletion = false, Function()? next}) async {
    try {
      final hasInternet = await _connectivity.hasInternet;
      if (!hasInternet) {
        throw Exception('No internet connection. Please check your connection and try again.');
      }

      await _googleSignIn.initialize(
        serverClientId: '791480731407-hc266q1klj0br5c9312gkjbsko05qjoq.apps.googleusercontent.com',
      );
      return await _googleSignIn.authenticate();
    } catch (err) {
      $logger.e(err);
      throw ('Error signing in');
    }
  }

  Future<void> signOut() async {
    // Call disconnect rather than signOut to more fully reset the example app.
    await _googleSignIn.disconnect();
    // googleUser = null;
  }

  Future<gapis.AccessToken> getAccessToken(GoogleSignInAccount user) async {
    GoogleSignInClientAuthorization? authorization;

    try {
      // First check authorization without client interaction
      authorization = await user.authorizationClient.authorizationForScopes(_scopes);
      // If authorization is still null, request it interactively
      authorization ??= await user.authorizationClient.authorizeScopes(_scopes);

      return gapis.AccessToken(
        'Bearer',
        authorization.accessToken,
        // The underlying SDKs don't provide expiry information, so set an arbitrary distant-future time.
        DateTime.now().toUtc().add(const Duration(days: 365)),
      );
    } catch (err) {
      $logger.e(err);
      throw ('Error getting Access Token');
    }
  }

  Future<drive.DriveApi> getDriveApi(gapis.AccessToken accessToken) async {
    try {
      final hasInternet = await _connectivity.hasInternet;
      if (!hasInternet) {
        throw NetworkException('No internet connection available');
      }

      final credentials = gapis.AccessCredentials(accessToken, null, _scopes);
      final client = gapis.authenticatedClient(InternetAwareHttpClient(), credentials);

      return _driveApi = drive.DriveApi(client);
    } on NetworkException catch (e) {
      $logger.e('Network error getting Drive API: $e');
      rethrow;
    } catch (err) {
      $logger.e(err);
      throw ('Error getting Drive API');
    }
  }

  Future<List<drive.File>?> getDriveFiles(gapis.AccessToken accessToken) async {
    try {
      final hasInternet = await _connectivity.hasInternet;
      if (!hasInternet) {
        throw NetworkException('No internet connection available');
      }

      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, modifiedTime, size)',
      );
      final files = fileList.files;
      if (files == null || files.isEmpty) {
        return null;
      }
      return files;
    } on NetworkException catch (e) {
      $logger.e('Network error getting Drive files: $e');
      rethrow;
    } catch (err) {
      $logger.e(err);
      rethrow;
    }
  }

  Future<List<int>?> getDriveFileContent({required gapis.AccessToken accessToken, required String fileId}) async {
    try {
      final hasInternet = await _connectivity.hasInternet;
      if (!hasInternet) {
        throw NetworkException('No internet connection available');
      }

      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final List<int> dataStore = [];
      await for (var data in media.stream) {
        dataStore.insertAll(dataStore.length, data);
      }

      return dataStore;
    } on NetworkException catch (e) {
      $logger.e('Network error getting Drive file content: $e');
      return null;
    } catch (err) {
      $logger.e(err);
    }
    return null;
  }

  Future<void> saveFileInDrive({required gapis.AccessToken accessToken, required File file}) async {
    try {
      final hasInternet = await _connectivity.hasInternet;
      if (!hasInternet) {
        throw NetworkException('No internet connection available');
      }

      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      final dbFileBytes = await file.readAsBytes();

      final media = drive.Media(file.openRead(), dbFileBytes.length);
      final dateTime = DateTime.now().toUtc();
      final driveFile = drive.File(
        name: 'invesly-${dateTime.millisecondsSinceEpoch}.db',
        modifiedTime: dateTime,
        parents: ['appDataFolder'],
      );
      await driveApi.files.create(driveFile, uploadMedia: media);
    } on NetworkException catch (e) {
      $logger.e('Network error saving file to Drive: $e');
      rethrow;
    } catch (e) {
      if (e is DetailedApiRequestError && e.status == 401) {
        $logger.e('Unauthorized error while creating backup: $e');
      } else if (e is PlatformException) {
        $logger.e('Platform error while creating backup: $e');
      } else {
        $logger.e(e);
      }
      rethrow;
    }
  }

  Future<void> deleteFilesFromDrive(gapis.AccessToken accessToken) async {
    try {
      final files = await getDriveFiles(accessToken);

      if (files == null || files.isEmpty) {
        return;
      }

      // files.forEach((file) async {
      //   await deleteBackup(accessToken: accessToken, fileId: file.id!);
      // });
      Future.wait(files.map((file) => deleteFileFromDrive(accessToken: accessToken, fileId: file.id!)));
    } catch (err) {
      $logger.e(err);
      // openSnackbar(
      //   SnackbarMessage(
      //     title: err.toString(),
      //     icon: Icon(Icons.error_rounded),
      //   ),
      // );
    }
  }

  Future<void> deleteFileFromDrive({required gapis.AccessToken accessToken, required String fileId}) async {
    try {
      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      await driveApi.files.delete(fileId);
    } catch (err) {
      $logger.e(err);
      // openSnackbar(SnackbarMessage(title: err.toString()));
    }
  }
}
