class AddressModel {
  final int id;
  final String addressType;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String pincode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.addressType,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.pincode,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      addressType: json['address_type'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2'],
      city: json['city'],
      pincode: json['pincode'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_type': addressType,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
