import 'package:invesly/common/utils/keyboard.dart';
import 'package:invesly/common_libs.dart';

/// Display a dialog with a title, a description and confirm/cancel buttons.
///
/// When the confirm dialogs is closed, it will return `true` or `false` when one of the actions
/// button is pressed, and null if closed without tapping on any icon
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  Widget? icon,
  Widget? content,
  bool showCancelButton = false,
  String? confirmationText,
  bool canPop = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: canPop,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        icon: icon,
        content: content,
        actions: <Widget>[
          if (showCancelButton)
            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context, rootNavigator: true).pop(false)),
          TextButton(
            child: Text(confirmationText ?? 't.general.understood'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
          ),
        ],
      );
    },
  );
}

Future<T?> openPopup<T extends Object?>(
  BuildContext? contextPassed, {
  IconData? icon,
  double? iconScale,
  String? title,
  String? subtitle,
  String? description,
  Widget? descriptionWidget,
  Widget? beforeDescriptionWidget,
  String? onSubmitLabel,
  String? onCancelLabel,
  String? onExtraLabel,
  String? onExtraLabel2,
  VoidCallback? onSubmit,
  VoidCallback? onCancel,
  Function(BuildContext context)? onCancelWithBoxContext,
  VoidCallback? onExtra,
  VoidCallback? onExtra2,
  bool barrierDismissible = true,
}) {
  if ((contextPassed ?? navigatorKey.currentContext) == null) return Future.error('No context');
  BuildContext context = contextPassed ?? navigatorKey.currentContext!;

  minimizeKeyboard();
  return showGeneralDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withOpacity(0.4),
    barrierLabel: '',
    transitionBuilder: (_, anim, _, child) {
      Tween<double> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: 0.9, end: 1);
      } else {
        tween = Tween(begin: 0.95, end: 1);
      }
      return ScaleTransition(
        scale: tween.animate(CurvedAnimation(parent: anim, curve: Curves.easeInOutQuart)),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (_, _, _) {
      final borderRadius = 25.0;
      return PopScope(
        //Stop back button
        onPopInvokedWithResult: (_, _) => barrierDismissible,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              // maxWidth: getWidthBottomSheet(context)
            ),
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.paddingOf(context).left + 20,
                right: MediaQuery.paddingOf(context).right + 20,
                top: MediaQuery.paddingOf(context).top + 20,
                bottom: MediaQuery.paddingOf(context).bottom + 20,
              ),
              decoration: BoxDecoration(
                color: context.colors.secondaryContainer,
                borderRadius: BorderRadiusDirectional.circular(borderRadius),
                // boxShadow: boxShadowGeneral(context),
              ),
              child: SingleChildScrollView(
                child: Builder(
                  builder: (context) {
                    Widget content = Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.symmetric(horizontal: 25),
                          child: Column(
                            children: [
                              SizedBox(height: 17),
                              if (icon != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8.0, horizontal: 10),
                                  child: Transform.scale(
                                    scale: iconScale ?? 1,
                                    child: Icon(icon, size: 65, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              if (title != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8.0, horizontal: 10),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 23.0,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onPrimaryContainer,
                                    ),
                                    maxLines: 5,
                                  ),
                                ),
                              if (subtitle != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8.0, horizontal: 10),
                                  child: Text(
                                    subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onTertiaryContainer,
                                    ),
                                    maxLines: 5,
                                  ),
                                ),
                              if (beforeDescriptionWidget != null) beforeDescriptionWidget,
                              if (description != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8.0, horizontal: 10),
                                  child: Text(
                                    description,
                                    style: TextStyle(fontSize: 16.5),
                                    textAlign: TextAlign.center,
                                    maxLines: 100,
                                  ),
                                ),
                              if (descriptionWidget != null) descriptionWidget,
                              if (onSubmitLabel != null || onCancelLabel != null)
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(vertical: 16.0),
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    runSpacing: 10,
                                    children: [
                                      onCancelLabel != null
                                          ? IntrinsicWidth(
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                                                child: Builder(
                                                  builder: (boxContext) {
                                                    return TextButton(
                                                      // color: tertiaryButtonColor,
                                                      // textColor: onTertiaryButtonColor,
                                                      child: Text(onCancelLabel),
                                                      onPressed: () {
                                                        if (onCancel != null) {
                                                          onCancel();
                                                        }
                                                        if (onCancelWithBoxContext != null) {
                                                          onCancelWithBoxContext(boxContext);
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      onExtraLabel != null
                                          ? IntrinsicWidth(
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                                                child: TextButton(
                                                  // expandedLayout: true,
                                                  // color: primaryButtonColor,
                                                  // textColor: onPrimaryButtonColor,
                                                  onPressed: onExtra ?? () {},
                                                  child: Text(onExtraLabel),
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      onSubmitLabel != null
                                          ? IntrinsicWidth(
                                              child: Padding(
                                                padding: const EdgeInsetsDirectional.symmetric(horizontal: 8.0),
                                                child: TextButton(
                                                  // color: primaryButtonColor,
                                                  // textColor: onPrimaryButtonColor,
                                                  onPressed: onSubmit ?? () {},
                                                  child: Text(onSubmitLabel),
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              onExtraLabel2 == null ? SizedBox(height: 17) : SizedBox(height: 5),
                            ],
                          ),
                        ),
                        if (onExtraLabel2 != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 10, end: 10, bottom: 12),
                            child: TextButton(
                              // borderRadius: borderRadius,
                              // expandedLayout: true,
                              // color: tertiaryButtonColor,
                              // textColor: onTertiaryButtonColor,
                              onPressed: onExtra2 ?? () {},
                              child: Text(onExtraLabel2),
                            ),
                          ),
                        // SizedBox(height: 16),
                      ],
                    );
                    // Only use intrinsic width if the content is controlled
                    if (onExtraLabel2 != null && descriptionWidget == null && beforeDescriptionWidget == null) {
                      return IntrinsicWidth(child: content);
                    }
                    return content;
                  },
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

enum DeletePopupAction { cancel, delete, extra }

enum RoutesToPopAfterDelete { none, one, all, preventDelete }

// Future<DeletePopupAction?> openDeletePopup(
//   BuildContext context, {
//   String? title,
//   String? subtitle,
//   String? description,
//   String? extraLabel,
// }) async {
//   dynamic result = await openPopup(
//     context,
//     title: title,
//     subtitle: subtitle,
//     description: description,
//     icon: appStateSettings["outlinedIcons"] ? Icons.delete_outlined : Icons.delete_rounded,
//     onCancel: () {
//       popRoute(context, DeletePopupAction.cancel);
//     },
//     onCancelLabel: "cancel".tr(),
//     onSubmit: () async {
//       popRoute(context, DeletePopupAction.delete);
//     },
//     onSubmitLabel: "delete".tr(),
//     onExtraLabel2: extraLabel,
//     onExtra2: () async {
//       popRoute(context, DeletePopupAction.extra);
//     },
//   );
//   if (result is DeletePopupAction) return result;
//   return null;
// }

// Future<T?> openPopupCustom<T extends Object?>(
//   BuildContext context, {
//   String? title,
//   bool barrierDismissible = true,
//   EdgeInsetsDirectional padding = const EdgeInsetsDirectional.symmetric(horizontal: 25, vertical: 20),
//   BorderRadius? borderRadius,
//   required Widget child,
// }) {
//   return showGeneralDialog(
//     context: context,
//     useRootNavigator: false,
//     barrierDismissible: barrierDismissible,
//     barrierColor: Colors.black.withOpacity(0.4),
//     barrierLabel: '',
//     transitionBuilder: (_, anim, __, child) {
//       Tween<double> tween;
//       if (anim.status == AnimationStatus.reverse) {
//         tween = Tween(begin: 0.9, end: 1);
//       } else {
//         tween = Tween(begin: 0.95, end: 1);
//       }
//       return ScaleTransition(
//         scale: tween.animate(new CurvedAnimation(parent: anim, curve: Curves.easeInOutQuart)),
//         child: FadeTransition(opacity: anim, child: child),
//       );
//     },
//     transitionDuration: Duration(milliseconds: 200),
//     pageBuilder: (_, _, _) {
//       return WillPopScope(
//         //Stop back button
//         onWillPop: () async => barrierDismissible,
//         child: Center(
//           child: Container(
//             margin: EdgeInsetsDirectional.only(
//               start: 20,
//               end: 20,
//               top: MediaQuery.paddingOf(context).top,
//               bottom: MediaQuery.paddingOf(context).bottom,
//             ),
//             decoration: BoxDecoration(
//               color:
//                   appStateSettings["materialYou"]
//                       ? dynamicPastel(context, Theme.of(context).colorScheme.secondaryContainer, amount: 0.5)
//                       : getColor(context, "lightDarkAccent"),
//               borderRadius:
//                   borderRadius ?? BorderRadiusDirectional.circular(getPlatform() == PlatformOS.isIOS ? 10 : 25),
//               boxShadow: boxShadowGeneral(context),
//             ),
//             child: SingleChildScrollView(
//               padding: padding,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   title == null
//                       ? SizedBox.shrink()
//                       : Padding(
//                         padding: const EdgeInsetsDirectional.only(bottom: 15),
//                         child: TextFont(
//                           text: title,
//                           fontSize: 25,
//                           fontWeight: FontWeight.bold,
//                           maxLines: 5,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                   child,
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

Future<T?> openLoadingPopup<T extends Object?>(BuildContext context, Future<T?> Function() callback) async {
  return showDialog(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.4),
    // barrierLabel: '',
    // transitionBuilder: (_, anim, _, child) {
    //   final tween = Tween<double>(begin: 0.9, end: 1);
    //   return ScaleTransition(
    //     scale: tween.animate(CurvedAnimation(parent: anim, curve: Curves.easeInOutQuart)),
    //     child: FadeTransition(opacity: anim, child: child),
    //   );
    // },
    // transitionDuration: Duration(milliseconds: 200),
    builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        T? result;
        try {
          result = await callback.call();
        } catch (err) {
          $logger.e(err);
        }
        if (context.mounted) context.pop(result);
      });
      return Center(
        child: Material(
          borderRadius: BorderRadiusDirectional.circular(25.0),
          color: context.colors.secondaryContainer,
          child: Padding(padding: const EdgeInsets.all(20.0), child: CircularProgressIndicator()),
        ),
      );
    },
  );

  // return result;
}

// Future openLoadingPopupTryCatch(
//   Future Function() function, {
//   BuildContext? context,
//   Function(dynamic error)? onError,
//   Function(dynamic result)? onSuccess,
// }) async {
//   openLoadingPopup(context ?? navigatorKey.currentContext!);
//   try {
//     dynamic result = await function();
//     popRoute(context ?? navigatorKey.currentContext!, result);
//     if (onSuccess != null) onSuccess(result);
//     return result;
//   } catch (e) {
//     $logger.e(e);
//     popRoute(context ?? navigatorKey.currentContext!, null);
//     if (onError != null) {
//       onError(e);
//     } else {
//       $logger.e(e);
//       // openSnackbar(SnackbarMessage(title: 'an-error-occurred', icon: Icons.warning_rounded, description: e.toString()));
//     }
//   }
//   return null;
// }

// // TODO: Move this function to new file
// void popRoute<T extends Object?>(BuildContext? context, [T? result]) {
//   BuildContext? contextToPop = context;
//   if (context == null) contextToPop = navigatorKey.currentContext;
//   if (contextToPop == null) return;
//   Navigator.of(contextToPop, rootNavigator: false).pop(result);
//   // bool hasPopped = false;
//   // Navigator.of(contextToPop, rootNavigator: true).popUntil((route) {
//   //   if (route.isFirst) return true;
//   //   if (hasPopped == false) {
//   //     hasPopped = true;
//   //     return route.isFirst;
//   //   } else {
//   //     return true;
//   //   }
//   // });
// }

// void discardChangesPopup(context, {previousObject, currentObject, Function? onDiscard, bool forceShow = false}) async {
//   print(previousObject);
//   print(currentObject);

//   if (forceShow == false && previousObject == currentObject && previousObject != null && currentObject != null) {
//     popRoute(context);
//     return;
//   }
//   if (forceShow == false && previousObject == null) {
//     popRoute(context);
//     return;
//   }

//   previousObject = previousObject?.copyWith(dateTimeModified: Value(null));

//   if (forceShow == false &&
//       previousObject != null &&
//       currentObject != null &&
//       previousObject.toString() == currentObject.toString()) {
//     print(previousObject.toString());
//     print(currentObject.toString());

//     popRoute(context);
//   } else {
//     await openPopup(
//       context,
//       title: "discard-changes".tr(),
//       description: "discard-changes-description".tr(),
//       icon: appStateSettings["outlinedIcons"] ? Icons.warning_outlined : Icons.warning_rounded,
//       onSubmitLabel: "discard".tr(),
//       onSubmit: () async {
//         if (onDiscard != null) await onDiscard();
//         popRoute(context);
//         popRoute(context);
//       },
//       onCancelLabel: "cancel".tr(),
//       onCancel: () {
//         popRoute(context);
//       },
//     );
//   }
// }
