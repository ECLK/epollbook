import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}

class AnalyticsScreen extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  AnalyticsScreen(this.seriesList, {this.animate});

  factory AnalyticsScreen.withSampleData() {
    return new AnalyticsScreen(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(18.0),
        // child: Column(
        //   children: <Widget>[
        //     Text(
        //       "Total Votes",
        //       style: TextStyle(fontSize: 18),
        //     ),
        //     Text(
        //       "870",
        //       style: TextStyle(
        //         fontSize: 30,
        //         fontWeight: FontWeight.w800,
        //       ),
        //     ),
        //     SizedBox(
        //       height: 40.0,
        //     ),
        //     Text(
        //       "Vote Progress",
        //       style: TextStyle(fontSize: 18),
        //     ),

        //   ],
        // ),
        child: charts.PieChart(
          seriesList,
          animate: animate,
          defaultRenderer: new charts.ArcRendererConfig(arcWidth: 60),
          defaultInteractions: true,
        ),
      ),
    );
  }

  static List<charts.Series<LinearSales, int>> _createSampleData() {
    final data = [
      new LinearSales(0, 100),
      new LinearSales(1, 75),
      new LinearSales(2, 25),
      new LinearSales(3, 5),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'Sales',
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}
