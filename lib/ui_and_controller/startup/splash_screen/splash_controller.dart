import 'package:get/get.dart';
import 'package:rent_n_sell/config/routes/route_manager.dart';
import 'package:rent_n_sell/ui_and_controller/auth/auth_controller.dart';
import 'package:rent_n_sell/utils/shared_pref.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Get.put(AuthController());
    Future.delayed(const Duration(seconds: 3), () {
      navigateToNextPage();
    });
  }

  void navigateToNextPage() async {
    await preferences.init();
    bool isOnboardingCompleted = preferences.getBool(
      SharedPreference.isOnboarding,
      defValue: false,
    );
    if (!isOnboardingCompleted) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }
    Get.offAllNamed(AppRoutes.master);
  }
}
