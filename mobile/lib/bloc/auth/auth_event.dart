part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class CheckToken extends AuthEvent {}

class SignIn extends AuthEvent {
  final AuthUser user;
  SignIn(this.user);
}

class SignOut extends AuthEvent {}
