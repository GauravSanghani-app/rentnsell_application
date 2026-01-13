import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../../utils/theme_manager.dart';

class CustomCurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomCurvedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,

      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Curved Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CurvedNavigationBar(
              index: currentIndex,
              height: 70,
              backgroundColor: Colors.transparent,
              color: colorMainTheme,
              buttonBackgroundColor: colorMainTheme,
              animationCurve: Curves.easeInOutCubic,
              animationDuration: const Duration(milliseconds: 500),
              onTap: onTap,
              items: [
                _buildIcon(Icons.home_rounded, 0, 28),
                _buildIcon(Icons.category_rounded, 1, 28),
                _buildIcon(Icons.add_circle_rounded, 2, 36),
                _buildIcon(Icons.favorite_rounded, 3, 28),
                _buildIcon(Icons.person_rounded, 4, 28),
              ],
            ),
          ),
          // Labels positioned above the curved bar
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLabel('Home', 0),
                _buildLabel('Category', 1),
                _buildLabel('Add', 2),
                _buildLabel('Wishlist', 3),
                _buildLabel('Profile', 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index, double size) {
    return Icon(icon, size: size, color: Colors.white);
  }

  Widget _buildLabel(String label, int index) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isSelected ? 1.0 : 0.7,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()..translate(0.0, isSelected ? 0.0 : 3.0),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: colorWhite,
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
