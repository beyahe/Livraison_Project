import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DriverHomePage(),
    );
  }
}

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {

  String status = "Offline";

  Timer? timer;

  @override
  void initState() {
    super.initState();

    startTracking();
  }

  Future<void> startTracking() async {

    LocationPermission permission;

    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      return;
    }

    setState(() {
      status = "Online";
    });

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {

        Position position = await Geolocator.getCurrentPosition();

        double latitude = position.latitude;

        double longitude = position.longitude;

        await updateLocation(
          latitude,
          longitude,
        );

      },
    );
  }

  Future<void> updateLocation(
    double latitude,
    double longitude,
  ) async {

    try {

      final response = await http.put(
        Uri.parse(
          "http://127.0.0.1:8000/drivers/1/location?latitude=$latitude&longitude=$longitude",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({}),
      );

      print("Location Updated");
      print(response.body);

    } catch (e) {

      print("Error:");
      print(e);

    }
  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver App"),
      ),
      body: Center(
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}