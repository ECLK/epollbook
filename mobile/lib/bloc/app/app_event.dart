part of 'app_bloc.dart';

@immutable
abstract class AppEvent {}

class FetchMeta extends AppEvent {
  final String election;

  FetchMeta(this.election);
}

class FetchElectors extends AppEvent {
  final String election;
  final String district;
  final String division;
  final String station;

  FetchElectors(this.election, this.district, this.division, this.station);
}

class SelecMethod extends AppEvent {
  final int option;

  SelecMethod(this.option);
}

class ChangeSelection extends AppEvent {
  final String election;

  ChangeSelection(this.election);
}
