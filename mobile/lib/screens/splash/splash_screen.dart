import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile/routes/application.dart';
import 'package:mobile/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () async {
      _navigate();
    });

    super.initState();
  }

  void _navigate() async {
    // Check internet connection
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        AuthService().isSignedIn().then((_) {
          (_)
              ? Application.router.navigateTo(context, '/home', replace: true)
              : Application.router.navigateTo(context, '/auth', replace: true);
        });
      }
    } on SocketException catch (_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No network"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Please turn on wifi or mobile data to continue")
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Continue"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _navigate();
                },
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Container(
        height: 100.0,
        child: Image.asset('assets/images/gov.png'),
      )),
    );
  }
}
