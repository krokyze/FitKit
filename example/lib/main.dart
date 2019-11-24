import 'dart:async';

import 'package:fit_kit/fit_kit.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = '';
  Map<DataType, List<FitData>> results = Map();
  bool permissions;

  @override
  void initState() {
    super.initState();
    hasPermissions();
  }

  Future<void> readAll() async {
    results.clear();

    try {
      permissions = await FitKit.requestPermissions(DataType.values);
      if (!permissions) {
        result = 'requestPermissions: failed';
      } else {
        for (DataType type in DataType.values) {
          final data = await FitKit.read(
            type,
            DateTime.now().subtract(Duration(days: 5)),
            DateTime.now(),
          );

          results[type] = data;
        }

        result = 'readAll: success';
      }
    } catch (e) {
      result = 'readAll: $e';
    }

    setState(() {});
  }

  Future<void> revokePermissions() async {
    results.clear();

    try {
      await FitKit.revokePermissions();
      permissions = await FitKit.hasPermissions(DataType.values);
      result = 'revokePermissions: success';
    } catch (e) {
      result = 'revokePermissions: $e';
    }

    setState(() {});
  }

  Future<void> hasPermissions() async {
    try {
      permissions = await FitKit.hasPermissions(DataType.values);
    } catch (e) {
      result = 'hasPermissions: $e';
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items =
        results.entries.expand((entry) => [entry.key, ...entry.value]).toList();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('FitKit Example'),
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FlatButton(
                    onPressed: () => readAll(),
                    child: Text('Read All'),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () => revokePermissions(),
                    child: Text('Revoke permissions'),
                  ),
                ),
              ],
            ),
            Text('Permissions: $permissions'),
            Text(result),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item is DataType) {
                    return ListTile(
                      title: Text(
                        '$item - ${results[item].length}',
                        style: Theme.of(context).textTheme.title,
                      ),
                    );
                  } else if (item is FitData) {
                    return ListTile(
                      title: Text(
                        '$item',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  }

                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
