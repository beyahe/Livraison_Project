import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() =>
      _RestaurantsScreenState();
}

class _RestaurantsScreenState
    extends State<RestaurantsScreen> {

  final ApiService apiService = ApiService();

  List restaurants = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {

    try {

      final data =
          await apiService.getRestaurants();

      setState(() {

        restaurants = data;

        isLoading = false;
      });

    } catch (e) {

      print(e);
    }
  }

  Future<void> showAddRestaurantDialog() async {

    final nameController =
        TextEditingController();

    final categoryController =
        TextEditingController();

    final latitudeController =
        TextEditingController();

    final longitudeController =
        TextEditingController();

    final imageController =
        TextEditingController();

    await showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text("Add Restaurant"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                TextField(
                  controller: nameController,

                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),

                TextField(
                  controller: categoryController,

                  decoration: const InputDecoration(
                    labelText: "Category",
                  ),
                ),

                TextField(
                  controller: latitudeController,

                  decoration: const InputDecoration(
                    labelText: "Latitude",
                  ),
                ),

                TextField(
                  controller: longitudeController,

                  decoration: const InputDecoration(
                    labelText: "Longitude",
                  ),
                ),

                TextField(
                  controller: imageController,

                  decoration: const InputDecoration(
                    labelText: "Image URL",
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                await apiService.createRestaurant(

                  name: nameController.text,

                  category:
                      categoryController.text,

                  latitude: double.parse(
                    latitudeController.text,
                  ),

                  longitude: double.parse(
                    longitudeController.text,
                  ),

                  image: imageController.text,
                );

                Navigator.pop(context);

                fetchRestaurants();
              },

              child: const Text("Create"),
            ),
          ],
        );
      },
    );
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

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [

            const Text(
              "Restaurants",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            ElevatedButton.icon(

              onPressed: showAddRestaurantDialog,

              icon: const Icon(Icons.add),

              label:
                  const Text("Add Restaurant"),
            ),
          ],
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

              itemCount: restaurants.length,

              itemBuilder: (context, index) {

                final restaurant =
                    restaurants[index];

                return ListTile(

                  leading: const CircleAvatar(
                    child: Icon(Icons.restaurant),
                  ),

                  title: Text(
                    restaurant["name"],
                  ),

                  subtitle: Text(
                    restaurant["category"],
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      Text(
                        "ID: ${restaurant["id"]}",
                      ),

                      const SizedBox(width: 15),

                      IconButton(

                        onPressed: () async {

                          await apiService
                              .deleteRestaurant(
                            restaurant["id"],
                          );

                          fetchRestaurants();
                        },

                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
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