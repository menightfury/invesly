// import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:flutter/foundation.dart';
import 'package:invesly/intro/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:invesly/database/invesly_api.dart';
import 'bloc_observer.dart';
// import 'connectivity/cubit/internet_cubit.dart';
// import 'common/api/settings_api.dart';
// import 'common/repository/settings_repository.dart';

import 'users/cubit/users_cubit.dart';
import 'amcs/model/amc_repository.dart';
import 'transactions/model/transaction_repository.dart';
import 'users/model/user_repository.dart';
import 'common/styles/theme.dart';
import 'common_libs.dart';
import 'settings/cubit/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Bloc.observer = InveslyBlocObserver();

  await Bootstrap.initialize();
  runApp(const InveslyApp());
  // timeDilation = 4.0;
}

class InveslyApp extends StatelessWidget {
  const InveslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Bootstrap.instance.api;
    final userRepository = UserRepository(api);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider(create: (_) => AmcRepository(api)),
        RepositoryProvider(create: (_) => TransactionRepository(api)),
      ],
      child: MultiBlocProvider(
        providers: [
          // BlocProvider<InternetCubit>(create: (_) => InternetCubit()),
          BlocProvider<UsersCubit>(create: (_) => UsersCubit(repository: userRepository)),
          BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView({super.key});

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  // late final StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // _connectivitySubscription =
    //     Connectivity().onConnectivityChanged.listen(context.read<InternetCubit>().updateConnectivityStatus);
  }

  @override
  void dispose() {
    // _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    // BlocListener<InternetCubit, InternetState>(
    //   listener: (context, state) {
    //     $logger.d(state);
    //   },
    //   child:
    BlocSelector<SettingsCubit, SettingsState, bool>(
      selector: (state) => state.isDarkMode,
      builder: (context, isDarkMode) {
        $logger.i('Material app rebuilds 😟.');

        return MaterialApp(
          title: 'Expense Manager',
          debugShowCheckedModeBanner: false,
          // routerConfig: AppRouter.router,
          theme: AppStyle.instance.lightTheme,
          darkTheme: AppStyle.instance.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
      // ),
    );
  }
}

class Bootstrap {
  final InveslyApi api;

  // preventing from calling the class
  const Bootstrap._(this.api);

  static Bootstrap? _instance;
  static Bootstrap get instance {
    assert(_instance != null, 'No instance found, please make sure to initialize before getting instance');
    return _instance!;
  }

  static Future<Bootstrap> initialize() async {
    if (_instance != null) return _instance!;

    // Default error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    // declare directory where both the databases will be stored
    final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    // Initialize hydrated storage (i.e. hive database) in that declared directory.
    // However, no need to specify hive db name separately, because `HydratedStorage` already
    // specified the name as `hydrated_box`
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb ? HydratedStorageDirectory.web : HydratedStorageDirectory(directory.path),
    );

    // Initialize local storage i.e. sqlite
    final api = await InveslyApi.initialize(directory);
    return _instance = Bootstrap._(api);
  }
}
