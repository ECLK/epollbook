part of 'app_bloc.dart';

@immutable
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppMetaLoaded extends AppState {
  final List<Info> meta;

  AppMetaLoaded({this.meta});
}

class AppMethodSelect extends AppState {
  final List<Elector> all;
  final List<Elector> inQueue;

  AppMethodSelect({this.all, this.inQueue});
}

class AppElectorsLoaded extends AppState {
  final List<Elector> electors;

  AppElectorsLoaded({this.electors});
}

class AppError extends AppState {
  final String error;
  AppError(this.error);
}
