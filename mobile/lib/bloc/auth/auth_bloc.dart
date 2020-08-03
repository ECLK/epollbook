import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:mobile/models/auth_user.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/repository/dto/login_response.dart';
import 'package:mobile/repository/repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial());

  Repository _repository = Repository();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is CheckToken) {
      yield AuthLoading();
      final bool _hasToken = await _repository.checkToken();
      if (_hasToken) {
        final User _user = await _repository.loadLocalUser();
        yield AuthSuccess(_user);
      } else {
        yield AuthNeedsLogin();
      }
    } else if (event is SignIn) {
      yield AuthLoading();
      final LoginResponse _response = await _repository.signIn(event.user);
      if (_response != null && _response.user != null)
        yield AuthSuccess(_response.user);
      else
        yield AuthError("Sign in failed");
    } else if (event is SignOut) {
      _repository.signOut();
      yield AuthNeedsLogin();
    }
  }
}
