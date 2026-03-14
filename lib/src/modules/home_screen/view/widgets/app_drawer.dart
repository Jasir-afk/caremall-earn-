import 'package:care_mall_affiliate/gen/assets.gen.dart';
import 'package:care_mall_affiliate/src/modules/auth/view/login_screen.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/view/genate_links.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/view/all_link_view.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/controller/link_controller.dart';
import 'package:care_mall_affiliate/src/modules/earning/view/earning_screen.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/home_screen.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/cancelled_order.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/all_order_screen.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/delived_order.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/pending_order.dart';
import 'package:care_mall_affiliate/src/modules/orders/view/return_order.dart';
import 'package:care_mall_affiliate/src/modules/orders/controller/order_controller.dart';
import 'package:care_mall_affiliate/src/modules/payout/view/payout_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header: Logo and Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 35,
                    child: Assets.icons.appLogoPng.image(fit: BoxFit.fitHeight),
                  ),
                  const SizedBox(width: 12),

                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]!),

            // Profile Section: Showing real user data
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                final name = authController.userName.value;
                final email = authController.userEmail.value;
                // Get the first letter of the name for the avatar initial
                final initial = name.isNotEmpty ? name[0].toLowerCase() : 'u';

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.red,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name.isNotEmpty ? name : 'User',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email.isNotEmpty ? email : 'No email provided',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
            Divider(height: 1, color: Colors.grey[200]!),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.grid_view_outlined,
                    label: 'Dashboard',
                    isSelected:
                        Get.currentRoute == '/HomeScreen' ||
                        Get.currentRoute == '/',
                    onTap: () {
                      Get.back();
                      if (Get.currentRoute != '/HomeScreen' &&
                          Get.currentRoute != '/') {
                        Get.offAll(() => const HomeScreen());
                      }
                    },
                  ),
                  _buildExpansionTile(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Affiliate Orders',
                    children: [
                      _buildDrawerItem(
                        icon: Icons.list,
                        label: 'All Orders',
                        isSelected: Get.currentRoute == '/OrderScreen',
                        onTap: () {
                          Get.back();
                          if (Get.currentRoute != '/OrderScreen') {
                            if (!Get.isRegistered<OrderController>()) {
                              Get.put(OrderController());
                            }
                            Get.find<OrderController>().clearFilters();
                            Get.to(() => const OrderScreen());
                          }
                        },
                        isSubItem: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.check_circle_outline,
                        label: 'Delivered Orders',
                        isSelected: Get.currentRoute == '/DeliveredOrderScreen',
                        onTap: () {
                          Get.back();
                          if (!Get.isRegistered<OrderController>()) {
                            Get.put(OrderController());
                          }
                          Get.find<OrderController>().clearFilters();
                          Get.to(() => const DeliveredOrderScreen());
                        },
                        isSubItem: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.access_time,
                        label: 'Pending Orders',
                        isSelected: Get.currentRoute == '/PendingOrderScreen',
                        onTap: () {
                          Get.back();
                          if (!Get.isRegistered<OrderController>()) {
                            Get.put(OrderController());
                          }
                          Get.find<OrderController>().clearFilters();
                          Get.to(() => const PendingOrderScreen());
                        },
                        isSubItem: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.cancel_outlined,
                        label: 'Cancelled Orders',
                        isSelected: Get.currentRoute == '/CancelledOrderScreen',
                        onTap: () {
                          Get.back();
                          if (!Get.isRegistered<OrderController>()) {
                            Get.put(OrderController());
                          }
                          Get.find<OrderController>().clearFilters();
                          Get.to(() => const CancelledOrderScreen());
                        },
                        isSubItem: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.assignment_return_outlined,
                        label: 'Returned Orders',
                        isSelected: Get.currentRoute == '/ReturnOrderScreen',
                        onTap: () {
                          Get.back();
                          if (!Get.isRegistered<OrderController>()) {
                            Get.put(OrderController());
                          }
                          Get.find<OrderController>().clearFilters();
                          Get.to(() => const ReturnOrderScreen());
                        },
                        isSubItem: true,
                      ),
                    ],
                  ),
                  _buildDrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Earning Panel',
                    isSelected: Get.currentRoute == '/EarningScreen',
                    onTap: () {
                      Get.back();
                      Get.to(() => const EarningScreen());
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.payments_outlined,
                    label: 'Payout Panel',
                    isSelected: Get.currentRoute == '/PayoutView',
                    onTap: () {
                      Get.back();
                      Get.to(() => const PayoutView());
                    },
                  ),
                  _buildExpansionTile(
                    icon: Icons.link,
                    label: 'Affiliate Link',
                    initiallyExpanded: Get.currentRoute == '/CreateLinkView',
                    children: [
                      _buildDrawerItem(
                        icon: Icons.add,
                        label: 'Create Link',
                        isSelected: Get.currentRoute == '/CreateLinkView',
                        onTap: () {
                          Get.back();
                          if (Get.currentRoute != '/GenerateLinksScreen') {
                            final linkController =
                                Get.isRegistered<CreateLinkController>()
                                ? Get.find<CreateLinkController>()
                                : Get.put(CreateLinkController());
                            linkController.clearSearch();
                            Get.to(() => const GenerateLinksScreen());
                          }
                        },
                        isSubItem: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.list,
                        label: 'All Links',
                        isSelected: Get.currentRoute == '/AllLinkView',
                        onTap: () {
                          Get.back();
                          if (Get.currentRoute != '/AllLinkView') {
                            final linkController =
                                Get.isRegistered<CreateLinkController>()
                                ? Get.find<CreateLinkController>()
                                : Get.put(CreateLinkController());
                            linkController.clearSearch();
                            Get.to(() => const AllLinkView());
                          }
                        },
                        isSubItem: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer: Logout
            Divider(height: 1, color: Colors.grey[200]!),
            _buildDrawerItem(
              icon: Icons.logout_outlined,
              label: 'Logout',
              onTap: () => _showLogoutConfirmation(context, authController),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AuthController authController,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to logout of this app?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back(); // Close bottom sheet
                      Get.back(); // Close drawer
                      await authController.logout();
                      Get.offAll(() => const LoginScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    bool isSubItem = false,
  }) {
    return Container(
      margin: EdgeInsets.only(left: isSubItem ? 16 : 0),
      decoration: BoxDecoration(
        border: isSubItem
            ? Border(left: BorderSide(color: Colors.grey[200]!, width: 1))
            : null,
      ),
      child: ListTile(
        leading: icon != null
            ? Icon(
                icon,
                color: isSelected ? Colors.red : Colors.black87,
                size: 20,
              )
            : null,
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: isSubItem ? 16 : 16),
        dense: true,
        onTap: onTap,
      ),
    );
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String label,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: ThemeData().copyWith(
        dividerColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.black87, size: 20),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: initiallyExpanded,
        children: children,
      ),
    );
  }
}
