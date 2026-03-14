import 'package:app_links/app_links.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/controller/link_controller.dart';
import 'package:care_mall_affiliate/src/modules/affilatelinks/view/genate_links.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();

  // Store pending deep link
  static Uri? pendingDeepLink;

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      pendingDeepLink = initialUri;
    }

    _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  static void processPendingLink() {
    if (pendingDeepLink != null) {
      _instance._handleUri(pendingDeepLink!);
      pendingDeepLink = null;
    }
  }

  void _handleUri(Uri uri) {
    debugPrint('DeepLinkService: Handling URI: $uri');
    debugPrint('DeepLinkService: Scheme: ${uri.scheme}');
    debugPrint('DeepLinkService: Host: ${uri.host}');
    debugPrint('DeepLinkService: Path: ${uri.path}');

    // Only handle HTTPS links to caremallonline.com/product/...
    // caremall:// scheme belongs to the CareMall customer app — not intercepted here.
    final bool isCorrectHost = uri.host.contains('caremallonline.com');
    final bool isProductPath =
        uri.pathSegments.isNotEmpty &&
        (uri.pathSegments[0] == 'product' ||
            (uri.pathSegments.length >= 2 && uri.pathSegments[1] == 'product'));

    if (!isCorrectHost || !isProductPath) {
      debugPrint('DeepLinkService: URI does not match criteria');
      return;
    }

    String slug = '';
    if (uri.pathSegments[0] == 'product' && uri.pathSegments.length >= 2) {
      slug = uri.pathSegments[1];
    } else if (uri.pathSegments.length >= 3 &&
        uri.pathSegments[1] == 'product') {
      slug = uri.pathSegments[2];
    }

    if (slug.isEmpty) {
      debugPrint('DeepLinkService: No slug found in path segments');
      return;
    }

    debugPrint(
      'DeepLinkService: Navigating to GenerateLinksScreen for slug: $slug',
    );

    // Navigate to GenerateLinksScreen
    Get.to(() => const GenerateLinksScreen());

    // Trigger search in CreateLinkController
    try {
      if (Get.isRegistered<CreateLinkController>()) {
        final controller = Get.find<CreateLinkController>();
        controller.searchProducts(slug);
      } else {
        final controller = Get.put(CreateLinkController());
        controller.searchProducts(slug);
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }
}
