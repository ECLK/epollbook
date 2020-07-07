import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  String qrInput = "";
  QRViewController _qrViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
          SizedBox(height: 12),
          Text(qrInput),
          SizedBox(height: 12),
          // TODO: Add on pressed call to update voter state
          // FlatButton(child: Text("Okay"))
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController qrViewController) {
    _qrViewController = qrViewController;

    _qrViewController.scannedDataStream.listen((data) {
      setState(() {
        qrInput = data;
      });
    });
  }
}
