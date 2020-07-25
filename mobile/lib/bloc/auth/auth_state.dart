part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthNeedsLogin extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User currentUser;
  AuthSuccess(this.currentUser);
}

class AuthError extends AuthState {
  final String error;
  AuthError(this.error);
}
