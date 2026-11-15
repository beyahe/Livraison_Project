import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'config.dart';

void main() {
  runApp(const MyApp());
}

// =====================================================
// APP
// =====================================================

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const DriverOrdersPage(),
    );
  }
}

// =====================================================
// DRIVER PAGE
// =====================================================

class DriverOrdersPage
    extends StatefulWidget {

  const DriverOrdersPage({super.key});

  @override
  State<DriverOrdersPage> createState() =>
      _DriverOrdersPageState();
}

class _DriverOrdersPageState
    extends State<DriverOrdersPage> {

  List orders = [];

  bool isOnline = true;

  double latitude = 18.0735;
  double longitude = -15.9582;

  Timer? timer;

  late WebSocketChannel channel;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {

    super.initState();

    connectWebSocket();

    getOrders();

    startLocationTracking();
  }

  // =====================================================
  // WEBSOCKET
  // =====================================================

  void connectWebSocket() {

    channel = WebSocketChannel.connect(

      Uri.parse(
        "${AppConfig.wsUrl}/ws/driver-location",
      ),
    );
  }

  // =====================================================
  // GET ORDERS
  // =====================================================

  Future<void> getOrders() async {

    final response = await http.get(

      Uri.parse(
        "${AppConfig.apiUrl}/orders",
      ),
    );

    orders = jsonDecode(response.body);

    setState(() {});
  }

  // =====================================================
  // ACCEPT ORDER
  // =====================================================

  Future<void> acceptOrder(
      int orderId,
      ) async {

    await http.put(

      Uri.parse(
        "${AppConfig.apiUrl}/orders/$orderId/accept",
      ),
    );

    getOrders();
  }

  // =====================================================
  // DELIVER ORDER
  // =====================================================

  Future<void> deliverOrder(
      int orderId,
      ) async {

    await http.put(

      Uri.parse(
        "${AppConfig.apiUrl}/orders/$orderId/deliver",
      ),
    );

    getOrders();
  }

  // =====================================================
  // REAL GPS TRACKING
  // =====================================================

  Future<void> startLocationTracking() async {

    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();

      if (permission ==
          LocationPermission.denied) {
        return;
      }
    }

    if (permission ==
        LocationPermission.deniedForever) {
      return;
    }

    Geolocator.getPositionStream(

      locationSettings:
          const LocationSettings(

        accuracy: LocationAccuracy.high,

        distanceFilter: 5,
      ),

    ).listen((Position position) {

      if (!isOnline) return;

      setState(() {

        latitude = position.latitude;

        longitude = position.longitude;
      });

      channel.sink.add(

        jsonEncode({

          "latitude": latitude,

          "longitude": longitude,
        }),
      );
    });
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {

    timer?.cancel();

    channel.sink.close();

    super.dispose();
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Driver Dashboard",
        ),

        actions: [

          Switch(

            value: isOnline,

            onChanged: (value) {

              setState(() {

                isOnline = value;
              });
            },
          ),
        ],
      ),

      body: Column(

        children: [

          // =============================================
          // DRIVER STATUS
          // =============================================

          Container(

            width: double.infinity,

            margin: const EdgeInsets.all(15),

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: isOnline
                  ? Colors.green
                  : Colors.red,

              borderRadius:
              BorderRadius.circular(25),
            ),

            child: Column(

              children: [

                Icon(

                  isOnline
                      ? Icons.check_circle
                      : Icons.cancel,

                  color: Colors.white,

                  size: 60,
                ),

                const SizedBox(height: 15),

                Text(

                  isOnline
                      ? "ONLINE"
                      : "OFFLINE",

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 28,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(

                  "Latitude: $latitude",

                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),

                Text(

                  "Longitude: $longitude",

                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ).animate().fade().slideY(
            begin: 0.3,
            end: 0,
          ),

          // =============================================
          // ORDERS TITLE
          // =============================================

          const Padding(

            padding: EdgeInsets.all(15),

            child: Align(

              alignment: Alignment.centerLeft,

              child: Text(

                "Available Orders",

                style: TextStyle(

                  fontSize: 28,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ),

          // =============================================
          // ORDERS LIST
          // =============================================

          Expanded(

            child: ListView.builder(

              itemCount: orders.length,

              itemBuilder: (context, index) {

                final order = orders[index];

                return Card(

                  margin:
                  const EdgeInsets.all(12),

                  elevation: 5,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Padding(

                    padding:
                    const EdgeInsets.all(20),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Text(

                          "Order #${order["id"]}",

                          style:
                          const TextStyle(

                            fontSize: 24,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(

                          "Customer: ${order["customer_name"]}",
                        ),

                        Text(

                          "Price: ${order["total_price"]} MRU",
                        ),

                        Text(

                          "Status: ${order["status"]}",
                        ),

                        const SizedBox(height: 20),

                        Row(

                          children: [

                            Expanded(

                              child:
                              ElevatedButton(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.orange,
                                ),

                                onPressed: () {

                                  acceptOrder(
                                    order["id"],
                                  );
                                },

                                child: const Text(

                                  "Accept",

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(

                              child:
                              ElevatedButton(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.green,
                                ),

                                onPressed: () {

                                  deliverOrder(
                                    order["id"],
                                  );
                                },

                                child: const Text(

                                  "Delivered",

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fade().slideY(
                  begin: 0.3,
                  end: 0,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}