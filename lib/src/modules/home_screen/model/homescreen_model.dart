import 'package:flutter/material.dart';

class DashboardDataModel {
  final String title;
  final String value;
  final String subtitle;
  final Color titleColor;
  final Color valueColor;
  final Color subtitleColor;
  final Color iconColor;

  /// Top right badge icon and colors
  final IconData? cardIcon;
  final Color? cardIconColor;
  final Color? cardIconBgColor;

  /// Icon shown before subtitle (e.g. arrow for "to Target").
  final IconData? subtitleIcon;
  final Color? subtitleIconColor;

  /// When set with subtitleLabel: amount in red (uses subtitleColor), label in grey.
  final String? subtitleValue;
  final String? subtitleLabel;
  final Color? subtitleLabelColor;
  final String? trendValue;
  final String? trendLabel;
  final bool? isTrendPositive;
  final VoidCallback? onTap;
  final bool showProgress;
  final double progressValue;
  final String? progressLabel;

  DashboardDataModel({
    required this.title,
    required this.value,
    this.subtitle = '',
    this.titleColor = const Color(0xFF475569),
    this.valueColor = Colors.black,
    this.subtitleColor = Colors.grey,
    required this.iconColor,
    this.cardIcon,
    this.cardIconColor,
    this.cardIconBgColor,
    this.subtitleIcon,
    this.subtitleIconColor,
    this.subtitleValue,
    this.subtitleLabel,
    this.subtitleLabelColor,
    this.trendValue,
    this.trendLabel,
    this.isTrendPositive,
    this.onTap,
    this.showProgress = false,
    this.progressValue = 0.0,
    this.progressLabel,
  });
}
