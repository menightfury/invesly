import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:invesly/authentication/user_model.dart';

class InveslyUserCircleAvatar extends StatelessWidget {
  const InveslyUserCircleAvatar({
    super.key,
    required this.user,
    this.placeholderPhotoUrl,
    this.foregroundColor,
    this.backgroundColor,
  });

  final InveslyUser user;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final String? placeholderPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final placeholderChar = [
      user.displayName.trimLeft(),
      user.email.trimLeft(),
      '-',
    ].firstWhere((str) => str.isNotEmpty)[0].toUpperCase();
    Widget placeholder = Center(child: Text(placeholderChar, textAlign: TextAlign.center));

    final photoUrl = user.photoUrl ?? placeholderPhotoUrl;

    return CircleAvatar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      foregroundImage: photoUrl != null ? CachedNetworkImageProvider(photoUrl) : null,
      child: photoUrl == null ? placeholder : null,
    );
  }
}
