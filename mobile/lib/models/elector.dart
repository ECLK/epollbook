class Elector {
  final String id, electorId, nic, nameSi, nameTa;

  Elector({
    this.id,
    this.electorId,
    this.nic,
    this.nameSi,
    this.nameTa,
  });

  factory Elector.fromJson(dynamic json) {
    return Elector(
      id: json['ID'].toString(),
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
