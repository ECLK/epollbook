enum VoteState {
  PENDING,
  IN_QUEUE,
  VOTE_SUCCESS,
  VOTE_ERROR,
}

class Elector {
  final String id, nic, fullName, gender, age, address;
  VoteState state;

  Elector(
      {this.id,
      this.nic,
      this.fullName,
      this.gender,
      this.age,
      this.address,
      this.state = VoteState.PENDING});

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
