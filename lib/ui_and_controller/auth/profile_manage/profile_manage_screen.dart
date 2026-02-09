// import 'dart:io';
// import 'package:country_code_picker/country_code_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../utils/app_const.dart';
// import '../../../utils/theme_manager.dart';
// import '../profile_controller.dart';
// import '../../main/widgets/form_text_field.dart';
// import '../../main/widgets/multi_select_chips.dart';
// import '../../main/widgets/primary_button.dart';
// import 'profile_manage_controller.dart';
//
// class ProfileManageScreen extends StatelessWidget {
//   const ProfileManageScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     width = MediaQuery.of(context).size.width;
//     height = MediaQuery.of(context).size.height;
//
//     Get.put(ProfileManageController());
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Complete Your Profile'),
//         backgroundColor: colorMainTheme,
//         foregroundColor: colorWhite,
//         elevation: 0,
//       ),
//       body: GetBuilder<ProfileManageController>(
//         builder: (ProfileManageController controller) {
//           return GetBuilder<ProfileController>(
//             builder: (ProfileController profileController) {
//               return Form(
//                 key: controller.formKey,
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Center(
//                         child: Stack(
//                           children: [
//                             Container(
//                               width: 120,
//                               height: 120,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: colorMainTheme,
//                                   width: 3,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: ClipOval(
//                                 child: _buildProfileImage(profileController),
//                               ),
//                             ),
//                             if (profileController.profileImagePath != null ||
//                                 profileController.photoUrl == null ||
//                                 profileController.photoUrl!.isEmpty)
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: controller.pickProfileImage,
//                                   child: Container(
//                                     width: 40,
//                                     height: 40,
//                                     decoration: BoxDecoration(
//                                       color: colorMainTheme,
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                         color: colorWhite,
//                                         width: 3,
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.2),
//                                           blurRadius: 5,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: const Icon(
//                                       Icons.camera_alt,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       FormTextField(
//                         label: 'Email',
//                         controller: controller.emailController,
//                         readOnly: true,
//                         keyboardType: TextInputType.emailAddress,
//                       ),
//                       const SizedBox(height: 20),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Mobile Number',
//                             style: textStyleSubHeading.copyWith(fontSize: 14),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               CountryCodePicker(
//                                 onChanged: (code) {
//                                   profileController.setCountryCode(
//                                     code.dialCode ?? '+1',
//                                   );
//                                 },
//                                 initialSelection: 'US',
//                                 favorite: const ['+1', 'US'],
//                                 showCountryOnly: false,
//                                 showOnlyCountryWhenClosed: false,
//                                 alignLeft: false,
//                               ),
//                               Expanded(
//                                 child: TextFormField(
//                                   controller: controller.phoneController,
//                                   keyboardType: TextInputType.phone,
//                                   onChanged: (value) {
//                                     controller.onPhoneChanged(value);
//                                     profileController.phone = value;
//                                     profileController.update();
//                                   },
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Phone number is required';
//                                     }
//                                     if (value.length < 10) {
//                                       return 'Invalid phone number';
//                                     }
//                                     return null;
//                                   },
//                                   decoration: inputDecoration.copyWith(
//                                     hintText: 'Enter phone number',
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       FormTextField(
//                         label: 'Age',
//                         controller: controller.ageController,
//                         keyboardType: TextInputType.number,
//                         hint: 'Enter your age',
//                         onChanged: controller.onAgeChanged,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Age is required';
//                           }
//                           final age = int.tryParse(value);
//                           if (age == null || age < 13 || age > 120) {
//                             return 'Age must be between 13 and 120';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Gender',
//                             style: textStyleSubHeading.copyWith(fontSize: 14),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: profileController.genderOptions.map((
//                               gender,
//                             ) {
//                               final isSelected =
//                                   profileController.gender == gender;
//                               return Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 4,
//                                   ),
//                                   child: ChoiceChip(
//                                     label: Text(gender),
//                                     selected: isSelected,
//                                     onSelected: (_) =>
//                                         controller.onGenderSelected(gender),
//                                     selectedColor: colorMainTheme.withOpacity(
//                                       0.2,
//                                     ),
//                                     labelStyle: TextStyle(
//                                       color: isSelected
//                                           ? colorMainTheme
//                                           : Colors.grey.shade700,
//                                       fontWeight: isSelected
//                                           ? FontWeight.w600
//                                           : FontWeight.normal,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       FormTextField(
//                         label: 'Address',
//                         controller: controller.addressController,
//                         maxLines: 3,
//                         hint: 'Enter your address',
//                         onChanged: controller.onAddressChanged,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Address is required';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       if (profileController.isLoading)
//                         const Center(child: CircularProgressIndicator())
//                       else
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Interested Categories',
//                               style: textStyleSubHeading.copyWith(fontSize: 14),
//                             ),
//                             const SizedBox(height: 12),
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: profileController.categories.map((
//                                 category,
//                               ) {
//                                 final isSelected = profileController
//                                     .selectedCategoryIds
//                                     .contains(category.id);
//                                 return FilterChip(
//                                   label: Text(category.name),
//                                   selected: isSelected,
//                                   onSelected: (_) =>
//                                       controller.onCategoryToggled(category.id),
//                                   selectedColor: colorMainTheme.withOpacity(
//                                     0.2,
//                                   ),
//                                   checkmarkColor: colorMainTheme,
//                                   labelStyle: TextStyle(
//                                     color: isSelected
//                                         ? colorMainTheme
//                                         : Colors.grey.shade700,
//                                     fontWeight: isSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.normal,
//                                   ),
//                                   side: BorderSide(
//                                     color: isSelected
//                                         ? colorMainTheme
//                                         : Colors.grey.shade300,
//                                     width: isSelected ? 2 : 1,
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       const SizedBox(height: 20),
//                       // Actions
//                       MultiSelectChips(
//                         label: 'What are you interested in',
//                         options: profileController.actionOptions,
//                         selectedItems: profileController.selectedActions,
//                         onToggle: controller.onActionToggled,
//                       ),
//                       const SizedBox(height: 32),
//                       // Save Button
//                       PrimaryButton(
//                         text: 'Save Profile',
//                         isLoading: profileController.isSaving,
//                         onPressed: profileController.isFormValid
//                             ? () => controller.saveProfile()
//                             : null,
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildProfileImage(ProfileController profileController) {
//     if (profileController.profileImagePath != null &&
//         profileController.profileImagePath!.isNotEmpty) {
//       try {
//         return Image.file(
//           File(profileController.profileImagePath!),
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return _buildDefaultAvatar();
//           },
//         );
//       } catch (e) {
//         return _buildDefaultAvatar();
//       }
//     } else if (profileController.photoUrl != null &&
//         profileController.photoUrl!.isNotEmpty) {
//       return Image.network(
//         profileController.photoUrl!,
//         fit: BoxFit.cover,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Center(
//             child: CircularProgressIndicator(
//               value: loadingProgress.expectedTotalBytes != null
//                   ? loadingProgress.cumulativeBytesLoaded /
//                         loadingProgress.expectedTotalBytes!
//                   : null,
//               color: colorMainTheme,
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return _buildDefaultAvatar();
//         },
//       );
//     } else {
//       return _buildDefaultAvatar();
//     }
//   }
//
//   Widget _buildDefaultAvatar() {
//     return Image.asset(
//       'assets/images/avatar.png',
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: colorMainTheme.withOpacity(0.1),
//           child: Icon(Icons.person, size: 60, color: colorMainTheme),
//         );
//       },
//     );
//   }
// }
