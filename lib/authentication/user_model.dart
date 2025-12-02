// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/database/table_schema.dart';

class InveslyUser extends InveslyDataModel implements GoogleIdentity {
  const InveslyUser({required super.id, required this.name, required this.email, this.photoUrl, this.gapiAccessToken});

  // const InveslyUser.empty() : name = '', email = '', photoUrl = null, gapiAccessToken = null, super(id: '');

  final String name;

  @override
  final String email;

  @override
  final String? photoUrl;

  final AccessToken? gapiAccessToken;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'gapiAccessToken': gapiAccessToken?.toJson(),
    };
  }

  factory InveslyUser.fromMap(Map<String, dynamic> map) {
    return InveslyUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
      gapiAccessToken: map['gapiAccessToken'] != null
          ? AccessToken.fromJson(map['gapiAccessToken'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InveslyUser.fromJson(String source) => InveslyUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => super.props..addAll([name, email, photoUrl, gapiAccessToken]);

  @override
  String get displayName => name;
}

extension InveslyUserX on InveslyUser? {
  // bool get isNullOrEmpty => this == null || this == InveslyUser.empty();
  bool get isNullOrEmpty => this == null;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
