import 'dart:async';
import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';

import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/model/kyc_model.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/repo/kyc_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:shared_preferences/shared_preferences.dart';

class KycController extends GetxController {
  final isLoading = false.obs;
  final userData = Rxn<KycModel>();

  /// Completes when the first profile fetch (KYC data) is done.
  final Completer<void> _profileReadyCompleter = Completer<void>();
  Future<void> get profileLoaded => _profileReadyCompleter.future;

  @override
  void onInit() {
    super.onInit();
    getKycData();
  }

  void clearData() {
    userData.value = null;
    debugPrint("KycController: Data cleared.");
  }

  Future<void> getKycData() async {
    // If already loading, don't trigger another fetch
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      debugPrint("KycController: Fetching KYC data...");
      // Both getKycData and getProfileData in Repo hit the same endpoint (kycupdates)
      // so we only need to call it once.
      final result = await KycProfileRepo.getKycData();

      if (result['success'] && result['data'] != null) {
        final kycModel = KycModel.fromJson(result['data']);
        debugPrint(
          "KycController: KYC data fetched. Status: ${kycModel.kycStatus}",
        );

        // Sync system status
        if (result['full_response'] != null) {
          await _syncStatus(result['full_response']);
        }

        // Robust Merge: Update existing state instead of replacing it
        _updateUserData(kycModel);
      }
    } catch (e) {
      debugPrint("KycController: Error fetching KYC data: $e");
    } finally {
      isLoading.value = false;
      // Always complete the future, even on error, to avoid blocking splash
      if (!_profileReadyCompleter.isCompleted) {
        _profileReadyCompleter.complete();
      }
    }
  }

  /// Helper to merge new data into existing state to prevent field loss
  void _updateUserData(KycModel newData) {
    if (userData.value == null) {
      userData.value = newData;
      _syncWithAuth(newData);
      return;
    }

    final current = userData.value!;

    // Create a new model with merged contents
    final merged = KycModel(
      fullName: (newData.fullName?.isNotEmpty == true)
          ? newData.fullName
          : current.fullName,
      email: (newData.email?.isNotEmpty == true)
          ? newData.email
          : current.email,
      dateOfBirth: (newData.dateOfBirth?.isNotEmpty == true)
          ? newData.dateOfBirth
          : current.dateOfBirth,
      gender: (newData.gender?.isNotEmpty == true)
          ? newData.gender
          : current.gender,
      address: _mergeAddress(current.address, newData.address),
      bankAccountNumber: (newData.bankAccountNumber?.isNotEmpty == true)
          ? newData.bankAccountNumber
          : current.bankAccountNumber,
      ifscCode: (newData.ifscCode?.isNotEmpty == true)
          ? newData.ifscCode
          : current.ifscCode,
      bankName: (newData.bankName?.isNotEmpty == true)
          ? newData.bankName
          : current.bankName,
      bankBranch: (newData.bankBranch?.isNotEmpty == true)
          ? newData.bankBranch
          : current.bankBranch,
      accountHolderName: (newData.accountHolderName?.isNotEmpty == true)
          ? newData.accountHolderName
          : current.accountHolderName,
      upiId: (newData.upiId?.isNotEmpty == true)
          ? newData.upiId
          : current.upiId,
      upiNumber: (newData.upiNumber?.isNotEmpty == true)
          ? newData.upiNumber
          : current.upiNumber,
      paymentMethod: (newData.paymentMethod?.isNotEmpty == true)
          ? newData.paymentMethod
          : current.paymentMethod,
      aadharFrontImage: (newData.aadharFrontImage?.isNotEmpty == true)
          ? newData.aadharFrontImage
          : current.aadharFrontImage,
      aadharBackImage: (newData.aadharBackImage?.isNotEmpty == true)
          ? newData.aadharBackImage
          : current.aadharBackImage,
      kycStatus: (newData.kycStatus?.isNotEmpty == true)
          ? newData.kycStatus
          : current.kycStatus,
    );

    userData.value = merged;
    _syncWithAuth(merged);
    debugPrint(
      "KycController: State merged. Name: ${userData.value?.fullName}",
    );
  }

  void _syncWithAuth(KycModel model) {
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      authController.saveUserData(
        name: model.fullName,
        email: model.email,
        kyc: model.kycStatus,
      );
    }
  }

  Address? _mergeAddress(Address? current, Address? newData) {
    if (newData == null) return current;
    if (current == null) return newData;

    return Address(
      street: (newData.street?.isNotEmpty == true)
          ? newData.street
          : current.street,
      city: (newData.city?.isNotEmpty == true) ? newData.city : current.city,
      state: (newData.state?.isNotEmpty == true)
          ? newData.state
          : current.state,
      pincode: (newData.pincode?.isNotEmpty == true)
          ? newData.pincode
          : current.pincode,
    );
  }

  Future<void> _syncStatus(Map<String, dynamic> json) async {
    try {
      debugPrint("KycController: Syncing status from JSON: $json");
      // Look for status in multiple places/keys
      final rawStatus =
          json['kycData']?['kycStatus'] ??
          json['kycStatus'] ??
          json['kyc_status'] ??
          json['status'] ??
          json['data']?['kycStatus'] ??
          json['data']?['kyc_status'] ??
          json['data']?['status'];

      if (rawStatus != null) {
        final status = rawStatus.toString().toLowerCase().trim();
        if (status.isNotEmpty && status != 'null') {
          if (Get.isRegistered<AuthController>()) {
            final authController = Get.find<AuthController>();
            await authController.saveUserData(kyc: status);
            debugPrint("KycController: Status Sync Success -> $status");
          }
        }
      }
    } catch (e) {
      debugPrint("KycController: Error in _syncStatus: $e");
    }
  }

  Future<void> refreshKycData() async {
    await getKycData();
  }

  Future<void> submitKyc({
    required KycModel kycData,
    Function? onSuccess,
    Function(String)? onError,
  }) async {
    isLoading.value = true;

    try {
      final result = await KycProfileRepo.submitKycData(kycData.toJson());

      debugPrint("KYC Response Code: ${result['statusCode']}");
      debugPrint("KYC Response Body: ${result['data']}");

      final responseData = result['data'];
      final statusCode = result['statusCode'];

      if (result['success']) {
        try {
          if (Get.isRegistered<AuthController>()) {
            final authController = Get.find<AuthController>();

            // Robust check for kyc status in response
            final statusFromResponse =
                responseData['kycData']?['kycStatus'] ??
                responseData['kycData']?['kyc_status'] ??
                responseData['kycStatus'] ??
                responseData['kyc_status'] ??
                responseData['status'] ??
                'pending';

            // Centralized Save (Updates memory AND SharedPreferences)
            await authController.saveUserData(
              kyc: statusFromResponse.toString().toLowerCase(),
            );

            debugPrint(
              "KycController: Persisted kycStatus to -> ${authController.kycStatus.value}",
            );
          }
        } catch (e) {
          debugPrint("Failed to update kycStatus in AuthController: $e");
        }

        // Fetch fresh state from server
        await getKycData();

        if (onSuccess != null) {
          onSuccess();
          // Snackbar shown in onSuccess after navigating to home
        } else {
          TcSnackbar.success(
            'Success',
            result['message'] ?? 'KYC submitted successfully',
          );
        }
      } else {
        String errorMessage = result['message'] ?? 'KYC Submission Failed';

        if (statusCode == 401) {
          errorMessage = "Session expired. Please login again.";
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('auth_token');
        }

        // Handle 'already pending' as a pseudo-success
        if (errorMessage.toLowerCase().contains('already pending')) {
          try {
            if (Get.isRegistered<AuthController>()) {
              final authController = Get.find<AuthController>();
              await authController.saveUserData(kyc: 'pending');
              debugPrint(
                "KycController: Handled 'already pending' and persisted status.",
              );
            }
          } catch (e) {}

          TcSnackbar.success('Success', errorMessage);
          await getKycData();
          if (onSuccess != null) onSuccess();
          return;
        }

        TcSnackbar.error('Error', errorMessage);
        if (onError != null) onError(errorMessage);
      }
    } catch (e) {
      TcSnackbar.error('Error', 'Network error. Please try again.');
      if (onError != null) onError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
