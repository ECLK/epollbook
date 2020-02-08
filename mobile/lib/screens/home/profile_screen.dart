import 'package:flutter/material.dart';
import 'package:mobile/routes/application.dart';
import 'package:mobile/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 60.0,
            ),
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 64.0,
              backgroundImage: NetworkImage(
                  "https://i0.wp.com/365webresources.com/wp-content/uploads/2016/09/FREE-PROFILE-AVATARS.png?resize=502%2C494&ssl=1"),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "John Doe",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Senior Polling Officer",
              style: TextStyle(color: Colors.grey),
            ),
            Expanded(child: Container()),
            FlatButton(
              child: Text(
                "Sign Out",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.redAccent,
              onPressed: () {
                _signOut(context);
              },
            ),
            SizedBox(height: 60.0,)
          ],
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    AuthService().signOut().then((_) {
      if (_)
        Application.router.navigateTo(context, '/auth', replace: true);
      else {
        // Handle sign out failure
      }
    });
  }
}
