import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/restore_drive_backup_page.dart';
import 'package:invesly/intro/intro_page.dart';
import 'package:invesly/main.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final Timer _timer;
  late final Completer<void> _completer;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppCubit>().state;

    _completer = Completer<void>();
    // show splash screen for at least 2 seconds
    _timer = Timer(2.seconds, () => _completer.complete());

    Future.wait<void>([_completer.future, Bootstrap.instance.api.initializeDatabase()]).then((_) async {
      // check amc status is latest or not
      final client = http.Client();
      final response = await client.get(
        Uri.parse('https://api.github.com/repos/menightfury/invesly-data/contents/amcs.json'),
      );

      // If the server did return a 200 OK response, parse the JSON.
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final sha = decoded['sha'] as String?;
        final url = decoded['download_url'] as String?;
        if (sha != null && sha != appState.amcSha && url != null) {
          // If sha is not same, it means amcs in remote location have changed
          // Fetch and update amcs
          final amcs = await AmcRepository.instance.getAmcsFromNetwork(client, url);
          $logger.w(amcs);
          // write amcs to database
          if (amcs != null && amcs.isNotEmpty) {
            await AmcRepository.instance.saveAmcs(amcs);
          }
          if (!mounted) {
            return;
          }
          // update amc sha in app state
          context.read<AppCubit>().updateAmcSha(sha);
        }
      }

      if (!mounted) return;

      if (!appState.isOnboarded) {
        context.go(const IntroPage());
      } else if (appState.user.isNotNullOrEmpty && appState.lastRestoreDate == null) {
        context.go(const RestoreDriveBackupPage());
      } else {
        context.go(const DashboardPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colors;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Branding
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    PhysicalModel(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8.0),
                      clipBehavior: Clip.hardEdge,
                      color: colorScheme.primaryContainer,
                      child: SizedBox(
                        height: 120.0,
                        width: 120.0,
                        child: Image.asset('assets/images/app_icon/app_icon.png', fit: BoxFit.cover),
                      ),
                    ),
                    const Gap(24.0),
                    Text(
                      'Invesly',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Gap(8.0),
                    Text(
                      'Your personal portfolio manager',
                      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8.0,
                children: <Widget>[
                  Text(
                    'Your data will only be stored on your device, and will be safe as long as you don\'t uninstall the app or change phone.',
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'To prevent data loss, it is recommended to make a backup regularly from the app settings.',
                    style: textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                  InveslyDivider(colors: [colorScheme.primaryContainer], thickness: 1.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'By continuing, you agree to our '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Terms of Use',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                      style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
