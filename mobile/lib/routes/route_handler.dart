import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/auth/auth_screen.dart';
import 'package:mobile/screens/home/home_screen.dart';
import 'package:mobile/screens/splash/splash_screen.dart';

var splashHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return SplashScreen();
});

var authHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return AuthScreen();
});

var homeHandler = Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return HomeScreen();
});
