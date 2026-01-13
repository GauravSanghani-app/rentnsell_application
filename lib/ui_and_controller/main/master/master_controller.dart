import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/auth_controller.dart';
import '../widgets/login_bottom_sheet.dart';
import '../widgets/offering_popup_menu.dart';
import '../home/home_controller.dart';
import '../wishlist/wishlist_controller.dart';

class MasterController extends GetxController {
  int currentIndex = 0;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    // AuthController is initialized in master_screen
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void changeTab(int index) {
    // Refresh auth status before checking (in case it was updated)
    _authController.checkAuthStatus();
    
    // Handle center button (index 2) - show offering popup if logged in
    if (index == 2) {
      if (!_authController.isLoggedIn) {
        _showLoginBottomSheet();
        return;
      }
      // Show offering popup menu
      _showOfferingPopup();
      return; // Don't change tab
    }

    // Check if trying to access Wishlist (index 3) or Profile (index 4)
    if (index == 3 || index == 4) {
      if (!_authController.isLoggedIn) {
        // Show login bottom sheet and prevent tab change
        _showLoginBottomSheet();
        return; // Don't change tab
      }

      // Profile completion check removed - allow access to Wishlist and Profile tabs
      // ProfileManageScreen navigation has been disabled
    }

    // Only change tab if index is different
    if (currentIndex != index) {
      currentIndex = index;
      update();
      
      // Trigger data load for visible tab
      _triggerTabDataLoad(index);
    }
  }

  void _triggerTabDataLoad(int index) {
    // Small delay to ensure widget is built and controller is registered
    Future.delayed(const Duration(milliseconds: 200), () {
      try {
        switch (index) {
          case 0: // Home
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().onTabVisible();
            }
            break;
          case 3: // Wishlist
            if (Get.isRegistered<WishlistController>()) {
              Get.find<WishlistController>().onTabVisible();
            }
            break;
        }
      } catch (e) {
        print('MasterController: Error triggering tab data load: $e');
      }
    });
  }

  void _showOfferingPopup() {
    Get.dialog(
      OfferingPopupMenu(buttonKey: GlobalKey()),
      barrierColor: Colors.transparent,
    );
  }

  void _showLoginBottomSheet() {
    Get.bottomSheet(
      const LoginBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
