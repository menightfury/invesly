import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invesly/common/model/currency.dart';
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
  final Currency? currency;

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

  int get _compactLimit => 1000;
  int get _fractionsDigits =>
      amount >= 10000000
          ? 3
          : amount >= 100000
          ? 2
          : 1;

  bool get _shouldCompact => compactView && amount.abs() >= _compactLimit;

  String _getFormattedCurrencyAmount(String decimalSep) {
    if (_shouldCompact) {
      final formatter = NumberFormat.compactCurrency(decimalDigits: 2, symbol: currency?.symbol);
      formatter.minimumFractionDigits = _fractionsDigits;
      formatter.maximumFractionDigits = _fractionsDigits;

      return formatter.format(amount);
    } else {
      return NumberFormat.currency(decimalDigits: showDecimals ? 2 : 0, symbol: currency?.symbol).format(amount);
    }
  }

  List<String> _splitAndKeepDelimiter(String input, String delimiter) {
    if (delimiter.isEmpty) {
      throw ArgumentError('Delimiter cannot be an empty string.');
    }

    final regex = RegExp('(${RegExp.escape(delimiter)})');

    // Use a set of chars that do not collide with the formatted amount (and its currency)
    const splitSep = '**';

    return input
        .splitMapJoin(
          regex,
          onMatch: (match) => '$splitSep${match.group(0)}$splitSep',
          onNonMatch: (nonMatch) => nonMatch,
        )
        .split(splitSep)
        .where((element) => element.isNotEmpty)
        .toList();
  }

  List<TextSpan> _getTextSpanListForAFormattedNumber(String number, {required double fontSize}) {
    final decimalSep = currentDecimalSep;

    List<String> parts = number.split(decimalSep);

    final computedDecimalStyles =
        decimalsStyle ??
        integerStyle.copyWith(
          fontWeight: FontWeight.w300,
          fontSize: fontSize > 12.25 ? max(fontSize * 0.75, 12.25) : fontSize,
        );

    return [
      // Integer part
      TextSpan(text: parts[0], style: integerStyle),

      // Decimal separator:
      if (parts.length > 1) TextSpan(text: decimalSep, style: integerStyle),

      // Decimal part
      if (parts.length > 1) TextSpan(text: parts[1], style: _shouldCompact ? integerStyle : computedDecimalStyles),
    ];
  }

  List<TextSpan> getTextSpanList(BuildContext context) {
    final valueFontSize = (integerStyle.fontSize ?? DefaultTextStyle.of(context).style.fontSize) ?? 16;

    final String formattedAmount = _getFormattedCurrencyAmount('.');

    final List<TextSpan> toReturn = [];

    for (final elementToDisplay in _splitAndKeepDelimiter(formattedAmount, _currencySymbolWithoutDecimalSep)) {
      if (elementToDisplay == currency?.symbol) {
        toReturn.add(TextSpan(text: currency!.symbol, style: currencyStyle ?? integerStyle));
      } else {
        toReturn.addAll(_getTextSpanListForAFormattedNumber(elementToDisplay, fontSize: valueFontSize));
      }
    }

    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    final valueFontSize = (integerStyle.fontSize ?? DefaultTextStyle.of(context).style.fontSize) ?? 16;
    Widget child = Text.rich(
      TextSpan(style: integerStyle, children: getTextSpanList(context)),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (privateMode) {
      child = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 0.75, sigmaY: 0.75), child: child);
    }

    return child;
  }
}
