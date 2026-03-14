class KycModel {
  String? fullName;
  String? dateOfBirth;
  String? gender;
  String? email;
  Address? address;
  String? aadharFrontImage;
  String? aadharBackImage;
  String? bankAccountNumber;
  String? bankBranch;
  String? ifscCode;
  String? paymentMethod;
  String? upiId;
  String? upiNumber;
  String? accountHolderName;
  String? bankName;
  String? kycStatus;

  String? kycName; // Not in JSON but maybe useful
  String? kycRejectionReason;
  String? kycSubmittedAt;

  KycModel({
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.address,
    this.aadharFrontImage,
    this.aadharBackImage,
    this.bankAccountNumber,
    this.bankBranch,
    this.ifscCode,
    this.paymentMethod,
    this.upiId,
    this.upiNumber,
    this.accountHolderName,
    this.bankName,
    this.kycStatus,
    this.kycRejectionReason,
    this.kycSubmittedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'email': email,
      'address': address?.toJson(),
      'aadharFrontImage': aadharFrontImage,
      'aadharBackImage': aadharBackImage,
      'bankAccountNumber': bankAccountNumber,
      'bankBranch': bankBranch,
      'ifscCode': ifscCode,
      'paymentMethod': paymentMethod,
      'upiId': upiId,
      'upiNumber': upiNumber,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'kycStatus': kycStatus,
      'kycRejectionReason': kycRejectionReason,
      'kycSubmittedAt': kycSubmittedAt,
    };
  }

  factory KycModel.fromJson(dynamic json) {
    if (json == null) return KycModel();
    if (json is List) {
      if (json.isNotEmpty) {
        return KycModel.fromJson(json.first);
      }
      return KycModel();
    }

    final Map<String, dynamic> data = json is Map
        ? Map<String, dynamic>.from(json)
        : {};

    return KycModel(
      fullName:
          data['fullName'] ??
          data['full_name'] ??
          data['name'] ??
          data['user_name'] ??
          data['username'],
      dateOfBirth: data['dateOfBirth'] ?? data['date_of_birth'] ?? data['dob'],
      gender: data['gender'],
      email: data['email'],
      address: data['address'] != null
          ? Address.fromJson(data['address'])
          : (data['street'] != null || data['city'] != null)
          ? Address.fromJson(data) // Flat fallback
          : null,
      aadharFrontImage:
          data['aadharFrontImage'] ??
          data['aadhar_front_image'] ??
          data['aadharFront'] ??
          data['aadhar_front'],
      aadharBackImage:
          data['aadharBackImage'] ??
          data['aadhar_back_image'] ??
          data['aadharBack'] ??
          data['aadhar_back'],
      bankAccountNumber:
          data['bankAccountNumber'] ??
          data['bank_account_number'] ??
          data['accountNumber'] ??
          data['account_number'],
      bankBranch:
          data['bankBranch'] ??
          data['branch_path'] ??
          data['branch_path'] ??
          data['branch'],
      ifscCode: data['ifscCode'] ?? data['ifsc_code'] ?? data['ifsc'],
      paymentMethod:
          data['paymentMethod'] ?? data['payment_method'] ?? data['payment'],
      upiId: data['upiId'] ?? data['upi_id'] ?? data['upiId'],
      upiNumber: data['upiNumber'] ?? data['upi_number'],
      accountHolderName:
          data['accountHolderName'] ??
          data['holderName'] ??
          data['holder_name'],
      bankName: data['bankName'] ?? data['bank_name'],
      kycStatus: data['kycStatus'] ?? data['kyc_status'] ?? data['status'],
      kycRejectionReason:
          data['kycRejectionReason'] ?? data['kyc_rejection_reason'],
      kycSubmittedAt: data['kycSubmittedAt'] ?? data['kyc_submitted_at'],
    );
  }
}

class Address {
  String? street;
  String? city;
  String? state;
  String? pincode;

  Address({this.street, this.city, this.state, this.pincode});

  Map<String, dynamic> toJson() {
    return {'street': street, 'city': city, 'state': state, 'pincode': pincode};
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? json['address_line_1'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'] ?? json['zip_code'] ?? json['pincode_no'],
    );
  }
}
