import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();
}

class _OrdersScreenState
    extends State<OrdersScreen> {

  final ApiService apiService = ApiService();

  List orders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchOrders();
  }

  Future<void> fetchOrders() async {

    try {

      final data =
          await apiService.getOrders();

      setState(() {

        orders = data;

        isLoading = false;
      });

    } catch (e) {

      print(e);
    }
  }

  Future<void> showAssignDriverDialog(
    int orderId,
  ) async {

    final drivers =
        await apiService.getDrivers();

    if (!mounted) return;

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            "Assign Driver",
          ),

          content: SizedBox(
            width: 300,

            child: ListView.builder(

              shrinkWrap: true,

              itemCount: drivers.length,

              itemBuilder: (context, index) {

                final driver =
                    drivers[index];

                return ListTile(

                  title: Text(
                    driver["name"],
                  ),

                  subtitle: Text(
                    driver["status"],
                  ),

                  onTap: () async {

                    await apiService
                        .assignDriver(

                      orderId: orderId,

                      driverId:
                          driver["id"],
                    );

                    if (!mounted) return;

                    Navigator.pop(
                      context,
                    );

                    fetchOrders();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color getStatusColor(String status) {

    switch (status) {

      case "pending":
        return Colors.orange;

      case "accepted":
        return Colors.blue;

      case "delivered":
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(
          "Orders",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 30),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: ListView.builder(

              itemCount: orders.length,

              itemBuilder: (context, index) {

                final order = orders[index];

                return Card(

                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),

                  child: ListTile(

                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.shopping_bag,
                      ),
                    ),

                    title: Text(
                      order["customer_name"],
                    ),

                    subtitle: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          "${order["total_price"]} MRU",
                        ),

                        if (order["driver_name"] != null)

                          Text(
                            "Driver: ${order["driver_name"]}",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                        const SizedBox(height: 5),

                        Text(
                          order["status"],
                          style: TextStyle(
                            color: getStatusColor(
                              order["status"],
                            ),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        if (order["status"] ==
                            "pending")

                          ElevatedButton(

                            onPressed: () {

                              showAssignDriverDialog(
                                order["id"],
                              );
                            },

                            child: const Text(
                              "Assign Driver",
                            ),
                          ),

                        if (order["status"] ==
                            "pending")

                          const SizedBox(
                            width: 10,
                          ),

                        if (order["status"] ==
                            "pending")

                          ElevatedButton(

                            onPressed: () async {

                              await apiService
                                  .acceptOrder(
                                order["id"],
                              );

                              fetchOrders();
                            },

                            child: const Text(
                              "Accept",
                            ),
                          ),

                        if (order["status"] ==
                            "accepted")

                          const SizedBox(
                            width: 10,
                          ),

                        if (order["status"] ==
                            "accepted")

                          ElevatedButton(

                            onPressed: () async {

                              await apiService
                                  .deliverOrder(
                                order["id"],
                              );

                              fetchOrders();
                            },

                            child: const Text(
                              "Deliver",
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}