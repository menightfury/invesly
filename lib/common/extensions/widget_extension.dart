// import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invesly/constants.dart';

extension LabelOfWidget on Widget {
  Widget withLabel(String label, {TextStyle? labelStyle, EdgeInsetsGeometry? labelPadding}) {
    final defaultLabelStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: const Color(0xFF757575),
    );
    return Column(
      spacing: iFormFieldLabelSpacing,
      crossAxisAlignment: CrossAxisAlignment.start, // CrossAxisAlignment.stretch
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: labelPadding ?? const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(label, style: defaultLabelStyle.merge(labelStyle), overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        this,
      ],
    );
  }
}
