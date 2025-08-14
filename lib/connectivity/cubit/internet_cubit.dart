import 'package:invesly/common_libs.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  InternetCubit() : super(InternetInitialState());

  // void _handleSignIn(BuildContext context) {
  //   // loadingIndeterminateKey.currentState?.setVisibility(true); // Loading progress bar at bottom
  //   openLoadingPopupTryCatch(
  //     () async {
  //       // Can maybe use this function, but on web first login does not sync...
  //       // Let's just use the functionality below this
  //       // await signInAndSync(context, next: () {});

  //       await signInGoogle(context: context);
  //       if (appStateSettings["username"] == "" && googleUser != null) {
  //         updateSettings("username", googleUser?.displayName ?? "", pagesNeedingRefresh: [0], updateGlobalState: false);
  //       }
  //       // If user has sync backups, but no real backups it will show up here
  //       // For now disable restoring of a backup popup, the sync backups will be restored automatically using the function call below
  //       // var result;
  //       // List<drive.File>? files = (await getDriveFiles()).$2;
  //       // if ((files?.length ?? 0) > 0) {
  //       //   result = await openPopup(
  //       //     context,
  //       //     icon: appStateSettings["outlinedIcons"] ? Icons.cloud_sync_outlined : Icons.cloud_sync_rounded,
  //       //     title: "backup-found".tr(),
  //       //     description: "backup-found-description".tr(),
  //       //     onSubmit: () {
  //       //       popRoute(context, true);
  //       //     },
  //       //     onCancel: () {
  //       //       popRoute(context, false);
  //       //     },
  //       //     onSubmitLabel: "restore".tr(),
  //       //     onCancelLabel: "cancel".tr(),
  //       //   );
  //       // }
  //       // if (result == true) {
  //       //   chooseBackup(context, hideDownloadButton: true);
  //       // } else if (result == false && googleUser != null) {
  //       //   openLoadingPopup(context);
  //       //   // set this to true so cloud functions run
  //       //   entireAppLoaded = true;
  //       //   await runAllCloudFunctions(
  //       //     context,
  //       //     forceSignIn: true,
  //       //   );
  //       //   popRoute(context);
  //       //   nextNavigation();
  //       // }
  //       // else {
  //       //   nextNavigation();
  //       // }

  //       // set this to true so cloud functions run
  //       entireAppLoaded = true;
  //       await runAllCloudFunctions(context, forceSignIn: true);

  //       nextNavigation();
  //       // loadingIndeterminateKey.currentState?.setVisibility(false);
  //     },
  //     onError: (e) {
  //       print("Error signing in: " + e.toString());
  //       // loadingIndeterminateKey.currentState?.setVisibility(false);
  //     },
  //   );
  // }
}
