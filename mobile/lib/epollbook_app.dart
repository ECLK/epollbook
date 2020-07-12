import 'package:flutter/material.dart';
import 'package:mobile/screens/home/home_screen.dart';

class EPollBookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "E Poll Book",
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
