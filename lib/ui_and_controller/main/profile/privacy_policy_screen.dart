import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Privacy Policy',
          style: textStyleSubHeading.copyWith(
            color: colorWhite,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Privacy Matters',
                style: textStyleSubHeading.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We respect your privacy and are committed to protecting your information.',
                style: textStyleBody.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Information We Collect',
                style: textStyleSubHeading.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'When you use this app, we may collect basic details such as your name, '
                'phone number, email, and the product information you upload '
                '(such as clothing or vehicles for sale or rent).',
                style: textStyleBody.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How We Use Your Information',
                style: textStyleSubHeading.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletItem(
                    'Allow you to list products for rent or sale',
                  ),
                  _buildBulletItem(
                    'Allow others to rent or buy products',
                  ),
                  _buildBulletItem(
                    'Improve app functionality and provide customer support',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Sharing & Security',
                style: textStyleSubHeading.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We do not sell or share your personal information with third parties, '
                'except when required by law or to complete a transaction.\n\n'
                'We take reasonable steps to keep your data secure.',
                style: textStyleBody.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Consent',
                style: textStyleSubHeading.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'By using this app, you agree to this Privacy Policy.',
                style: textStyleBody.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Last updated: ${DateTime.now().year}',
                  style: textStyleCaption.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colorMainTheme,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textStyleBody.copyWith(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

