import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const methodChannel = MethodChannel('com.julow.barometer/method');
  static const pressureChannel = EventChannel('com.julow.barometer/pressure');

  String _sensorAvailable = 'Unknown';
  double _pressureReading = 0;
  late StreamSubscription pressureSubscription;

  Future<void> _checkAvailability() async {
    try {
      var available = await methodChannel.invokeMethod("isSensorAvailable");
      setState(() {
        _sensorAvailable = available.toString();
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  _startReading() {
    pressureSubscription =
        pressureChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        _pressureReading = event;
      });
    });
  }

  _stopReading() {
    setState(() {
      _pressureReading = 0;
    });
    pressureSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Sensor Available? : $_sensorAvailable"),
          ElevatedButton(
              onPressed: () => _checkAvailability(),
              child: Text("Check Sensor Available")),
          const SizedBox(
            height: 50,
          ),
          if (_pressureReading != 0) Text("Sensor Reading : $_pressureReading"),
          if (_sensorAvailable == 'true' && _pressureReading == 0)
            ElevatedButton(
              onPressed: () => _startReading(),
              child: Text('Start Reading'),
            ),
          if (_pressureReading != 0)
            ElevatedButton(
              onPressed: () => _stopReading(),
              child: Text("Stop Reading"),
            )
        ]),
      ),
    );
  }
}
