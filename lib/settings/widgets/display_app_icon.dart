import 'package:flutter/material.dart';

class DisplayAppIcon extends StatelessWidget {
  const DisplayAppIcon({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFF0F3375),
      ),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(aspectRatio: 1, child: Image.asset('assets/resources/appIcon.png', fit: BoxFit.fill)),
      ),
    );
  }
}
