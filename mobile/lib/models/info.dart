class Info {
  final String districtSi,
      districtTa,
      pollingDivisionSi,
      pollingDivisionTa,
      stationId;

  Info(
      {this.districtSi,
      this.districtTa,
      this.pollingDivisionSi,
      this.pollingDivisionTa,
      this.stationId});

  factory Info.fromJson(dynamic json) {
    return Info(
      districtSi: json['DistrictSI'],
      districtTa: json['DistrictTA'],
      pollingDivisionSi: json['PollingDivisionSI'],
      pollingDivisionTa: json['PollingDivisionTA'],
      stationId: json['PollingStationID'],
    );
  }

  factory Info.error() {
    return Info(
      districtSi: "-1",
      districtTa: "-1",
      pollingDivisionSi: "-1",
      pollingDivisionTa: "-1",
      stationId: "-1",
    );
  }
}
