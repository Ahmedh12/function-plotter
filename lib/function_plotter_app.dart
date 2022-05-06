// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
//import 'package:eval_ex/expression.dart';

class FunctionPlotterApp extends StatefulWidget {
  const FunctionPlotterApp({Key? key}) : super(key: key);

  @override
  State<FunctionPlotterApp> createState() => FunctionPlotterAppState();
}

class PointData {
  final double x;
  final double y;
  PointData({required this.x, required this.y});
}

class EqComp {
  double coeff;
  double power;
  EqComp(this.coeff, this.power);
}

class FunctionPlotterAppState extends State<FunctionPlotterApp> {
  final TextEditingController _functionController = TextEditingController();
  final TextEditingController _xMinController = TextEditingController();
  final TextEditingController _xMaxController = TextEditingController();
  String? errorMessage;
  late List<PointData> chartData = [
    PointData(x: 0, y: 0),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Function Plotter',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    label: 'Enter the function:',
                    hint: 'f(x) = ...',
                    controller: _functionController,
                    keyboardType: TextInputType.text,
                    sizeFactor: 0.30),
                _buildTextField(
                    label: 'Enter the minimum value:',
                    hint: 'xmin = ...',
                    controller: _xMinController,
                    keyboardType: TextInputType.number,
                    sizeFactor: 0.20),
                _buildTextField(
                    label: 'Enter the maximum value:',
                    hint: 'xmax = ...',
                    controller: _xMaxController,
                    keyboardType: TextInputType.number,
                    sizeFactor: 0.20),
              ]),
          _buildChart(),
          _buildElevatedButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required double sizeFactor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20.0),
      child: TextField(
        decoration: InputDecoration(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * sizeFactor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          labelText: label,
          hintText: hint,
        ),
        keyboardType: keyboardType,
        controller: controller,
      ),
    );
  }

  Widget _buildElevatedButton() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            chartData = [PointData(x: 0, y: 0)];
          });
          if (_functionController.text.isEmpty ||
              _xMinController.text.isEmpty ||
              _xMaxController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill all the fields.'),
              ),
            );
          } else if (!isValid(_functionController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage!),
              ),
            );
          } else if (double.tryParse(_xMinController.text) == null ||
              double.tryParse(_xMaxController.text) == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter valid range numbers.'),
              ),
            );
          } else {
            plot();
          }
        },
        child: Text(
          'Plot',
          style: TextStyle(
              color: Colors.black87,
              fontSize: 25.0,
              fontWeight: FontWeight.w600),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.lightBlue),
          minimumSize: MaterialStateProperty.all<Size>(
              Size(MediaQuery.of(context).size.width * 0.35, 50)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0))),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 45.0),
      child: SfCartesianChart(
          backgroundColor: Colors.white12,
          series: <ChartSeries>[
            SplineSeries<PointData, double>(
              dataSource: chartData,
              xValueMapper: (PointData data, _) => data.x,
              yValueMapper: (PointData data, _) => data.y,
            ),
          ]),
    );
  }

  List<PointData> fillChartdata(List<EqComp> comps) {
    List<PointData> data = [];
    double x = 0;
    double y = 0;
    double xMax = double.parse(_xMaxController.text);
    double xMin = double.parse(_xMinController.text);
    double step = (xMax - xMin) / 200;

    x = xMin;
    while (x <= xMax) {
      for (EqComp comp in comps) {
        y += comp.coeff * pow(x, comp.power);
      }
      data.add(PointData(x: x, y: y));
      x += step;
      y = 0;
    }
    return data;
  }

  List<EqComp> parseEquation(String euqation) {
    List<EqComp> eqComponents = [];
    RegExp regExp = RegExp(r'[+-]?[(\d)|(\d+/\d+)]*x(\^\d+)?|\d+');
    euqation = euqation.replaceAll('*', '');
    euqation = euqation.trim();
    euqation = euqation.replaceAll(RegExp(r'\s+'), '');
    Iterable<RegExpMatch> matches = regExp.allMatches(euqation);
    for (RegExpMatch match in matches) {
      //print(match.group(0));
      String? matchString = match.group(0);
      if (matchString != null &&
          matchString.contains('x') &&
          matchString.contains('^')) {
        double coeff;
        double power = matchString.split('^')[1].contains('/')
            ? double.parse(matchString.split('^')[1].split('/')[0]) /
                double.parse(matchString.split('^')[1].split('/')[1])
            : double.parse(matchString.split('^')[1]);
        if (matchString.replaceAll("x", "").replaceAll("^", "").length == 1) {
          coeff = 1;
        } else {
          coeff = matchString.split('^')[0].replaceAll('x', '').contains('/')
              ? double.parse(matchString
                      .split('^')[0]
                      .replaceAll('x', '')
                      .split('/')[0]) /
                  double.parse(matchString
                      .split('^')[0]
                      .replaceAll('x', '')
                      .split('/')[1])
              : double.parse(matchString.split('^')[0].replaceAll('x', ''));
        }
        eqComponents.add(EqComp(coeff, power));
      } else if (matchString != null && matchString.contains('x')) {
        double coeff;
        double power = 1.0;
        if (matchString.replaceAll("x", "").length == 0) {
          coeff = 1;
        } else {
          coeff = matchString.substring(0, matchString.length - 1).contains('/')
              ? double.parse(matchString
                      .substring(0, matchString.length - 1)
                      .split('/')[0]) /
                  double.parse(matchString
                      .substring(0, matchString.length - 1)
                      .split('/')[1])
              : double.parse(matchString.substring(0, matchString.length - 1));
        }
        eqComponents.add(EqComp(coeff, power));
      } else if (matchString != null) {
        double coeff = matchString.contains('/')
            ? double.parse(matchString.split('/')[0]) /
                double.parse(matchString.split('/')[1])
            : double.parse(matchString);
        eqComponents.add(EqComp(coeff, 0.0));
      } else {
        eqComponents.add(EqComp(0.0, 0.0));
      }
    }
    return eqComponents;
  }

  void plot() {
    setState(() {
      chartData = fillChartdata(parseEquation(_functionController.text));
    });
  }

  bool isValid(String input) {
    if (input.isEmpty) {
      return false;
    }
    print(input);
    if (RegExp(r'[a-w_y-zA-Z]').hasMatch(input)) {
      errorMessage = 'equation should contain the variable x only';
      return false;
    }
    return true;
  }

  // void plot() {
  //   Expression eq = Expression(_functionController.text);
  //   double xMax = double.parse(_xMaxController.text);
  //   double xMin = double.parse(_xMinController.text);
  //   double step = (xMax - xMin) / 500;
  //   setState(() {
  //     for (double i = xMin; i <= xMax; i += step) {
  //       try {
  //         eq.setStringVariable('x', i.toString());
  //         var y = eq.eval()?.toDouble();
  //         if (y != null && !y.isNaN) {
  //           chartData.add(PointData(x: i, y: y));
  //         } else {
  //           chartData.add(PointData(x: i, y: 0.0));
  //         }
  //       } catch (e) {
  //         ScaffoldMessenger.of(context)
  //             .showSnackBar(SnackBar(content: Text('Error: $e')));
  //       }
  //     }
  //   });
  // }
}
