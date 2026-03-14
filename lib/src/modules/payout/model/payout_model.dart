import 'package:intl/intl.dart';

class PayoutModel {
  final String id;
  final String affiliateId;
  final int month;
  final int year;
  final double totalSales;
  final double commissionPercentage;
  final double commissionAmount;
  final double payoutAmount;
  final double tdsDeduction;
  final double otherDeduction;
  final String payoutMethod; // 'upi' | 'bank_transfer' | 'wallet' etc.
  final String payoutStatus; // 'pending' | 'completed' | 'failed' | 'processing'
  final String paidAt;
  final String remarks;
  final String createdAt;

  const PayoutModel({
    required this.id,
    required this.affiliateId,
    required this.month,
    required this.year,
    required this.totalSales,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.payoutAmount,
    required this.tdsDeduction,
    required this.otherDeduction,
    required this.payoutMethod,
    required this.payoutStatus,
    required this.paidAt,
    required this.remarks,
    required this.createdAt,
  });

  /// Display-friendly formatted date e.g. "2 Mar 2026"
  String get formattedDate {
    try {
      final dateStr = paidAt.isNotEmpty ? paidAt : createdAt;
      if (dateStr.isEmpty) return _fallbackDate();
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return _fallbackDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return _fallbackDate();
    }
  }

  String _fallbackDate() {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    if (month >= 1 && month <= 12) {
      return '${monthNames[month - 1]} $year';
    }
    return 'N/A';
  }

  /// Full month+year label e.g. "February 2026"
  String get monthYearLabel {
    const fullMonthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    if (month >= 1 && month <= 12) {
      return '${fullMonthNames[month - 1]} $year';
    }
    return 'N/A';
  }

  /// Human-readable payment method label
  String get methodLabel {
    switch (payoutMethod.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'wallet':
        return 'Wallet';
      case 'neft':
        return 'NEFT';
      case 'imps':
        return 'IMPS';
      default:
        return payoutMethod
            .split('_')
            .map(
              (w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}',
            )
            .join(' ');
    }
  }

  /// Formatted payout amount using Indian locale e.g. "₹1,102"
  String get formattedPayoutAmount {
    try {
      final fmt = NumberFormat('#,##,##0.##', 'en_IN');
      return '₹${fmt.format(payoutAmount)}';
    } catch (_) {
      return '₹${payoutAmount.toStringAsFixed(0)}';
    }
  }

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    final deductions = json['deductions'] as Map<String, dynamic>? ?? {};
    return PayoutModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      affiliateId: (json['affiliateId'] ?? '').toString(),
      month: _toInt(json['month'] ?? 0),
      year: _toInt(json['year'] ?? 0),
      totalSales: _toDouble(json['totalSales'] ?? 0),
      commissionPercentage: _toDouble(json['commissionPercentage'] ?? 0),
      commissionAmount: _toDouble(json['commissionAmount'] ?? 0),
      payoutAmount: _toDouble(json['payoutAmount'] ?? json['amount'] ?? 0),
      tdsDeduction: _toDouble(deductions['tds'] ?? 0),
      otherDeduction: _toDouble(deductions['other'] ?? 0),
      payoutMethod: (json['payoutMethod'] ?? json['method'] ?? '').toString(),
      payoutStatus:
          (json['payoutStatus'] ?? json['status'] ?? 'pending')
              .toString()
              .toLowerCase(),
      paidAt: (json['paidAt'] ?? '').toString(),
      remarks: (json['remarks'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

/// Summary stats shown in the top card grid.
/// Derived locally from the payouts list.
class PayoutSummaryModel {
  final int totalPayouts;
  final int completedPayouts;
  final int pendingPayouts;
  final double totalPayoutAmount;
  final double pendingPayoutAmount;
  final double completedPayoutAmount;

  const PayoutSummaryModel({
    required this.totalPayouts,
    required this.completedPayouts,
    required this.pendingPayouts,
    required this.totalPayoutAmount,
    required this.pendingPayoutAmount,
    required this.completedPayoutAmount,
  });

  /// Build summary by deriving from the full payout list.
  factory PayoutSummaryModel.fromList(List<PayoutModel> payouts) {
    final completed =
        payouts.where((p) => p.payoutStatus == 'completed').toList();
    final pending =
        payouts.where((p) => p.payoutStatus == 'pending').toList();

    return PayoutSummaryModel(
      totalPayouts: payouts.length,
      completedPayouts: completed.length,
      pendingPayouts: pending.length,
      totalPayoutAmount: payouts.fold(0.0, (s, p) => s + p.payoutAmount),
      completedPayoutAmount: completed.fold(0.0, (s, p) => s + p.payoutAmount),
      pendingPayoutAmount: pending.fold(0.0, (s, p) => s + p.payoutAmount),
    );
  }

  factory PayoutSummaryModel.empty() => const PayoutSummaryModel(
    totalPayouts: 0,
    completedPayouts: 0,
    pendingPayouts: 0,
    totalPayoutAmount: 0,
    completedPayoutAmount: 0,
    pendingPayoutAmount: 0,
  );
}
