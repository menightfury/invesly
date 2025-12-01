// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis_auth/googleapis_auth.dart';
// import 'package:invesly/authentication/user_model.dart';
// import 'package:invesly/common/presentations/widgets/popups.dart';
// import 'package:invesly/authentication/auth_repository.dart';
// import 'package:invesly/common_libs.dart';
// import 'package:invesly/common/cubit/app_cubit.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key, this.onLoginComplete});

//   /// onLoginComplete returns either InveslyUser (if sign-in with Google is chosen & successful)
//   /// or InveslyUser.empty() (if without sign-in is chosen) or Null
//   final ValueChanged<InveslyUser?>? onLoginComplete;

//   @override
//   Widget build(BuildContext context) {
//     return _LoginPage(key: key, onLoginComplete: onLoginComplete);
//   }

//   static Future<InveslyUser?> showModal(BuildContext context, {Key? key}) async {
//     return await showModalBottomSheet<InveslyUser>(
//       context: context,
//       useSafeArea: true,
//       builder: (context) {
//         return _LoginPage(key: key, showInModal: true, onLoginComplete: (user) => context.pop(user));
//       },
//     );
//   }
// }

// class _LoginPage extends StatefulWidget {
//   const _LoginPage({super.key, this.showInModal = false, this.onLoginComplete});

//   final bool showInModal;
//   final ValueChanged<InveslyUser?>? onLoginComplete;

//   @override
//   State<_LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<_LoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     Widget content = Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         spacing: 4.0,
//         children: <Widget>[
//           // Welcome text
//           SizedBox.square(dimension: 80.0, child: Image.asset('assets/images/app_icon/app_icon.png')),
//           Text('Welcome to Invesly!', style: context.textTheme.headlineMedium),
//           Text(
//             'Keep your data backed up and synced with Google Drive',
//             style: context.textTheme.labelMedium?.copyWith(color: Colors.grey),
//           ),
//           Spacer(),

//           // Sign in button
//           // Sign-in callback returns User
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () => _onSignInPressed(context),
//               icon: CircleAvatar(radius: 16.0, backgroundImage: AssetImage('assets/images/google_logo.png')),
//               label: Text('Sign in with Google', textAlign: TextAlign.center),
//             ),
//           ),
//           Gap(2.0),
//           // Without sign-in return User.empty()
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: () => _onWithoutSignInPressed(context),
//               child: Text('Continue without sign in', textAlign: TextAlign.center),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (!widget.showInModal) {
//       content = Scaffold(
//         appBar: AppBar(title: Text('Login with google')),
//         body: SafeArea(child: content),
//       );
//     }

//     return content;
//   }

//   Future<void> _onSignInPressed(BuildContext context) async {
//     final (user, _) = await LoginPage.startLoginFlow(context);
//     if (!context.mounted) return;
//     widget.onLoginComplete?.call(InveslyUser.fromGoogleSignInAccount(user));
//   }

//   void _onWithoutSignInPressed(BuildContext context) {
//     widget.onLoginComplete?.call(InveslyUser.empty());
//   }
// }
