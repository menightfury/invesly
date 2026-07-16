import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'accounts/cubit/accounts_cubit.dart';
import 'accounts/model/account_repository.dart';
import 'amcs/model/amc_repository.dart';
import 'authentication/auth_repository.dart';
import 'bloc_observer.dart';
import 'common/cubit/app_cubit.dart';
import 'common/presentations/styles/theme.dart';
import 'common_libs.dart';
import 'database/backup/backup_repository.dart';
import 'database/invesly_api.dart';
import 'intro/splash_page.dart';
import 'stat/cubit/stat_cubit.dart';
import 'stat/model/stat_repository.dart';
import 'transactions/model/transaction_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     systemNavigationBarColor: Colors.transparent, // Make bar transparent
  //     systemNavigationBarDividerColor: Colors.transparent,
  //   ),
  // );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Bloc.observer = InveslyBlocObserver();
  await Bootstrap.initialize();

  runApp(const InveslyApp());
}

class InveslyApp extends StatelessWidget {
  const InveslyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = Bootstrap.instance.api;
    // initialize all repositories here
    AuthRepository.initialize();
    BackupRepository.initialize(api);
    final accountRepository = AccountRepository.initialize(api);
    AmcRepository.initialize(api);
    TransactionRepository.initialize(api);
    final statRepository = StatRepository.initialize(api);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountsCubit>(create: (_) => AccountsCubit(repository: accountRepository)..fetchAccounts()),
        BlocProvider<AppCubit>(create: (_) => AppCubit()),
        BlocProvider(create: (_) => StatCubit(repository: statRepository)..fetchAllStats()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) {
        return previous.isDarkMode != current.isDarkMode ||
            previous.isDynamicColor != current.isDynamicColor ||
            previous.accentColor != current.accentColor;
      },
      builder: (context, state) {
        $logger.e('Material app rebuilds 😟.');

        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final lightScheme = state.isDynamicColor && lightDynamic != null
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(seedColor: Color(state.accentColor ?? 0xFF413D32), brightness: Brightness.light);
            final darkScheme = state.isDynamicColor && darkDynamic != null
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(seedColor: Color(state.accentColor ?? 0xFFF1E8D9), brightness: Brightness.dark);
            return MaterialApp(
              title: 'Invesly',
              debugShowCheckedModeBanner: false,
              theme: AppStyle.instance.getTheme(lightScheme),
              darkTheme: AppStyle.instance.getTheme(darkScheme),
              themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const SplashPage(),
            );
          },
        );
      },
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
    final api = InveslyApi(directory);
    return _instance = Bootstrap._(api);
  }
}
