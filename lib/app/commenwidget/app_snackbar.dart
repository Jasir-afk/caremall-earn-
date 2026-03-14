import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class TcSnackbar {
  // 🔒 Prevent rapid-fire snackbar calls
  static bool _isShowing = false;

  static void success(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.successMain,
      icon: Icons.check_circle_outline,
    );
  }

  static void warning(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.warningMain,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void error(String title, String message) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: AppColors.errorMain,
      icon: Icons.error_outline,
    );
  }

  static Future<void> _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) async {
    // ✅ Ensure GetX context exists
    if (Get.context == null) {
      debugPrint('⚠️ Snackbar called before context is ready');
      return;
    }

    // 🛑 Block stacking & rapid calls
    if (_isShowing) return;
    _isShowing = true;

    try {
      // 🔥 Force close existing snackbars
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        await Future.delayed(const Duration(milliseconds: 120));
      }

      // 🎯 Optional haptic feedback
      HapticFeedback.lightImpact();

      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        icon: Icon(icon, color: Colors.white),
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        maxWidth: 600,
        duration: const Duration(seconds: 3),
        isDismissible: true,
        animationDuration: const Duration(milliseconds: 250),
        titleText: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        messageText: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Snackbar error: $e');
    } finally {
      // 🕒 Cooldown to fully prevent stacking
      await Future.delayed(const Duration(milliseconds: 500));
      _isShowing = false;
    }
  }
}
