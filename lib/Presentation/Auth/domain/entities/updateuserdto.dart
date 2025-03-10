class UpdateUserDto {
  final String name;
  final String email;
  final List<int> phoneNumbers;
  final String? profilePicture;
  final String? patentImage;

  UpdateUserDto({
    required this.name,
    required this.email,
    required this.phoneNumbers,
    this.profilePicture,
    this.patentImage,
  });

  // Convert UpdateUserDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumbers': phoneNumbers,
      'profilePicture': profilePicture,
      'patentImage': patentImage,
    };
  }
}
