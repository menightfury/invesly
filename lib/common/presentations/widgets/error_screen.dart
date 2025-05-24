import 'package:flutter/material.dart';
import 'package:invesly/common/presentations/widgets/error_widget.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: PMErrorWidget());
  }
}
