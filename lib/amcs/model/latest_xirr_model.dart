// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:invesly/common_libs.dart';

class LatestXirr extends Equatable {
  final double xirr;
  final DateTime date;

  const LatestXirr({required this.xirr, required this.date});

  LatestXirr copyWith({double? xirr, DateTime? date}) {
    return LatestXirr(date: date ?? this.date, xirr: xirr ?? this.xirr);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'xirr': xirr, 'date': date.millisecondsSinceEpoch};
  }

  factory LatestXirr.fromMap(Map<String, dynamic> map) {
    return LatestXirr(xirr: map['xirr'] as double, date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int));
  }

  String toJson() => json.encode(toMap());

  factory LatestXirr.fromJson(String source) => LatestXirr.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [xirr, date];
}
