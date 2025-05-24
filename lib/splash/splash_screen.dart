import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/common_libs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UsersCubit>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UsersCubit, UsersState>(
      listener: (context, state) {
        $logger.d(state);
        if (state is UsersLoadedState) {
          if (state.hasNoUser) {
            context.go(AppRouter.editUser);
          } else {
            context.go(AppRouter.initialDeeplink ?? AppRouter.dashboard);
          }
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Icon(Icons.gesture_rounded), SizedBox(height: 12.0), Text('New Splash screen!')],
            ),
          ),
        ),
      ),
    );
  }
}
