import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderManagementChart extends StatefulWidget {
  final Map<String, int> data;
  final String selectedTimeRange;
  final Function(String) onTimeRangeChanged;

  const OrderManagementChart({
    super.key,
    required this.data,
    required this.selectedTimeRange,
    required this.onTimeRangeChanged,
  });

  State<OrderManagementChart> createState() => _OrderManagementChartState();
}

class _OrderManagementChartState extends State<OrderManagementChart>
    with SingleTickerProviderStateMixin {
  Widget build(BuildContext context) {
    final displayData = widget.data;

    final int totalOrders = displayData.values.fold(
      0,
      (sum, item) => sum + item,
    );
    final processing = displayData['pending'] ?? 0;
    final delivered = displayData['completed'] ?? 0;
    final cancelled = displayData['cancelled'] ?? 0;
    final returned = displayData['returned'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.bordercolor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Management',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D0D1B),
                    ),
                  ),
                  Text(
                    'Distribution of order statuses',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value:
                        [
                          'Last 7 Days',
                          'Last 30 Days',
                          'Last 90 Days',
                        ].contains(widget.selectedTimeRange)
                        ? widget.selectedTimeRange
                        : 'Last 30 Days',
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    items: ['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: [
                                Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (e == widget.selectedTimeRange) ...[
                                  SizedBox(width: 8.w),
                                ],
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onTimeRangeChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 200.h,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: totalOrders == 0 ? 0 : 4,
                    centerSpaceRadius: 65.w,
                    startDegreeOffset: -90,
                    sections: totalOrders == 0
                        ? [
                            PieChartSectionData(
                              color: Colors.grey[200]!,
                              value: 1,
                              title: '',
                              radius: 20.w,
                              showTitle: false,
                            ),
                          ]
                        : [
                            if (returned > 0)
                              PieChartSectionData(
                                color: const Color(0xFF7080EE), // Returned - Purple/Blue
                                value: returned.toDouble(),
                                title: '',
                                radius: 20.w,
                                showTitle: false,
                              ),
                            if (cancelled > 0)
                              PieChartSectionData(
                                color: const Color(0xFFEB4444), // Cancelled - Red
                                value: cancelled.toDouble(),
                                title: '',
                                radius: 20.w,
                                showTitle: false,
                              ),
                            if (processing > 0)
                              PieChartSectionData(
                                color: const Color(0xFFEE9209), // Processing - Amber/Orange
                                value: processing.toDouble(),
                                title: '',
                                radius: 20.w,
                                showTitle: false,
                              ),
                            if (delivered > 0)
                              PieChartSectionData(
                                color: const Color(0xFF27B558), // Delivered - Vibrant Green
                                value: delivered.toDouble(),
                                title: '',
                                radius: 20.w,
                                showTitle: false,
                              ),
                          ],
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF8C98A4),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$totalOrders',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(
                      const Color(0xFFEB4444),
                      'Cancelled',
                      cancelled,
                    ),
                    SizedBox(width: 24.w),
                    _buildLegendItem(
                      const Color(0xFF27B558),
                      'Delivered',
                      delivered,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(
                      const Color(0xFFEE9209),
                      'Processing',
                      processing,
                    ),
                    SizedBox(width: 24.w),
                    _buildLegendItem(
                      const Color(0xFF7080EE),
                      'Returned',
                      returned,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF475467),
              fontWeight: FontWeight.w400,
              fontFamily: 'Outfit',
            ),
            children: [
              TextSpan(text: '$label: '),
              TextSpan(
                text: '$value',
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
