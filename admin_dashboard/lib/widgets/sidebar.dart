import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.black87,

      child: Column(
        children: [

          const SizedBox(height: 40),

          const Text(
            "Livraison",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 50),

          sidebarItem(
            index: 0,
            icon: Icons.dashboard,
            title: "Dashboard",
          ),

          sidebarItem(
            index: 1,
            icon: Icons.restaurant,
            title: "Restaurants",
          ),

          sidebarItem(
            index: 2,
            icon: Icons.fastfood,
            title: "Products",
          ),

          sidebarItem(
            index: 3,
            icon: Icons.shopping_bag,
            title: "Orders",
          ),

          sidebarItem(
            index: 4,
            icon: Icons.delivery_dining,
            title: "Drivers",
          ),
        ],
      ),
    );
  }

  Widget sidebarItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),

      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepOrange
              : Colors.transparent,

          borderRadius: BorderRadius.circular(10),
        ),

        child: Row(
          children: [

            Icon(
              icon,
              color: Colors.white,
            ),

            const SizedBox(width: 15),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}