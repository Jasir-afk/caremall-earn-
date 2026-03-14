import 'package:care_mall_affiliate/src/modules/home_screen/controller/homescreen_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OverallPerformanceWidget extends StatefulWidget {
  final List<FlSpot>? spots;
  const OverallPerformanceWidget({super.key, this.spots});

  @override
  State<OverallPerformanceWidget> createState() =>
      _OverallPerformanceWidgetState();
}

class _OverallPerformanceWidgetState extends State<OverallPerformanceWidget>
    with SingleTickerProviderStateMixin {
  List<Color> gradientColors = [
    const Color(0xFF22C55E).withAlpha(51), // ~20% opacity
    const Color(0xFF22C55E).withAlpha(3), // ~1% opacity (faded)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.bordercolor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Performance',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Obx(() {
                final controller = Get.find<DashboardController>();
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 0.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value:
                          [
                            'Last 7 Days',
                            'Last 30 Days',
                            'Last 90 Days',
                          ].contains(controller.selectedTimeRange.value)
                          ? controller.selectedTimeRange.value
                          : 'Last 30 Days',
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16.sp,
                        color: Colors.grey[700],
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                        fontFamily: 'Outfit',
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          controller.updateTimeRange(newValue);
                        }
                      },
                      items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          })
                          .toList(),
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start, // Left aligned
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Obx(() {
                final controller = Get.find<DashboardController>();
                final totalAmount = controller.totalOrderAmount.value
                    .toInt()
                    .clamp(0, 1 << 31);
                final formatted = NumberFormat(
                  '#,##,###',
                  'en_IN',
                ).format(totalAmount);
                return Text(
                  '₹$formatted',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              }),
              SizedBox(width: 8.w),
              Text(
                '+10%',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF22C55E), // Green
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Obx(() {
            final controller = Get.find<DashboardController>();
            return AspectRatio(
              aspectRatio: 1.4,
              child: LineChart(mainData(controller), duration: Duration.zero),
            );
          }),
        ],
      ),
    );
  }

  LineChartData mainData(DashboardController dashboardController) {
    // Use widget.spots if provided, else use controller's spots
    final spots = (widget.spots != null && widget.spots!.isNotEmpty)
        ? widget.spots!
        : dashboardController.performanceSpots.toList();

    // 1. Calculate Max Y from chart data
    double maxY = 0;
    if (spots.isNotEmpty) {
      for (var spot in spots) {
        if (spot.y > maxY) maxY = spot.y;
      }
    }

    // 2. Make the vertical scale depend on this month's sales
    final double thisMonthSales =
        dashboardController.totalOrderAmount.value; // already in ₹
    if (thisMonthSales > 0 && thisMonthSales >= maxY) {
      maxY = thisMonthSales;
    }

    // Default scaling if data is 0 or empty
    if (maxY == 0) maxY = 10;

    // Add some buffer to the top so the line doesn't touch the max
    maxY = maxY * 1.25;

    // Calculate interval (aim for ~5 steps)
    double yInterval = maxY / 5;
    // CRITICAL: Ensure yInterval is at least 1 and finite to prevent fl_chart crashes
    if (yInterval < 1 || yInterval.isInfinite || yInterval.isNaN) {
      yInterval = 1;
    }

    // Calculate dynamic maxX
    double maxX = (spots.isNotEmpty && spots.length > 1)
        ? (spots.length - 1).toDouble()
        : 3.0;
    if (maxX < 1) maxX = 1;

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: Colors.grey[400]!, strokeWidth: 1),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.grey[300]!,
                        ),
                  ),
                );
              }).toList();
            },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.white,
          tooltipBorder: BorderSide(color: Colors.grey[300]!),
          tooltipRoundedRadius: 8,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                'Performance: ${barSpot.y.toInt()}',
                TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: const Color(0xffe7e8ec), strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: yInterval,
            getTitlesWidget: (value, meta) =>
                leftTitleWidgets(value, meta, yInterval),
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots.isNotEmpty
              ? spots
              : const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0)],
          isCurved: true,
          preventCurveOverShooting: true,
          color: const Color(0xFF22C55E), // Green line
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 1.5,
                  strokeColor: const Color(0xFF22C55E),
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.normal,
      fontSize: 9,
    );

    final controller = Get.find<DashboardController>();
    String range = controller.selectedTimeRange.value;
    int index = value.toInt();

    Widget text;
    if (range == 'Last 7 Days') {
      if (index == 0)
        text = const Text('Day 1-2', style: style);
      else if (index == 1)
        text = const Text('Day 3-4', style: style);
      else if (index == 2)
        text = const Text('Day 5-6', style: style);
      else if (index == 3)
        text = const Text('Day 7', style: style);
      else
        text = const Text('');
    } else if (range == 'Last 90 Days') {
      if (index == 0)
        text = const Text('Month 1', style: style);
      else if (index == 1)
        text = const Text('Month 2', style: style);
      else if (index == 2)
        text = const Text('Month 3', style: style);
      else if (index == 3)
        text = const Text('Month 3+', style: style);
      else
        text = const Text('');
    } else {
      // Last 30 Days (4 spots)
      if (index == 0)
        text = const Text('Week 1', style: style);
      else if (index == 1)
        text = const Text('Week 2', style: style);
      else if (index == 2)
        text = const Text('Week 3', style: style);
      else if (index == 3)
        text = const Text('Week 4', style: style);
      else
        text = const Text('');
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, double yInterval) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );

    // Format value
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}k';
      if (text.endsWith('.0k')) {
        text = text.replaceAll('.0k', 'k');
      }
    } else {
      text = value.toInt().toString();
    }

    return Text('₹$text', style: style, textAlign: TextAlign.left);
  }
}
