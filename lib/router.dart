// // ignore_for_file: avoid_print

// class AppRouter {
//   // preventing from creating an instance of this class
//   AppRouter._();

//   // ~~~ GoRouter implementation ~~~
//   static const String test = '/test';
//   static const String splash = '/';
//   static const String intro = '/intro';
//   static const String editProfile = '/edit_profile';
//   static const String dashboard = '/dashboard'; // requires at least one user
//   static String amcDetails(String id) => '/amc/$id'; // requires at least one user
//   static const String editTransaction = '/edit_transaction'; // requires at least one user
//   static const String editAmc = '/edit_amc';
//   static const String settings = '/settings';
//   static const String error = '/error'; // ??

//   static final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

//   // Routing table, matches string paths to UI Screens
//   static final _router = GoRouter(
//     navigatorKey: _rootKey,
//     redirect: _handleRedirect,
//     debugLogDiagnostics: true,
//     initialLocation: dashboard,
//     routes: <RouteBase>[
//       AppRoute(splash, (_) => const SplashScreen()),
//       AppRoute(intro, (_) => const IntroScreen()),
//       AppRoute(editProfile, (state) => EditProfileScreen(initialProfile: state.extra as InveslyProfile?)),
//       AppRoute(dashboard, (_) => const DashboardScreen()),
//       AppRoute(amcDetails(':id'), (state) => AmcOverviewScreen(state.pathParameters['id']!)),
//       AppRoute(editAmc, (state) => EditAmcScreen(initialAmc: state.extra as InveslyAmc?)),
//       AppRoute(
//         editTransaction,
//         (state) => EditTransactionScreen(initialTransaction: state.extra as InveslyTransaction?),
//       ),
//       AppRoute(settings, (_) => const SettingsScreen()),
//       AppRoute(error, (_) => const ErrorScreen()),
//     ],
//   );

//   static GoRouter get router => _router;
//   static String? get initialDeeplink => _initialDeeplink;
//   static String? _initialDeeplink;

//   static FutureOr<String?> _handleRedirect(BuildContext context, GoRouterState state) {
//     final settingState = context.read<SettingsCubit>().state;
//     final userState = context.read<UsersCubit>().state;

//     final initializing = state.uri.path == splash;
//     final onboarding = state.uri.path == intro;

//     if (userState is UsersErrorState && state.uri.path != error) {
//       return error;
//     }

//     if (userState is UsersInitialState) {
//       if (!initializing) {
//         _initialDeeplink ??= state.uri.path;
//         $logger.i('1. Redirecting from $_initialDeeplink to $splash');
//         return splash;
//       }
//       return null;
//     }

//     if (!settingState.isOnboarded) {
//       if (!onboarding) {
//         $logger.i('2. Redirecting from ${state.uri.path} to $intro');
//         return intro;
//       }
//       return null;
//     }

//     if (userState is UsersLoadedState && userState.hasNoUser) {
//       if (state.uri.path != editUser) {
//         $logger.i('3. Redirecting from ${state.uri.path} to $editUser');
//         return editUser;
//       }
//       return null;
//     }

//     if (initializing || onboarding) {
//       $logger.i('4. Redirecting from ${state.uri.path} to ${_initialDeeplink ?? dashboard}');
//       return _initialDeeplink ?? dashboard;
//     }

//     return null;
//   }
// }

// // ~~~ Custom GoRoute sub-class ~~~
// class AppRoute extends GoRoute {
//   AppRoute(String path, Widget Function(GoRouterState st) builder, [GlobalKey<NavigatorState>? parentNavigatorKey])
//     : super(
//         path: path,
//         parentNavigatorKey: parentNavigatorKey,
//         pageBuilder: (context, state) {
//           // default Scaffold removed to enable more control, like AppBar and FAB
//           final Widget content = builder(state);

//           // if (fade) {
//           //   return CustomTransitionPage(
//           //     key: state.pageKey,
//           //     child: pageContent,
//           //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           //       return FadeTransition(opacity: animation, child: child);
//           //     },
//           //   );
//           // }

//           return MaterialPage(key: state.pageKey, child: content);
//         },
//       );

//   // final bool fade;
// }
