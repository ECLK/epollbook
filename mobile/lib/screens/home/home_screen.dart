import 'package:flutter/material.dart';
import 'package:mobile/screens/home/profile_screen.dart';
import 'package:mobile/screens/home/search_screen.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _title;

  static List<TabItem> _navItems = List.of([
    new TabItem(Icons.search, "", Colors.blueAccent),
    new TabItem(Icons.person, "", Colors.blueAccent),
  ]);

  static List<Widget> _screens = [SearchScreen(), ProfileScreen()];

  CircularBottomNavigationController _navController =
      new CircularBottomNavigationController(0);

  void _setTitle() {
    _title = (_navController.value.isOdd) ? "Profile" : "Search";
  }

  @override
  void initState() {
    _setTitle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _screens.elementAt(_navController.value),
      bottomNavigationBar: CircularBottomNavigation(
        _navItems,
        iconsSize: 24.0,
        normalIconColor: Colors.blueAccent,
        controller: _navController,
        selectedCallback: (navIndex) {
          setState(() {
            _navController.value = navIndex;
            _setTitle();
          });
        },
      ),
    );
  }
}
