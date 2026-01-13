import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../main/widgets/primary_button.dart';
import '../../main/widgets/form_text_field.dart';
import 'signup_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(SignupController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Create Account',
          style: textStyleSubHeading.copyWith(color: colorWhite),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<SignupController>(
          builder: (SignupController controller) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            _showImagePickerBottomSheet(controller, context),
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(
                                  color: colorMainTheme,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: controller.selectedImage != null
                                  ? ClipOval(
                                      child: Image.file(
                                        controller.selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_add_rounded,
                                      size: 50,
                                      color: colorMainTheme,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorMainTheme,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorWhite,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profile Photo (Optional)',
                      style: textStyleCaption.copyWith(
                        color: colorGrey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Name Input
                    FormTextField(
                      label: 'Name',
                      hint: 'Enter your full name',
                      controller: controller.nameController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Mobile Number Input
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
                    const SizedBox(height: 16),
                    // Email Input
                    FormTextField(
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Gender Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender',
                          style: textStyleBody.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildGenderOption(
                                controller: controller,
                                value: 'male',
                                label: 'Male',
                                icon: Icons.male_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGenderOption(
                                controller: controller,
                                value: 'female',
                                label: 'Female',
                                icon: Icons.female_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildGenderOption(
                                controller: controller,
                                value: 'other',
                                label: 'Other',
                                icon: Icons.person_rounded,
                              ),
                            ),
                          ],
                        ),
                        if (controller.selectedGender == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 12),
                            child: Text(
                              'Please select your gender',
                              style: textStyleCaption.copyWith(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Address Input
                    FormTextField(
                      label: 'Address',
                      hint: 'Enter your address',
                      controller: controller.addressController,
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        if (value.length < 5) {
                          return 'Address must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Age Input
                    FormTextField(
                      label: 'Age',
                      hint: 'Enter your age',
                      controller: controller.ageController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 1 || age > 120) {
                          return 'Please enter a valid age (1-120)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Signup Button
                    PrimaryButton(
                      text: 'Signup',
                      isLoading: controller.isLoading,
                      onPressed: controller.signup,
                    ),
                    const SizedBox(height: 16),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: textStyleBody.copyWith(color: colorGrey),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Login',
                            style: textStyleBody.copyWith(
                              color: colorMainTheme,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Info text
                    Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy',
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

  Widget _buildGenderOption({
    required SignupController controller,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = controller.selectedGender == value;

    return GestureDetector(
      onTap: () => controller.setGender(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorMainTheme.withOpacity(0.15)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorMainTheme : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorMainTheme : colorGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textStyleBody.copyWith(
                color: isSelected ? colorMainTheme : colorGrey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet(
    SignupController controller,
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorMainTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: colorMainTheme,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: textStyleSubHeading.copyWith(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.pickImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorMainTheme.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: colorMainTheme),
                ),
                title: Text(
                  'Take Photo',
                  style: textStyleSubHeading.copyWith(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await controller.pickImage(source: ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
