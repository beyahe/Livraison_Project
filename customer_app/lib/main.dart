import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'config.dart';

List cart = [];

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

        scaffoldBackgroundColor:
        const Color(0xfff5f5f5),

        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}

// =====================================================
// SPLASH SCREEN
// =====================================================

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {

    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {

    final prefs =
    await SharedPreferences.getInstance();

    final token =
    prefs.getString("token");

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (token != null) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>
          const MainNavigation(),
        ),
      );
    }

    else {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (context) =>
          const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xff121212),

      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: const [

            Icon(

              Icons.delivery_dining,

              size: 120,

              color: Colors.orange,
            ),

            SizedBox(height: 20),

            Text(

              "Livraison",

              style: TextStyle(

                color: Colors.white,

                fontSize: 42,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(height: 40),

            CircularProgressIndicator(
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// LOGIN PAGE
// =====================================================

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final usernameController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool isLoading = false;

  // =====================================================
  // LOGIN
  // =====================================================

  Future<void> login() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "${AppConfig.apiUrl}/login"
              "?username=${usernameController.text}"
              "&password=${passwordController.text}",
        ),
      );

      final data =
      jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      if (data["access_token"] != null) {

        final prefs =
        await SharedPreferences.getInstance();

        await prefs.setString(
          "token",
          data["access_token"],
        );

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (context) =>
            const MainNavigation(),
          ),
        );
      }

      else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            backgroundColor: Colors.red,

            content: Text(

              data["error"] ??
                  "Login failed",
            ),
          ),
        );
      }
    }

    catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<void> register() async {

    setState(() {
      isLoading = true;
    });

    try {

      final response = await http.post(

        Uri.parse(
          "${AppConfig.apiUrl}/register"
              "?username=${usernameController.text}"
              "&password=${passwordController.text}"
              "&role=customer",
        ),
      );

      final data =
      jsonDecode(response.body);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor: Colors.green,

          content: Text(

            data["message"] ??
                data["error"] ??
                "Done",
          ),
        ),
      );
    }

    catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xff121212),

      body: Center(

        child: SingleChildScrollView(

          child: Padding(

            padding:
            const EdgeInsets.all(25),

            child: Column(

              children: [

                const Icon(

                  Icons.delivery_dining,

                  size: 120,

                  color: Colors.orange,
                ),

                const SizedBox(height: 20),

                const Text(

                  "Livraison",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 42,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(

                  "Premium Delivery Experience",

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 50),

                TextField(

                  controller:
                  usernameController,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(

                    filled: true,

                    fillColor:
                    const Color(0xff1E1E1E),

                    hintText: "Username",

                    hintStyle:
                    const TextStyle(
                      color: Colors.white54,
                    ),

                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.orange,
                    ),

                    border:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(20),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(

                  controller:
                  passwordController,

                  obscureText: true,

                  style: const TextStyle(
                    color: Colors.white,
                  ),

                  decoration: InputDecoration(

                    filled: true,

                    fillColor:
                    const Color(0xff1E1E1E),

                    hintText: "Password",

                    hintStyle:
                    const TextStyle(
                      color: Colors.white54,
                    ),

                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.orange,
                    ),

                    border:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(20),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(

                  width: double.infinity,
                  height: 60,

                  child: ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.orange,

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                    ),

                    onPressed:
                    isLoading ? null : login,

                    child: isLoading

                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )

                        : const Text(

                      "LOGIN",

                      style: TextStyle(

                        fontSize: 18,

                        color: Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(

                  onPressed: register,

                  child: const Text(

                    "Create Account",

                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// NAVIGATION
// =====================================================

class MainNavigation extends StatefulWidget {

  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  int currentIndex = 0;

  final screens = [

    RestaurantsPage(),
    OrdersPage(),
    const CartPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        // Keep all 4 buttons visible
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.orange,

        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// =====================================================
// HOME PAGE
// =====================================================

class RestaurantsPage
    extends StatelessWidget {

  final List restaurants = [

    {
      "id": 1,
      "name": "مطعم شنقيط",
      "image":
      "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
    },

    {
      "id": 2,
      "name": "بيت البيتزا",
      "image":
      "https://images.unsplash.com/photo-1513104890138-7c749659a591",
    },

    {
      "id": 3,
      "name": "مطعم الساحل",
      "image":
      "https://images.unsplash.com/photo-1579871494447-9811cf80d66c",
    },
  ];

  RestaurantsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: ListView(

        children: [

          const SizedBox(height: 20),

          const Padding(

            padding: EdgeInsets.all(20),

            child: Text(

              "Popular Restaurants",

              style: TextStyle(

                fontSize: 30,

                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          ...restaurants.map((restaurant) {

            return Container(

              margin:
              const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: Colors.white,

                borderRadius:
                BorderRadius.circular(30),

                boxShadow: const [

                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  ),
                ],
              ),

              child: Column(

                children: [

                  ClipRRect(

                    borderRadius:
                    const BorderRadius.only(

                      topLeft:
                      Radius.circular(30),

                      topRight:
                      Radius.circular(30),
                    ),

                    child: CachedNetworkImage(

                      imageUrl:
                      restaurant["image"],

                      height: 220,

                      width:
                      double.infinity,

                      fit: BoxFit.cover,
                    ),
                  ),

                  Padding(

                    padding:
                    const EdgeInsets.all(20),

                    child: Row(

                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                      children: [

                        Text(

                          restaurant["name"],

                          style:
                          const TextStyle(

                            fontSize: 24,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        ElevatedButton(

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.orange,
                          ),

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (context) =>

                                    ProductsPage(

                                      restaurant: restaurant,
                                    ),
                              ),
                            );
                          },

                          child:
                          const Text("Order"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade().slideY();
          }).toList(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// =====================================================
// PRODUCTS PAGE
// =====================================================

class ProductsPage extends StatefulWidget {

  final dynamic restaurant;

  const ProductsPage({
    super.key,
    required this.restaurant,
  });

  @override
  State<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState
    extends State<ProductsPage> {

  List products = [];

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    fetchProducts();
  }

  Future<void> fetchProducts() async {

    try {

      final response = await http.get(

        Uri.parse(

          "${AppConfig.apiUrl}/restaurants/"
              "${widget.restaurant["id"]}"
              "/products",
        ),
      );

      products =
      jsonDecode(response.body);

      setState(() {

        isLoading = false;
      });
    }

    catch (e) {

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(

          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(

        title: Text(
          widget.restaurant["name"],
        ),
      ),

      body: ListView.builder(

        itemCount: products.length,

        itemBuilder: (context, index) {

          final product =
          products[index];

          return Card(

            margin:
            const EdgeInsets.all(15),

            child: ListTile(

              leading: const Icon(
                Icons.fastfood,
              ),

              title: Text(
                product["name"],
              ),

              subtitle: Text(
                "${product["price"]} MRU",
              ),

              trailing: ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.orange,
                ),

                onPressed: () {

                  final restaurantId = widget.restaurant["id"];

                  // One order = one restaurant (the backend checks this)
                  if (cart.isNotEmpty &&
                      cart.first["restaurant_id"] != restaurantId) {

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "Your cart has products from another restaurant. "
                          "Checkout or clear the cart first.",
                        ),
                      ),
                    );
                    return;
                  }

                  // Same product already in the cart -> quantity + 1
                  final index = cart.indexWhere(
                    (item) => item["product_id"] == product["id"],
                  );

                  if (index >= 0) {
                    cart[index]["quantity"] += 1;
                  } else {
                    cart.add({
                      "product_id": product["id"],
                      "restaurant_id": restaurantId,
                      "name": product["name"],
                      "price": product["price"],
                      "quantity": 1,
                    });
                  }

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    SnackBar(

                      content: Text(
                        "${product["name"]} added",
                      ),
                    ),
                  );
                },

                child:
                const Text("Add"),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// CART PAGE
// =====================================================

class CartPage extends StatefulWidget {

  const CartPage({super.key});

  @override
  State<CartPage> createState() =>
      _CartPageState();
}

class _CartPageState
    extends State<CartPage> {

  double getTotal() {

    double total = 0;

    for (var item in cart) {

      total += item["price"] * item["quantity"];
    }

    return total;
  }

  Future<void> createOrder() async {

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    try {

      // The token saved at login tells the server who the customer is
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      // Send the products, the server computes the total price
      final response = await http.post(
        Uri.parse("${AppConfig.apiUrl}/orders"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "restaurant_id": cart.first["restaurant_id"],
          "items": cart
              .map((item) => {
                    "product_id": item["product_id"],
                    "quantity": item["quantity"],
                  })
              .toList(),
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 401) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Session expired. Please log out and log in again."),
          ),
        );
        return;
      }

      if (response.statusCode == 200) {

        cart.clear();

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Order #${data["order_id"]} created - "
              "${data["total_price"]} MRU 🚀",
            ),
          ),
        );
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              data["detail"]?.toString() ?? "Order failed",
            ),
          ),
        );
      }
    }

    catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Cart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear cart",
            onPressed: () {
              setState(() {
                cart.clear();
              });
            },
          ),
        ],
      ),

      body: Column(

        children: [

          Expanded(

            child: ListView.builder(

              itemCount: cart.length,

              itemBuilder:
                  (context, index) {

                final item = cart[index];

                return ListTile(

                  title:
                  Text(item["name"]),

                  subtitle: Text(
                    "${item["quantity"]} x ${item["price"]} MRU",
                  ),

                  trailing: Text(
                    "${item["price"] * item["quantity"]} MRU",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(

            padding:
            const EdgeInsets.all(20),

            child: SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.orange,
                ),

                onPressed: createOrder,

                child: Text(

                  "Checkout ${getTotal()} MRU",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ORDERS PAGE
// =====================================================

class OrdersPage
    extends StatefulWidget {

  @override
  State<OrdersPage> createState() =>
      _OrdersPageState();
}

class _OrdersPageState
    extends State<OrdersPage> {

  List orders = [];

  bool isLoading = true;

  @override
  void initState() {

    super.initState();

    fetchOrders();
  }

  Future<void> fetchOrders() async {

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      // Only the orders of the logged-in customer
      final response = await http.get(
        Uri.parse("${AppConfig.apiUrl}/me/orders"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        orders = jsonDecode(response.body);
      } else {
        orders = [];
      }

      if (!mounted) return;

      setState(() {

        isLoading = false;
      });
    }

    catch (e) {

      setState(() {

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(

          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Orders"),
      ),

      body: ListView.builder(

        itemCount: orders.length,

        itemBuilder: (context, index) {

          final order =
          orders[index];

          return Card(

            margin:
            const EdgeInsets.all(15),

            child: ListTile(

              leading:
              const Icon(Icons.shopping_bag),

              title: Text(
                "Order #${order["id"]}",
              ),

              subtitle: Text(
                order["status"],
              ),

              trailing: Text(
                "${order["total_price"]} MRU",
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (context) =>
                        TrackingPage(
                          order: order,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// TRACKING PAGE
// =====================================================

class TrackingPage
    extends StatefulWidget {

  final dynamic order;

  const TrackingPage({
    super.key,
    required this.order,
  });

  @override
  State<TrackingPage> createState() =>
      _TrackingPageState();
}

class _TrackingPageState
    extends State<TrackingPage> {

  final WebSocketChannel channel =

  WebSocketChannel.connect(

    Uri.parse(
      '${AppConfig.wsUrl}/ws/driver-location',
    ),
  );

  double latitude = 18.0735;
  double longitude = -15.9582;

  @override
  void initState() {

    super.initState();

    listenToDriver();
  }

  void listenToDriver() {

    channel.stream.listen((message) {

      final data =
      jsonDecode(message);

      setState(() {

        latitude =
        data["latitude"];

        longitude =
        data["longitude"];
      });
    });
  }

  @override
  void dispose() {

    channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text("Live Tracking"),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.delivery_dining,

              size: 120,

              color: Colors.orange,
            ),

            const SizedBox(height: 30),

            const Text(

              "Driver is moving 🚀",

              style: TextStyle(

                fontSize: 30,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Text(

              "Latitude: $latitude",

              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 10),

            Text(

              "Longitude: $longitude",

              style: const TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// PROFILE PAGE
// =====================================================

class ProfilePage extends StatelessWidget {

  const ProfilePage({super.key});

  Future<void> logout(
      BuildContext context) async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove("token");

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (context) =>
        const LoginPage(),
      ),

          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const CircleAvatar(

              radius: 55,

              backgroundColor:
              Colors.orange,

              child: Icon(

                Icons.person,

                size: 55,

                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const Text(

              "Abderrahmane",

              style: TextStyle(

                fontSize: 30,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              "Premium Livraison User",

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(

              width: 220,
              height: 55,

              child:
              ElevatedButton.icon(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.red,
                ),

                onPressed: () {
                  logout(context);
                },

                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),

                label: const Text(

                  "Logout",

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}