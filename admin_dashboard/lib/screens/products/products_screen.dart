import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState
    extends State<ProductsScreen> {

  final ApiService apiService = ApiService();

  List products = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchProducts();
  }

  Future<void> fetchProducts() async {

    try {

      final data =
          await apiService.getProducts(1);

      setState(() {

        products = data;

        isLoading = false;
      });

    } catch (e) {

      print(e);
    }
  }

  Future<void> showAddProductDialog() async {

    final nameController =
        TextEditingController();

    final priceController =
        TextEditingController();

    final imageController =
        TextEditingController();

    final restaurantIdController =
        TextEditingController();

    await showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text("Add Product"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                TextField(
                  controller: nameController,

                  decoration: const InputDecoration(
                    labelText: "Product Name",
                  ),
                ),

                TextField(
                  controller: priceController,

                  decoration: const InputDecoration(
                    labelText: "Price",
                  ),
                ),

                TextField(
                  controller: imageController,

                  decoration: const InputDecoration(
                    labelText: "Image URL",
                  ),
                ),

                TextField(
                  controller:
                      restaurantIdController,

                  decoration: const InputDecoration(
                    labelText: "Restaurant ID",
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

                await apiService.createProduct(

                  name: nameController.text,

                  price: double.parse(
                    priceController.text,
                  ),

                  image: imageController.text,

                  restaurantId: int.parse(
                    restaurantIdController.text,
                  ),
                );

                Navigator.pop(context);

                fetchProducts();
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
              "Products",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            ElevatedButton.icon(

              onPressed: showAddProductDialog,

              icon: const Icon(Icons.add),

              label:
                  const Text("Add Product"),
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

              itemCount: products.length,

              itemBuilder: (context, index) {

                final product =
                    products[index];

                return ListTile(

                  leading: const CircleAvatar(
                    child: Icon(Icons.fastfood),
                  ),

                  title: Text(
                    product["name"],
                  ),

                  subtitle: Text(
                    "${product["price"]} MRU",
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [

                      Text(
                        "Restaurant: ${product["restaurant_id"]}",
                      ),

                      const SizedBox(width: 15),

                      IconButton(

                        onPressed: () async {

                          await apiService.deleteProduct(
                            product["id"],
                          );

                          fetchProducts();
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