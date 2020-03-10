import 'package:fluro/fluro.dart';
import 'package:mobile/routes/route_handler.dart';

class Routes {
  static const auth = "/";
  static const home = "/home";

  static void configureRouter(Router router) {
    router.define(auth,
        handler: authHandler, transitionType: TransitionType.native);
    router.define(home,
        handler: homeHandler, transitionType: TransitionType.native);
  }
}
