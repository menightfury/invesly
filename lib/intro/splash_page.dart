import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/intro/intro_page.dart';
import 'package:invesly/main.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/dashboard/view/dashboard_screen.dart';

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
          final amcs = await AmcRepository.instance.fetchAmcsFromNetwork(client, url);
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

      if (!mounted) {
        return;
      }

      if (!appState.isOnboarded) {
        context.go(const IntroPage());
        return;
      }

      // context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
      context.go(const DashboardScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colors;
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ~~~ App Icon, title ~~~
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Material(
                    shape: ContinuousRectangleBorder(
                      side: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      height: 80.0,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Image.asset('assets/images/app_icon/app_icon.png', fit: BoxFit.fill),
                      ),
                    ),
                  ),
                  const Gap(12.0),
                  Text('Invesly', style: textTheme.headlineMedium),
                  const Gap(4.0),
                  Text('Your personal portfolio manager', style: textTheme.bodySmall),
                ],
              ),

              // ~~~ Tips, Terms & conditions ~~~
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 12.0,
                children: <Widget>[
                  Text(
                    'Your data will only be stored on your device, and will be safe as long as you don\'t uninstall the app or change phone. To prevent data loss, it is recommended to make a backup regularly from the app settings.',
                    style: textTheme.bodySmall,
                  ),
                  InveslyDivider(colors: [colorScheme.primaryContainer], thickness: 1.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'By logging in, you agree to the '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        TextSpan(text: ' and the '),
                        TextSpan(
                          text: 'Terms of Use',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                        TextSpan(text: ' of the application'),
                      ],
                      style: textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
