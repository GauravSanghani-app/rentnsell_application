import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/route_manager.dart';
import '../../../utils/theme_manager.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Please log in',
            style: textStyleHeading.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            'Login to access Wishlist and Profile',
            style: textStyleBody.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 24),
          // Primary CTA
          PrimaryButton(
            text: 'Login',
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.mobileLogin);
            },
          ),
          const SizedBox(height: 12),
          // Secondary CTA
          SecondaryButton(
            text: 'Continue as Guest',
            onPressed: () {
              Get.back();
            },
          ),
          const SizedBox(height: 16),
          // Why login note
          Center(
            child: Text(
              'Why login?',
              style: textStyleCaption.copyWith(
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Login saves your profile and personalizes your experience',
              textAlign: TextAlign.center,
              style: textStyleCaption.copyWith(fontSize: 11),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

