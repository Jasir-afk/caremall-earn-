import 'package:flutter/foundation.dart';

class RecentOrderModel {
  final String id;
  final String orderId;
  final String customerName;
  final String status;
  final String amount;
  final String productName;
  final String productImage;
  final String date;
  final String itemCount;

  RecentOrderModel({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.productName,
    required this.productImage,
    required this.status,
    required this.amount,
    required this.date,
    required this.itemCount,
  });

  String get formattedDate {
    try {
      if (date.isEmpty) return 'N/A';
      final dateTime = DateTime.parse(date);
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
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$day ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    // Default values
    String pName = (json['productName'] ?? '').toString();
    String pImage = (json['productImage'] ?? '').toString();
    String itemCount = "1";
    if (json['totalItems'] != null) {
      itemCount = json['totalItems'].toString();
    } else if (json['totalQuantity'] != null) {
      itemCount = json['totalQuantity'].toString();
    } else if (json['productCount'] != null) {
      itemCount = json['productCount'].toString();
    } else if (json['itemCount'] != null) {
      itemCount = json['itemCount'].toString();
    } else if (json['totalQty'] != null) {
      itemCount = json['totalQty'].toString();
    } else if (json['items'] is List) {
      final items = json['items'] as List;
      int total = 0;
      for (var item in items) {
        if (item is Map) {
          total +=
              int.tryParse((item['quantity'] ?? item['qty'] ?? 1).toString()) ??
              1;
        } else {
          total += 1;
        }
      }
      itemCount = total.toString();
    } else if (json['quantity'] != null) {
      itemCount = json['quantity'].toString();
    }
    debugPrint("DEBUG: Order ${json['orderId']} - Final itemCount: $itemCount");

    // Check nested product object (Return API structure)
    if (json['product'] != null && json['product'] is Map) {
      final product = json['product'];
      if (pName.isEmpty) {
        pName = (product['productName'] ?? '').toString();
      }
      if (pImage.isEmpty) {
        if (product['productImages'] is List &&
            (product['productImages'] as List).isNotEmpty) {
          pImage = product['productImages'][0].toString();
        } else if (product['image'] != null) {
          pImage = product['image'].toString();
        }
      }
    }

    // Check nested items (Standard Order structure)
    if (json['items'] is List && (json['items'] as List).isNotEmpty) {
      final firstItem = json['items'][0];
      if (firstItem['product'] != null) {
        final product = firstItem['product'];
        if (pName.isEmpty) {
          pName = (product['productName'] ?? '').toString();
        }
        if (pImage.isEmpty) {
          if (product['productImages'] is List &&
              (product['productImages'] as List).isNotEmpty) {
            pImage = product['productImages'][0].toString();
          } else if (product['image'] != null) {
            pImage = product['image'].toString();
          }
        }
      }
    }

    // fallback for pName if still empty
    if (pName.isEmpty) pName = 'Unknown Product';

    String status = (json['orderStatus'] ?? json['status'] ?? 'Pending')
        .toString();

    // Explicit return status check
    if (json['isReturned'] == true ||
        json['returned'] == true ||
        json['return'] == true ||
        status.toLowerCase() ==
            'approved' || // Approved in return list usually means return approved
        status.toLowerCase() == 'refunded') {
      status = 'returned';
    }

    return RecentOrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      customerName: (json['customerName'] ?? 'Customer').toString(),
      productName: pName,
      productImage: pImage,
      status: status,
      amount:
          (json['refundAmount'] ??
                  json['amount'] ??
                  json['referredAmount'] ??
                  json['finalAmount'] ??
                  json['returnAmount'] ??
                  '0')
              .toString(),
      date: (json['createdAt'] ?? json['orderDate'] ?? json['date'] ?? '')
          .toString(),
      itemCount: itemCount,
    );
  }
}
