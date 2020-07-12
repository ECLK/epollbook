import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    _navigateIfAuthed();
    super.initState();
  }

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
                onPressed: () {
                  _signIn(context);
                },
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

  void _navigateIfAuthed() {
    // AuthService().isSignedIn().then((_) {
    //   (_)
    //       ? Application.router.navigateTo(context, '/home', replace: true)
    //       : null;
    // });
  }

  void _signIn(BuildContext context) {
    // AuthService().signIn().then((_) {
    //   if (_)
    //     Application.router.navigateTo(context, '/home', replace: true);
    //   else {
    //     // Handle sign in failure
    //   }
    // });
  }
}
