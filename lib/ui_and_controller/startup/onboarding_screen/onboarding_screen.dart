import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_n_sell/utils/app_const.dart';
import 'package:rent_n_sell/utils/theme_manager.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(OnboardingController());
    return Scaffold(
      body: GetBuilder<OnboardingController>(
        builder: (OnboardingController controller) {
          return SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: controller.onSkip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: colorMainTheme,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    onPageChanged: controller.onPageChanged,
                    controller: controller.pageController,
                    children: [
                      _buildOnboardingPage(
                        image: "assets/images/rentnsell_icon.png",
                        title: "Welcome to Rent N Sell",
                        description:
                            "Your one-stop solution for renting and selling items. Discover amazing deals and connect with buyers and sellers.",
                      ),
                      _buildOnboardingPage(
                        image: "assets/images/rentnsell_icon.png",
                        title: "Easy to Use",
                        description:
                            "Browse through thousands of listings, filter by category, and find exactly what you're looking for in seconds.",
                      ),
                      _buildOnboardingPage(
                        image: "assets/images/rentnsell_icon.png",
                        title: "Get Started",
                        description:
                            "Join our community today and start renting or selling your items. It's quick, easy, and secure.",
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: controller.currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: controller.currentPage == index
                            ? colorMainTheme
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorMainTheme,
                        foregroundColor: colorWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        controller.currentPage == 2 ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.6,
            height: width * 0.6,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorMainTheme,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
