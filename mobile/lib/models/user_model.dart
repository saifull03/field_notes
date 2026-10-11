class UserModel {
  final dynamic id;
  final String username;
  final String email;
  final String? fullName;
  final String? token;

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'],
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    dynamic id,
    String? username,
    String? email,
    String? fullName,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      token: token ?? this.token,
    );
  }
}
