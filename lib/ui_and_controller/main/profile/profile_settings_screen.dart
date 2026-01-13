import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../main/widgets/form_text_field.dart';
import '../../main/widgets/primary_button.dart';
import 'profile_settings_controller.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // Use Get.find() to reuse existing controller or create if not exists
    // Check if controller already exists to prevent recreation
    ProfileSettingsController controller;
    if (Get.isRegistered<ProfileSettingsController>()) {
      controller = Get.find<ProfileSettingsController>();
    } else {
      controller = Get.put(ProfileSettingsController(), permanent: false);
    }

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
          'Edit Profile',
          style: textStyleSubHeading.copyWith(color: colorWhite, fontSize: 20),
        ),
      ),
      body: GetBuilder<ProfileSettingsController>(
        id: 'profile_settings', // Use specific ID to control rebuilds
        builder: (ProfileSettingsController controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: colorMainTheme),
            );
          }

          if (controller.profileData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: colorGrey),
                  const SizedBox(height: 20),
                  Text('Failed to load profile', style: textStyleSubHeading),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: controller.loadProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorMainTheme,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Profile Image Section
                _buildProfileImageSection(controller, context),
                const SizedBox(height: 24),
                // Personal Information Section
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 12),
                _buildPersonalInfoCard(controller, context),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: textStyleSubHeading.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(
    ProfileSettingsController controller,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImagePickerBottomSheet(controller, context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorMainTheme, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(child: _buildProfileImage(controller)),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorMainTheme,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorWhite, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: colorWhite,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change profile photo',
            style: textStyleCaption.copyWith(color: colorGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(
    ProfileSettingsController controller,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            FormTextField(
              label: 'Name',
              hint: 'Enter your name',
              controller: controller.nameController,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Email Field
            FormTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Phone Field (Read-only display)
            FormTextField(
              label: 'Phone Number',
              hint: 'Phone number',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            // Gender Field
            _buildGenderField(controller),
            const SizedBox(height: 16),
            // Address Field
            FormTextField(
              label: 'Address',
              hint: 'Enter your address',
              controller: controller.addressController,
              keyboardType: TextInputType.streetAddress,
              textCapitalization: TextCapitalization.words,
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Age Field
            FormTextField(
              label: 'Age',
              hint: 'Enter your age',
              controller: controller.ageController,
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 20),
            // Save Button
            PrimaryButton(
              text: 'Save Changes',
              isLoading: controller.isUpdating,
              onPressed: () async {
                if (controller.formKey.currentState?.validate() ?? false) {
                  await controller.updateProfile();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderField(ProfileSettingsController controller) {
    return Column(
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
      ],
    );
  }

  Widget _buildGenderOption({
    required ProfileSettingsController controller,
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

  Widget _buildProfileImage(ProfileSettingsController controller) {
    if (controller.selectedImagePath != null &&
        controller.selectedImagePath!.isNotEmpty) {
      try {
        return Image.file(
          File(controller.selectedImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } catch (e) {
        return _buildDefaultAvatar();
      }
    } else if (controller.serverImageUrl != null &&
        controller.serverImageUrl!.isNotEmpty) {
      return Image.network(
        controller.serverImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: colorMainTheme,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else if (controller.profileData?.photoUrl != null &&
        controller.profileData!.photoUrl!.isNotEmpty) {
      return Image.network(
        controller.profileData!.photoUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: colorMainTheme,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: colorMainTheme.withOpacity(0.1),
      child: Icon(Icons.person, size: 60, color: colorMainTheme),
    );
  }

  void _showImagePickerBottomSheet(
    ProfileSettingsController controller,
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
                  // Image will be saved when user taps Save button
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
                  // Image will be saved when user taps Save button
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
