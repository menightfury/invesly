import 'package:http/http.dart' as http;
import 'package:invesly/common_libs.dart';
import 'package:invesly/connectivity/connectivity_extension.dart';

class InternetAwareHttpClient extends http.BaseClient {
  InternetAwareHttpClient() : _inner = http.Client(), _connectivity = Connectivity();

  final http.Client _inner;
  final Connectivity _connectivity;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final hasInternet = await _connectivity.hasInternet;
      if (!hasInternet) {
        throw NetworkException('No internet connection available');
      }

      $logger.i('${request.method} ${request.url}');
      return await _inner.send(request);
    } on http.ClientException catch (e) {
      $logger.e('HTTP Client Error: $e');
      rethrow;
    } catch (e) {
      $logger.e('Network Error: $e');
      rethrow;
    }
  }
}

class NetworkException implements Exception {
  NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
