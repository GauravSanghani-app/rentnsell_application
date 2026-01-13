import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/theme_manager.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

class ExitConfirmationBottomSheet extends StatelessWidget {
  const ExitConfirmationBottomSheet({super.key});

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
            'Exit App?',
            style: textStyleHeading.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            'Are you sure you want to exit the app?',
            style: textStyleBody.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Back',
                  onPressed: () {
                    Get.back(); // Close bottom sheet
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Exit',
                  onPressed: () {
                    Get.back(); // Close bottom sheet
                    // Exit the app
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

