import 'dart:async';
import 'package:care_mall_affiliate/app/app_buttons/app_buttons.dart';
import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/app/commenwidget/apptext.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/app/utils/network/auth_service.dart';
import 'package:care_mall_affiliate/app/utils/spaces.dart';
import 'package:care_mall_affiliate/gen/assets.gen.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/home_screen.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/view/kyc_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String mode; // "login" or "signup"
  final String? name;
  final String? email;

  const OTPVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.mode,
    this.name,
    this.email,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  Timer? _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOTP() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    final otp = _getOTP();

    if (otp.length != 6) {
      TcSnackbar.error('Error', 'Please enter complete 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.verifyOtp(
        phone: widget.phoneNumber,
        otp: otp,
      );

      if (mounted) {
        if (result['success']) {
          TcSnackbar.success('Success', result['message']);

          final String nameVal = widget.name?.trim() ?? '';
          final String emailVal = widget.email?.trim() ?? '';
          final String phoneVal = widget.phoneNumber.trim();

          // Sync into AuthController so Drawer updates without restart
          if (Get.isRegistered<AuthController>()) {
            final authCtrl = Get.find<AuthController>();

            String kycStatusStr = '';
            final responseData = result['data'];
            if (responseData is Map) {
              kycStatusStr =
                  (responseData['kycStatus'] ??
                          responseData['kyc_status'] ??
                          responseData['status'] ??
                          responseData['user']?['kycStatus'] ??
                          '')
                      .toString()
                      .toLowerCase()
                      .trim();
            }

            // Centralized Save
            await authCtrl.saveUserData(
              name: nameVal,
              email: emailVal,
              phone: phoneVal,
              kyc: kycStatusStr,
            );
          }

          final authCtrl = Get.find<AuthController>();
          final statusVal = authCtrl.kycStatus.value.toLowerCase();
          final bool kycSubmitted =
              statusVal == 'pending' || statusVal == 'approved';

          // Navigate: KYC screen only for confirmed new users,
          // HomeScreen for everyone else (banner handles the nudge there)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => kycSubmitted || statusVal.isEmpty
                  ? const HomeScreen()
                  : KycScreen(),
            ),
            (route) => false,
          );
        } else {
          TcSnackbar.error('Error', result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        TcSnackbar.error('Error', 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      final result = await AuthService.sendOtp(
        phone: widget.phoneNumber,
        mode: widget.mode,
        name: widget.name ?? '',
        email: widget.email ?? '',
      );

      if (mounted) {
        TcSnackbar.success('Success', result['message']);
        if (result['success']) {
          setState(() {
            _start = 30;
          });
          startTimer();
        }
      }
    } catch (e) {
      if (mounted) {
        TcSnackbar.error('Error', 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _editNumber() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight -
                    (defaultPadding * 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CareMall Logo
                  SizedBox(
                    width: 170.w,
                    height: 40.h,
                    child: Assets.icons.appLogoPng.image(fit: BoxFit.fitHeight),
                  ),
                  defaultSpacerLarge,

                  // Title
                  AppText(
                    text: 'Enter OTP',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textnaturalcolor,
                  ),
                  defaultSpacerSmall,

                  // Subtitle with phone number
                  AppText(
                    text:
                        'A 6-digit code was sent to +91 ${widget.phoneNumber.substring(0, 5)} ${widget.phoneNumber.substring(5)}',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDefaultSecondarycolor,
                  ),
                  defaultSpacerLarge,

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50.w,
                        height: 60.h,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: AppColors.primarycolor,
                                width: 2,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              6,
                            ), // Allow up to 6 digits for paste
                          ],
                          onChanged: (value) {
                            // Handle paste - if multiple digits are pasted
                            if (value.length > 1) {
                              // Clear current field first
                              _otpControllers[index].text = '';

                              // Distribute the pasted digits across all fields starting from current index
                              final digits = value.split('');
                              for (
                                int i = 0;
                                i < digits.length && (index + i) < 6;
                                i++
                              ) {
                                _otpControllers[index + i].text = digits[i];
                              }
                              // Hide keyboard after paste
                              FocusScope.of(context).unfocus();

                              setState(() {});
                              return;
                            }

                            // Handle single character input
                            if (value.length == 1) {
                              if (index < 5) {
                                // Move to next field
                                _otpFocusNodes[index + 1].requestFocus();
                              }
                            } else if (value.isEmpty && index > 0) {
                              // Move to previous field on backspace
                              _otpFocusNodes[index - 1].requestFocus();
                            }
                            setState(() {});
                          },
                        ),
                      );
                    }),
                  ),
                  defaultSpacerLarge,
                  // Resend OTP
                  Center(
                    child: _isResending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : _start > 0
                        ? AppText(
                            text: 'Resend OTP in $_start s',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          )
                        : TextButton(
                            onPressed: _resendOTP,
                            child: AppText(
                              text: 'Resend OTP',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                  ),
                  defaultSpacer,

                  // Verify Button
                  AppButton(
                    isLoading: _isLoading,
                    child: AppText(
                      text: "Verify OTP",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.whitecolor,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _verifyOTP();
                    },
                  ),
                  defaultSpacer,

                  // Edit Number
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: 'Wrong number? ',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDefaultSecondarycolor,
                        ),
                        TextButton(
                          onPressed: _editNumber,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: AppText(
                            text: 'Edit number',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
