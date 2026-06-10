import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:http/http.dart' as http;

/// Service to handle mandatory app updates for the Affiliate app.
class UpdateService {
  // ─── Configuration ───
  static const int minBuildNumber = 14;
  // Trigger update if installed semantic version is less than this.
  static const String minAppVersion = '1.0.0';
  static const String appleAppId = '6760577907';
  // ─── Public Methods ───
  /// Checks if an update is required and shows a non-dismissible popup if so.
  /// Returns [true] if a popup was shown (halting the app), [false] otherwise.
  static Future<bool> showUpdateDialogIfNeeded(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      final installedVersion = packageInfo.version;
      final installedBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Step 1: Dynamic check against App Stores
      bool updateAvailable = false;

      if (Platform.isAndroid) {
        updateAvailable = await _checkPlayStoreAPI();
      } else if (Platform.isIOS) {
        updateAvailable = await _checkAppStoreAPI(installedVersion);
      }

      // Step 2: Trigger popup if update is found
      if (updateAvailable) {
        _logStatus(
          packageName,
          installedBuild,
          installedVersion,
          "Update Required",
        );
        if (context.mounted) {
          _triggerPopup(context, packageName);
          return true;
        }
      }

      _logStatus(packageName, installedBuild, installedVersion, "Up to date");
      return false;
    } catch (e) {
      debugPrint('❌ [UpdateService] Error: $e');
      return false;
    }
  }

  // ─── Internal Logic ───

  static void _logStatus(String pkg, int build, String version, String status) {
    debugPrint(
      '🔍 [UpdateService] Status: $status\n'
      '   - Package: $pkg\n'
      '   - Installed: $version (Build $build)',
    );
  }

  static bool _isInstalledVersionLess(String installed, String required) {
    try {
      final installedParts = installed
          .split('.')
          .map((e) => int.parse(e))
          .toList();
      final requiredParts = required
          .split('.')
          .map((e) => int.parse(e))
          .toList();

      final maxLen = installedParts.length > requiredParts.length
          ? installedParts.length
          : requiredParts.length;

      for (var i = 0; i < maxLen; i++) {
        final a = i < installedParts.length ? installedParts[i] : 0;
        final b = i < requiredParts.length ? requiredParts[i] : 0;
        if (a == b) continue;
        return a < b;
      }
      return false;
    } catch (_) {
      // If parsing fails, don't block users due to bad version format.
      return false;
    }
  }

  static Future<bool> _checkPlayStoreAPI() async {
    try {
      final info = await InAppUpdate.checkForUpdate().timeout(
        const Duration(seconds: 5),
      );
      return info.updateAvailability == UpdateAvailability.updateAvailable;
    } catch (e) {
      debugPrint('⚠️ [UpdateService] Play Store API failure: $e');
      return false;
    }
  }

  static Future<bool> _checkAppStoreAPI(String installedVersion) async {
    try {
      final url =
          'https://itunes.apple.com/lookup?id=$appleAppId&country=in&t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final storeVersion = data['results'][0]['version'];
          return _isInstalledVersionLess(installedVersion, storeVersion);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [UpdateService] App Store API failure: $e');
    }
    return false;
  }

  static void _triggerPopup(BuildContext context, String packageName) async {
    // Small delay to ensure Navigator is ready and transitions look smooth
    await Future.delayed(const Duration(milliseconds: 200));
    if (!context.mounted) return;

    Get.dialog(
      _MandatoryUpdateDialog(packageName: packageName),
      barrierDismissible: false,
    );
  }

  /// Placeholder for future remote config init
  static void configure({bool debugLogging = false}) {}
}

// ─── UI Components ───

class _MandatoryUpdateDialog extends StatelessWidget {
  final String packageName;

  const _MandatoryUpdateDialog({required this.packageName});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_buildHeader(), _buildBody(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCC0000), Color(0xFF262626)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: const Icon(
        Icons.system_update_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Update Required',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'A new version of the Care Mall Earn+ app is available. Please update to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _launchStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC0000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Update Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchStore() async {
    final url = Platform.isIOS
        ? 'https://apps.apple.com/in/app/care-mall-earn/id${UpdateService.appleAppId}'
        : 'https://play.google.com/store/apps/details?id=$packageName';

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Update',
          'Could not open the store link',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Update',
        'Could not open the store link',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
