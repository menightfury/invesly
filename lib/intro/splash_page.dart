import 'dart:async';
import 'package:invesly/common_libs.dart';
import 'package:invesly/intro/intro_page.dart';
import 'package:invesly/main.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final Timer _timer;
  // late final Completer _completer;

  @override
  void initState() {
    super.initState();
    final settingsState = context.read<SettingsCubit>().state;

    // _completer = Completer();
    // show splash screen for few seconds
    // _timer = Timer(2.seconds, () => _completer.complete());
    _timer = Timer(2.seconds, () async {
      if (!settingsState.isOnboarded) {
        context.go(const IntroPage());
        return;
      }

      // if (settingsState.currentUser == null) {
      //   LoginPage.showModal(context);
      //   return;
      // }
      // Load database
      await Bootstrap.instance.api.initializeDatabase();
      if (!mounted) {
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
    // final settingsState = context.read<SettingsCubit>().state;

    return Scaffold(
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
                  Gap(12.0),
                  Text('Invesly', style: textTheme.headlineMedium),
                  Gap(4.0),
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
