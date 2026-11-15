import 'package:dio/dio.dart';

import '../config.dart';

class ApiService {

  final Dio dio = Dio(

    BaseOptions(
      baseUrl: AppConfig.apiUrl,
    ),
  );

  // =======================================================
  // DASHBOARD
  // =======================================================

  Future<Map<String, dynamic>> getDashboardStats() async {

    final response = await dio.get(
      "/dashboard/stats",
    );

    return response.data;
  }

  // =======================================================
  // RESTAURANTS
  // =======================================================

  Future<List<dynamic>> getRestaurants() async {

    final response = await dio.get(
      "/restaurants",
    );

    return response.data;
  }

  Future<void> createRestaurant({

    required String name,
    required String category,
    required double latitude,
    required double longitude,
    required String image,

  }) async {

    await dio.post(

      "/restaurants",

      queryParameters: {

        "name": name,
        "category": category,
        "latitude": latitude,
        "longitude": longitude,
        "image": image,
      },
    );
  }

  Future<void> deleteRestaurant(
    int id,
  ) async {

    await dio.delete(
      "/restaurants/$id",
    );
  }

  // =======================================================
  // PRODUCTS
  // =======================================================

  Future<List<dynamic>> getProducts(
    int restaurantId,
  ) async {

    final response = await dio.get(
      "/restaurants/$restaurantId/products",
    );

    return response.data;
  }

  Future<void> createProduct({

    required String name,
    required double price,
    required String image,
    required int restaurantId,

  }) async {

    await dio.post(

      "/products",

      queryParameters: {

        "name": name,
        "price": price,
        "image": image,
        "restaurant_id": restaurantId,
      },
    );
  }

  Future<void> deleteProduct(
    int id,
  ) async {

    await dio.delete(
      "/products/$id",
    );
  }

  // =======================================================
  // ORDERS
  // =======================================================

  Future<List<dynamic>> getOrders() async {

    final response = await dio.get(
      "/orders",
    );

    return response.data;
  }

  Future<void> acceptOrder(
    int orderId,
  ) async {

    await dio.put(
      "/orders/$orderId/accept",
    );
  }

  Future<void> deliverOrder(
    int orderId,
  ) async {

    await dio.put(
      "/orders/$orderId/deliver",
    );
  }

  Future<void> assignDriver({

    required int orderId,
    required int driverId,

  }) async {

    await dio.put(

      "/orders/$orderId/assign-driver",

      queryParameters: {

        "driver_id": driverId,
      },
    );
  }

  // =======================================================
  // DRIVERS
  // =======================================================

  Future<List<dynamic>> getDrivers() async {

    final response = await dio.get(
      "/drivers",
    );

    return response.data;
  }
}