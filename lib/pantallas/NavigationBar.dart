import 'package:flutter/material.dart';
import 'package:zymbiot/pantallas/Library.dart';
import 'package:zymbiot/pantallas/Profile.dart';
import 'package:zymbiot/pantallas/Principal.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 1;

  final List<Widget> _screens = const [
    ProfileScreen(),
    PrincipalScreen(),
    LibraryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavIcon(Icons.person_outline, 0),
            _buildNavIcon(Icons.home, 1),
            _buildNavIcon(Icons.image_outlined, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF33133B) : Colors.white,
        size: 28,
      ),
    );
  }
}
