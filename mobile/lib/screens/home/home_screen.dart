import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:mobile/bloc/app/app_bloc.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/screens/error/error_screen.dart';
import 'package:mobile/screens/home/search/search_screen.dart';
import 'package:mobile/screens/loading/loading_screen.dart';
import 'package:logger/logger.dart';
import 'package:mobile/styles/color_palette.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // String _title;
  final AppBloc _appBloc = AppBloc();

  String _currentDivision = "Select one";
  List<String> _divisions;

  String _currentStation = "Select one";
  List<String> _stations;

  // static List<TabItem> _navItems = List.of([
  //   new TabItem(Icons.insert_chart, "", Colors.blueAccent),
  //   new TabItem(Icons.search, "", Colors.blueAccent),
  //   new TabItem(Icons.person, "", Colors.blueAccent),
  // ]);

  // CircularBottomNavigationController _navController =
  //     new CircularBottomNavigationController(1);

  // void _setTitle() {
  //   switch (_navController.value) {
  //     case 0:
  //       _title = "Analytics";
  //       break;
  //     case 1:
  //       _title = "Search";
  //       break;
  //     case 2:
  //       _title = "Profile";
  //       break;
  //   }
  // }

  @override
  void initState() {
    // _setTitle();
    _appBloc.add(FetchMeta(ELECTION));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: BlocProvider(
        lazy: true,
        create: (BuildContext context) => _appBloc,
        child: BlocBuilder(
          bloc: _appBloc,
          builder: (BuildContext context, AppState state) {
            if (state is AppInitial || state is AppLoading) {
              return _buildLoadingScreen();
            } else if (state is AppMetaLoaded) {
              return _buildMetaLoadedScreen(context, state.meta);
            } else if (state is AppMethodSelect) {
              return _buildMethodSelectScreen(context);
            } else if (state is AppElectorsLoaded) {
              return _buildElectorsLoadedScreen(
                  context, state.electors, state.isPending);
            } else if (state is AppError) {
              return _buildErrorScreen(state.error);
            }
            return Container();
          },
        ),
      )),
      // bottomNavigationBar: CircularBottomNavigation(
      //   _navItems,
      //   iconsSize: 24.0,
      //   normalIconColor: Colors.blueAccent,
      //   controller: _navController,
      //   selectedCallback: (navIndex) {
      //     setState(() {
      //       _navController.value = navIndex;
      //       _setTitle();
      //     });
      //   },
      // ),
    );
  }

  LoadingScreen _buildLoadingScreen() => LoadingScreen();

  Widget _buildMetaLoadedScreen(BuildContext context, List<Info> meta) {
    _divisions = List.of(["Select one"]) +
        meta.map((m) => m.pollingDivisionSi).toSet().toList();

    _stations = List.of(["Select one"]) +
        meta
            .where((m) => m.pollingDivisionSi == _currentDivision)
            .map((m) => m.stationId)
            .toSet()
            .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 40),
          Text(
            "Tell us about your station",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 60),
          Text(
            "Polling Division",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                value: _currentDivision,
                items: _divisions
                    .map((String division) => DropdownMenuItem<String>(
                          value: division,
                          child: Text(division),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _currentDivision = value;
                  });
                  Logger().i(_currentDivision);
                },
              ),
            ],
          ),
          SizedBox(height: 40),
          _currentDivision != "Select one"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Station",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DropdownButton<String>(
                          value: _currentStation,
                          items: _stations
                              .map((String station) => DropdownMenuItem<String>(
                                    value: station,
                                    child: Text(station),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _currentStation = value;
                            });
                            Logger().i(_currentStation);
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : Container(),
          Expanded(
            child: Container(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _currentDivision != "Select one" &&
                            _currentStation != "Select one"
                        ? ColorPalette.primary
                        : ColorPalette.idle,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Proceed",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                onTap: _currentDivision != "Select one" &&
                        _currentStation != "Select one"
                    ? () => _handleProceed(
                        context, _currentDivision, _currentStation)
                    : null,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMethodSelectScreen(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40),
                  Text(
                    "What will you be doing",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                InkWell(
                  child: Container(
                    height: 200,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage('assets/images/queue.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () => _handleMethodSelect(context, 0),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                InkWell(
                  child: Container(
                    height: 40,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text("Marking Queue"),
                    ),
                  ),
                  onTap: () => _handleMethodSelect(context, 0),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Container(
                    height: 200,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage('assets/images/vote.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () => _handleMethodSelect(context, 1),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Container(
                    height: 40,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text("Marking Vote"),
                    ),
                  ),
                  onTap: () => _handleMethodSelect(context, 1),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

SearchScreen _buildElectorsLoadedScreen(
        BuildContext context, List<Elector> electors, bool isPending) =>
    SearchScreen(context, electors, isPending);

ErrorScreen _buildErrorScreen(String error) => ErrorScreen(error);

void _handleMethodSelect(BuildContext context, int method) {
  BlocProvider.of<AppBloc>(context).add(FetchElectors(method));
}

void _handleProceed(
    BuildContext context, String _currentDivision, String _currentStation) {
  BlocProvider.of<AppBloc>(context)
      .add(SaveMeta(ELECTION, DISTRICT, _currentDivision, _currentStation));
}
