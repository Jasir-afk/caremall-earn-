import 'dart:io';

class NetworkUtils {
  /// Checks if the device has an active internet connection.
  ///
  /// Returns `true` if connected, `false` otherwise.
  static Future<bool> isInternetConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
