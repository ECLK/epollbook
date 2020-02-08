import 'package:flutter/material.dart';
import 'package:mobile/routes/application.dart';
import 'package:mobile/services/auth_service.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: FlatButton(
            child: Text("Sign In"),
            onPressed: () {
              _signIn(context);
            },
          ),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) {
    AuthService().signIn().then((_) {
      if (_)
        Application.router.navigateTo(context, '/home', replace: true);
      else {
        // Handle sign in failure
      }
    });
  }
}
