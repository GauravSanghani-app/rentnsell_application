import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ui_and_controller/auth/login/mobile_login_screen.dart';
import '../../ui_and_controller/auth/signup/signup_screen.dart';
import '../../ui_and_controller/auth/profile_manage/profile_manage_screen.dart';
import '../../ui_and_controller/main/master/master_screen.dart';
import '../../ui_and_controller/main/add_product/add_product_screen.dart';
import '../../ui_and_controller/main/product_detail/product_detail_screen.dart';
import '../../models/product_model.dart';
import '../../ui_and_controller/main/notification/notification_screen.dart';
import '../../ui_and_controller/main/profile/profile_settings_screen.dart';
import '../../ui_and_controller/main/profile/my_products_screen.dart';
import '../../ui_and_controller/main/edit_product/edit_product_screen.dart';
import '../../ui_and_controller/startup/onboarding_screen/onboarding_screen.dart';
import '../../ui_and_controller/startup/splash_screen/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = "/splash";
  static const String onboarding = "/onboarding";
  static const String master = "/master";
  static const String mobileLogin = "/mobile-login";
  static const String signup = "/signup";
  static const String profileManage = "/profile-manage";
  static const String addProduct = "/add-product";
  static const String productDetail = "/product-detail";
  static const String notification = "/notification";
  static const String profileSettings = "/profile-settings";
  static const String myProducts = "/my-products";
  static const String editProduct = "/edit-product";

  static List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: master, page: () => const MasterScreen()),
    GetPage(name: mobileLogin, page: () => const MobileLoginScreen()),
    GetPage(name: signup, page: () => const SignupScreen()),
    GetPage(name: profileManage, page: () => const ProfileManageScreen()),
    GetPage(
      name: addProduct,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return AddProductScreen(productType: args?['productType'] ?? 'rent');
      },
    ),
    GetPage(
      name: productDetail,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        ProductModel? productData;
        if (args?['productData'] != null) {
          productData = ProductModel.fromJson(
            args!['productData'] as Map<String, dynamic>,
          );
        }
        return ProductDetailScreen(
          productId: args?['productId'] ?? '',
          productData: productData,
        );
      },
    ),
    GetPage(name: notification, page: () => const NotificationScreen()),
    GetPage(name: profileSettings, page: () => const ProfileSettingsScreen()),
    GetPage(name: myProducts, page: () => const MyProductsScreen()),
    GetPage(
      name: editProduct,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        if (args?['product'] != null) {
          return EditProductScreen(
            product: ProductModel.fromJson(
              args!['product'] as Map<String, dynamic>,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    ),
  ];
}
