part of 'app_bloc.dart';

@immutable
abstract class AppEvent {}

class FetchMeta extends AppEvent {
  final String election;

  FetchMeta(this.election);
}

class SaveMeta extends AppEvent {
  final String election;
  final String district;
  final String division;
  final String station;

  SaveMeta(this.election, this.district, this.division, this.station);
}

class FetchElectors extends AppEvent {
  final int option;

  FetchElectors(this.option);
}

class ChangeMeta extends AppEvent {
  final String election;

  ChangeMeta(this.election);
}

class ChangeMethod extends AppEvent {}

class UpdateToQueued extends AppEvent {
  final String voterId;

  UpdateToQueued(this.voterId);
}

class UpdateToVoted extends AppEvent {
  final String voterId;

  UpdateToVoted(this.voterId);
}

class Refresh extends AppEvent {
  final int option;

  Refresh(this.option);
}
