// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:invesly/common_libs.dart';

extension ConnectivityX on Connectivity {
  Future<bool> get hasInternet async {
    try {
      if (kIsWeb) return true;

      final result = await checkConnectivity();
      if (result.any((r) => r == ConnectivityResult.mobile || r == ConnectivityResult.wifi)) {
        return true;
      }

      return false;
    } catch (e) {
      $logger.e('Error checking internet connection: $e');
      rethrow;
    }
  }
}

// class InternetConnectivityService {
//   // Singleton pattern
//   static final InternetConnectivityService _instance = InternetConnectivityService._internal();

//   factory InternetConnectivityService() => _instance;

//   InternetConnectivityService._internal() {
//     _connectivity = Connectivity();
//     _initConnectivityStream();
//   }

//   late final Connectivity _connectivity;
//   bool _isConnected = true;

//   bool get isConnected => _isConnected;

//   Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged.map((result) {
//     final isConnected = result != ConnectivityResult.none;
//     _isConnected = isConnected;
//     return isConnected;
//   });

//   void _initConnectivityStream() {
//     connectivityStream.listen((isConnected) {
//       _isConnected = isConnected;
//       $logger.i('Internet connectivity changed: $isConnected');
//     });
//   }

//   Future<bool> hasInternetConnection() async {
//     try {
//       if (kIsWeb) return _isConnected;

//       final result = await _connectivity.checkConnectivity();
//       if (result == ConnectivityResult.none) {
//         _isConnected = false;
//         return false;
//       }

//       final canReachInternet = await _canReachInternet();
//       _isConnected = canReachInternet;
//       return canReachInternet;
//     } catch (e) {
//       $logger.e('Error checking internet connection: $e');
//       return _isConnected;
//     }
//   }

//   Future<bool> _canReachInternet() async {
//     try {
//       final result = await InternetAddress.lookup(
//         'google.com',
//       ).timeout(const Duration(seconds: 3), onTimeout: () => <InternetAddress>[]);
//       return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
//     } catch (e) {
//       $logger.e('Error reaching internet: $e');
//       return false;
//     }
//   }
// }
