import 'dart:ui';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/auth/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 24.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xffFFF5F5),
              const Color(0xffFFEFEF).withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.errorMain.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.errorMain.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Container(
                    //   padding: EdgeInsets.all(8.r),
                    //   decoration: BoxDecoration(
                    //     color: AppColors.errorMain.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(10.r),
                    //   ),
                    //   // child: Icon(
                    //   //   Icons.shield_outlined,
                    //   //   color: AppColors.errorMain,
                    //   //   size: 20.sp,
                    //   // ),
                    // ),
                    // SizedBox(width: 12.w),
                    Text(
                      'Delete Profile',
                      style: GoogleFonts.manrope(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.errorMain,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Once you delete your profile, there is no going back. Please be certain.',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: AppColors.errorMain.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.errorMain.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showConfirmationDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorMain,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      icon: Icon(Icons.delete_outline_rounded, size: 20.sp),
                      label: Text(
                        'Delete Profile',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController confirmController = TextEditingController();
    final RxBool isConfirmEnabled = false.obs;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 340.w,
                padding: EdgeInsets.all(28.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Icon with Glow
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF5F5),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.errorMain.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.report_problem_rounded,
                          color: AppColors.errorMain,
                          size: 36.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Are you absolutely sure?',
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.errorMain,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            color: const Color(0xff4B5563),
                            height: 1.6,
                          ),
                          children: [
                            const TextSpan(
                              text: 'This action is irreversible and you will ',
                            ),
                            TextSpan(
                              text: 'never receive your pending payouts',
                              style: TextStyle(
                                color: AppColors.errorMain,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  '. All your data will be permanently removed from our servers.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            color: const Color(0xff374151),
                          ),
                          children: [
                            const TextSpan(text: 'Please type '),
                            TextSpan(
                              text: 'delete my account',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xff111827),
                              ),
                            ),
                            const TextSpan(text: ' to confirm.'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: confirmController,
                        onChanged: (val) {
                          isConfirmEnabled.value =
                              val.trim().toLowerCase() == "delete my account";
                        },
                        cursorColor: AppColors.errorMain,
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'delete my account',
                          hintStyle: GoogleFonts.manrope(
                            color: Colors.grey[400],
                            fontSize: 13.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          filled: true,
                          fillColor: const Color(0xffF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Color(0xffE5E7EB),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: Color(0xffE5E7EB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: const BorderSide(
                              color: AppColors.errorMain,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Obx(
                        () => Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isConfirmEnabled.value
                                    ? () {
                                        Get.back();
                                        authController.deleteAccount(
                                          onSuccess: () {
                                            Get.offAll(() => const LoginScreen());
                                          },
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.errorMain,
                                  disabledBackgroundColor: AppColors.errorMain
                                      .withOpacity(0.35),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                child: Text(
                                  'Yes, Delete My Profile',
                                  style: GoogleFonts.manrope(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  side: const BorderSide(
                                    color: Color(0xffE5E7EB),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.manrope(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xff4B5563),
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
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }
}
