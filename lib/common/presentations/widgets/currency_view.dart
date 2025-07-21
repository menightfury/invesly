import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyView extends StatelessWidget {
  /// Creates a widget that takes an amount and display it in a localized currency
  /// format with the decimals smaller that the rest of the text.
  const CurrencyView({
    super.key,
    required this.amount,
    // this.currency,
    this.locale = 'en_IN',
    this.decimalDigits = 2,
    this.integerStyle,
    this.decimalsStyle,
    this.currencyStyle,
    this.privateMode = false,
    this.compactView = false,
  });

  final num amount;

  /// If `true` (the default value), the widget will display the amount with a
  /// blurred effect if the user has the private mode activated
  final bool privateMode;

  /// The currency of the amount, used to display the symbol.
  /// If not specified, will be the user preferred currency
  // final Currency? currency;
  final String locale;

  /// Style of the text that corresponds to the integer part of the number to be displayed
  final TextStyle? integerStyle;

  /// Style of the text that corresponds to the decimal part of the number to be displayed.
  /// If not defined, a less prominent style than the integerStyle will be used.
  final TextStyle? decimalsStyle;

  /// Style of the text that corresponds to the currency symbol. By default will be
  /// the same as the `decimalStyle`. This property is only defined and
  /// used if the `UINumberFormatterMode` of this Widget is set to `currency`.
  final TextStyle? currencyStyle;

  final int? decimalDigits;
  final bool compactView;

  int get _compactLimit => 1000;
  bool get _shouldCompact => compactView && amount.abs() >= _compactLimit;

  NumberFormat _getFormatter() {
    if (_shouldCompact) {
      final formatter = NumberFormat.compactCurrency(locale: locale, name: '\u20B9', decimalDigits: decimalDigits);
      // formatter.minimumFractionDigits = _fractionsDigits;
      // formatter.maximumFractionDigits = _fractionsDigits;
      return formatter;
    }

    return NumberFormat.simpleCurrency(locale: locale, name: '\u20B9', decimalDigits: decimalDigits);
  }

  String _getFormattedAmountWithoutCurrency(NumberFormat formatter) {
    final fAmount = formatter.format(amount);
    return fAmount.split(formatter.currencySymbol).join();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = _getFormatter();
    final formattedNumber = _getFormattedAmountWithoutCurrency(formatter);
    final parts = formattedNumber.split('.'); // TODO: decimal_separator

    Widget child = Text.rich(
      TextSpan(
        style: integerStyle,
        children: [
          // Currency symbol
          TextSpan(text: formatter.currencySymbol, style: currencyStyle ?? decimalsStyle ?? integerStyle),

          // Integer part
          TextSpan(text: parts[0], style: integerStyle),

          if (parts.length > 1) ...[
            // Decimal separator:
            TextSpan(text: '.', style: integerStyle), // TODO: decimal_separator
            // Decimal part
            TextSpan(text: parts[1], style: _shouldCompact ? integerStyle : (decimalsStyle ?? integerStyle)),
          ],
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (privateMode) {
      child = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0), child: child);
    }

    return child;
  }
}
