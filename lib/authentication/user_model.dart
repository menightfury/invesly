// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

class InveslyUser extends InveslyDataModel implements GoogleIdentity {
  const InveslyUser({required super.id, required this.name, required this.email, this.photoUrl});

  const InveslyUser.empty() : name = '', email = '', photoUrl = null, super(id: '');

  final String name;

  @override
  final String email;

  @override
  final String? photoUrl;

  // InveslyUser copyWith({String? name, String? email, String? photoUrl}) {
  //   return InveslyUser(
  //     id: id,
  //     name: name ?? this.name,
  //     email: email ?? this.email,
  //     photoUrl: photoUrl ?? this.photoUrl,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'email': email, 'photoUrl': photoUrl};
  }

  factory InveslyUser.fromMap(Map<String, dynamic> map) {
    return InveslyUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] != null ? map['photoUrl'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InveslyUser.fromJson(String source) => InveslyUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => super.props..addAll([name, email, photoUrl]);

  factory InveslyUser.fromGoogleSignInAccount(GoogleSignInAccount user) {
    return InveslyUser(
      id: user.id,
      name: user.displayName ?? '',
      email: user.email,
      photoUrl: user.photoUrl, // TODO: Cached network image and default avatar
    );
  }

  @override
  String get displayName => name;
}
