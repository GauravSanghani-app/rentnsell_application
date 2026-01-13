import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/route_manager.dart';
import '../../../utils/theme_manager.dart';
import '../../../utils/profile_completion_helper.dart';

class OfferingPopupMenu extends StatelessWidget {
  final GlobalKey buttonKey;

  const OfferingPopupMenu({super.key, required this.buttonKey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Stack(
          children: [
            // Position the popup above the center button
            Positioned(
              bottom: 90, // Position above the bottom nav bar
              left: 0,
              right: 0,
              child: Center(child: _buildPopupMenu(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Popup content
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  context: context,
                  icon: Icons.sell_rounded,
                  label: 'Sell',
                  onTap: () async {
                    Navigator.pop(context);
                    final canProceed = await ProfileCompletionHelper.requireLoginAndProfile(
                      actionName: 'add a product for sale',
                      incompleteMessage: 'Please complete your profile to add products for sale. This helps us provide a better experience for all users.',
                    );
                    if (canProceed) {
                      Get.toNamed(
                        AppRoutes.addProduct,
                        arguments: {'productType': 'sell'},
                      );
                    }
                  },
                ),
                const SizedBox(width: 20),
                _buildOption(
                  context: context,
                  icon: Icons.shopping_cart_rounded,
                  label: 'Rent',
                  onTap: () async {
                    Navigator.pop(context);
                    final canProceed = await ProfileCompletionHelper.requireLoginAndProfile(
                      actionName: 'add a product for rent',
                      incompleteMessage: 'Please complete your profile to add products for rent. This helps us provide a better experience for all users.',
                    );
                    if (canProceed) {
                      Get.toNamed(
                        AppRoutes.addProduct,
                        arguments: {'productType': 'rent'},
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Triangle pointer
          CustomPaint(size: const Size(24, 12), painter: TrianglePainter()),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorMainTheme.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorMainTheme,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorMainTheme.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: colorWhite, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: textStyleSubHeading.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorMainTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for triangle pointer
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
