import 'package:care_mall_affiliate/src/modules/orders/view/all_order_screen.dart';
import 'package:flutter/material.dart';

class DeliveredOrderScreen extends StatelessWidget {
  const DeliveredOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OrderScreen(status: 'delivered');
  }
}
