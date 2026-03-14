import 'package:intl/intl.dart';

class EarningSummaryModel {
  final String totalCommission;
  final String pendingCommission;
  final String withdrawableCommission;
  final String totalSales;
  final String thisMonthSales;
  final double conversionRate;
  final int conversions;
  final int totalClicks;
  final String nextPayoutDate;
  EarningSummaryModel({
    required this.totalCommission,
    required this.pendingCommission,
    required this.withdrawableCommission,
    required this.totalSales,
    required this.thisMonthSales,
    required this.conversionRate,
    required this.conversions,
    this.totalClicks = 0,
    this.nextPayoutDate = '',
  });

  factory EarningSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningSummaryModel(
      totalCommission: (json['totalCommission'] ?? '0').toString(),
      pendingCommission: (json['pendingCommission'] ?? '0').toString(),
      withdrawableCommission: (json['withdrawableCommission'] ?? '0')
          .toString(),
      totalSales: (json['totalSales'] ?? '0').toString(),
      thisMonthSales: (json['thisMonthSales'] ?? '0').toString(),
      conversionRate: (json['conversionRate'] ?? 0.0).toDouble(),
      conversions:
          (json['conversions'] ??
                  json['totalConversions'] ??
                  json['total_conversions'] ??
                  0)
              .toInt(),
      totalClicks:
          (json['totalClicks'] ??
                  json['total_clicks'] ??
                  json['clicksThisMonth'] ??
                  0)
              .toInt(),
      nextPayoutDate: (json['nextPayoutDate'] ?? '').toString(),
    );
  }
  factory EarningSummaryModel.empty() {
    return EarningSummaryModel(
      totalCommission: '0',
      pendingCommission: '0',
      withdrawableCommission: '0',
      totalSales: '0',
      thisMonthSales: '0',
      conversionRate: 0.0,
      conversions: 0,
    );
  }
}

class MonthlyEarningModel {
  final String monthlyEarning;
  final String monthlySales;
  final int confirmedConversions;
  final int commissionRate;
  final String periodStart;
  final String periodEnd;

  MonthlyEarningModel({
    required this.monthlyEarning,
    required this.monthlySales,
    required this.confirmedConversions,
    required this.commissionRate,
    required this.periodStart,
    required this.periodEnd,
  });

  factory MonthlyEarningModel.fromJson(Map<String, dynamic> json) {
    return MonthlyEarningModel(
      monthlyEarning: (json['monthlyEarning'] ?? '0').toString(),
      monthlySales: (json['monthlySales'] ?? '0').toString(),
      confirmedConversions: (json['confirmedConversions'] ?? 0).toInt(),
      commissionRate: (json['commissionRate'] ?? 0).toInt(),
      periodStart: (json['periodStart'] ?? '').toString(),
      periodEnd: (json['periodEnd'] ?? '').toString(),
    );
  }

  factory MonthlyEarningModel.empty() {
    return MonthlyEarningModel(
      monthlyEarning: '0',
      monthlySales: '0',
      confirmedConversions: 0,
      commissionRate: 0,
      periodStart: '',
      periodEnd: '',
    );
  }
}

class SlabModel {
  final String title;
  final double minSales;
  final double maxSales;
  final double commissionPercentage;
  final bool isCurrent;

  SlabModel({
    required this.title,
    required this.minSales,
    required this.maxSales,
    required this.commissionPercentage,
    this.isCurrent = false,
  });

  /// Sales range: "₹2,00,001 - ₹∞" for last (Platinum) slab, else "₹X - ₹Y".
  String get range {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    final minStr = fmt.format(minSales.toInt());
    final noUpperLimit =
        maxSales <= 0 || maxSales >= 999999999 || maxSales.isInfinite;
    if (noUpperLimit) return '₹$minStr - ₹∞';
    return '₹$minStr - ₹${fmt.format(maxSales.toInt())}';
  }

  String get commission => '${commissionPercentage.toString()}%';

  static double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.trim();
      if (cleaned.isEmpty) return 0.0;
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static bool _asBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }
    return false;
  }

  factory SlabModel.fromJson(
    Map<String, dynamic> json, {
    int? index,
    int? currentIndex,
  }) {
    final minSalesVal =
        json['minSales'] ?? json['min_sales'] ?? json['minSale'];
    final maxSalesVal =
        json['maxSales'] ?? json['max_sales'] ?? json['maxSale'];
    final commissionVal =
        json['commissionPercentage'] ??
        json['commission_percentage'] ??
        json['commission'] ??
        json['commissionPercent'] ??
        json['commission_percent'];

    return SlabModel(
      title: index != null
          ? 'Tier ${index + 1}'
          : (json['slabName'] ?? '').toString(),
      minSales: _asDouble(minSalesVal),
      maxSales: _asDouble(maxSalesVal),
      commissionPercentage: _asDouble(commissionVal),
      isCurrent: currentIndex != null
          ? index == currentIndex
          : _asBool(json['isCurrent'] ?? json['is_current']),
    );
  }
}

class PartnerBadgeModel {
  final String name;
  final String icon;
  final String color;

  PartnerBadgeModel({
    required this.name,
    required this.icon,
    required this.color,
  });

  factory PartnerBadgeModel.fromJson(Map<String, dynamic> json) {
    return PartnerBadgeModel(
      name: (json['name'] ?? 'Silver Partner').toString(),
      icon: (json['icon'] ?? '').toString(),
      color: (json['color'] ?? '0xFF6366F1').toString(),
    );
  }
}

class EarningTransactionModel {
  final String id;
  final String orderId;
  final String amount;
  final String status;
  final String date;
  final String productName;

  EarningTransactionModel({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.date,
    required this.productName,
  });

  String get formattedDate {
    try {
      if (date.isEmpty) return 'N/A';
      final dateTime = DateTime.tryParse(date);
      if (dateTime == null) return date;

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  factory EarningTransactionModel.fromJson(Map<String, dynamic> json) {
    return EarningTransactionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      amount: (json['commissionAmount'] ?? '0').toString(),
      status: (json['status'] ?? 'pending').toString(),
      date: (json['createdAt'] ?? '').toString(),
      productName: (json['productName'] ?? 'Product').toString(),
    );
  }
}
