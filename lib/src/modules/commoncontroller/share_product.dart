import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<XFile?> downloadImageToCache(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      debugPrint("HTTP ${response.statusCode} for $url");
      return null;
    }

    final cacheDir = await getTemporaryDirectory();
    final fileName = url.split('/').last.split('?').first;
    final filePath = '${cacheDir.path}/share_$fileName';

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    // Verify file exists
    if (await file.exists()) {
      return XFile(filePath);
    } else {
      debugPrint("File not created: $filePath");
      return null;
    }
  } catch (e) {
    debugPrint("Download failed: $e");
    return null;
  }
}

class ProductSharingService {
  static Future<void> shareProduct({
    required String name,
    required String url,
    double? mrp,
    double? sellingPrice,
    String? imageUrl,
  }) async {
    String priceText = '';
    if (mrp != null && sellingPrice != null && mrp > sellingPrice) {
      priceText =
          '\nProduct Price: ₹${mrp % 1 == 0 ? mrp.toInt().toString() : mrp.toStringAsFixed(2)}';
    } else if (sellingPrice != null) {
      priceText =
          '\nPrice: ₹${sellingPrice % 1 == 0 ? sellingPrice.toInt().toString() : sellingPrice.toStringAsFixed(2)}';
    } else if (mrp != null) {
      priceText =
          '\nPrice: ₹${mrp % 1 == 0 ? mrp.toInt().toString() : mrp.toStringAsFixed(2)}';
    }

    final String message = '*$name*$priceText\n\nCheck it out: $url';
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final XFile? imageFile = await downloadImageToCache(imageUrl);
        if (imageFile != null) {
          await Share.shareXFiles([imageFile], text: message);
          return;
        }
      }
      await Share.share(message);
    } catch (e) {
      debugPrint('ProductSharingService: Share exception: $e');
      await Share.share(message);
    }
  }
}
