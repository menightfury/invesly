// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';
// import 'package:equatable/equatable.dart';
// import 'package:invesly/common_libs.dart';

// class LatestXirr extends Equatable {
//   final double value;
//   final DateTime date;

//   const LatestXirr({required this.value, required this.date});

//   LatestXirr copyWith({double? value, DateTime? date}) {
//     return LatestXirr(date: date ?? this.date, value: value ?? this.value);
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{'value': value, 'date': date.millisecondsSinceEpoch};
//   }

//   factory LatestXirr.fromMap(Map<String, dynamic> map) {
//     return LatestXirr(value: map['value'] as double, date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int));
//   }

//   String toJson() => json.encode(toMap());

//   factory LatestXirr.fromJson(String source) => LatestXirr.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   bool get stringify => true;

//   @override
//   List<Object?> get props => [value, date];
// }
