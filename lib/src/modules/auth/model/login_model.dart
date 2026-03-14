/// Model class for Login/Authentication response
/// Handles user data and authentication token from API
class LoginModel {
  final bool success;
  final String message;
  final String? token;
  final UserData? user;

  LoginModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  /// Creates LoginModel from JSON response
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
    );
  }

  /// Converts LoginModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }

  /// Creates a copy with modified fields
  LoginModel copyWith({
    bool? success,
    String? message,
    String? token,
    UserData? user,
  }) {
    return LoginModel(
      success: success ?? this.success,
      message: message ?? this.message,
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }
}

/// Model class for User Data
class UserData {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates UserData from JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      profileImage: json['profileImage'] ?? json['profile_image'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Converts UserData to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with modified fields
  UserData copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user's display name (name or email or phone)
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return 'User';
  }

  /// Check if user has complete profile
  bool get isProfileComplete {
    return name != null &&
        email != null &&
        phone != null &&
        name!.isNotEmpty &&
        email!.isNotEmpty &&
        phone!.isNotEmpty;
  }
}

/// Model for OTP Request
class OTPRequest {
  final String phone;
  final String mode; // 'login' or 'signup'
  final String? name;
  final String? email;

  OTPRequest({required this.phone, required this.mode, this.name, this.email});

  /// Converts to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'mode': mode,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (email != null && email!.isNotEmpty) 'email': email,
    };
  }
}

/// Model for OTP Verification Request
class OTPVerifyRequest {
  final String phone;
  final String otp;

  OTPVerifyRequest({required this.phone, required this.otp});

  /// Converts to JSON for API request
  Map<String, dynamic> toJson() {
    return {'phone': phone, 'otp': otp};
  }

  /// Validates OTP format
  bool get isValid {
    return otp.length == 6 && RegExp(r'^\d{6}$').hasMatch(otp);
  }
}
