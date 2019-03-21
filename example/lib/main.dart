import 'dart:async';

import 'package:fit_kit/fit_kit.dart';
import 'package:flutter/material.dart';

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
      final permissions = await FitKit.requestPermissions(DataType.values);
      if (!permissions) {
        results = "User declined permissions";
      } else {
        for (DataType type in DataType.values) {
          final data = await FitKit.read(
            type,
            DateTime.now().subtract(Duration(days: 5)),
            DateTime.now(),
          );

          final result = "Type $type = ${data.length} $data\n\n\n";
          results += result;
          debugPrint(result);
        }
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('$_results'),
              FlatButton(
                onPressed: () => readAll(),
                child: Text("Reload"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
