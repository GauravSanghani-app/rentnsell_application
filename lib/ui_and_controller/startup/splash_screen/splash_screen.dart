import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rent_n_sell/utils/app_const.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(SplashController());
    return Scaffold(
      body: GetBuilder<SplashController>(
        builder: (SplashController splashController) {
          return Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width * 0.5,
                    child: Image.asset(
                      "assets/images/rentnsell_icon.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: width * 0.5,
                    child: Image.asset(
                      "assets/images/rentnsell_text_final.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
