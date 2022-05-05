import 'package:flutter/material.dart';
import 'function_plotter_app.dart';

void main() {
  runApp(const FunctionPlotter());
}

class FunctionPlotter extends StatelessWidget {
  const FunctionPlotter({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Function Plotter',
        theme: ThemeData(
          backgroundColor: Colors.white,
          primarySwatch: Colors.blue,
        ),
        home: const FunctionPlotterApp());
  }
}
