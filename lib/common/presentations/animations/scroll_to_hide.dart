import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'animated_expanded.dart';

class ScrollToHide extends StatefulWidget {
  const ScrollToHide({
    super.key,
    required this.child,
    required this.scrollController,
    this.duration = const Duration(milliseconds: 300),
    this.hideAxis = Axis.horizontal,
    this.hideDirection = ScrollDirection.reverse,
    this.isShown = true,
  });

  final Widget child;
  final ScrollController scrollController;
  final Duration duration;
  final Axis hideAxis;
  final ScrollDirection hideDirection;
  final bool isShown;

  @override
  State<ScrollToHide> createState() => _ScrollToHideState();
}

class _ScrollToHideState extends State<ScrollToHide> {
  late bool _expand;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_listen);
    _expand = widget.isShown;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_listen);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedExpanded(expand: _expand, axis: widget.hideAxis, duration: widget.duration, child: widget.child);
  }

  void _listen() {
    _expand = widget.scrollController.position.userScrollDirection != widget.hideDirection;
    setState(() {});
  }
}
