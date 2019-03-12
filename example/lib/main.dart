import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fit_kit/fit_kit.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _results = 'Unknown';

  @override
  void initState() {
    super.initState();
    readAll();
  }

  Future<void> readAll() async {
    String results = "";

    try {
      for (DataType type in DataType.values) {
        final response = await FitKit.read(
          type,
          DateTime.now().subtract(Duration(days: 5)),
          DateTime.now(),
        );

        final result = "Type $type = ${response.length} ${response.map((data) => data.value)}\n\n\n";
        results += result;
        debugPrint(result);
      }
    } catch (e) {
      results = 'Failed to read all values. $e';
    }

    if (!mounted) return;

    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Text('$_results'),
          ),
        ),
      ),
    );
  }
}
