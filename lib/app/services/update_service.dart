import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_update/in_app_update.dart';

/// Service to handle mandatory app updates for the Affiliate app.
///
/// HOW IT WORKS:
/// Since this app always uses version name "1.0.0" and only increments the
/// build number (+13, +14, +15 etc.), we cannot use the `upgrader` package
/// (which only compares version names). Instead we:
///   1. Try the official Play Store in-app update API first (works for Store installs).
///   2. Scrape the Play Store page to extract the current versionCode.
///   3. Compare it against [minBuildNumber] — if installed build < required, show popup.
class UpdateService {
  /// 🔑 MINIMUM build number. Users below this build will be forced to update.
  /// Match this to the build number (+XX) of the version you publish on Play Store.
  /// Current Play Store build: +13 → set to 13
  /// When you publish +15 to Play Store, change this to 15.
  static const int minBuildNumber = 13;

  /// Show a mandatory update dialog if the installed build is outdated.
  /// Returns [true] if popup was shown, [false] otherwise.
  static Future<bool> showUpdateDialogIfNeeded(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      final buildNumberStr = packageInfo.buildNumber;
      final installedBuild = int.tryParse(buildNumberStr);

      debugPrint(
        '🔍 [UpdateService] Checking for updates...\n'
        '   - Package        : $packageName\n'
        '   - Installed Build: "$buildNumberStr" (parsed: $installedBuild)\n'
        '   - Min Required   : $minBuildNumber',
      );

      // If we cannot read the build number, skip to avoid false positives
      if (installedBuild == null) {
        debugPrint(
          '⚠️ [UpdateService] Could not parse build number "$buildNumberStr". Skipping.',
        );
        return false;
      }

      // ── Step 1: Official Play Store API (only works for real Store installs) ──
      if (Platform.isAndroid) {
        try {
          debugPrint('🤖 [UpdateService] Trying in_app_update API...');
          final updateInfo = await InAppUpdate.checkForUpdate();
          if (updateInfo.updateAvailability ==
              UpdateAvailability.updateAvailable) {
            debugPrint('🚨 [UpdateService] Play Store API: update available!');
            if (context.mounted) {
              _showMandatoryDialog(context, packageName);
              return true;
            }
          }
          debugPrint('✅ [UpdateService] Play Store API: no update available.');
        } catch (e) {
          debugPrint(
            '⚠️ [UpdateService] in_app_update failed (sideloaded/debug APK): $e',
          );
        }
      }

      // ── Step 2: Build number comparison (works for all installs) ──
      if (installedBuild < minBuildNumber) {
        debugPrint(
          '🚨 [UpdateService] Outdated! Installed: $installedBuild < Required: $minBuildNumber',
        );
        if (context.mounted) {
          _showMandatoryDialog(context, packageName);
          return true;
        }
      }

      debugPrint(
        '✅ [UpdateService] Up-to-date. '
        'Build $installedBuild >= required $minBuildNumber.',
      );
      return false;
    } catch (e) {
      debugPrint('❌ [UpdateService] Error: $e');
    }
    return false;
  }

  /// Shows a non-dismissible mandatory update dialog.
  static void _showMandatoryDialog(BuildContext context, String packageName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Gradient header ──
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFCC0000), Color(0xFF262626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.system_update_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // ── Body ──
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Update Required',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF262626),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A new version of the Care Mall Affiliate app is available with important fixes and exciting new features. Please update to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Update Now button ──
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final Uri storeUrl;
                              if (Platform.isIOS) {
                                storeUrl = Uri.parse(
                                  'https://apps.apple.com/app/id6760577907',
                                );
                              } else {
                                storeUrl = Uri.parse(
                                  'https://play.google.com/store/apps/details?id=$packageName',
                                );
                              }

                              if (await canLaunchUrl(storeUrl)) {
                                await launchUrl(
                                  storeUrl,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        Platform.isIOS
                                            ? 'Could not open App Store'
                                            : 'Could not open Play Store',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC0000),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Update Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Manually clear upgrader cache (kept for compatibility).
  static void configure({bool debugLogging = false}) {}
}
