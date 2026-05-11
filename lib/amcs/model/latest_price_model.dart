// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:invesly/common_libs.dart';

class LatestPrice extends Equatable {
  final double price;
  final DateTime? date;
  final DateTime fetchDate;

  const LatestPrice({required this.price, this.date, required this.fetchDate});

  LatestPrice copyWith({double? price, DateTime? date, DateTime? fetchDate}) {
    return LatestPrice(date: date ?? this.date, price: price ?? this.price, fetchDate: fetchDate ?? this.fetchDate);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'date': date?.millisecondsSinceEpoch,
      'fetchDate': fetchDate.millisecondsSinceEpoch,
    };
  }

  factory LatestPrice.fromMap(Map<String, dynamic> map) {
    return LatestPrice(
      price: map['price'] as double,
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date'] as int) : null,
      fetchDate: DateTime.fromMillisecondsSinceEpoch(map['fetchDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory LatestPrice.fromJson(String source) => LatestPrice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [price, date, fetchDate];
}
