// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import 'package:invesly/common_libs.dart';

class LatestPrice extends Equatable {
  final double price;
  final DateTime? date;
  final DateTime fetchDate;

  const LatestPrice({required this.price, this.date, required this.fetchDate});

  DateFormat get _dateFormat => DateFormat('yyyy-MM-dd');

  LatestPrice copyWith({double? price, DateTime? date, DateTime? fetchDate}) {
    return LatestPrice(date: date ?? this.date, price: price ?? this.price, fetchDate: fetchDate ?? this.fetchDate);
  }

  Map<String, dynamic> toMap() {
    final now = DateTime.now();
    return <String, dynamic>{
      'price': price,
      'date': _dateFormat.format(date ?? now),
      'fetchDate': _dateFormat.format(fetchDate),
    };
  }

  factory LatestPrice.fromMap(Map<String, dynamic> map) {
    return LatestPrice(
      date: map['date'] != null ? _dateFormat.tryParse(map['date'] as String) : null,
      price: map['price'] as double,
      fetchDate: DateTime.parse(map['fetchDate'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory LatestPrice.fromJson(String source) => LatestPrice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [date, price];
}
