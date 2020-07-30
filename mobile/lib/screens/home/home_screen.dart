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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _title;
  final AppBloc _appBloc = AppBloc();

  String _currentDivision = "Select one";
  List<String> _divisions;

  String _currentStation = "Select one";
  List<String> _stations;

  static List<TabItem> _navItems = List.of([
    new TabItem(Icons.insert_chart, "", Colors.blueAccent),
    new TabItem(Icons.search, "", Colors.blueAccent),
    new TabItem(Icons.person, "", Colors.blueAccent),
  ]);

  CircularBottomNavigationController _navController =
      new CircularBottomNavigationController(1);

  void _setTitle() {
    switch (_navController.value) {
      case 0:
        _title = "Analytics";
        break;
      case 1:
        _title = "Search";
        break;
      case 2:
        _title = "Profile";
        break;
    }
  }

  @override
  void initState() {
    // _setTitle();
    _appBloc.add(FetchMeta(ELECTION));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

    return Center(
      child: Column(
        children: <Widget>[
          Text("Division"),
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
          SizedBox(height: 20),
          _currentDivision != "Select one"
              ? Column(
                  children: <Widget>[
                    Text("Station"),
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
                )
              : Container(),
          SizedBox(height: 40),
          FlatButton(
            child: Text("Proceed"),
            onPressed: _currentDivision != "Select one" &&
                    _currentStation != "Select one"
                ? () =>
                    _handleProceed(context, _currentDivision, _currentStation)
                : null,
          )
        ],
      ),
    );
  }

  _buildMethodSelectScreen(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          child: Text("Back"),
          onPressed: () => _goBack(context),
        ),
        FlatButton(
          child: Text("Pending"),
          onPressed: () => _handleMethodSelect(context, 0),
        ),
        FlatButton(
          child: Text("Queue"),
          onPressed: () => _handleMethodSelect(context, 1),
        )
      ],
    );
  }
}

void _handleMethodSelect(BuildContext context, int method) {
  BlocProvider.of<AppBloc>(context).add(FetchElectors(method));
}

SearchScreen _buildElectorsLoadedScreen(
        BuildContext context, List<Elector> electors, bool isPending) =>
    SearchScreen(context, electors, isPending);

void _handleProceed(
    BuildContext context, String _currentDivision, String _currentStation) {
  BlocProvider.of<AppBloc>(context)
      .add(SaveMeta(ELECTION, DISTRICT, _currentDivision, _currentStation));
}

void _goBack(BuildContext context) {
  BlocProvider.of<AppBloc>(context).add(ChangeMeta(ELECTION));
}

ErrorScreen _buildErrorScreen(String error) => ErrorScreen(error);
