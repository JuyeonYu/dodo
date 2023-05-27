class UserDomain {
  String email;
  String name;
  String thumbnail;

  UserDomain({
    required this.email,
    required this.name,
    required this.thumbnail,
  });
 static var myself = UserDomain(email: '', name: '', thumbnail: '');
}