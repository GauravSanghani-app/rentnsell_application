import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../utils/app_const.dart';
import '../../auth/auth_controller.dart';
import '../category/category_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../widgets/custom_curved_nav_bar.dart';
import '../widgets/exit_confirmation_bottom_sheet.dart';
import 'master_controller.dart';

class MasterScreen extends StatelessWidget {
  const MasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // Initialize AuthController and refresh auth status
    final authController = Get.put(AuthController());
    authController.checkAuthStatus();
    
    Get.put(MasterController());

    // Check location permission on app start
    _checkLocationPermission(context);

    final List<Widget> pages = [
      const HomeScreen(),
      const CategoryScreen(),
      // Add button opens dialog, so no screen needed here
      const SizedBox.shrink(),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Check if we can pop any routes using GetX context
          final navigatorContext = Get.context;
          if (navigatorContext != null &&
              Navigator.of(navigatorContext).canPop()) {
            // There are routes in the stack, pop normally
            Get.back();
          } else {
            // We're at root, show exit confirmation
            Get.bottomSheet(
              const ExitConfirmationBottomSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              isDismissible: true,
              enableDrag: true,
            );
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        body: GetBuilder<MasterController>(
          builder: (MasterController controller) {
            return IndexedStack(
              index: controller.currentIndex,
              children: pages,
            );
          },
        ),
        bottomNavigationBar: GetBuilder<MasterController>(
          builder: (MasterController controller) {
            return CustomCurvedNavBar(
              currentIndex: controller.currentIndex,
              onTap: controller.changeTab,
            );
          },
        ),
      ),
    );
  }

  Future<void> _checkLocationPermission(BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('MasterScreen: Location service is disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('MasterScreen: Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('MasterScreen: Location permission permanently denied');
        return;
      }

      print('MasterScreen: Location permission granted');
    } catch (e) {
      print('MasterScreen: Error checking location permission: $e');
    }
  }
}
