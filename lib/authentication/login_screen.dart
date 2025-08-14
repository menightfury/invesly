// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/cubit/auth_cubit.dart';
import 'package:invesly/accounts/edit_account/cubit/edit_account_cubit.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/common_libs.dart';
import 'package:shimmer/shimmer.dart';

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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState?.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    // final cubit = context.read<EditAccountCubit>();

    return
    // BlocListener<EditAccountCubit, EditAccountState>(
    //   listenWhen: (prevState, state) => prevState.status != state.status && state.status.isFailureOrSuccess,
    //   listener: (context, state) {
    //     // late final SnackBar message;
    //     //   if (state.status == EditAccountFormStatus.success) {
    //     //     if (context.canPop) {
    //     //       context.pop();
    //     //     } else {
    //     //       context.go(const DashboardScreen());
    //     //     }
    //     //     message = const SnackBar(content: Text('User saved successfully'), backgroundColor: Colors.teal);
    //     //   } else if (state.status == EditAccountFormStatus.failure) {
    //     //     message = const SnackBar(content: Text('Sorry! some error occurred'), backgroundColor: Colors.redAccent);
    //     //   }
    //     //   ScaffoldMessenger.of(context)
    //     //     ..hideCurrentSnackBar()
    //     //     ..showSnackBar(message);
    //   },
    //   child:
    GestureDetector(
      // onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(body: SafeArea(child: Center(child: GoogleAccountLoginButton()))),
      // ),
    );
  }

  // ~ Save user
  Future<void> _handleSavePressed(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      context.read<EditAccountCubit>().save();
      // if (!context.mounted) return;
      // context.read<SettingsCubit>().saveCurrentUser(user);
    } else {
      // Handle form validation failure
    }
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

class GoogleAccountLoginButton extends StatefulWidget {
  const GoogleAccountLoginButton({super.key, this.isButtonSelected = false, this.forceButtonName});
  final bool isButtonSelected;
  final String? forceButtonName;

  @override
  State<GoogleAccountLoginButton> createState() => GoogleAccountLoginButtonState();
}

class GoogleAccountLoginButtonState extends State<GoogleAccountLoginButton> {
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
  Widget build(BuildContext context) {
    // if (widget.navigationSidebarButton == true) {
    //   return AnimatedSwitcher(
    //     duration: Duration(milliseconds: 600),
    //     child:
    //         googleUser == null
    //             ? NavigationSidebarButton(
    //               key: ValueKey("login"),
    //               label: '"login".tr()',
    //               icon: MoreIcons.google,
    //               onTap: loginWithSync,
    //               isSelected: false,
    //             )
    //             : NavigationSidebarButton(
    //               key: ValueKey("user"),
    //               label: googleUser!.displayName ?? '',
    //               icon: widget.forceButtonName == null ? Icons.person_rounded : MoreIcons.google_drive,
    //               iconScale: widget.forceButtonName == null ? 1 : 0.87,
    //               onTap: openPage,
    //               isSelected: widget.isButtonSelected,
    //             ),
    //   );
    // }
    //   return googleUser == null
    //       ? SettingsContainerOpenPage(
    //         openPage: AccountsPage(),
    //         onTap: (openContainer) {
    //           loginWithSync(onNext: openContainer);
    //         },
    //         title: widget.forceButtonName ?? 'Login',
    //         // icon: widget.forceButtonName == null ? MoreIcons.google : MoreIcons.google_drive,
    //         icon: Icons.abc,
    //         // icon: widget.forceButtonName == null ? MoreIcons.google : MoreIcons.google_drive,
    //         iconScale: widget.forceButtonName == null ? 1 : 0.87,
    //       )
    //       : SettingsContainerOpenPage(
    //         openPage: AccountsPage(),
    //         title: widget.forceButtonName ?? googleUser!.displayName ?? "",
    //         // icon: widget.forceButtonName == null ? Icons.person_rounded : MoreIcons.google_drive,
    //         icon: Icons.person_rounded,
    //         iconScale: widget.forceButtonName == null ? 1 : 0.87,
    //       );
    // }
    return Text('Sign in with google');
  }
}
