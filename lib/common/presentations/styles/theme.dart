// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

@immutable
class AppStyle {
  // Singleton pattern
  const AppStyle._();
  static final instance = AppStyle._();

  // data for theme
  // static const _primaryFont = 'Source Sans Pro';
  // static const _headerFont = 'Maragsa';

  ThemeData getTheme(ColorScheme colorScheme) {
    return ThemeData(
      brightness: colorScheme.brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.secondaryContainer,
      cardColor: colorScheme.secondaryContainer,
      colorScheme: colorScheme,
      fontFamily: GoogleFonts.portLligatSlab(fontWeight: FontWeight.w500).fontFamily,
      // fontFamily: _primaryFont,
      dividerColor: colorScheme.primary.withAlpha(50),
      textTheme: TextTheme(
        // headlineLarge: TextStyle(fontFamily: _headerFont, fontSize: 32.0),
        headlineLarge: GoogleFonts.rye(fontSize: 26.0),
        // headlineMedium: TextStyle(fontFamily: _headerFont, fontSize: 26.0),
        headlineMedium: GoogleFonts.rye(fontSize: 22.0),
        // headlineSmall: TextStyle(fontFamily: _headerFont, fontSize: 22.0),
        headlineSmall: GoogleFonts.rye(fontSize: 20.0),
        titleLarge: TextStyle(fontSize: 20.0), // appbar title
        titleMedium: TextStyle(fontSize: 18.0), // textfield
        bodyLarge: TextStyle(fontSize: 20.0, height: 1.25), // chip, ListTile title,
        bodyMedium: TextStyle(fontSize: 18.0, height: 1.4), // body
        bodySmall: TextStyle(fontSize: 14.0), // textfield helper
        labelLarge: TextStyle(fontSize: 18.0, height: 1.4, fontWeight: FontWeight.w600), // button, *-chip
        labelMedium: TextStyle(fontSize: 16.0, height: 1.4), // bottomNavBar
        labelSmall: TextStyle(fontSize: 13.0),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      chipTheme: ChipThemeData(
        color: WidgetStateProperty.resolveWith<Color?>((state) {
          if (state.contains(WidgetState.selected)) return colorScheme.primaryContainer;
          return colorScheme.surface;
        }),
        // selectedColor: colorScheme.primaryContainer,
        shape: StadiumBorder(side: BorderSide(color: colorScheme.primary)),
        padding: const EdgeInsets.all(4.0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        scrolledUnderElevation: 1.0,
        elevation: 0,
        surfaceTintColor: colorScheme.surface,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarIconBrightness: colorScheme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        // shadowColor: Colors.black38,
        // iconTheme: IconThemeData(color: colorScheme.onBackground),
      ),
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
        contentPadding: iFormFieldContentPadding,
        isCollapsed: true,
        // isDense: true,
        hintStyle: const TextStyle(color: Colors.black38),
        border: const OutlineInputBorder(borderRadius: iTextFieldBorderRadius, borderSide: BorderSide.none),
        // enabledBorder: OutlineInputBorder(
        //   borderRadius: iTextFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.primary.withOpacity(0.38)),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: iTextFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.primary),
        // ),
        // disabledBorder: OutlineInputBorder(
        //   borderRadius: iTextFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.onSurface.withOpacity(0.38)),
        // ),
        // errorBorder: OutlineInputBorder(
        //   borderRadius: iTextFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.error),
        // ),
        // focusedErrorBorder: OutlineInputBorder(
        //   borderRadius: iTextFieldBorderRadius,
        //   borderSide: BorderSide(width: 1.0, color: colorScheme.error),
        // ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll<double>(2.0),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iMinButtonSize),
          backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
            if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
            if (state.contains(WidgetState.error)) return colorScheme.error;
            return colorScheme.primary;
          }),
          foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iMinButtonSize),
          // backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
          //   if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
          //   if (state.contains(WidgetState.error)) return colorScheme.error;
          //   return colorScheme.primary;
          // }),
          // foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iMinButtonSize),
          // backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
          //   if (state.contains(WidgetState.disabled)) return colorScheme.primaryContainer.withAlpha(30);
          //   if (state.contains(WidgetState.error)) return colorScheme.errorContainer;
          //   return colorScheme.primaryContainer;
          // }),
          // foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimaryContainer),
          shape: WidgetStateProperty.resolveWith<OutlinedBorder>((state) {
            // Color borderColor = colorScheme.primary;
            // if (state.contains(WidgetState.disabled)) {
            //   borderColor = colorScheme.primaryContainer;
            // } else if (state.contains(WidgetState.error)) {
            //   borderColor = colorScheme.error;
            // }

            return RoundedRectangleBorder(borderRadius: iButtonBorderRadius);
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: const WidgetStatePropertyAll<Size>(iMinButtonSize),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
          side: WidgetStatePropertyAll(BorderSide(width: 1.0, color: colorScheme.outlineVariant)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2.0,
        shape: const RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          // padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(iButtonPadding),
          minimumSize: WidgetStatePropertyAll<Size>(Size.square(iMinButtonSize.shortestSide)),
          // backgroundColor: WidgetStateProperty.resolveWith<Color>((state) {
          //   if (state.contains(WidgetState.disabled)) return colorScheme.primary.withAlpha(100);
          //   if (state.contains(WidgetState.error)) return colorScheme.error;
          //   return colorScheme.primary;
          // }),
          // foregroundColor: WidgetStatePropertyAll<Color>(colorScheme.onPrimary),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: iButtonBorderRadius),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 10.0,
        dragHandleSize: const Size(25.0, 4.0),
        // modalBackgroundColor: colorScheme.surface,
        dragHandleColor: colorScheme.onSurface,
        clipBehavior: Clip.hardEdge,
        showDragHandle: true,
      ),
      listTileTheme: ListTileThemeData(minVerticalPadding: 8.0, minTileHeight: 56.0),
      navigationBarTheme: NavigationBarThemeData(backgroundColor: colorScheme.surface),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: iCardBorderRadius),
        elevation: 1.0,
        color: colorScheme.secondaryContainer,
      ),
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
