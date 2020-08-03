import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/auth_bloc.dart';
import 'package:mobile/screens/auth/auth_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/loading/loading_screen.dart';

class EPollBookApp extends StatelessWidget {
  final AuthBloc _authBloc = AuthBloc();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "E Poll Book",
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        lazy: true,
        create: (BuildContext context) => _authBloc,
        child: BlocBuilder(
          bloc: _authBloc,
          builder: (BuildContext context, AuthState state) {
            if (state is AuthInitial) {
              _authBloc.add(CheckToken());
              return _buildLoadingScreen();
            } else if (state is AuthNeedsLogin) {
              return _buildAuthScreen();
            } else if (state is AuthLoading) {
              return _buildLoadingScreen();
            } else if (state is AuthSuccess) {
              return _buildHomeScreen();
            } else if (state is AuthError) {
              return _buildAuthScreen(error: "Sign in failed");
            }
            return Container();
          },
        ),
      ),
    );
  }

  LoadingScreen _buildLoadingScreen() => LoadingScreen();

  AuthScreen _buildAuthScreen({String error}) => AuthScreen(
        error: error,
      );

  HomeScreen _buildHomeScreen() => HomeScreen();
}
