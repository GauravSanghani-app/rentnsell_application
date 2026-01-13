import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/route_manager.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../main/widgets/primary_button.dart';
import '../../main/widgets/form_text_field.dart';
import 'mobile_login_controller.dart';

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(MobileLoginController());

    return Scaffold(
      body: SafeArea(
        child: GetBuilder<MobileLoginController>(
          builder: (MobileLoginController controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: height * 0.1),
                    Icon(
                      Icons.phone_android_rounded,
                      size: 100,
                      color: colorMainTheme,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to Rent N Sell',
                      style: textStyleHeading,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your mobile number to continue',
                      style: textStyleBody,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    FormTextField(
                      label: 'Mobile Number',
                      hint: 'Enter your 10-digit mobile number',
                      controller: controller.mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (value.length != 10) {
                          return 'Please enter a valid 10-digit mobile number';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Mobile number should contain only digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: 'Login',
                      isLoading: controller.isLoading,
                      onPressed: controller.login,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.signup);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Don\'t have an account? Signup',
                        style: textStyleBody.copyWith(
                          color: colorMainTheme,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'By logging in, you agree to our Terms of Service and Privacy Policy',
                      style: textStyleCaption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
