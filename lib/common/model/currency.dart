import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  const Currency({required this.code, required this.symbol, required this.name});

  /// ISO 4217 currency code. Identifies a currency uniquely ([see more](https://en.wikipedia.org/wiki/ISO_4217#List_of_ISO_4217_currency_codes))
  final String code;

  /// Symbol to represent the currency
  final String symbol;

  /// Name of the currency (in the user language at database creation)
  final String name;

  Currency copyWith({String? code, String? symbol, String? name}) =>
      Currency(code: code ?? this.code, symbol: symbol ?? this.symbol, name: name ?? this.name);

  @override
  List<Object?> get props => [code, symbol, name];

  Map<String, dynamic> toMap() {
    return {'code': code, 'symbol': symbol, 'name': name};
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(code: map['code'] ?? '', symbol: map['symbol'] ?? '', name: map['name'] ?? '');
  }

  static const empty = Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee');
}
