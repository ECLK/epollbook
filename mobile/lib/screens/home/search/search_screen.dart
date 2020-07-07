import 'package:awesome_button/awesome_button.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/styles/color_palette.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Elector> data = [
    Elector(
        id: "2332123",
        nic: "961881579v",
        fullName: "John Doe",
        address: "Colombo 3",
        age: "23",
        gender: "Male"),
    Elector(
        id: "2333221",
        nic: "988771233v",
        fullName: "Alice Fender",
        address: "Colombo 7",
        age: "21",
        gender: "Female")
  ];

  List<Elector> electors;

  @override
  void initState() {
    electors = data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(18.0),
      child: Column(
        children: <Widget>[
          AwesomeButton(
            blurRadius: 10.0,
            splashColor: Color.fromRGBO(255, 255, 255, 0.4),
            borderRadius: BorderRadius.circular(50.0),
            height: 100.0,
            width: 100.0,
            color: Colors.blueAccent,
            child: Icon(
              Icons.crop_free,
              color: Colors.white,
              size: 40,
            ),
            onTap: _scanQR,
          ),
          SizedBox(
            height: 40.0,
          ),
          Text("OR"),
          SizedBox(
            height: 40.0,
          ),
          TextField(
            decoration: InputDecoration(
                hintText: "Search by Elector ID / NIC",
                suffixIcon: Icon(Icons.search)),
            // TODO: set autofocus
            // autofocus: true,
            onChanged: (value) {
              _onSearch(value);
            },
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView(
      children: electors
          .map(
            (elector) => ListTile(
              title: Text(elector.id),
              subtitle: Text(elector.nic),
              trailing: _buildStateTail(elector.state),
              onTap: () {
                _handleTap(elector);
              },
            ),
          )
          .toList(),
    );
  }

  void _scanQR() {}

  void _onSearch(String value) {
    setState(() {
      electors = data
          .where((elector) =>
              elector.id.toLowerCase().contains(value.toLowerCase()) ||
              elector.nic.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _handleTap(Elector elector) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Elector Id",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.id,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "NIC",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.nic,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Full Name",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.fullName,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Age",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.age,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Gender",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.gender,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Address",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.address,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 40.0,
                ),
                (elector.state == VoteState.PENDING ||
                        elector.state == VoteState.IN_QUEUE)
                    ? elector.state == VoteState.PENDING
                        ? FlatButton(
                            child: Text(
                              "Update to In Queue",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.blueAccent,
                            onPressed: () => _updateVoterState(elector),
                          )
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  child: Text(
                                    "Vote Error",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: ColorPalette.error,
                                  onPressed: () =>
                                      _updateVoterState(elector, isFine: false),
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: FlatButton(
                                  child: Text(
                                    "Vote Success",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: ColorPalette.success,
                                  onPressed: () =>
                                      _updateVoterState(elector, isFine: true),
                                ),
                              ),
                            ],
                          )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateTail(VoteState state) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: getStateColor(state),
      ),
      child: Text(
        getStateText(state),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _updateVoterState(Elector elector, {bool isFine}) {
    Navigator.pop(context);

    switch (elector.state) {
      case VoteState.PENDING:
        setState(() {
          elector.state = VoteState.IN_QUEUE;
        });
        break;

      case VoteState.IN_QUEUE:
        setState(() {
          elector.state =
              isFine ? VoteState.VOTE_SUCCESS : VoteState.VOTE_ERROR;
        });
        break;

      default:
    }
  }

  Color getStateColor(VoteState state) {
    switch (state) {
      case VoteState.IN_QUEUE:
        return ColorPalette.pending;

      case VoteState.VOTE_SUCCESS:
        return ColorPalette.success;

      case VoteState.VOTE_ERROR:
        return ColorPalette.error;

      default:
        return Colors.white;
    }
  }

  String getStateText(VoteState state) {
    switch (state) {
      case VoteState.IN_QUEUE:
        return "In Queue";

      case VoteState.VOTE_SUCCESS:
        return "Success";

      case VoteState.VOTE_ERROR:
        return "Error";

      default:
        return "";
    }
  }
}
