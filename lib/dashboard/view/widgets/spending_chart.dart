import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 800,
        minY: 0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(color: Colors.black54, fontSize: 12);
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Apr 25';
                    break;
                  case 1:
                    text = 'May 25';
                    break;
                  case 2:
                    text = 'Jun 25';
                    break;
                  case 3:
                    text = 'Jul 25';
                    break;
                  case 4:
                    text = 'Aug 25';
                    break;
                  case 5:
                    text = 'Sep 25';
                    break;
                  default:
                    text = '';
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 200,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox();
                return SideTitleWidget(
                  meta: meta,
                  child: Text('\$${value.toInt()}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 200,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey[200], strokeWidth: 1);
          },
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, 300, Colors.green),
          _buildBarGroup(1, 600, Colors.green),
          _buildBarGroup(2, 500, Colors.green),
          _buildBarGroup(3, 700, Colors.green),
          _buildBarGroup(4, 550, Colors.green),
          _buildBarGroup(5, 450, Colors.green),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
        ),
      ],
    );
  }
}
