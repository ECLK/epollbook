part of 'app_bloc.dart';

@immutable
abstract class AppState {}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppMetaLoaded extends AppState {
  final List<Info> meta;

  AppMetaLoaded({this.meta});
}

class AppMethodSelect extends AppState {}

class AppElectorsLoaded extends AppState {
  final List<Elector> electors;
  final isPending;

  AppElectorsLoaded({this.electors, this.isPending});
}

class AppError extends AppState {
  final String error;
  AppError(this.error);
}
