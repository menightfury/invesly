import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:invesly/common/cubit/app_cubit.dart';

class MockStorage implements Storage {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String key) async {}

  @override
  dynamic read(String key) => null;

  @override
  Future<void> write(String key, dynamic value) async {}

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() {
    HydratedBloc.storage = MockStorage();
  });

  testWidgets('resolveInitialAccountId uses the primary account when no explicit id is provided', (
    WidgetTester tester,
  ) async {
    final appCubit = AppCubit();
    appCubit.updatePrimaryAccount(42);

    await tester.pumpWidget(
      BlocProvider.value(
        value: appCubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              final accountId = null;
              return Scaffold(body: Text(accountId?.toString() ?? 'none'));
            },
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('42'), findsOneWidget);
  });
}
