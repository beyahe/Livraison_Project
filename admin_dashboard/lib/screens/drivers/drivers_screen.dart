import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() =>
      _DriversScreenState();
}

class _DriversScreenState
    extends State<DriversScreen> {

  late WebSocketChannel channel;

  double latitude = 18.0735;
  double longitude = -15.9582;

  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();

    connectWebSocket();
  }

  void connectWebSocket() {

    channel = WebSocketChannel.connect(

      Uri.parse(
        "${AppConfig.wsUrl}/ws/driver-location",
      ),
    );

    channel.stream.listen((message) {

      final data = jsonDecode(message);

      setState(() {

        latitude = data["latitude"];
        longitude = data["longitude"];
      });

      moveCamera();
    });
  }

  void moveCamera() {

    if (mapController != null) {

      mapController!.animateCamera(

        CameraUpdate.newLatLng(

          LatLng(
            latitude,
            longitude,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {

    channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Drivers Live Tracking",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ClipRRect(

            borderRadius:
                BorderRadius.circular(20),

            child: GoogleMap(

              initialCameraPosition:
                  CameraPosition(

                target: LatLng(
                  latitude,
                  longitude,
                ),

                zoom: 14,
              ),

              onMapCreated: (controller) {
                mapController = controller;
              },

              markers: {

                Marker(

                  markerId:
                      const MarkerId("driver"),

                  position: LatLng(
                    latitude,
                    longitude,
                  ),

                  infoWindow: const InfoWindow(
                    title: "Ahmed Driver",
                  ),
                ),
              },
            ),
          ),
        ),
      ],
    );
  }
}