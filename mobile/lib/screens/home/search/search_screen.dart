import 'package:awesome_button/awesome_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/app/app_bloc.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/styles/color_palette.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();

  final BuildContext baseContext;
  final bool isPending;

  final List<Elector> data;
  List<Elector> electors;

  SearchScreen(this.baseContext, this.data, this.isPending) {
    electors = data;
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(18.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: Icon(Icons.refresh),
                onTap: () => _refresh(widget.baseContext, widget.isPending),
              ),
              PopupMenuButton(
                elevation: 2,
                onSelected: (int value) {
                  switch (value) {
                    case 0:
                      _goBack(widget.baseContext);
                      break;

                    case 1:
                      _gotoMetadataChange(context);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text("Change Position"),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text("Change Metadata"),
                  )
                ].toList(),
              )
            ],
          ),
          // AwesomeButton(
          //   blurRadius: 10.0,
          //   splashColor: Color.fromRGBO(255, 255, 255, 0.4),
          //   borderRadius: BorderRadius.circular(50.0),
          //   height: 100.0,
          //   width: 100.0,
          //   color: Colors.blueAccent,
          //   child: Icon(
          //     Icons.crop_free,
          //     color: Colors.white,
          //     size: 40,
          //   ),
          //   onTap: _scanQR,
          // ),
          // SizedBox(
          //   height: 40.0,
          // ),
          // Text("OR"),
          SizedBox(
            height: 40.0,
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                ),
              ],
            ),
            child: TextField(
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                focusColor: ColorPalette.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(width: 0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(width: 1, color: ColorPalette.primary),
                ),
                hintText: "Search by Elector ID / NIC",
                suffixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ),
              // TODO: set autofocus
              // autofocus: true,
              controller: _editingController,
              onChanged: (value) {
                _onSearch(value);
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
          ),
        ],
      ),
      child: widget.electors.isNotEmpty
          ? ListView(
              children: widget.electors
                  .map(
                    (elector) => ListTile(
                      title: Text(
                        elector.id,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(elector.nic),
                      onTap: () {
                        _handleTap(elector);
                      },
                    ),
                  )
                  .toList())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: ColorPalette.idle,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nothing so far",
                    style: TextStyle(color: ColorPalette.idle),
                  )
                ],
              ),
            ),
    );
  }

  void _scanQR() {
    // Application.router.navigateTo(context, '/scanner');
  }

  void _onSearch(String value) {
    setState(() {
      widget.electors = widget.data
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
                  "ID",
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
                  "Elector Id",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.electorId,
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
                  "Name",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  elector.nameSi,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 40.0,
                ),
                FlatButton(
                  child: Text(
                    widget.isPending ? "Add to Queue" : "Mark as Voted",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: ColorPalette.primary,
                  onPressed: () =>
                      _updateVoterState(elector.id, widget.isPending),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateVoterState(String id, bool isPending) {
    setState(() {
      _editingController.text = "";
    });
    Navigator.pop(context);
    BlocProvider.of<AppBloc>(context)
        .add(isPending ? UpdateToQueued(id) : UpdateToVoted(id));
  }

  void _goBack(BuildContext context) {
    BlocProvider.of<AppBloc>(context).add(ChangeMethod());
  }

  void _gotoMetadataChange(BuildContext context) {
    BlocProvider.of<AppBloc>(context).add(ChangeMeta(ELECTION));
  }

  void _refresh(BuildContext context, bool isPending) {
    BlocProvider.of<AppBloc>(context).add(Refresh(isPending ? 0 : 1));
  }
}
