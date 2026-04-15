import 'dart:convert';

class UserModel {
  final String  id;
  final String  firstName;
  final String  lastName;
  final String  email;
  final String? phone;
  final String  role;
  final String  status;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
  });

  String get fullName  => '$firstName $lastName';

  /// Initials from first letter of first name + first letter of last name
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty  ? lastName[0].toUpperCase()  : '';
    return '$f$l';
  }

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id:        j['id']        as String,
        firstName: j['firstName'] as String,
        lastName:  j['lastName']  as String,
        email:     j['email']     as String,
        phone:     j['phone']     as String?,
        role:      (j['role']     as String).toLowerCase(),
        status:    (j['status']   as String? ?? 'active').toLowerCase(),
      );

  Map<String, dynamic> toJson() => {
        'id':        id,
        'firstName': firstName,
        'lastName':  lastName,
        'email':     email,
        'phone':     phone,
        'role':      role,
        'status':    status,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String s) =>
      UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) =>
      UserModel(
        id:        id,
        firstName: firstName ?? this.firstName,
        lastName:  lastName  ?? this.lastName,
        email:     email     ?? this.email,
        phone:     phone     ?? this.phone,
        role:      role,
        status:    status,
      );
}
