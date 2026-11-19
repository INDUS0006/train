class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isGuest;
  final String phoneNumber;
  final bool locationSharingEnabled;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isGuest,
    required this.phoneNumber,
    required this.locationSharingEnabled,
  });

  String get displayName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return username;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isGuest: json['is_guest'] ?? false,
      phoneNumber: json['phone_number'] ?? '',
      locationSharingEnabled: json['location_sharing_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_guest': isGuest,
      'phone_number': phoneNumber,
      'location_sharing_enabled': locationSharingEnabled,
    };
  }
}
