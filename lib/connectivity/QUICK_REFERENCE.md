# Internet Connectivity Package - Quick Reference

## Quick Start

### Check Connectivity
```dart
final service = InternetConnectivityService();
bool connected = await service.hasInternetConnection();
```

### Make HTTP Request with Connectivity Check
```dart
final client = InternetAwareHttpClient();
try {
  final response = await client.get(Uri.parse(url));
} on NetworkException {
  print('No internet connection');
}
```

### Listen to Connectivity Changes
```dart
InternetConnectivityService().connectivityStream.listen((isConnected) {
  print('Connected: $isConnected');
});
```

### Check in UI (BLoC)
```dart
BlocListener<InternetCubit, InternetState>(
  listener: (context, state) {
    if (state is InternetFailureState) {
      showSnackBar('No connection');
    }
  },
)
```

---

## Common Scenarios

### Scenario 1: API Call with Fallback to Cache
```dart
Future<List<Item>> getItems() async {
  try {
    final client = InternetAwareHttpClient();
    final response = await client.get(Uri.parse('https://api.example.com/items'));
    return parseItems(response.body);
  } on NetworkException {
    return await getCachedItems();
  }
}
```

### Scenario 2: Retry on Network Failure
```dart
Future<T> retryOnNetworkFailure<T>(Future<T> Function() operation) async {
  int attempts = 0;
  while (attempts < 3) {
    try {
      return await operation();
    } on NetworkException {
      attempts++;
      if (attempts >= 3) rethrow;
      await Future.delayed(Duration(seconds: attempts * 2));
    }
  }
  throw Exception('Max retries exceeded');
}
```

### Scenario 3: Show Offline Banner
```dart
@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      YourMainWidget(),
      BlocBuilder<InternetCubit, InternetState>(
        builder: (context, state) {
          if (state is InternetFailureState) {
            return Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red,
                child: Text('Offline Mode'),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    ],
  );
}
```

### Scenario 4: Sync Data When Connection Restored
```dart
void setupSyncOnReconnect() {
  InternetConnectivityService().connectivityStream.listen((isConnected) {
    if (isConnected) {
      syncPendingOperations();
    }
  });
}
```

---

## Error Handling Patterns

### Pattern 1: Specific Error Handling
```dart
try {
  final response = await client.get(url);
} on NetworkException catch (e) {
  // No internet
} on SocketException catch (e) {
  // Socket error
} on http.ClientException catch (e) {
  // HTTP error
}
```

### Pattern 2: Graceful Degradation
```dart
Future<Data> getData() async {
  try {
    return await fetchFresh();
  } on NetworkException {
    return fetchStale(); // Return cached/old data
  }
}
```

### Pattern 3: User Feedback
```dart
Future<void> uploadData(BuildContext context) async {
  try {
    await _uploadOperation();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Upload successful')),
    );
  } on NetworkException {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No internet. Will retry when online.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
```

---

## Testing Tips

### Mock Connectivity Service
```dart
class MockConnectivityService extends Mock
    implements InternetConnectivityService {
  @override
  bool get isConnected => true;
  
  @override
  Future<bool> hasInternetConnection() async => true;
}

// In test setup
setUp(() {
  provideDummy(MockConnectivityService());
});
```

### Test Network Error
```dart
test('should handle network error', () async {
  final client = InternetAwareHttpClient(
    connectivityService: MockConnectivityService(),
  );
  
  when(mockService.hasInternetConnection()).thenAnswer((_) async => false);
  
  expect(
    () => client.get(Uri.parse('https://example.com')),
    throwsA(isA<NetworkException>()),
  );
});
```

---

## Important Constants

| Item                           | Value                              |
| ------------------------------ | ---------------------------------- |
| Connectivity check timeout     | 3 seconds                          |
| Internet verification endpoint | google.com                         |
| Network exception message      | `No internet connection available` |

---

## Files to Reference

| Purpose              | File                                                          |
| -------------------- | ------------------------------------------------------------- |
| Implementation guide | `lib/connectivity/CONNECTIVITY_GUIDE.md`                      |
| Code examples        | `lib/connectivity/examples.dart`                              |
| Service class        | `lib/connectivity/service/internet_connectivity_service.dart` |
| HTTP client          | `lib/connectivity/client/internet_aware_http_client.dart`     |
| BLoC                 | `lib/connectivity/cubit/internet_cubit.dart`                  |

---

## Do's and Don'ts

### ✅ DO
- Check connectivity before critical operations
- Use `InternetAwareHttpClient` for all API calls
- Handle `NetworkException` in try-catch blocks
- Listen to connectivity stream for UI updates
- Log network errors for debugging

### ❌ DON'T
- Create multiple `InternetConnectivityService` instances (use singleton)
- Ignore network errors silently
- Use raw `http.Client()` directly
- Make assumptions about connectivity
- Block UI thread for connectivity checks

---

## Troubleshooting

### Issue: "No internet connection" always shown
**Solution:** Check if device actually has internet. Connectivity check verifies both network and internet.

### Issue: Too many connectivity checks
**Solution:** Use the service singleton instead of creating new instances.

### Issue: Stale connectivity status
**Solution:** Listen to `connectivityStream` instead of checking once.

### Issue: HTTP timeout instead of network error
**Solution:** Ensure `InternetAwareHttpClient` is used and connectivity is checked.

---

## Migration Checklist

If migrating existing code to use this package:

- [ ] Replace `http.Client()` with `InternetAwareHttpClient()`
- [ ] Add try-catch for `NetworkException`
- [ ] Add connectivity check before critical operations
- [ ] Update error handling in repositories
- [ ] Add UI feedback for offline state
- [ ] Test with internet disabled
- [ ] Add logger calls for network errors
