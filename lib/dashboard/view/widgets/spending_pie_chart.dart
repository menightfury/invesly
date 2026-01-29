part of '../dashboard_page.dart';

class _SpendingPieChart extends StatefulWidget {
  const _SpendingPieChart(this.stats, {super.key, this.selectedGenre, this.onSelected});

  final List<TransactionStat> stats;
  final AmcGenre? selectedGenre;
  final ValueChanged<AmcGenre?>? onSelected;

  @override
  State<_SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<_SpendingPieChart> {
  int touchedIndex = -1;
  final centerRadius = 40.0;

  @override
  void didUpdateWidget(covariant _SpendingPieChart oldWidget) {
    if (widget.stats.length != oldWidget.stats.length || widget.selectedGenre != oldWidget.selectedGenre) {
      if (widget.selectedGenre != null) {
        touchedIndex = AmcGenre.values.indexOf(widget.selectedGenre!);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.center,
      children: <Widget>[
        PinWheelReveal(
          delay: Duration(milliseconds: 0),
          duration: Duration(milliseconds: 850),
          child: PieChart(
            PieChartData(
              startDegreeOffset: -45.0,
              centerSpaceRadius: centerRadius,
              sections: _buildSections(widget.stats),
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (event, pieTouchResponse) {
                  // print(event.runtimeType);
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    return;
                  }

                  if (event.runtimeType == FlTapDownEvent) {
                    setState(() {
                      if (touchedIndex != pieTouchResponse.touchedSection!.touchedSectionIndex) {
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        final genre = touchedIndex == -1 ? null : AmcGenre.fromIndex(touchedIndex);
                        widget.onSelected?.call(genre);
                      } else {
                        touchedIndex = -1;
                        widget.onSelected?.call(null);
                      }
                    });
                  }
                  // else if (event is FlLongPressMoveUpdate) {
                  //   touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  //   // widget.setSelectedCategory(
                  //   //   widget.data[touchedIndex].category.categoryPk,
                  //   //   widget.data[touchedIndex].category,
                  //   // );
                  // }
                },
              ),
            ),
            duration: Duration(milliseconds: 1300),
            curve: ElasticOutCurve(0.6),
          ),
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 15.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: centerRadius * 2),
          ),
        ),
      ],
    );
  }

  T? nullIfIndexOutOfRange<T>(List<T> list, int index) {
    if (index < 0 || index >= list.length) {
      return null;
    } else {
      return list[index];
    }
  }

  List<PieChartSectionData> _buildSections(List<TransactionStat> stats) {
    final grandTotalAmount = stats.fold<double>(0, (v, el) => v + el.totalAmount);
    double totalPercentAccumulated = 0;

    return List.generate(AmcGenre.values.length, (i) {
      final genre = AmcGenre.fromIndex(i);
      // final stat = stats.singleWhereOrNull((stat) => stat.amc == genre);
      final filteredStats = stats.where((stat) => stat.amc.genre == genre);
      final totalAmount = filteredStats.fold<double>(0, (v, el) => v + el.totalAmount);
      final percent = grandTotalAmount == 0 ? 0.0 : ((totalAmount) / grandTotalAmount * 100).abs();

      totalPercentAccumulated += percent;

      final isTouched = i == touchedIndex;
      final radius = isTouched ? 56.0 : 50.0;
      final widgetScale = isTouched ? 1.3 : 1.0;

      return PieChartSectionData(
        color: genre.color,
        // value: stat.totalAmount == 0 ? 5 : (stats[i].total / widget.totalSpent).abs(),
        value: totalAmount,
        showTitle: false,
        radius: radius,
        badgeWidget: _Badge(
          genre,
          totalPercentAccumulated: totalPercentAccumulated,
          showLabels: false,
          scale: widgetScale,
          categoryColor: genre.color,
          percent: percent,
          isTouched: isTouched,
        ),
        titlePositionPercentageOffset: 1.4,
        badgePositionPercentageOffset: 0.98,
      );
    });
  }
}

class _Badge extends StatelessWidget {
  final AmcGenre genre;
  final double scale;
  final double percent;
  final bool isTouched;
  final bool showLabels;
  final Color categoryColor;
  final double totalPercentAccumulated;

  const _Badge(
    this.genre, {
    super.key,
    required this.scale,
    required this.percent,
    required this.isTouched,
    required this.showLabels,
    required this.categoryColor,
    required this.totalPercentAccumulated,
  });

  @override
  Widget build(BuildContext context) {
    bool showIcon = percent.abs() < 5;
    return AnimatedScale(
      curve: showIcon ? Curves.easeInOutCubicEmphasized : ElasticOutCurve(0.6),
      duration: showIcon ? Duration(milliseconds: 700) : Duration(milliseconds: 1300),
      scale: showIcon && isTouched == false ? 0 : (showLabels || isTouched ? (showIcon ? 1 : scale) : 0),
      child: Container(
        height: 42.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: genre.color.lighten(70),
          border: Border.all(color: genre.color, width: 2.0),
        ),
        child: Center(child: Icon(genre.icon, size: 24.0, color: genre.color)),
      ),
    );
  }
}

class PinWheelReveal extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const PinWheelReveal({
    super.key,
    required this.child,
    required this.duration,
    this.delay = Duration.zero,
    this.curve = Curves.easeInOutCubic,
  });

  @override
  _PinWheelRevealState createState() => _PinWheelRevealState();
}

class _PinWheelRevealState extends State<PinWheelReveal> with SingleTickerProviderStateMixin {
  double? _fraction = 0.0;
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween(begin: 0.0, end: 1.0).animate(new CurvedAnimation(parent: _controller, curve: widget.curve))
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      });

    Future.delayed(widget.delay, () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CirclePainter(fraction: _fraction!),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomClipper<Path> {
  final double? fraction;

  CirclePainter({this.fraction});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width + 500),
      _degreesToRadians(-90).toDouble(),
      (_degreesToRadians(360 * fraction!).toDouble()),
    );
    path.arcTo(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: 0),
      _degreesToRadians(269.999 * fraction!).toDouble(),
      _degreesToRadians(-90).toDouble() - _degreesToRadians((269.999) * fraction!).toDouble(),
      false,
    );
    return path;
  }

  @override
  bool shouldReclip(CirclePainter oldClipper) {
    return oldClipper.fraction != fraction;
  }
}

num _degreesToRadians(num deg) => deg * (math.pi / 180);
