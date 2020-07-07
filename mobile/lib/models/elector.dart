class Elector {
  String id, nic, fullName, gender, age, address;
  bool isVoted = false;

  Elector(
      {this.id, this.nic, this.fullName, this.gender, this.age, this.address});

  factory Elector.fromJson(dynamic json) {
    return Elector(
      id: json['id'],
      nic: json['nic'],
      fullName: json['full_name'],
      gender: json['gender'],
      age: json['age'],
      address: json['address'],
    );
  }
}
