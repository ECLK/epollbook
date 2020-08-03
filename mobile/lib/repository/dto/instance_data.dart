import 'package:mobile/config/config.dart';

class InstanceData {
  final String election = ELECTION;
  final String district = DISTRICT;
  final String division;
  final String station;

  InstanceData(this.division, this.station);
}
