enum VoteState {
  PENDING,
  IN_QUEUE,
  VOTE_SUCCESS,
  VOTE_ERROR,
}

class Elector {
  final String id, electorId, nic, nameSi, nameTa;
  VoteState state;

  Elector({
    this.id,
    this.electorId,
    this.nic,
    this.nameSi,
    this.nameTa,
    this.state = VoteState.PENDING,
  });

  factory Elector.fromJson(dynamic json) {
    return Elector(
      id: json['ID'],
      electorId: json['ElectorID'],
      nic: json['NIC'],
      nameSi: json['Name_SI'],
      nameTa: json['Name_TA'],
    );
  }

  factory Elector.error() {
    return Elector(
      id: "-1",
      electorId: "-1",
      nic: "-1",
      nameSi: "-1",
      nameTa: "-1",
    );
  }
}

VoteState mapStringToState(String state) {
  switch (state) {
    case "pending":
      return VoteState.PENDING;

    case "in_queue":
      return VoteState.IN_QUEUE;

    case "voted":
      return VoteState.VOTE_SUCCESS;

    case "not_voted":
      return VoteState.VOTE_ERROR;
  }

  return VoteState.PENDING;
}
