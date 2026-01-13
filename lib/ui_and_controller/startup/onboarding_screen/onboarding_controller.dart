import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/route_manager.dart';
import '../../../utils/shared_pref.dart';

class OnboardingController extends GetxController {
  int currentPage = 0;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage = index;
    update();
  }

  void onNext() {
    if (currentPage < 2) {
      currentPage++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      update();
    } else {
      completeOnboarding();
    }
  }

  void onSkip() {
    completeOnboarding();
  }

  void completeOnboarding() async {
    await preferences.putBool(SharedPreference.isOnboarding, true);
    Get.offAllNamed(AppRoutes.master);
  }
}
