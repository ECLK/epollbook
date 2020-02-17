import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:mobile/routes/application.dart';
import 'package:mobile/routes/routes.dart';

class EPollBookApp extends StatelessWidget {
  EPollBookApp() {
    final router = Router();
    Routes.configureRouter(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "E Poll Book",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Application.router.generator,
    );
  }
}
