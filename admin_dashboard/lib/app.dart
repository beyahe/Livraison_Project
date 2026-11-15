import 'package:flutter/material.dart';

import 'widgets/sidebar.dart';

import 'screens/restaurants/restaurants_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/drivers/drivers_screen.dart';

import 'services/api_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Livraison Admin',

      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
      ),

      home: const DashboardLayout(),
    );
  }
}

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {

  final ApiService apiService = ApiService();

  int selectedIndex = 0;

  Map<String, dynamic> stats = {

    "orders": 0,
    "drivers": 0,
    "restaurants": 0,
    "products": 0,
  };

  @override
  void initState() {

    super.initState();

    loadStats();
  }

  Future<void> loadStats() async {

    try {

      final data =
          await apiService.getDashboardStats();

      setState(() {

        stats = data;
      });

    } catch (e) {

      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Row(
        children: [

          Sidebar(
            selectedIndex: selectedIndex,

            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),

              child: getSelectedScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget getSelectedScreen() {

    switch (selectedIndex) {

      case 0:
        return dashboardHome();

      case 1:
        return const RestaurantsScreen();

      case 2:
        return const ProductsScreen();

      case 3:
        return const OrdersScreen();

      case 4:
        return const DriversScreen();

      default:
        return dashboardHome();
    }
  }

  Widget dashboardHome() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 30),

        Wrap(
          spacing: 20,
          runSpacing: 20,

          children: [

            SizedBox(
              width: 300,

              child: dashboardCard(
                title: "Orders",
                value: stats["orders"].toString(),
                icon: Icons.shopping_bag,
                color: Colors.orange,
              ),
            ),

            SizedBox(
              width: 300,

              child: dashboardCard(
                title: "Drivers",
                value: stats["drivers"].toString(),
                icon: Icons.delivery_dining,
                color: Colors.green,
              ),
            ),

            SizedBox(
              width: 300,

              child: dashboardCard(
                title: "Restaurants",
                value: stats["restaurants"].toString(),
                icon: Icons.restaurant,
                color: Colors.red,
              ),
            ),

            SizedBox(
              width: 300,

              child: dashboardCard(
                title: "Products",
                value: stats["products"].toString(),
                icon: Icons.fastfood,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 28,

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(height: 25),

          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}