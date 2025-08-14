import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:invesly/constants.dart';

extension LabelOfWidget on Widget {
  Widget withLabel(String label, {EdgeInsetsGeometry? labelPadding}) {
    return Column(
      spacing: AppConstants.formFieldLabelSpacing,
      crossAxisAlignment: CrossAxisAlignment.start, // CrossAxisAlignment.stretch
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: labelPadding ?? const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(label, overflow: TextOverflow.ellipsis),
        ),
        this,
      ],
    );
  }
}
