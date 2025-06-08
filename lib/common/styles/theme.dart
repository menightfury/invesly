// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:invesly/constants.dart';

@immutable
class AppStyle {
  // Singleton pattern
  const AppStyle._();
  static final instance = AppStyle._();

  // ~ Light theme colors
  final _lightScheme = const ColorScheme.light(
    primary: AppLightColors.teal,
    onPrimary: AppLightColors.white,
    primaryContainer: AppLightColors.teal100,
    onPrimaryContainer: AppLightColors.teal900,
    secondary: AppLightColors.amber,
    onSecondary: AppLightColors.black,
    secondaryContainer: AppLightColors.amber100,
    onSecondaryContainer: AppLightColors.amber900,
    error: AppLightColors.red,
    onError: AppLightColors.white,
    errorContainer: AppLightColors.red100,
    onErrorContainer: AppLightColors.red900,
    surface: AppLightColors.offwhite,
    onSurface: AppLightColors.black,
  );
  ThemeData get lightTheme => _getThemeData(_lightScheme);

  // ~ Dark theme colors
  final _darkScheme = const ColorScheme.dark(
    primary: AppDarkColors.primary,
    onPrimary: AppDarkColors.black,
    secondary: AppDarkColors.secondary,
    onSecondary: AppDarkColors.black,
    error: AppDarkColors.error,
    onError: AppDarkColors.black,
    surface: AppDarkColors.surface,
    onSurface: AppDarkColors.white,
  );
  ThemeData get darkTheme => _getThemeData(_darkScheme);

  ThemeData _getThemeData(ColorScheme colorScheme) {
    return ThemeData(
      brightness: colorScheme.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      colorScheme: colorScheme,
      fontFamily: AppConstants.primaryFont,
      dividerColor: colorScheme.primary,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: AppConstants.headerFont, fontSize: 30.0),
        headlineMedium: TextStyle(fontFamily: AppConstants.headerFont, fontSize: 24.0),
        headlineSmall: TextStyle(fontFamily: AppConstants.headerFont, fontSize: 18.0),
        titleLarge: TextStyle(fontSize: 18.0), // appbar title
        titleMedium: TextStyle(fontSize: 15.0), // textfield
        bodyLarge: TextStyle(fontSize: 16.0, height: 1.5), // chip
        bodyMedium: TextStyle(fontSize: 15.0, height: 1.25), // body
        bodySmall: TextStyle(fontSize: 13.0), // textfield helper
        labelLarge: TextStyle(fontSize: 15.0), // button, *-chip
        labelMedium: TextStyle(fontSize: 12.0), // bottomNavBar
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.primaryContainer,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.all(4.0),
      ),
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 1.0,
        // elevation: 0.1,
        surfaceTintColor: colorScheme.surface,
        shadowColor: Colors.black38,
        // iconTheme: IconThemeData(color: colorScheme.onBackground),
        // foregroundColor: colorScheme.onBackground,
        // backgroundColor: colorScheme.background,
      ),
      // toggleButtonsTheme: ToggleButtonsThemeData(
      //   color: colorScheme.secondary,
      //   borderColor: colorScheme.secondary,
      //   selectedColor: colorScheme.primary,
      //   selectedBorderColor: colorScheme.primary,
      //   fillColor: colorScheme.primary.withOpacity(0.1),
      //   splashColor: colorScheme.primary.withOpacity(0.1),
      //   borderRadius: BorderRadius.circular(EMCorners.sm),
      // ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.error)) {
            return colorScheme.errorContainer;
          }
          if (state.contains(WidgetState.disabled)) {
            return Colors.black12;
          }
          return colorScheme.primaryContainer;
        }),
        contentPadding: AppConstants.textFieldPadding,
        isCollapsed: true,
        // isDense: true,
        hintStyle: const TextStyle(color: Colors.black38),
        border: const OutlineInputBorder(borderRadius: AppConstants.textFieldBorderRadius, borderSide: BorderSide.none),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: AppConstants.textFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.primary.withOpacity(0.38)),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: AppConstants.textFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.primary),
        // ),
        // disabledBorder: OutlineInputBorder(
        //   borderRadius: AppConstants.textFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.onSurface.withOpacity(0.38)),
        // ),
        // errorBorder: OutlineInputBorder(
        //   borderRadius: AppConstants.textFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.error),
        // ),
        // focusedErrorBorder: OutlineInputBorder(
        //   borderRadius: AppConstants.textFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.error),
        // ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(AppConstants.buttonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(AppConstants.minButtonSize),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
            if (state.contains(WidgetState.disabled)) return Colors.black26;
            if (state.contains(WidgetState.error)) return colorScheme.error;
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            ContinuousRectangleBorder(borderRadius: AppConstants.buttonBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(AppConstants.buttonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(AppConstants.minButtonSize),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
            if (state.contains(WidgetState.disabled)) return colorScheme.primaryContainer.withAlpha(30);
            if (state.contains(WidgetState.error)) return colorScheme.errorContainer;
            return colorScheme.primaryContainer;
          }),
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimaryContainer),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            ContinuousRectangleBorder(borderRadius: AppConstants.buttonBorderRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(AppConstants.buttonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(AppConstants.minButtonSize),
          // side: WidgetStatePropertyAll<BorderSide>(),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            ContinuousRectangleBorder(
              side: BorderSide(color: colorScheme.primary),
              borderRadius: AppConstants.buttonBorderRadius,
            ),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 10.0,
        dragHandleSize: const Size(25.0, 4.0),
        modalBackgroundColor: colorScheme.surface,
        dragHandleColor: Colors.grey[300],
        clipBehavior: Clip.hardEdge,
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(dense: true, minVerticalPadding: 16.0),
    );
  }
}

class CustomChipBorderSide extends WidgetStateBorderSide {
  const CustomChipBorderSide(this.colorScheme);

  final ColorScheme colorScheme;

  @override
  BorderSide? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return BorderSide(color: colorScheme.onSurface.withAlpha(30));
    }
    if (states.contains(WidgetState.selected)) {
      return BorderSide(color: colorScheme.primary);
    }
    return BorderSide(color: colorScheme.primary.withAlpha(30));
  }
}
