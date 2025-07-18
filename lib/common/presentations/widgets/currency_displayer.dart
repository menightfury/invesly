import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/components/ui_number_formatter.dart';

class CurrencyDisplayer extends StatelessWidget {
  /// Creates a widget that takes an amount and display it in a localized currency
  /// format with the decimals smaller that the rest of the text.
  const CurrencyDisplayer({
    super.key,
    required this.amount,
    this.currency,
    this.showDecimals = true,
    this.integerStyle = const TextStyle(inherit: true),
    this.decimalsStyle,
    this.currencyStyle,
    this.privateMode = true,
    this.compactView = false,
  });

  final double amount;

  /// If `true` (the default value), the widget will display the amount with a
  /// blurred effect if the user has the private mode activated
  final bool privateMode;

  /// The currency of the amount, used to display the symbol.
  /// If not specified, will be the user preferred currency
  final CurrencyInDB? currency;

  /// Style of the text that corresponds to the integer part of the number to be displayed
  final TextStyle integerStyle;

  /// Style of the text that corresponds to the decimal part of the number to be displayed.
  /// If not defined, a less prominent style than the integerStyle will be used.
  final TextStyle? decimalsStyle;

  /// Style of the text that corresponds to the currency symbol. By default will be
  /// the same as the `decimalStyle`. This property is only defined and
  /// used if the `UINumberFormatterMode` of this Widget is set to `currency`.
  final TextStyle? currencyStyle;

  final bool showDecimals;
  final bool compactView;

  Widget _amountDisplayer(BuildContext context, {required CurrencyInDB currency}) {
    return UINumberFormatter.currency(
      amount: amount,
      currency: currency,
      showDecimals: showDecimals,
      integerStyle: integerStyle,
      decimalsStyle: decimalsStyle,
      currencyStyle: currencyStyle,
      compactView: compactView,
    ).getTextWidget(context);
  }

  @override
  Widget build(BuildContext context) {
    final valueFontSize = (integerStyle.fontSize ?? DefaultTextStyle.of(context).style.fontSize) ?? 16;
    Widget child = _amountDisplayer(context, currency: currency!);

    if (privateMode) {
      child = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 0.75, sigmaY: 0.75), child: child);
    }
    return child;
  }
}
