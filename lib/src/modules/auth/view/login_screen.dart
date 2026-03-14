import 'package:care_mall_affiliate/app/app_buttons/app_buttons.dart';
import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/app/commenwidget/apptext.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/app/utils/network/auth_service.dart';
import 'package:care_mall_affiliate/app/utils/spaces.dart';
import 'package:care_mall_affiliate/gen/assets.gen.dart';
import 'package:care_mall_affiliate/src/modules/auth/view/otp_verification_screen.dart';
import 'package:care_mall_affiliate/src/modules/auth/view/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final CommonController commonController = Get.put(
  // CommonController(),
  // permanent: true,
  // );
  // final MyCartController mymCartController = Get.put(
  //   MyCartController(),
  //   permanent: true,
  // );
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.sendOtp(
          phone: _phoneController.text,
          mode: 'login',
        );

        if (mounted) {
          if (result['success']) {
            TcSnackbar.success('Success', result['message']);
            // Navigate to OTP verification screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OTPVerificationScreen(
                  phoneNumber: _phoneController.text,
                  mode: 'login',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo and Description
                        SizedBox(
                          width: 170,
                          height: 40,
                          child: Assets.icons.appLogoPng.image(
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        defaultSpacerSmall,
                        AppText(
                          text: 'Join the Care Mall Affiliate Program',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textnaturalcolor,
                        ),
                        defaultSpacerSmall,
                        AppText(
                          text:
                              'Partner with us to promote top-quality products and earn competitive commissions.',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDefaultSecondarycolor,
                        ),

                        defaultSpacerLarge,
                        // SizedBox(height: 100.h),
                        AppText(
                          text: 'Login',
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textnaturalcolor,
                        ),
                        AppText(
                          text: 'Sign in using your mobile number ',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textDefaultSecondarycolor,
                        ),
                        // defaultSpacerLarge,
                        defaultSpacerLarge,
                        // defaultSpacerSmall,
                        AppText(
                          text: "Mobile Number",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        defaultSpacerSmall,

                        // Mobile number field with validator
                        TextFormField(
                          onChanged: (value) {
                            setState(() {});
                          },
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Enter Mobile Number here',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Assets.icons.phone.svg(),
                            ),
                            // 👇 Default Border
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),

                            // 👇 When Enabled
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),

                            // 👇 When Focused
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: AppColors.primarycolor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10-digit number';
                            }
                            return null;
                          },
                        ),

                        defaultSpacer,
                        AppButton(
                          isLoading: _isLoading,
                          child: AppText(
                            text: "Send OTP",
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.whitecolor,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            if (_formKey.currentState?.validate() ?? false) {
                              _login();
                            }
                          },
                        ),
                        defaultSpacer,

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Create New Account',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
