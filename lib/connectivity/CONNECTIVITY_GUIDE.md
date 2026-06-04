# Internet Connectivity Package Guide

## Overview

This package provides a robust solution for handling internet connectivity checks and managing HTTP requests with automatic connectivity verification.

## Components

### 1. InternetConnectivityService
**Location:** `lib/connectivity/service/internet_connectivity_service.dart`

A singleton service that monitors device connectivity and verifies actual internet access.

**Features:**
- Real-time connectivity monitoring via `connectivity_plus`
- Actual internet reachability verification (pings google.com)
- Stream-based connectivity status updates
- Web and native platform support

**Usage:**
```dart
final connectivityService = InternetConnectivityService();

// Check if device has internet connection
bool isConnected = await connectivityService.hasInternetConnection();

// Listen to connectivity changes
connectivityService.connectivityStream.listen((isConnected) {
  print('Connected: $isConnected');
});

// Get current connectivity status
bool current = connectivityService.isConnected;
```

### 2. InternetAwareHttpClient
**Location:** `lib/connectivity/client/internet_aware_http_client.dart`

An HTTP client wrapper that automatically checks internet connectivity before making requests.

**Features:**
- Extends `http.BaseClient`
- Automatic connectivity verification before each request
- Throws `NetworkException` if no connection
- Request logging via logger
- Drop-in replacement for `http.Client()`

**Usage:**
```dart
final client = InternetAwareHttpClient();

try {
  final response = await client.get(Uri.parse('https://example.com/api'));
  // Handle response
} on NetworkException catch (e) {
  print('Network error: $e');
}
```

### 3. InternetCubit
**Location:** `lib/connectivity/cubit/internet_cubit.dart`

BLoC for managing internet connectivity state in the app.

**Features:**
- Emits `InternetSuccessState` when connected
- Emits `InternetFailureState` when disconnected
- Continuous monitoring of connectivity changes
- Methods to check and query connectivity status

**Usage:**
```dart
// In UI
context.read<InternetCubit>().checkConnectivity();

// Listen to state changes
BlocListener<InternetCubit, InternetState>(
  listener: (context, state) {
    if (state is InternetFailureState) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection')),
      );
    }
  },
  child: YourWidget(),
);

// Check current status
bool isConnected = context.read<InternetCubit>().isConnected;
```

## Integration Points

### AMC Repository
- **File:** `lib/amcs/model/amc_repository.dart`
- **Changes:** Updated to use `InternetAwareHttpClient`
- **Methods:**
  - `getAmcsFromNetwork()` - Now checks connectivity before fetching AMCs
  - `getLatestPrice()` - Verifies connection before fetching price data

### Authentication Repository
- **File:** `lib/authentication/auth_repository.dart`
- **Changes:** Integrated connectivity checks before API calls
- **Methods:**
  - `signInWithGoogle()` - Checks connectivity before authentication
  - `getDriveApi()` - Uses `InternetAwareHttpClient` with Drive API
  - `getDriveFiles()` - Verifies connection before fetching files
  - `getDriveFileContent()` - Checks connectivity before downloading
  - `saveFileInDrive()` - Verifies connection before uploading

## Network Exception Handling

All network-related failures throw `NetworkException`:

```dart
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
```

**Catch it explicitly:**
```dart
try {
  await client.get(Uri.parse('https://example.com'));
} on NetworkException catch (e) {
  // Handle no connection
} on SocketException catch (e) {
  // Handle socket errors
}
```

## Best Practices

1. **Always check connectivity before critical operations**
   ```dart
   final service = InternetConnectivityService();
   if (await service.hasInternetConnection()) {
     // Proceed with API call
   }
   ```

2. **Use InternetAwareHttpClient for all HTTP calls**
   ```dart
   // Good
   final client = InternetAwareHttpClient();
   
   // Avoid
   final client = http.Client();
   ```

3. **Listen to connectivity changes in your UI**
   ```dart
   BlocListener<InternetCubit, InternetState>(
     listener: (context, state) {
       // Show appropriate message to user
     },
   )
   ```

4. **Handle NetworkException gracefully**
   ```dart
   try {
     final response = await client.get(uri);
   } on NetworkException {
     // Show offline message
   }
   ```

## Dependencies

The following packages are required (already in pubspec.yaml):
- `connectivity_plus: ^7.0.0` - Connectivity monitoring
- `http: ^1.5.0` - HTTP client
- `flutter_bloc: ^9.1.1` - State management

## Migration Guide

### Before (Direct HTTP calls):
```dart
final client = http.Client();
final response = await client.get(Uri.parse(url));
```

### After (With connectivity checks):
```dart
final client = InternetAwareHttpClient();
try {
  final response = await client.get(Uri.parse(url));
} on NetworkException catch (e) {
  // Handle no connection
}
```

## Testing

When testing, you can mock the connectivity service:

```dart
class MockInternetConnectivityService extends Mock
    implements InternetConnectivityService {
  @override
  bool get isConnected => true;
}

// In test setup
getIt.registerSingleton<InternetConnectivityService>(
  MockInternetConnectivityService(),
);
```
