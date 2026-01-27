import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/intro/intro_page.dart';

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

  testWidgets('IntroPage shows Welcome', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppCubit(),
        child: const MaterialApp(home: IntroPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.textContaining('stress-free independence'), findsOneWidget);
  });

  testWidgets('IntroPage navigates to next page', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppCubit(),
        child: const MaterialApp(home: IntroPage()),
      ),
    );

    // Initial state
    expect(find.text('Welcome'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Manage all your accounts'), findsOneWidget);
  });
}
