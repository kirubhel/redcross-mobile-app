class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profile,
    this.address,
    this.preferences,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'volunteer',
      profile: json['profile'],
      address: json['address'],
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profile': profile,
      'address': address,
      'preferences': preferences,
    };
  }

  bool get isAdmin => role == 'admin' || role == 'hub_coordinator';
}

