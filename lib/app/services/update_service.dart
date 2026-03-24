import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to handle app updates for the Affiliate app
class UpdateService {
  /// Show a mandatory update dialog (users MUST update to continue).
  /// Returns [true] if the dialog was shown (update needed), [false] otherwise.
  static Future<bool> showUpdateDialogIfNeeded(
    BuildContext context, {
    bool force = false,
  }) async {
    try {
      // Get actual app version & package name
      final packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;
      final currentVersion = packageInfo.version;

      debugPrint(
        '🔍 [UpdateService] Checking for updates. '
        'Current Version: $currentVersion, Package: $packageName',
      );

      final upgrader = Upgrader(
        debugLogging: true,
        debugDisplayAlways: force,
        durationUntilAlertAgain: const Duration(seconds: 1),
      );

      debugPrint('🚀 [UpdateService] Initializing Upgrader...');
      // Use a timeout to prevent hanging if Play Store is unreachable
      await upgrader.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ [UpdateService] Upgrader initialization timed out.');
          return false;
        },
      );

      final storeVersion = upgrader.currentAppStoreVersion;
      final installedVersion = upgrader.currentInstalledVersion;
      final updateAvailable = upgrader.isUpdateAvailable();

      debugPrint('📊 [UpdateService] Diagnostics:');
      debugPrint('   - Package Name    : $packageName');
      debugPrint('   - Installed       : $installedVersion');
      debugPrint('   - Play Store      : $storeVersion');
      debugPrint('   - Update Available: $updateAvailable');
      debugPrint('   - Force Mode      : $force');

      final shouldShow = updateAvailable || force;

      if (!shouldShow) {
        debugPrint('✅ [UpdateService] No update needed. Proceeding to app.');
        return false;
      }

      debugPrint('🚨 [UpdateService] Showing mandatory update dialog...');

      if (context.mounted) {
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
                      // ── Gradient header ──────────────────────────────
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

                      // ── Body ─────────────────────────────────────────
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

                            // ── Update Now button ─────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final playStoreUrl = Uri.parse(
                                    'https://play.google.com/store/apps/details?id=$packageName',
                                  );

                                  if (await canLaunchUrl(playStoreUrl)) {
                                    await launchUrl(
                                      playStoreUrl,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Could not open Play Store',
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
        return true;
      }
    } catch (e) {
      debugPrint('❌ [UpdateService] Error: $e');
    }
    return false;
  }

  /// Wrap your app root with UpgradeAlert (useful for production non-mandatory nagging)
  static Widget wrapWithUpgradeAlert({required Widget child}) {
    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: true,
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: child,
    );
  }

  /// Returns an UpgradeCard widget for embedding inside settings or profile
  static Widget getUpgradeCard() {
    return UpgradeCard(
      upgrader: Upgrader(
        debugLogging: true,
        durationUntilAlertAgain: const Duration(days: 1),
      ),
    );
  }

  /// Manually clear settings or configure upgrader (e.g. for testing)
  static void configure({bool debugLogging = false}) {
    Upgrader.clearSavedSettings();
  }
}
