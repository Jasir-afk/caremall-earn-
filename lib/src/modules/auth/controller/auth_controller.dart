import 'dart:async';
import 'dart:convert';
import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_repo.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/controller/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Controller using GetX for state management
/// Handles all authentication-related business logic
class AuthController extends GetxController {
  // Observable states
  final isLoading = false.obs;
  final isResendingOtp = false.obs;

  // User data
  final phoneNumber = ''.obs;
  final userName = ''.obs;
  final userEmail = ''.obs;
  final authToken = ''.obs;
  final kycStatus = ''.obs; // pending, approved, null

  /// Completes when auth data has been loaded from SharedPreferences.
  /// Await this before checking [authToken] to avoid race conditions.
  final Completer<void> _authReadyCompleter = Completer<void>();
  Future<void> get authDataLoaded => _authReadyCompleter.future;

  @override
  void onInit() {
    super.onInit();
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load Token
      final savedToken = prefs.getString('auth_token');
      if (savedToken != null) {
        authToken.value = savedToken;
        // Sync with GetStorage for DioInterceptor
        final storage = GetStorage();
        if (storage.read('token') == null) {
          storage.write('token', savedToken);
        }
      }

      // Load User Data (including KYC Status)
      final savedUserData = prefs.getString('user_data');
      if (savedUserData != null) {
        try {
          final Map<String, dynamic> userData = Map<String, dynamic>.from(
            jsonDecode(savedUserData),
          );
          userName.value = userData['name'] ?? '';
          userEmail.value = userData['email'] ?? '';
          phoneNumber.value = userData['phone'] ?? '';
          kycStatus.value = userData['kycStatus'] ?? '';
          debugPrint("Auth Data Loaded: KYC Status -> ${kycStatus.value}");
        } catch (e) {
          debugPrint("Error parsing saved user data: $e");
        }
      }

      debugPrint(
        "Auth loading complete. Token present: ${authToken.value.isNotEmpty}",
      );
    } finally {
      // Always complete the future, even on error
      if (!_authReadyCompleter.isCompleted) {
        _authReadyCompleter.complete();
      }
    }
  }

  /// Sends OTP for login
  Future<void> sendLoginOtp({
    required String phone,
    Function? onSuccess,
    Function(String)? onError,
  }) async {
    isLoading.value = true;

    try {
      final result = await AuthRepo.sendOtp(phone: phone, mode: 'login');

      if (result['success']) {
        phoneNumber.value = phone;
        TcSnackbar.success('Success', result['message']);
        if (onSuccess != null) onSuccess();
      } else {
        TcSnackbar.error('Error', result['message']);
        if (onError != null) onError(result['message']);
      }
    } catch (e) {
      TcSnackbar.error('Error', 'Failed to send OTP: ${e.toString()}');
      if (onError != null) onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends OTP for signup/registration
  Future<void> sendSignupOtp({
    required String phone,
    required String name,
    required String email,
    Function? onSuccess,
    Function(String)? onError,
  }) async {
    isLoading.value = true;

    try {
      final result = await AuthRepo.sendOtp(
        phone: phone,
        mode: 'signup',
        name: name,
        email: email,
      );

      if (result['success']) {
        phoneNumber.value = phone;
        userName.value = name;
        userEmail.value = email;
        TcSnackbar.success('Success', result['message']);
        if (onSuccess != null) onSuccess();
      } else {
        TcSnackbar.error('Error', result['message']);
        if (onError != null) onError(result['message']);
      }
    } catch (e) {
      TcSnackbar.error('Error', 'Failed to send OTP: ${e.toString()}');
      if (onError != null) onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies the OTP entered by user
  Future<void> verifyOtp({
    required String phone,
    required String otp,
    Function? onSuccess,
    Function(String)? onError,
  }) async {
    isLoading.value = true;

    try {
      final result = await AuthRepo.verifyOtp(phone: phone, otp: otp);

      if (result['success']) {
        // Save authentication token if provided
        if (result['token'] != null) {
          authToken.value = result['token'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', result['token']);
          await GetStorage().write('token', result['token']);
        }

        TcSnackbar.success('Success', result['message']);
        if (onSuccess != null) {
          await _loadAuthData();
          onSuccess();
        }
      } else {
        TcSnackbar.error('Error', result['message']);
        if (onError != null) onError(result['message']);
      }
    } catch (e) {
      TcSnackbar.error('Error', 'Failed to verify OTP: ${e.toString()}');
      if (onError != null) onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Resends OTP using stored user data
  Future<void> resendOtp({
    required String mode,
    Function? onSuccess,
    Function(String)? onError,
  }) async {
    isResendingOtp.value = true;

    try {
      final result = await AuthRepo.sendOtp(
        phone: phoneNumber.value,
        mode: mode,
        name: mode == 'signup' ? userName.value : '',
        email: mode == 'signup' ? userEmail.value : '',
      );

      if (result['success']) {
        TcSnackbar.success('Success', result['message']);
        if (onSuccess != null) onSuccess();
      } else {
        TcSnackbar.error('Error', result['message']);
        if (onError != null) onError(result['message']);
      }
    } catch (e) {
      TcSnackbar.error('Error', 'Failed to resend OTP: ${e.toString()}');
      if (onError != null) onError(e.toString());
    } finally {
      isResendingOtp.value = false;
    }
  }

  /// Saves user data to SharedPreferences for persistence
  Future<void> saveUserData({
    String? name,
    String? email,
    String? phone,
    String? kyc,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Update local observables if non-empty values are provided
    if (name != null && name.isNotEmpty) userName.value = name;
    if (email != null && email.isNotEmpty) userEmail.value = email;
    if (phone != null && phone.isNotEmpty) phoneNumber.value = phone;

    // Only update and persist kyc if it's a valid non-empty string
    if (kyc != null && kyc.isNotEmpty && kyc.toLowerCase() != 'null') {
      kycStatus.value = kyc.toLowerCase().trim();
    }

    // Create JSON for persistence - Always save current memory state
    final Map<String, String> userData = {
      "name": userName.value,
      "email": userEmail.value,
      "phone": phoneNumber.value,
      "kycStatus": kycStatus.value,
    };

    await prefs.setString('user_data', jsonEncode(userData));
    debugPrint("Auth Data Saved to SharedPreferences: $userData");
  }

  /// Clears all authentication data
  Future<void> logout() async {
    phoneNumber.value = '';
    userName.value = '';
    userEmail.value = '';
    authToken.value = '';
    kycStatus.value = '';
    isLoading.value = false;
    isResendingOtp.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await GetStorage().remove('token');
    await GetStorage().remove('user');

    // Clear KYC state if controller is registered
    try {
      if (Get.isRegistered<KycController>()) {
        Get.find<KycController>().clearData();
      }
    } catch (e) {
      debugPrint("Error clearing KycController on logout: $e");
    }
  }

  /// Deletes user account from server and logs out locally
  Future<void> deleteAccount({
    Function? onSuccess,
    Function(String)? onError,
  }) async {
    isLoading.value = true;
    try {
      final result = await AuthRepo.deleteAccount();

      if (result['success']) {
        await logout();
        if (onSuccess != null) onSuccess();
        TcSnackbar.success('Success', result['message']);
      } else {
        if (onError != null) onError(result['message']);
        TcSnackbar.error('Error', result['message']);
      }
    } catch (e) {
      final errorMsg = 'Failed to delete account: ${e.toString()}';
      if (onError != null) onError(errorMsg);
      TcSnackbar.error('Error', errorMsg);
    } finally {
      isLoading.value = false;
    }
  }
}
