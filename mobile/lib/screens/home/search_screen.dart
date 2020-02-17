import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List data = [];

  List voters;

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

  @override
  void initState() {
    voters = data;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(suffixIcon: Icon(Icons.search)),
            // TODO: set autofocus
            // autofocus: true,
            onChanged: (value) {
              _onSearch(value);
            },
          ),
          Expanded(
            child: ListView(
              children: voters
                  .map(
                    (voter) => ListTile(
                      title: Text(voter['name']),
                      subtitle: Text(voter['votingNumber']),
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            voter['avatarUrl'],
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration:
                                    BoxDecoration(color: Colors.blueAccent),
                              );
                            },
                          ),
                        ),
                      ),
                      onTap: () {
                        _handleTap(voter);
                      },
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
