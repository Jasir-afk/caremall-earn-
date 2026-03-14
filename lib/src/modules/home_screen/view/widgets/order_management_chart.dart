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

  @override
  State<OrderManagementChart> createState() => _OrderManagementChartState();
}

class _OrderManagementChartState extends State<OrderManagementChart>
    with SingleTickerProviderStateMixin {
  @override
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
                    sectionsSpace: 0,
                    centerSpaceRadius: 70.w,
                    sections: totalOrders == 0
                        ? [
                            PieChartSectionData(
                              color: Colors.grey[200]!,
                              value: 1,
                              title: '',
                              radius: 25.w,
                            ),
                          ]
                        : [
                            PieChartSectionData(
                              color: const Color(0xFFD92D20), // Cancelled - Red
                              value: cancelled.toDouble(),
                              title: '',
                              radius: 25.w,
                            ),
                            PieChartSectionData(
                              color: const Color(
                                0xFF2D8A29,
                              ), // Delivered - Dark Green
                              value: delivered.toDouble(),
                              title: '',
                              radius: 25.w,
                            ),
                            PieChartSectionData(
                              color: const Color(
                                0xFFF79009,
                              ), // Processing - Orange
                              value: processing.toDouble(),
                              title: '',
                              radius: 25.w,
                            ),
                            PieChartSectionData(
                              color: const Color(
                                0xFF7F56D9,
                              ), // Returned - Purple
                              value: returned.toDouble(),
                              title: '',
                              radius: 25.w,
                            ),
                          ],
                  ),
                  duration: Duration.zero,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalOrders',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
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
                      const Color(0xFFD92D20),
                      'Cancelled',
                      cancelled,
                    ),
                    SizedBox(width: 24.w),
                    _buildLegendItem(
                      const Color(0xFF2D8A29),
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
                      const Color(0xFFF79009),
                      'Processing',
                      processing,
                    ),
                    SizedBox(width: 24.w),
                    _buildLegendItem(
                      const Color(0xFF7F56D9),
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
