import 'package:awesome_button/awesome_button.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List data = [];

  List voters;

  @override
  void initState() {
    voters = data;
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
                hintText: "Search by elector id",
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
      children: voters
          .map(
            (voter) => ListTile(
              title: Text(voter['name']),
              subtitle: Text(voter['votingNumber']),
              onTap: () {
                _handleTap(voter);
              },
            ),
          )
          .toList(),
    );
  }

  void _scanQR() {}

  void _onSearch(String value) {
    setState(() {
      voters = data
          .where((voter) =>
              voter['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  void _handleTap(voter) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container(
                    width: 180,
                    height: 180,
                    child: Image.network(
                      voter['avatarUrl'],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(color: Colors.blueAccent),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(child: Text(voter['name'])),
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: Text(
                    voter['votingNumber'],
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: 120.0,
                ),
                FlatButton(
                  child: Text(
                    "Select",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  onPressed: () {
                    _selectVoter(voter['votingNumber']);
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _selectVoter(String index) {
    Logger().i(index);
  }
}
