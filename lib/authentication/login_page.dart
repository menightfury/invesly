// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:shimmer/shimmer.dart';

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/cubit/auth_cubit.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(); // TODO: Remove authRepository

    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (context) => AuthCubit(repository: authRepository),
        child: const _LoginScreen(),
      ),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({super.key});

  @override
  State<_LoginScreen> createState() => __LoginScreenState();
}

class __LoginScreenState extends State<_LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: <Widget>[
          // Welcome text
          Text('Welcome to Invesly!', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
          Text('Let’s login for explore continues', style: context.textTheme.labelMedium?.copyWith(color: Colors.grey)),
          Spacer(),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleSignIn(context),
              icon: CircleAvatar(
                radius: 20.0,
                child: SvgPicture.string(
                  '<svg viewBox="11.0 11.0 22.92 22.92" ><path transform="translate(11.0, 11.0)" d="M 22.6936149597168 9.214142799377441 L 21.77065277099609 9.214142799377441 L 21.77065277099609 9.166590690612793 L 11.45823860168457 9.166590690612793 L 11.45823860168457 13.74988651275635 L 17.93386268615723 13.74988651275635 C 16.98913192749023 16.41793632507324 14.45055770874023 18.33318138122559 11.45823860168457 18.33318138122559 C 7.661551475524902 18.33318138122559 4.583295345306396 15.25492572784424 4.583295345306396 11.45823860168457 C 4.583295345306396 7.661551475524902 7.661551475524902 4.583295345306396 11.45823860168457 4.583295345306396 C 13.21077632904053 4.583295345306396 14.80519008636475 5.244435787200928 16.01918983459473 6.324374675750732 L 19.26015281677246 3.083411931991577 C 17.21371269226074 1.176188230514526 14.47633838653564 0 11.45823860168457 0 C 5.130426406860352 0 0 5.130426406860352 0 11.45823860168457 C 0 17.78605079650879 5.130426406860352 22.91647720336914 11.45823860168457 22.91647720336914 C 17.78605079650879 22.91647720336914 22.91647720336914 17.78605079650879 22.91647720336914 11.45823860168457 C 22.91647720336914 10.68996334075928 22.83741569519043 9.940022468566895 22.6936149597168 9.214142799377441 Z" fill="#ffc107" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(12.32, 11.0)" d="M 0 6.125000953674316 L 3.764603137969971 8.885863304138184 C 4.78324031829834 6.363905429840088 7.250198841094971 4.583294868469238 10.13710117340088 4.583294868469238 C 11.88963890075684 4.583294868469238 13.48405265808105 5.244434833526611 14.69805240631104 6.324373722076416 L 17.93901443481445 3.083411693572998 C 15.89257335662842 1.176188111305237 13.15520095825195 0 10.13710117340088 0 C 5.735992908477783 0 1.919254422187805 2.484718799591064 0 6.125000953674316 Z" fill="#ff3d00" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(12.26, 24.78)" d="M 10.20069408416748 9.135653495788574 C 13.16035556793213 9.135653495788574 15.8496036529541 8.003005981445312 17.88286781311035 6.161093711853027 L 14.33654403686523 3.160181760787964 C 13.14749050140381 4.064460277557373 11.69453620910645 4.553541660308838 10.20069408416748 4.55235767364502 C 7.220407009124756 4.55235767364502 4.689855575561523 2.6520094871521 3.736530303955078 0 L 0 2.878881216049194 C 1.896337866783142 6.589632034301758 5.747450828552246 9.135653495788574 10.20069408416748 9.135653495788574 Z" fill="#4caf50" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(22.46, 20.17)" d="M 11.23537635803223 0.04755179211497307 L 10.31241607666016 0.04755179211497307 L 10.31241607666016 0 L 0 0 L 0 4.583295345306396 L 6.475625038146973 4.583295345306396 C 6.023715496063232 5.853105068206787 5.209692478179932 6.962699413299561 4.134132385253906 7.774986743927002 L 4.135851383209229 7.773841857910156 L 7.682177066802979 10.77475357055664 C 7.431241512298584 11.00277233123779 11.45823955535889 8.020766258239746 11.45823955535889 2.291647672653198 C 11.45823955535889 1.523372769355774 11.37917804718018 0.773431122303009 11.23537635803223 0.04755179211497307 Z" fill="#1976d2" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                  width: 22.92,
                  height: 22.92,
                ),
              ),
              label: Text('Sign in with Google', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Login with google')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                // final authorization = _authorization;
                if (state is AuthLoadingState) {
                  return const CircularProgressIndicator();
                }

                if (state is AuthErrorState) {
                  return Column(
                    children: <Widget>[
                      Text(state.message),
                      ElevatedButton(
                        onPressed: context.read<AuthCubit>().signin,
                        child: const Text('Sign in with Google'),
                      ),
                    ],
                  );
                }

                if (state is AuthenticatedState) {
                  final user = state.user;
                  // Save current user
                  context.read<SettingsCubit>().saveCurrentUser(InveslyUser.fromGoogleSignInAccount(user));
                  context.read<SettingsCubit>().saveGapiAccessToken(state.accessToken);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      ListTile(
                        leading: GoogleUserCircleAvatar(identity: user),
                        title: Text(user.displayName ?? ''),
                        subtitle: Text(user.email),
                      ),
                      const Text('Signed in successfully.'),

                      ElevatedButton(
                        onPressed: () async {
                          final files = await context.read<AuthRepository>().getDriveFiles(state.accessToken);
                          $logger.i(files);
                          // if files is not null and not empty, copy the latest backup file in the device,
                          // After copying, navigate to DashboardScreen
                          if (mounted) {
                            context.go(DashboardScreen());
                          }
                        },
                        child: const Text('Load Files'),
                      ),

                      ElevatedButton(onPressed: context.read<AuthCubit>().signout, child: const Text('Sign out')),
                    ],
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text('You are not currently signed in.'),
                    ElevatedButton(onPressed: context.read<AuthCubit>().signin, child: const Text('SIGN IN')),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSignIn(BuildContext context) async {
    // final ctx = context;

    final repository = context.read<AuthRepository>();
    openLoadingPopup(context);

    final user = await repository.signInWithGoogle();
    if (user != null) {
      final accessToken = await repository.getAccessToken(user);

      // Save access token to device
      if (!context.mounted) return;
      context.read<SettingsCubit>().saveGapiAccessToken(accessToken);

      // Get Google Drive files
      final files = await repository.getDriveFiles(accessToken);
      $logger.i(files);
      if (files != null && files.isNotEmpty) {
        // Copy the latest backup file to the device
        final latestFile = files.first;
        await repository.saveDriveFileToDevice();
      }
    }
  }
}

class LoadingShimmerDriveFiles extends StatelessWidget {
  const LoadingShimmerDriveFiles({super.key, required this.isManaging, required this.i});

  final bool isManaging;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // period: Duration(milliseconds: (1000 + randomDouble[i % 10] * 520).toInt()),
      period: Duration(milliseconds: (1000 + 0.5 * 520).toInt()),
      baseColor: Theme.of(context).colorScheme.secondaryContainer,
      highlightColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 8.0),
        child: Tappable(
          onTap: () {},
          // borderRadius: 15,
          // color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
          content: Container(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.description_rounded, color: Theme.of(context).colorScheme.secondary, size: 30),
                      SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.all(Radius.circular(5)),
                                color: Colors.white,
                              ),
                              height: 20,
                              // width: 70 + randomDouble[i % 10] * 120 + 13,
                              width: 70 + 0.5 * 120 + 13,
                            ),
                            SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadiusDirectional.all(Radius.circular(5)),
                                color: Colors.white,
                              ),
                              height: 14,
                              // width: 90 + randomDouble[i % 10] * 120,
                              width: 90 + 0.9 * 120,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 13),
                isManaging
                    ? Row(
                        children: [
                          IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
                          SizedBox(width: 5),
                          IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
