import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/auth/auth_bloc.dart';
import 'package:mobile/models/auth_user.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();

  final String error;
  AuthScreen({this.error});
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.blueAccent,
                onPressed: () => _signIn(context),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Please sign in using username and password provided to you by the election department",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(SignIn(AuthUser()));
  }
}
