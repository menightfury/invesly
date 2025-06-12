// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:invesly/common_libs.dart';
import 'constants.dart';

@immutable
class AppStyle {
  // Singleton pattern
  const AppStyle._();
  static final instance = AppStyle._();

  // data for theme
  static const _primaryFont = 'ZillaSlab';
  static const _headerFont = 'Maragsa';

  // ~ Light theme colors
  // Based on FlexColorScheme.sepia
  static const _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF413D32),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE7E6E4),
    onPrimaryContainer: Color(0xFF000000),
    secondary: Color(0xFF8F8880),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDEDCD6),
    onSecondaryContainer: Color(0xFF000000),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF000000),
    surface: Color(0xFFF7FEFF),
    onSurface: Color(0xFF111111),
  );

  // ~ Dark theme colors
  // Based on FlexColorScheme.sepia
  static const _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFFF1E8D9),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF363024),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFFE5E1D6),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF958D82),
    onSecondaryContainer: Color(0xFFFFFFFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFFFFF),
    surface: Color(0xFF14130f),
    onSurface: Color(0xFFF1F1F1),
  );

  ThemeData _getThemeData(ColorScheme colorScheme) {
    return ThemeData(
      brightness: colorScheme.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.primaryContainer,
      cardColor: colorScheme.primaryContainer,
      colorScheme: colorScheme,
      fontFamily: _primaryFont,
      dividerColor: colorScheme.primary.withAlpha(50),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontFamily: _headerFont, fontSize: 32.0),
        headlineMedium: TextStyle(fontFamily: _headerFont, fontSize: 26.0),
        headlineSmall: TextStyle(fontFamily: _headerFont, fontSize: 22.0),
        titleLarge: TextStyle(fontSize: 20.0), // appbar title
        titleMedium: TextStyle(fontSize: 18.0), // textfield
        bodyLarge: TextStyle(fontSize: 20.0, height: 1.25), // chip
        bodyMedium: TextStyle(fontSize: 18.0, height: 1.25), // body
        bodySmall: TextStyle(fontSize: 14.0), // textfield helper
        labelLarge: TextStyle(fontSize: 16.0), // button, *-chip
        labelMedium: TextStyle(fontSize: 14.0), // bottomNavBar
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.primaryContainer,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.all(4.0),
      ),
      appBarTheme: AppBarTheme(
        color: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        scrolledUnderElevation: 1.0,
        elevation: 0,
        surfaceTintColor: colorScheme.surface,
        systemOverlayStyle: SystemUiOverlayStyle(systemNavigationBarColor: colorScheme.surface),
        // shadowColor: Colors.black38,
        // iconTheme: IconThemeData(color: colorScheme.onBackground),
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
            if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2.0,
        shape: const ContinuousRectangleBorder(borderRadius: AppConstants.buttonBorderRadius),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        elevation: 10.0,
        dragHandleSize: const Size(25.0, 4.0),
        // modalBackgroundColor: colorScheme.surface,
        dragHandleColor: Colors.grey[300],
        clipBehavior: Clip.hardEdge,
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(dense: true, minVerticalPadding: 16.0),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: colorScheme.surface),
    );
  }

  ThemeData get lightTheme => _getThemeData(_lightColorScheme);

  ThemeData get darkTheme => _getThemeData(_darkColorScheme);
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
