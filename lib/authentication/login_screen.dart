// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:googleapis/drive/v3.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/cubit/auth_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

// import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/people/v1.dart';
// import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

final scopes = <String>[
  // See https://github.com/flutter/flutter/issues/155490 and https://github.com/flutter/flutter/issues/155429
  // Once an account is logged in with these scopes, they are not needed
  // So we will keep these to apply for all users to prevent errors, especially on silent sign in
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/userinfo.email',
  DriveApi.driveAppdataScope,
  DriveApi.driveFileScope,
];

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthenticationCubit(repository: AuthenticationRepository()),
      child: const _LoginScreen(),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({super.key});

  @override
  State<_LoginScreen> createState() => __LoginScreenState();
}

class __LoginScreenState extends State<_LoginScreen> {
  late Future<void> _signInInitialized;
  GoogleSignInAccount? _currentUser;
  // GoogleSignInClientAuthorization? _authorization;
  String _contactText = '';

  void refreshState() {
    setState(() {});
  }

  // void openPage({VoidCallback? onNext}) {
  //   if (widget.navigationSidebarButton) {
  //     pageNavigationFrameworkKey.currentState!.changePage(8, switchNavbar: true);
  //     appStateKey.currentState?.refreshAppState();
  //   } else {
  //     if (onNext != null) onNext();
  //   }
  // }

  // void loginWithSync({VoidCallback? onNext}) {
  //   signInAndSync(
  //     widget.navigationSidebarButton ? navigatorKey.currentContext ?? context : context,
  //     next: () {
  //       setState(() {});
  //       openPage(onNext: onNext);
  //     },
  //   );
  // }
  @override
  void initState() {
    super.initState();

    final GoogleSignIn signIn = GoogleSignIn.instance;
    _signInInitialized = signIn.initialize(
      // clientId: '791480731407-4j2dmhvu2l061j7g5odqelvg74bagu28.apps.googleusercontent.com',
      serverClientId: '791480731407-4j2dmhvu2l061j7g5odqelvg74bagu28.apps.googleusercontent.com',
    );
    signIn.authenticationEvents
        .listen((GoogleSignInAuthenticationEvent event) {
          if (!mounted) {
            return;
          }
          setState(() {
            switch (event) {
              case GoogleSignInAuthenticationEventSignIn():
                _currentUser = event.user;
              case GoogleSignInAuthenticationEventSignOut():
                _currentUser = null;
              // _authorization = null;
            }
          });

          // if (_currentUser != null) {
          //   _checkAuthorization();
          // }
        })
        .onError((Object error) {
          debugPrint(error.toString());
        });

    _signInInitialized.then((void value) {
      signIn.attemptLightweightAuthentication();
    });
  }

  // void _updateAuthorization(GoogleSignInClientAuthorization? authorization) {
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {
  //     _authorization = authorization;
  //   });

  //   // if (authorization != null) {
  //   //   unawaited(_handleGetContact(authorization));
  //   // }
  // }

  // Future<void> _checkAuthorization() async {
  //   _updateAuthorization(await _currentUser?.authorizationClient.authorizationForScopes(scopes));
  // }

  // Future<void> _requestAuthorization() async {
  //   _updateAuthorization(
  //     await _currentUser?.authorizationClient.authorizeScopes(<String>[PeopleServiceApi.contactsReadonlyScope]),
  //   );
  // }

  // Future<void> _handleGetContact(GoogleSignInClientAuthorization authorization) async {
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {
  //     _contactText = 'Loading contact info...';
  //   });

  //   // Retrieve an [auth.AuthClient] from a GoogleSignInClientAuthorization.
  //   // final auth.AuthClient client = authorization.authClient(scopes: scopes);

  //   // // Prepare a People Service authenticated client.
  //   // final PeopleServiceApi peopleApi = PeopleServiceApi(client);
  //   // // Retrieve a list of connected contacts' names.
  //   // final ListConnectionsResponse response = await peopleApi.people.connections.list(
  //   //   'people/me',
  //   //   personFields: 'names',
  //   // );

  //   // final String? firstNamedContactName = _pickFirstNamedContact(response.connections);

  //   // if (mounted) {
  //   //   setState(() {
  //   //     if (firstNamedContactName != null) {
  //   //       _contactText = 'I see you know $firstNamedContactName!';
  //   //     } else {
  //   //       _contactText = 'No contacts to display.';
  //   //     }
  //   //   });
  //   // }
  // }

  // String? _pickFirstNamedContact(List<Person>? connections) {
  //   return connections
  //       ?.firstWhere((Person person) => person.names != null)
  //       .names
  //       ?.firstWhere((Name name) => name.displayName != null)
  //       .displayName;
  // }

  Future<void> _handleSignIn() async {
    try {
      await GoogleSignIn.instance.authenticate();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  // Call disconnect rather than signOut to more fully reset the example app.
  Future<void> _handleSignOut() => GoogleSignIn.instance.disconnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login with google')),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _signInInitialized,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            final GoogleSignInAccount? user = _currentUser;
            // final GoogleSignInClientAuthorization? authorization = _authorization;
            final List<Widget> children;
            if (snapshot.hasError) {
              children = <Widget>[const Text('Error initializing sign in.')];
            } else if (snapshot.connectionState == ConnectionState.done) {
              children = <Widget>[
                if (user != null) ...<Widget>[
                  ListTile(
                    leading: GoogleUserCircleAvatar(identity: user),
                    title: Text(user.displayName ?? ''),
                    subtitle: Text(user.email),
                  ),
                  const Text('Signed in successfully.'),
                  // if (authorization != null) ...<Widget>[
                  //   Text(_contactText),
                  //   ElevatedButton(onPressed: () => _handleGetContact(authorization), child: const Text('REFRESH')),
                  // ] else ...<Widget>[
                  //   ElevatedButton(onPressed: _requestAuthorization, child: const Text('LOAD CONTACTS')),
                  // ],
                  ElevatedButton(onPressed: _handleSignOut, child: const Text('SIGN OUT')),
                ] else ...<Widget>[
                  const Text('You are not currently signed in.'),
                  ElevatedButton(onPressed: _handleSignIn, child: const Text('SIGN IN')),
                ],
              ];
            } else {
              children = <Widget>[const CircularProgressIndicator()];
            }

            return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: children);
          },
        ),
      ),
    );
  }
}

class LoadingShimmerDriveFiles extends StatelessWidget {
  const LoadingShimmerDriveFiles({Key? key, required this.isManaging, required this.i}) : super(key: key);

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
          child: Container(
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

// class BackupManagement extends StatefulWidget {
//   const BackupManagement({
//     Key? key,
//     required this.isManaging,
//     required this.isClientSync,
//     this.hideDownloadButton = false,
//   }) : super(key: key);

//   final bool isManaging;
//   final bool isClientSync;
//   final bool hideDownloadButton;

//   @override
//   State<BackupManagement> createState() => _BackupManagementState();
// }

// class _BackupManagementState extends State<BackupManagement> {
//   List<File> filesState = [];
//   List<int> deletedIndices = [];
//   late DriveApi driveApiState;
//   UniqueKey dropDownKey = UniqueKey();
//   bool isLoading = true;
//   bool autoBackups = appStateSettings["autoBackups"];
//   bool backupSync = appStateSettings["backupSync"];

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () async {
//       (DriveApi?, List<File>?) result = await getDriveFiles();
//       DriveApi? driveApi = result.$1;
//       List<File>? files = result.$2;
//       if (files == null || driveApi == null) {
//         setState(() {
//           filesState = [];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           filesState = files;
//           driveApiState = driveApi;
//           isLoading = false;
//         });
//         bottomSheetControllerGlobal.snapToExtent(0);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.isClientSync) {
//       if (filesState.length > 0) {
//         print(appStateSettings["devicesHaveBeenSynced"]);
//         filesState = filesState.where((file) => isSyncBackupFile(file.name)).toList();
//         updateSettings("devicesHaveBeenSynced", filesState.length, updateGlobalState: false);
//       }
//     } else {
//       if (filesState.length > 0) {
//         filesState = filesState.where((file) => !isSyncBackupFile(file.name)).toList();
//         updateSettings("numBackups", filesState.length, updateGlobalState: false);
//       }
//     }
//     Iterable<MapEntry<int, drive.File>> filesMap = filesState.asMap().entries;
//     return PopupFramework(
//       title:
//           widget.isClientSync
//               ? '"devices".tr().capitalizeFirst'
//               : widget.isManaging
//               ? '"backups".tr()'
//               : '"restore-a-backup".tr()',
//       subtitle:
//           widget.isClientSync
//               ? '"manage-syncing-info".tr()'
//               : widget.isManaging
//               ? 'appStateSettings["backupLimit"].toString() + " " + "stored-backups".tr()'
//               : '"overwrite-warning".tr()',
//       child: Column(
//         children: [
//           widget.isClientSync && kIsWeb == false
//               ? Row(
//                 children: [
//                   Expanded(
//                     child: AboutInfoBox(
//                       title: "web-app".tr(),
//                       link: "https://budget-track.web.app/",
//                       color: Theme.of(context).colorScheme.secondaryContainer,
//                       padding: EdgeInsetsDirectional.only(start: 5, end: 5, bottom: 10, top: 5),
//                     ),
//                   ),
//                 ],
//               )
//               : SizedBox.shrink(),
//           widget.isManaging && widget.isClientSync == false
//               ? SettingsContainerSwitch(
//                 enableBorderRadius: true,
//                 onSwitched: (value) async {
//                   await updateSettings("autoBackups", value, pagesNeedingRefresh: [], updateGlobalState: false);
//                   setState(() {
//                     autoBackups = value;
//                   });
//                 },
//                 initialValue: appStateSettings["autoBackups"],
//                 title: '"auto-backups".tr()',
//                 description: '"auto-backups-description".tr()',
//                 icon: Icons.cloud_done_rounded,
//               )
//               : SizedBox.shrink(),
//           widget.isClientSync
//               ? SettingsContainerSwitch(
//                 enableBorderRadius: true,
//                 onSwitched: (value) async {
//                   // Only update global is the sidebar is shown
//                   await updateSettings("backupSync", value, pagesNeedingRefresh: [], updateGlobalState: false);
//                   sidebarStateKey.currentState?.refreshState();
//                   setState(() {
//                     backupSync = value;
//                   });
//                   // Future.delayed(Duration(milliseconds: 100), () {
//                   //   bottomSheetControllerGlobal.snapToExtent(0);
//                   // });
//                 },
//                 initialValue: appStateSettings["backupSync"],
//                 title: '"sync-data".tr()',
//                 description: '"sync-data-description".tr('),
//                 icon: Icons.cloud_sync_rounded,
//               )
//               : SizedBox.shrink(),
//           // Only allow sync on every change for web
//           // Only on web, disabled automatically in initializeSettings if not web
//           widget.isClientSync && kIsWeb
//               ? AnimatedExpanded(
//                 expand: backupSync,
//                 child: SettingsContainerSwitch(
//                   enableBorderRadius: true,
//                   onSwitched: (value) async {
//                     await updateSettings("syncEveryChange", value, pagesNeedingRefresh: [], updateGlobalState: false);
//                   },
//                   initialValue: appStateSettings["syncEveryChange"],
//                   title: '"sync-every-change".tr()',
//                   descriptionWithValue: (value) {
//                     return value ? '"sync-every-change-description1".tr()' : '"sync-every-change-description2".tr()';
//                   },
//                   icon: Icons.all_inbox_rounded,
//                 ),
//               )
//               : SizedBox.shrink(),
//           widget.isManaging && widget.isClientSync == false
//               ? AnimatedExpanded(
//                 expand: autoBackups,
//                 child: SettingsContainerDropdown(
//                   enableBorderRadius: true,
//                   items: ["1", "2", "3", "7", "10", "14"],
//                   onChanged: (value) async {
//                     await updateSettings(
//                       "autoBackupsFrequency",
//                       int.parse(value),
//                       pagesNeedingRefresh: [],
//                       updateGlobalState: false,
//                     );
//                   },
//                   initial: appStateSettings["autoBackupsFrequency"].toString(),
//                   title: '"backup-frequency".tr()',
//                   description: '"number-of-days".tr()',
//                   icon: Icons.event_repeat_rounded,
//                 ),
//               )
//               : SizedBox.shrink(),
//           widget.isManaging && widget.isClientSync == false && appStateSettings["showBackupLimit"]
//               ? SettingsContainerDropdown(
//                 enableBorderRadius: true,
//                 key: dropDownKey,
//                 verticalPadding: 5,
//                 title: '"backup-limit".tr()',
//                 icon: Icons.format_list_numbered_rtl_outlined,
//                 initial: appStateSettings["backupLimit"].toString(),
//                 items: ["10", "15", "20", "30"],
//                 onChanged: (value) async {
//                   if (int.parse(value) < appStateSettings["backupLimit"]) {
//                     openPopup(
//                       context,
//                       icon: Icons.delete_rounded,
//                       title: "change-limit".tr(),
//                       description: "change-limit-warning".tr(),
//                       onSubmit: () async {
//                         await updateSettings("backupLimit", int.parse(value), updateGlobalState: false);
//                         popRoute(context);
//                       },
//                       onSubmitLabel: "change".tr(),
//                       onCancel: () {
//                         popRoute(context);
//                         setState(() {
//                           dropDownKey = UniqueKey();
//                         });
//                       },
//                       onCancelLabel: "cancel".tr(),
//                     );
//                   } else {
//                     await updateSettings("backupLimit", int.parse(value), updateGlobalState: false);
//                   }
//                 },
//               )
//               : SizedBox.shrink(),
//           if ((widget.isManaging == false && widget.isClientSync == false) == false) SizedBox(height: 10),
//           isLoading
//               ? Column(
//                 children: [
//                   for (
//                     int i = 0;
//                     i <
//                         (widget.isClientSync
//                             ? appStateSettings["devicesHaveBeenSynced"]
//                             : appStateSettings["numBackups"]);
//                     i++
//                   )
//                     LoadingShimmerDriveFiles(isManaging: widget.isManaging, i: i),
//                 ],
//               )
//               : SizedBox.shrink(),
//           ...filesMap
//               .map(
//                 (MapEntry<int, drive.File> file) => AnimatedSizeSwitcher(
//                   child:
//                       deletedIndices.contains(file.key)
//                           ? Container(key: ValueKey(1))
//                           : Padding(
//                             padding: const EdgeInsetsDirectional.only(bottom: 8.0),
//                             child: Tappable(
//                               onTap: () async {
//                                 if (!widget.isManaging) {
//                                   final result = await openPopup(
//                                     context,
//                                     title: "load-backup".tr(),
//                                     subtitle:
//                                         getWordedDateShortMore(
//                                           (file.value.modifiedTime ?? DateTime.now()).toLocal(),
//                                           includeTime: true,
//                                           includeYear: true,
//                                           showTodayTomorrow: false,
//                                         ) +
//                                         "\n" +
//                                         getWordedTime(
//                                           navigatorKey.currentContext?.locale.toString(),
//                                           (file.value.modifiedTime ?? DateTime.now()).toLocal(),
//                                         ),
//                                     beforeDescriptionWidget: Padding(
//                                       padding: const EdgeInsetsDirectional.only(top: 8, bottom: 5),
//                                       child: CodeBlock(text: (file.value.name ?? "No name")),
//                                     ),
//                                     description: '"load-backup-warning".tr()',
//                                     icon: Icons.warning_rounded,
//                                     onSubmit: () async {
//                                       popRoute(context, true);
//                                     },
//                                     onSubmitLabel: '"load".tr()',
//                                     onCancelLabel: '"cancel".tr()',
//                                     onCancel: () {
//                                       popRoute(context);
//                                     },
//                                   );
//                                   if (result == true) loadBackup(context, driveApiState, file.value);
//                                 }
//                                 // else {
//                                 //   await openPopup(
//                                 //     context,
//                                 //     title: "Backup Details",
//                                 //     description: (file.value.name ?? "") +
//                                 //         "\n" +
//                                 //         (file.value.size ?? "") +
//                                 //         "\n" +
//                                 //         (file.value.description ?? ""),
//                                 //     icon: appStateSettings["outlinedIcons"] ? Icons.warning_outlined : Icons.warning_rounded,
//                                 //     onSubmit: () async {
//                                 //       popRoute(context, true);
//                                 //     },
//                                 //     onSubmitLabel: "Close",
//                                 //   );
//                                 // }
//                               },
//                               borderRadius: 15,
//                               color:
//                                   widget.isClientSync && isCurrentDeviceSyncBackupFile(file.value.name)
//                                       ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
//                                       : Theme.of(context).colorScheme.secondaryContainer,
//                               child: Container(
//                                 padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             widget.isClientSync ? Icons.devices_rounded : Icons.description_rounded,
//                                             color: Theme.of(context).colorScheme.secondary,
//                                             size: 30,
//                                           ),
//                                           SizedBox(width: widget.isClientSync ? 17 : 13),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 TextFont(
//                                                   text:
//                                                       getTimeAgo(
//                                                         (file.value.modifiedTime ?? DateTime.now()).toLocal(),
//                                                       ).capitalizeFirst,
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.bold,
//                                                   maxLines: 2,
//                                                 ),
//                                                 TextFont(
//                                                   text:
//                                                       (isSyncBackupFile(file.value.name)
//                                                           ? getDeviceFromSyncBackupFileName(file.value.name) +
//                                                               " " +
//                                                               "sync"
//                                                           : file.value.name ?? "No name"),
//                                                   fontSize: 14,
//                                                   maxLines: 2,
//                                                 ),
//                                                 // isSyncBackupFile(
//                                                 //         file.value.name)
//                                                 //     ? Padding(
//                                                 //         padding:
//                                                 //             const EdgeInsetsDirectional
//                                                 //                 .only(top: 3),
//                                                 //         child: TextFont(
//                                                 //           text:
//                                                 //               file.value.name ??
//                                                 //                   "",
//                                                 //           fontSize: 11,
//                                                 //           maxLines: 2,
//                                                 //         ),
//                                                 //       )
//                                                 //     : SizedBox.shrink()
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     widget.isManaging
//                                         ? Row(
//                                           children: [
//                                             widget.hideDownloadButton
//                                                 ? SizedBox.shrink()
//                                                 : Padding(
//                                                   padding: const EdgeInsetsDirectional.only(start: 8.0),
//                                                   child: Builder(
//                                                     builder: (boxContext) {
//                                                       return ButtonIcon(
//                                                         color:
//                                                             Theme.of(
//                                                                   context,
//                                                                 ).colorScheme.onSecondaryContainer.withOpacity(0.08)
//                                                                 ,
//                                                         onTap: () {
//                                                           saveDriveFileToDevice(
//                                                             boxContext: boxContext,
//                                                             driveApi: driveApiState,
//                                                             fileToSave: file.value,
//                                                           );
//                                                         },
//                                                         icon: Icons.download_rounded,
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                             Padding(
//                                               padding: const EdgeInsetsDirectional.only(start: 5),
//                                               child: ButtonIcon(
//                                                 color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.08),
//                                                 onTap: () {
//                                                   openPopup(
//                                                     context,
//                                                     icon: Icons.delete_rounded,
//                                                     title: '"delete-backup".tr()',
//                                                     subtitle:
//                                                         getWordedDateShortMore(
//                                                           (file.value.modifiedTime ?? DateTime.now()).toLocal(),
//                                                           includeTime: true,
//                                                           includeYear: true,
//                                                           showTodayTomorrow: false,
//                                                         ) +
//                                                         "\n" +
//                                                         getWordedTime(
//                                                           navigatorKey.currentContext?.locale.toString(),
//                                                           (file.value.modifiedTime ?? DateTime.now()).toLocal(),
//                                                         ),
//                                                     beforeDescriptionWidget: Padding(
//                                                       padding: const EdgeInsetsDirectional.only(top: 8, bottom: 5),
//                                                       child: CodeBlock(
//                                                         text:
//                                                             (file.value.name ?? "No name") +
//                                                             "\n" +
//                                                             convertBytesToMB(
//                                                               file.value.size ?? "0",
//                                                             ).toStringAsFixed(2) +
//                                                             " MB",
//                                                       ),
//                                                     ),
//                                                     description:
//                                                         (widget.isClientSync
//                                                             ? "delete-sync-backup-warning".tr()
//                                                             : null),
//                                                     onSubmit: () async {
//                                                       popRoute(context);
//                                                       loadingIndeterminateKey.currentState?.setVisibility(true);
//                                                       await deleteBackup(driveApiState, file.value.id ?? "");
//                                                       openSnackbar(
//                                                         SnackbarMessage(
//                                                           title: "deleted-backup".tr(),
//                                                           description: (file.value.name ?? "No name"),
//                                                           icon: Icons.delete_rounded,
//                                                         ),
//                                                       );
//                                                       setState(() {
//                                                         deletedIndices.add(file.key);
//                                                       });
//                                                       // bottomSheetControllerGlobal
//                                                       //     .snapToExtent(0);
//                                                       if (widget.isClientSync)
//                                                         await updateSettings(
//                                                           "devicesHaveBeenSynced",
//                                                           appStateSettings["devicesHaveBeenSynced"] - 1,
//                                                           updateGlobalState: false,
//                                                         );
//                                                       if (widget.isManaging) {
//                                                         await updateSettings(
//                                                           "numBackups",
//                                                           appStateSettings["numBackups"] - 1,
//                                                           updateGlobalState: false,
//                                                         );
//                                                       }
//                                                       loadingIndeterminateKey.currentState?.setVisibility(false);
//                                                     },
//                                                     onSubmitLabel: '"delete".tr()',
//                                                     onCancel: () {
//                                                       popRoute(context);
//                                                     },
//                                                     onCancelLabel: '"cancel".tr()',
//                                                   );
//                                                 },
//                                                 icon: Icons.close_rounded,
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                         : SizedBox.shrink(),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                 ),
//               )
//               .toList(),
//         ],
//       ),
//     );
//   }
// }
