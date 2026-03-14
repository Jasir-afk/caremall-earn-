import 'package:care_mall_affiliate/src/modules/home_screen/model/homescreen_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCard extends StatelessWidget {
  final DashboardDataModel data;
  const DashboardCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: data.iconColor, width: 4.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data.trendValue != null || data.trendLabel != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (data.isTrendPositive != null)
                        Icon(
                          data.isTrendPositive!
                              ? Icons.north_east_rounded
                              : Icons.south_east_rounded,
                          size: 14.sp,
                          color: data.isTrendPositive!
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      if (data.isTrendPositive != null) SizedBox(width: 4.w),
                      Flexible(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                            children: [
                              if (data.trendValue != null)
                                TextSpan(
                                  text: '${data.trendValue} ',
                                  style: TextStyle(
                                    color: data.isTrendPositive == true
                                        ? const Color(0xFF22C55E)
                                        : data.isTrendPositive == false
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (data.trendLabel != null &&
                                  data.trendLabel!.isNotEmpty)
                                TextSpan(text: data.trendLabel),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (data.showProgress) ...[
                  SizedBox(height: 12.h),
                  LinearProgressIndicator(
                    value: data.progressValue,
                    backgroundColor: data.iconColor.withAlpha(4),
                    valueColor: AlwaysStoppedAnimation<Color>(data.iconColor),
                    minHeight: 6.h,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  if (data.progressLabel != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      data.progressLabel!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ] else if (data.subtitle.isNotEmpty ||
                    (data.subtitleValue != null &&
                        data.subtitleLabel != null)) ...[
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data.subtitleIcon != null) ...[
                        Icon(
                          data.subtitleIcon,
                          size: 14.sp,
                          color: data.subtitleIconColor ?? data.subtitleColor,
                        ),
                        SizedBox(width: 4.w),
                      ],
                      if (data.subtitleValue != null &&
                          data.subtitleLabel != null)
                        Flexible(
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: data.subtitleValue,
                                  style: TextStyle(color: data.subtitleColor),
                                ),
                                TextSpan(
                                  text: data.subtitleLabel,
                                  style: TextStyle(
                                    color:
                                        data.subtitleLabelColor ??
                                        const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: Text(
                            data.subtitle,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: data.subtitleColor,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
