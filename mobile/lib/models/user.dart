class User {
  String id, name, phoneNumber;

  User(this.id, this.name, this.phoneNumber);

  User.fromJson(dynamic json) {
    this.id = json['user_id'];
    this.name = json['user_name'];
    this.phoneNumber = json['user_phone_number'];
  }
}
