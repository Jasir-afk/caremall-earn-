import 'dart:convert';
import 'dart:io';
import 'package:care_mall_affiliate/app/app_buttons/app_buttons.dart';
import 'package:care_mall_affiliate/app/commenwidget/app_snackbar.dart';
import 'package:care_mall_affiliate/app/commenwidget/apptext.dart';
import 'package:care_mall_affiliate/app/theme_data/app_colors.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/model/kyc_model.dart';
import 'package:flutter/services.dart';
import 'package:care_mall_affiliate/src/modules/auth/controller/auth_controller.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/home_screen.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/view/widgets/app_drawer.dart';
import 'package:care_mall_affiliate/src/modules/home_screen/controller/homescreen_controller.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/controller/kyc_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:care_mall_affiliate/src/modules/kyc_profile/view/widgets/deletebutton.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final KycController _kycController = Get.find<KycController>();
  final AuthController _authController = Get.find<AuthController>();

  // Personal Information
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  DateTime? _selectedDob;
  String _selectedGender = 'Male';

  // Address
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  // Identity Documents
  File? _aadhaarFront;
  File? _aadhaarBack;
  final ImagePicker _picker = ImagePicker();
  // Bank Details
  final _accountNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _branchPathCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _upiNumberCtrl = TextEditingController();
  String _paymentMethod = 'Bank Transfer';
  Worker? _worker;

  @override
  void initState() {
    super.initState();
    _kycController.getKycData();
    _worker = ever(_kycController.userData, (KycModel? data) {
      if (data != null) {
        _populateFields(data);
      }
    });

    // Initial check in case KYC data is already loaded
    if (_kycController.userData.value != null) {
      _populateFields(_kycController.userData.value!);
    }

    // Pre-fill from AuthController as a fallback for empty fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_fullNameCtrl.text.isEmpty &&
          _authController.userName.value.isNotEmpty) {
        _fullNameCtrl.text = _authController.userName.value;
      }
      if (_emailCtrl.text.isEmpty &&
          _authController.userEmail.value.isNotEmpty) {
        _emailCtrl.text = _authController.userEmail.value;
      }
    });
  }

  void _populateFields(KycModel data) {
    if (data.fullName != null && data.fullName!.isNotEmpty) {
      _fullNameCtrl.text = data.fullName!;
    }
    if (data.email != null && data.email!.isNotEmpty) {
      _emailCtrl.text = data.email!;
    }

    if (data.dateOfBirth != null && data.dateOfBirth!.isNotEmpty) {
      try {
        _selectedDob = DateTime.parse(data.dateOfBirth!);
      } catch (e) {
        debugPrint("Error parsing DOB: $e");
      }
    }

    if (data.gender != null && data.gender!.isNotEmpty) {
      final genderVal = data.gender!.toLowerCase();
      if (genderVal == 'male') {
        _selectedGender = 'Male';
      } else if (genderVal == 'female') {
        _selectedGender = 'Female';
      } else if (genderVal == 'other') {
        _selectedGender = 'Other';
      }
    }

    if (data.address != null) {
      if (data.address!.street != null && data.address!.street!.isNotEmpty) {
        _streetCtrl.text = data.address!.street!;
      }
      if (data.address!.city != null && data.address!.city!.isNotEmpty) {
        _cityCtrl.text = data.address!.city!;
      }
      if (data.address!.state != null && data.address!.state!.isNotEmpty) {
        _stateCtrl.text = data.address!.state!;
      }
      if (data.address!.pincode != null && data.address!.pincode!.isNotEmpty) {
        _pincodeCtrl.text = data.address!.pincode!;
      }
    }

    if (data.bankAccountNumber != null && data.bankAccountNumber!.isNotEmpty) {
      _accountNumberCtrl.text = data.bankAccountNumber!;
    }
    if (data.ifscCode != null && data.ifscCode!.isNotEmpty) {
      _ifscCtrl.text = data.ifscCode!;
    }
    if (data.bankName != null && data.bankName!.isNotEmpty) {
      _bankNameCtrl.text = data.bankName!;
    }
    if (data.bankBranch != null && data.bankBranch!.isNotEmpty) {
      _branchPathCtrl.text = data.bankBranch!;
    }
    if (data.accountHolderName != null && data.accountHolderName!.isNotEmpty) {
      _holderNameCtrl.text = data.accountHolderName!;
    }

    if (data.paymentMethod != null && data.paymentMethod!.isNotEmpty) {
      final method = data.paymentMethod!.toLowerCase();
      if (method == 'bank_transfer' || method == 'bank transfer') {
        _paymentMethod = 'Bank Transfer';
      } else if (method == 'upi') {
        _paymentMethod = 'UPI';
      }
    }

    if (data.upiId != null && data.upiId!.isNotEmpty) {
      _upiCtrl.text = data.upiId!;
    }
    if (data.upiNumber != null && data.upiNumber!.isNotEmpty) {
      _upiNumberCtrl.text = data.upiNumber!;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    _branchPathCtrl.dispose();
    _holderNameCtrl.dispose();
    _upiCtrl.dispose();
    _upiNumberCtrl.dispose();
    _worker?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          if (isFront) {
            _aadhaarFront = File(image.path);
          } else {
            _aadhaarBack = File(image.path);
          }
        });
        if (mounted) {
          TcSnackbar.success('Success', 'Image uploaded successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        TcSnackbar.error('Error', 'Error picking image: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primarycolor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _submitKyc() async {
    final kycStatus = _authController.kycStatus.value.toLowerCase();
    final isAlreadySubmitted =
        kycStatus == 'pending' || kycStatus == 'approved';

    if (!isAlreadySubmitted && !_formKey.currentState!.validate()) return;

    if (!isAlreadySubmitted &&
        (_aadhaarFront == null || _aadhaarBack == null)) {
      TcSnackbar.error(
        'Missing Documents',
        'Please upload both Aadhaar front and back images',
      );
      return;
    }

    final dobString = _selectedDob != null
        ? '${_selectedDob!.year}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}'
        : null;

    String? frontBase64;
    String? backBase64;

    try {
      if (_aadhaarFront != null) {
        final bytes = await _aadhaarFront!.readAsBytes();
        frontBase64 = base64Encode(bytes);
      }
      if (_aadhaarBack != null) {
        final bytes = await _aadhaarBack!.readAsBytes();
        backBase64 = base64Encode(bytes);
      }
    } catch (e) {
      debugPrint('Error processing images: $e');
      TcSnackbar.error('Error', 'Failed to process images. Please try again.');
      return;
    }

    // Map UI values to backend constants
    final Map<String, String> paymentMethodMap = {
      'Bank Transfer': 'bank',
      'UPI': 'upi',
    };
    final Map<String, String> genderMap = {
      'Male': 'male',
      'Female': 'female',
      'Other': 'other',
    };

    final kycData = KycModel(
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      dateOfBirth: dobString,
      gender: genderMap[_selectedGender] ?? _selectedGender.toLowerCase(),
      address: Address(
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
      ),
      aadharFrontImage: frontBase64,
      aadharBackImage: backBase64,
      bankAccountNumber: _accountNumberCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim(),
      bankBranch: _branchPathCtrl.text.trim(),
      accountHolderName: _holderNameCtrl.text.trim(),
      paymentMethod:
          paymentMethodMap[_paymentMethod] ??
          _paymentMethod.toLowerCase().replaceAll(' ', '_'),
      upiId: _upiCtrl.text.trim(),
      upiNumber: _upiNumberCtrl.text.trim(),
    );

    _kycController.submitKyc(
      kycData: kycData,
      onSuccess: () {
        try {
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().refreshData();
          }
        } catch (e) {
          debugPrint("Error refreshing dashboard after KYC: $e");
        }
        Get.back();
        TcSnackbar.success('Success', 'KYC submitted successfully');
      },
    );
  }

  // ────────────────────── HELPER BUILDERS ──────────────────────

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primarycolor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppText(
          text: title,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primarycolor,
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AppText(
            text: label,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textnaturalcolor,
          ),
          if (required)
            AppText(
              text: ' *',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primarycolor,
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool disabled = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey[100]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.primarycolor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.errorMain.withOpacity(0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppColors.errorMain, width: 1.5),
      ),
      filled: true,
      fillColor: disabled ? Colors.grey[50] : Colors.white,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = true,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required: required && enabled),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          readOnly: !enabled,
          style: TextStyle(
            fontSize: 13.sp,
            color: enabled ? Colors.black87 : AppColors.textnaturalcolor,
          ),
          decoration: _inputDecoration(hint, disabled: !enabled),
          validator: enabled
              ? (validator ??
                    (required
                        ? (v) => (v == null || v.trim().isEmpty)
                              ? '$label is required'
                              : null
                        : null))
              : null,
        ),
      ],
    );
  }

  Widget _buildImageUpload(
    String title,
    File? file,
    VoidCallback onTap, {
    VoidCallback? onRemove,
    String? base64Image,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(title, required: true),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color:
                  file != null ||
                      (base64Image != null && base64Image.isNotEmpty)
                  ? Colors.white
                  : Colors.grey[50],
              border: Border.all(
                color:
                    file != null ||
                        (base64Image != null && base64Image.isNotEmpty)
                    ? AppColors.successMain.withOpacity(0.5)
                    : Colors.grey[300]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: file != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(file, fit: BoxFit.cover),
                        _buildRemoveOverlay(onRemove),
                      ],
                    )
                  : (base64Image != null && base64Image.isNotEmpty)
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        base64Image.startsWith('http')
                            ? Image.network(
                                base64Image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              )
                            : Image.memory(
                                base64Decode(base64Image),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                        _buildRemoveOverlay(onRemove),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: AppColors.primarycolor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 28.sp,
                            color: AppColors.primarycolor.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        AppText(
                          text: 'Upload $title',
                          fontSize: 12.sp,
                          color: AppColors.textDefaultSecondarycolor,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 4.h),
                        AppText(
                          text: 'JPG or PNG (max. 2MB)',
                          fontSize: 10.sp,
                          color: Colors.grey[400]!,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemoveOverlay(VoidCallback? onRemove) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ────────────────────── SECTIONS ──────────────────────

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Personal Information'),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _fullNameCtrl,
          label: 'Full Name',
          hint: 'John Doe',
        ),
        SizedBox(height: 14.h),
        _buildTextField(
          controller: _emailCtrl,
          label: 'Email',
          hint: 'john@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
            return null;
          },
        ),
        SizedBox(height: 14.h),
        // Date of Birth
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Date of Birth', required: true),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: _selectedDob != null
                            ? '${_selectedDob!.day.toString().padLeft(2, '0')}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.year}'
                            : 'dd-mm-yyyy',
                        fontSize: 13.sp,
                        color: _selectedDob != null
                            ? AppColors.textnaturalcolor
                            : Colors.grey[400]!,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18.sp,
                      color: Colors.grey[500],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        // Gender dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Gender', required: true),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              initialValue: _selectedGender,
              decoration: _inputDecoration('Select gender'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textnaturalcolor,
              ),
              icon: Icon(
                Icons.unfold_more,
                size: 18.sp,
                color: Colors.grey[500],
              ),
              items: [
                'Male',
                'Female',
                'Other',
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => setState(() => _selectedGender = v!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Address Details'),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _streetCtrl,
          label: 'Street / House No.',
          hint: 'eg. 12, MG Road',
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Street is required';
            if (v.trim().length < 5) return 'Enter at least 5 characters';
            return null;
          },
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityCtrl,
                label: 'City',
                hint: 'eg. Mumbai',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'City is required';
                  if (v.trim().length < 2) return 'Enter valid city name';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _stateCtrl,
                label: 'State',
                hint: 'eg. Kerala',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'State is required';
                  if (v.trim().length < 2) return 'Enter valid state name';
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        _buildTextField(
          controller: _pincodeCtrl,
          label: 'Pincode',
          hint: 'eg. 682001',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Pincode is required';
            if (v.trim().length != 6 || int.tryParse(v.trim()) == null) {
              return 'Enter a valid 6-digit numeric pincode';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Identity Documents'),
        SizedBox(height: 8.h),
        AppText(
          text: 'Ensure the document details are clearly visible.',
          fontSize: 12.sp,
          color: AppColors.textDefaultSecondarycolor,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildImageUpload(
                'Aadhaar Front',
                _aadhaarFront,
                () => _pickImage(true),
                onRemove: () => setState(() => _aadhaarFront = null),
                base64Image: _kycController.userData.value?.aadharFrontImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImageUpload(
                'Aadhaar Back',
                _aadhaarBack,
                () => _pickImage(false),
                onRemove: () => setState(() => _aadhaarBack = null),
                base64Image: _kycController.userData.value?.aadharBackImage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Bank Details'),
        SizedBox(height: 16.h),
        // Payment method toggle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel('Payment Method', required: true),
            Row(
              children: ['Bank Transfer', 'UPI'].map((method) {
                final selected = _paymentMethod == method;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _paymentMethod = method),
                    child: Container(
                      margin: EdgeInsets.only(
                        right: method == 'Bank Transfer' ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primarycolor : Colors.white,
                        border: Border.all(
                          color: selected
                              ? AppColors.primarycolor
                              : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: AppText(
                          text: method,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.grey[600]!,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (_paymentMethod == 'Bank Transfer') ...[
          _buildTextField(
            controller: _holderNameCtrl,
            label: 'Account Holder Name',
            hint: 'eg. John Doe',
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            controller: _accountNumberCtrl,
            label: 'Account Number',
            hint: 'eg. 1234567890',
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Account Number is required';
              }
              if (v.trim().length < 9) {
                return 'Minimum 9 digits required';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            controller: _ifscCtrl,
            label: 'IFSC Code',
            hint: 'eg. HDFC0001234',
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'IFSC Code is required';
              }
              // 4 chars, 0, 6 alphanumeric
              final regex = RegExp(r'^[A-Za-z]{4}0[A-Za-z0-9]{6}$');
              if (!regex.hasMatch(v.trim())) {
                return 'Invalid IFSC format (e.g. HDFC0001234)';
              }
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            controller: _bankNameCtrl,
            label: 'Bank Name',
            hint: 'eg. HDFC Bank',
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            controller: _branchPathCtrl,
            label: 'Branch Path',
            hint: 'eg. Mumbai, Bandra',
          ),
        ] else ...[
          _buildTextField(
            controller: _upiCtrl,
            label: 'UPI ID',
            hint: 'eg. name@upi',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'UPI ID is required';
              if (!v.contains('@')) return 'Enter a valid UPI ID';
              return null;
            },
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            controller: _upiNumberCtrl,
            label: 'Linked Number',
            hint: 'eg. 91+*********',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Linked Number is required';
              }
              if (v.trim().length != 10) return 'Enter valid 10-digit number';
              return null;
            },
          ),
        ],
      ],
    );
  }

  // ────────────────────── BUILD ──────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDefault,
      drawer: const AppDrawer(),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: AppColors.backgroundDefault,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.offAll(() => const HomeScreen()),
        ),
        title: AppText(
          text: 'KYC Verification',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      body: Obx(() {
        final isSubmitted = [
          'pending',
          'approved',
        ].contains(_authController.kycStatus.value.toLowerCase().trim());

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSubmitted) ...[
                    _buildKycStatusCard(),
                    SizedBox(height: 16.h),
                    _buildSubmittedView(),
                    const DeleteAccountButton(),
                  ] else ...[
                    _buildHeaderCard(),
                    SizedBox(height: 16.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildCard(child: _buildPersonalInfoSection()),
                          SizedBox(height: 16.h),
                          _buildCard(child: _buildAddressSection()),
                          SizedBox(height: 16.h),
                          _buildCard(child: _buildIdentitySection()),
                          SizedBox(height: 16.h),
                          _buildCard(child: _buildBankSection()),
                          SizedBox(height: 28.h),
                          AppButton(
                            width: double.infinity,
                            onPressed: _submitKyc,
                            isLoading: _kycController.isLoading.value,
                            btncolor: AppColors.primarycolor,
                            child: AppText(
                              text: 'Submit KYC',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (_kycController.isLoading.value)
              Container(
                color: Colors.black.withAlpha(4),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primarycolor,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSubmittedView() {
    return Column(
      children: [
        // Personal Information
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Personal Information',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textnaturalcolor,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _fullNameCtrl,
                label: 'Full Name',
                hint: 'Enter full name',
                enabled: false,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'Enter email',
                enabled: false,
              ),
              SizedBox(height: 12.h),
              // DOB (read-only styled container)
              _fieldLabel('Date of Birth', required: false),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  text: _selectedDob != null
                      ? '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}'
                      : '—',
                  fontSize: 13.sp,
                  color: AppColors.textnaturalcolor,
                ),
              ),
              SizedBox(height: 12.h),
              // Gender (read-only styled container)
              _fieldLabel('Gender', required: false),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  text: _selectedGender,
                  fontSize: 13.sp,
                  color: AppColors.textnaturalcolor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Address
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Address',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textnaturalcolor,
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _streetCtrl,
                label: 'Street / Area',
                hint: 'Street address',
                enabled: false,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityCtrl,
                      label: 'City',
                      hint: 'City',
                      enabled: false,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      controller: _stateCtrl,
                      label: 'State',
                      hint: 'State',
                      enabled: false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildTextField(
                controller: _pincodeCtrl,
                label: 'Pincode',
                hint: '6-digit pincode',
                enabled: false,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Identity Documents
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Identity Documents',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textnaturalcolor,
              ),
              SizedBox(height: 12.h),
              Obx(() {
                final data = _kycController.userData.value;
                // Extract values up-front so the type system knows they're non-null.
                final frontImage = data?.aadharFrontImage ?? '';
                final backImage = data?.aadharBackImage ?? '';
                final hasFrontFromApi = frontImage.isNotEmpty;
                final hasBackFromApi = backImage.isNotEmpty;
                final hasFrontLocal = _aadhaarFront != null;
                final hasBackLocal = _aadhaarBack != null;

                if (hasFrontFromApi || hasFrontLocal) {
                  return Row(
                    children: [
                      Expanded(
                        child: hasFrontFromApi
                            ? _buildAadhaarThumb('Aadhaar Front', frontImage)
                            : _buildAadhaarThumbLocal(
                                'Aadhaar Front',
                                _aadhaarFront!,
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: hasBackFromApi
                            ? _buildAadhaarThumb('Aadhaar Back', backImage)
                            : hasBackLocal
                            ? _buildAadhaarThumbLocal(
                                'Aadhaar Back',
                                _aadhaarBack!,
                              )
                            : const SizedBox(),
                      ),
                    ],
                  );
                }
                return AppText(
                  text: 'No Aadhaar documents uploaded',
                  fontSize: 13.sp,
                  color: Colors.grey,
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Payment Details
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Payment Details',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textnaturalcolor,
              ),
              SizedBox(height: 12.h),
              _fieldLabel('Payment Method', required: false),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AppText(
                  text: _paymentMethod,
                  fontSize: 13.sp,
                  color: AppColors.textnaturalcolor,
                ),
              ),
              SizedBox(height: 12.h),
              if (_paymentMethod == 'UPI') ...[
                _buildTextField(
                  controller: _upiCtrl,
                  label: 'UPI ID',
                  hint: 'example@upi',
                  enabled: false,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _upiNumberCtrl,
                  label: 'Linked Number',
                  hint: 'Mobile number linked to UPI',
                  enabled: false,
                ),
              ] else ...[
                _buildTextField(
                  controller: _holderNameCtrl,
                  label: 'Account Holder Name',
                  hint: 'Full name',
                  enabled: false,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _accountNumberCtrl,
                  label: 'Account Number',
                  hint: 'Bank account number',
                  enabled: false,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _ifscCtrl,
                  label: 'IFSC Code',
                  hint: 'eg. HDFC0001234',
                  enabled: false,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _bankNameCtrl,
                  label: 'Bank Name',
                  hint: 'eg. HDFC Bank',
                  enabled: false,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  controller: _branchPathCtrl,
                  label: 'Branch Path',
                  hint: 'eg. Mumbai, Bandra',
                  enabled: false,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  /// Show an Aadhaar image loaded from a URL or base64 string.
  Widget _buildAadhaarThumb(String label, String imageSource) {
    Widget imageWidget;
    if (imageSource.startsWith('http')) {
      imageWidget = Image.network(
        imageSource,
        height: 150.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150.h,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      try {
        imageWidget = Image.memory(
          base64Decode(imageSource),
          height: 150.h,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150.h,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      } catch (_) {
        imageWidget = Container(
          height: 150.h,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDefaultSecondarycolor,
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _showImageDialog(context, imageSource),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageWidget,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.zoom_in, size: 12.sp, color: Colors.grey),
            SizedBox(width: 4.w),
            AppText(text: 'Tap to view', fontSize: 10.sp, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  /// Show a local file image for Aadhaar (used right after picking, before API refresh).
  Widget _buildAadhaarThumbLocal(String label, File file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textDefaultSecondarycolor,
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () => _showImageDialogFromFile(context, file),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              file,
              height: 150.h,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.zoom_in, size: 12.sp, color: Colors.grey),
            SizedBox(width: 4.w),
            AppText(text: 'Tap to view', fontSize: 10.sp, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageSource) {
    Widget imageWidget;
    if (imageSource.startsWith('http')) {
      imageWidget = Image.network(
        imageSource,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey, size: 48),
      );
    } else {
      try {
        imageWidget = Image.memory(
          base64Decode(imageSource),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, color: Colors.grey, size: 48),
        );
      } catch (_) {
        imageWidget = const Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 48,
        );
      }
    }
    _showFullscreenDialog(context, imageWidget);
  }

  void _showImageDialogFromFile(BuildContext context, File file) {
    _showFullscreenDialog(context, Image.file(file, fit: BoxFit.contain));
  }

  void _showFullscreenDialog(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: imageWidget,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.05), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildKycStatusCard() {
    return Obx(() {
      final status = _authController.kycStatus.value.toLowerCase();
      final Color statusColor;
      final String statusLabel;
      final Color statusBg;

      switch (status) {
        case 'approved':
          statusColor = AppColors.successMain;
          statusBg = AppColors.bgPositiveTertiaryColor;
          statusLabel = 'APPROVED';
          break;
        case 'pending':
          statusColor = AppColors.warningMain;
          statusBg = const Color(0xFFFFF8E1);
          statusLabel = 'PENDING';
          break;
        case 'rejected':
          statusColor = AppColors.errorMain;
          statusBg = const Color(0xFFFFEDEA);
          statusLabel = 'REJECTED';
          break;
        default:
          statusColor = AppColors.textDefaultSecondarycolor;
          statusBg = Colors.grey[100]!;
          statusLabel = 'NOT SUBMITTED';
      }

      IconData statusIcon;
      switch (status) {
        case 'approved':
          statusIcon = Icons.verified_user_rounded;
          break;
        case 'pending':
          statusIcon = Icons.hourglass_top_rounded;
          break;
        case 'rejected':
          statusIcon = Icons.error_rounded;
          break;
        default:
          statusIcon = Icons.info_outline_rounded;
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: statusColor.withAlpha(40), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: statusBg,
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'KYC Verification',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDefaultSecondarycolor,
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: statusLabel,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ],
              ),
            ),
            if (status == 'approved')
              const Icon(
                Icons.check_circle,
                color: AppColors.successMain,
                size: 24,
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.primarycolor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primarycolor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'Complete Your KYC',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    SizedBox(height: 6.h),
                    AppText(
                      text:
                          'Verify your identity to unlock all features and start earning.',
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.security_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 50.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
