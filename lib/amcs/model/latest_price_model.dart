// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:invesly/common_libs.dart';

class LatestPrice extends Equatable {
  final DateTime date;
  final double price;

  const LatestPrice({required this.date, required this.price});

  LatestPrice copyWith({DateTime? date, double? price}) {
    return LatestPrice(date: date ?? this.date, price: price ?? this.price);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'date': '${date.year}-${date.month}-${date.day}', 'price': price};
  }

  factory LatestPrice.fromMap(Map<String, dynamic> map) {
    return LatestPrice(date: DateTime.parse(map['date'] as String), price: map['price'] as double);
  }

  String toJson() => json.encode(toMap());

  factory LatestPrice.fromJson(String source) => LatestPrice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [date, price];
}
