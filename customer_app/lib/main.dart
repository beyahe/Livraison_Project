import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      home: CustomerMapPage(),
    );
  }
}

class CustomerMapPage extends StatefulWidget {
  @override
  State<CustomerMapPage> createState() => _CustomerMapPageState();
}

class _CustomerMapPageState extends State<CustomerMapPage> {

  GoogleMapController? mapController;

  LatLng driverLocation = const LatLng(
    18.0837,
    -15.9729,
  );

  Timer? timer;

  @override
  void initState() {
    super.initState();

    startTracking();
  }

  void startTracking() {

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {

        await fetchDriverLocation();

      },
    );
  }

  Future<void> fetchDriverLocation() async {

    final response = await http.get(
      Uri.parse(
        "http://127.0.0.1:8000/drivers/1/location",
      ),
    );

    final data = jsonDecode(response.body);

    double latitude = data["latitude"];

    double longitude = data["longitude"];

    setState(() {

      driverLocation = LatLng(
        latitude,
        longitude,
      );

    });

    mapController?.animateCamera(
      CameraUpdate.newLatLng(driverLocation),
    );
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
        title: const Text("Customer App"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: driverLocation,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId("driver"),
            position: driverLocation,
          ),
        },
      ),
    );
  }
}