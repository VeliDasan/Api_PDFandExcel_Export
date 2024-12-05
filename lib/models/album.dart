class Album {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const Album({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      avatar: "json['avatar'] as String",
    );
  }
}
