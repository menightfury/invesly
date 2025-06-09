import 'dart:async';

import 'package:invesly/intro/intro_screen.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';
import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/users/edit_user/view/edit_user_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer;
  late final Completer _completer;

  @override
  void initState() {
    super.initState();
    context.read<UsersCubit>().fetchUsers();
    _completer = Completer();
    // show splash screen for few seconds
    _timer = Timer(3.seconds, () => _completer.complete());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.color;
    final settingsState = context.read<SettingsCubit>().state;

    return BlocListener<UsersCubit, UsersState>(
      listener: (context, usersState) async {
        if (usersState is UsersLoadedState) {
          await _completer.future; // show tips message in splash screen for few seconds
          if (!context.mounted) return;

          // If the user is not onboarded, go to IntroScreen
          if (!settingsState.isOnboarded) {
            context.go(const IntroScreen());
            return;
          }

          // If there are no users, go to EditUserScreen
          if (usersState.hasNoUser) {
            context.go(const EditUserScreen());
            return;
          }

          // If there are users but currentUserId is null, set the first user as current user
          if (settingsState.currentUserId == null) {
            context.read<SettingsCubit>().saveCurrentUser(usersState.users.first.id);
            // go to initial requested screen or dashboard
            // context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
          }
          context.go(const DashboardScreen());
        } else if (usersState is UsersErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: context.color.errorContainer,
              content: Text(
                'Error loading users: ${usersState.errorMsg}',
                style: TextStyle(color: context.color.onErrorContainer),
              ),
            ),
          );
        }
      },
      child: Scaffold(
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
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: colorScheme.primary)),
                          TextSpan(text: ' and the '),
                          TextSpan(text: 'Terms of Use', style: TextStyle(color: colorScheme.primary)),
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
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
