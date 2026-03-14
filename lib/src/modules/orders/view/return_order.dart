import 'package:care_mall_affiliate/src/modules/orders/view/all_order_screen.dart';
import 'package:flutter/material.dart';

class ReturnOrderScreen extends StatelessWidget {
  const ReturnOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrderScreen(status: 'returned');
  }
}
