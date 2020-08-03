import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String error;

  ErrorScreen(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(error),
      ),
    );
  }
}
