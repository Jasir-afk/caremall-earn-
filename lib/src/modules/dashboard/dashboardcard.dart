import 'package:care_mall_affiliate/src/modules/home_screen/model/homescreen_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCard extends StatelessWidget {
  final DashboardDataModel data;
  const DashboardCard({super.key, required this.data});

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color stripe
              Container(
                width: 4.w,
                color: data.iconColor,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header: Title on Left, Icon badge on Right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data.title,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (data.cardIcon != null) ...[
                            SizedBox(width: 8.w),
                            Container(
                              width: 34.r,
                              height: 34.r,
                              decoration: BoxDecoration(
                                color: data.cardIconBgColor ??
                                    data.iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: Icon(
                                  data.cardIcon,
                                  size: 18.sp,
                                  color: data.cardIconColor ?? data.iconColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 14.h),
                      // Big Value
                      Text(
                        data.value,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      // Bottom Trend / Subtitle
                      if (data.trendValue != null || data.trendLabel != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (data.isTrendPositive != null) ...[
                              Icon(
                                data.isTrendPositive!
                                    ? Icons.north_east_rounded
                                    : Icons.south_east_rounded,
                                size: 13.sp,
                                color: data.isTrendPositive!
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFEF4444),
                              ),
                              SizedBox(width: 3.w),
                            ],
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF64748B),
                                    height: 1.2,
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
                        LinearProgressIndicator(
                          value: data.progressValue,
                          backgroundColor: data.iconColor.withValues(alpha: 0.1),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(data.iconColor),
                          minHeight: 6.h,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        if (data.progressLabel != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            data.progressLabel!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ] else if (data.subtitle.isNotEmpty ||
                          (data.subtitleValue != null &&
                              data.subtitleLabel != null)) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (data.subtitleIcon != null) ...[
                              Icon(
                                data.subtitleIcon,
                                size: 13.sp,
                                color: data.subtitleIconColor ??
                                    data.subtitleColor,
                              ),
                              SizedBox(width: 3.w),
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
                                      color: const Color(0xFF64748B),
                                      height: 1.2,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: data.subtitleValue,
                                        style: TextStyle(
                                          color: data.subtitleColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: data.subtitleLabel,
                                        style: TextStyle(
                                          color: data.subtitleLabelColor ??
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
                                    fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }
}
