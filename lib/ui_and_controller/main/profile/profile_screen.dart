import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../config/routes/route_manager.dart';
import '../../../utils/shared_pref.dart';
import '../../../services/fcm_api_service.dart';
import '../../../services/fcm_service.dart';
import '../../auth/auth_controller.dart';
import 'profile_controller.dart';
import 'profile_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    Get.put(ProfileScreenController());

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        title: Text(
          'Profile',
          style: textStyleSubHeading.copyWith(
            color: colorWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<ProfileScreenController>(
        builder: (ProfileScreenController controller) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80, // Extra padding for bottom nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header Section
                _buildProfileHeader(controller),
                const SizedBox(height: 20),
                // Quick Actions Card
                _buildQuickActionsCard(context),
                const SizedBox(height: 12),
                // Profile Information Card
                _buildProfileInfoCard(controller),
                const SizedBox(height: 12),
                // Settings Section
                _buildSettingsSection(context),
                const SizedBox(height: 12),
                // Account Actions
                _buildAccountActionsSection(context),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileScreenController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorMainTheme,
            colorMainTheme.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Image (View Only - No Camera Icon)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorWhite, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildProfileImage(controller),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            controller.profileData?.displayName ?? controller.profileData?.name ?? 'User',
            style: textStyleHeading.copyWith(
              color: colorWhite,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          if (controller.profileData?.email != null && controller.profileData!.email!.isNotEmpty)
            Text(
              controller.profileData!.email!,
              style: textStyleBody.copyWith(
                color: colorWhite.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: textStyleSubHeading.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profile',
                  onTap: () => Get.to(() => const ProfileSettingsScreen()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.inventory_2_rounded,
                  label: 'My Products',
                  onTap: () => Get.toNamed(AppRoutes.myProducts),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colorMainTheme.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorMainTheme.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorMainTheme, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: textStyleBody.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorMainTheme,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(ProfileScreenController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: (controller.profileData?.mobile != null && controller.profileData!.mobile.isNotEmpty)
                ? controller.profileData!.mobile
                : (controller.phone.isNotEmpty ? controller.phone : 'Not set'),
          ),
          Divider(height: 1, color: Colors.grey.shade200, indent: 56),
          _buildInfoTile(
            icon: Icons.location_on_rounded,
            label: 'Address',
            value: (controller.profileData?.address != null && controller.profileData!.address!.isNotEmpty)
                ? controller.profileData!.address!
                : (controller.address.isNotEmpty ? controller.address : 'Not set'),
          ),
          if (controller.profileData?.gender != null && 
              controller.profileData!.gender!.isNotEmpty) ...[
            Divider(height: 1, color: Colors.grey.shade200, indent: 56),
            _buildInfoTile(
              icon: Icons.person_outline_rounded,
              label: 'Gender',
              value: controller.profileData!.gender!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorMainTheme.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colorMainTheme, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textStyleCaption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textStyleBody.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: () => _openPrivacyPolicy(context),
          ),
          Divider(height: 1, color: Colors.grey.shade200, indent: 56),
          _buildSettingsTile(
            icon: Icons.star_rounded,
            title: 'Rate Us',
            onTap: () => _openRateUs(context),
          ),
          Divider(height: 1, color: Colors.grey.shade200, indent: 56),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => _openHelp(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            iconColor: Colors.orange.shade600,
            onTap: () => _showLogoutDialog(context),
          ),
          Divider(height: 1, color: Colors.grey.shade200, indent: 56),
          _buildSettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            iconColor: Colors.red.shade600,
            titleColor: Colors.red.shade600,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? colorMainTheme).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? colorMainTheme, size: 22),
      ),
      title: Text(
        title,
        style: textStyleBody.copyWith(
          color: titleColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: colorGrey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildProfileImage(ProfileScreenController controller) {
    // Priority: Server image > Profile data photo > Default avatar
    if (controller.serverImageUrl != null &&
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
    } else if (controller.profileData?.profileImage != null &&
        controller.profileData!.profileImage!.isNotEmpty) {
      return Image.network(
        controller.profileData!.profileImage!,
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

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip_rounded, color: colorMainTheme, size: 24),
            const SizedBox(width: 12),
            Text('Privacy Policy', style: textStyleSubHeading),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Privacy Policy Content\n\n'
            'This is a placeholder for the privacy policy. In production, '
            'this would contain the full privacy policy text or link to a web page.\n\n'
            'You can replace this with actual privacy policy content or implement '
            'a web view to display the full policy.',
            style: textStyleBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colorMainTheme)),
          ),
        ],
      ),
    );
  }

  Future<void> _openRateUs(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            Text('Rate Us', style: textStyleSubHeading),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enjoying the app? Please rate us!',
              style: textStyleBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(Icons.star_rounded, color: Colors.amber, size: 32);
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'In production, this would open the app store page.',
              style: textStyleCaption.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Maybe Later', style: TextStyle(color: colorGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Thank you for rating!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green.shade700,
                textColor: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorMainTheme,
            ),
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _openHelp(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: colorMainTheme, size: 24),
            const SizedBox(width: 12),
            Text('Help & Support', style: textStyleSubHeading),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:', style: textStyleBody),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.email_rounded,
              label: 'Email',
              value: 'support@rentnsell.com',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.phone_rounded,
              label: 'Phone',
              value: '+1 (555) 123-4567',
            ),
            const SizedBox(height: 12),
            _buildHelpItem(
              icon: Icons.access_time_rounded,
              label: 'Hours',
              value: 'Mon-Fri: 9 AM - 6 PM',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colorMainTheme)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: colorMainTheme, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textStyleCaption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(value, style: textStyleBody.copyWith(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(
    BuildContext context,
  ) {
    bool isLoggingOut = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      decoration: BoxDecoration(
                        color: colorMainTheme,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        textAlign: TextAlign.start,
                        style: textStyleSubHeading.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Content Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    child: Text(
                      'Are you sure you want to logout?',
                      textAlign: TextAlign.center,
                      style: textStyleBody.copyWith(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  // Buttons Section
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade200, width: 1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: textStyleBody.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: colorGrey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Logout Button
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoggingOut
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoggingOut = true;
                                      });
                                      // Close dialog first
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      // Perform logout immediately - navigation will happen in _performLogout
                                      await _performLogout(context);
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: isLoggingOut
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(colorMainTheme),
                                          ),
                                        )
                                      : Text(
                                          'Logout',
                                          style: textStyleBody.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: colorMainTheme,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
  ) {
    bool isDeletingAccount = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
                      decoration: BoxDecoration(
                        color:  colorMainTheme,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Delete Account',
                        textAlign: TextAlign.start,
                        style: textStyleSubHeading.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color:Colors.white,
                        ),
                      ),
                    ),
                    // Content Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Are you sure you want to delete your account?',
                            textAlign: TextAlign.center,
                            style: textStyleBody.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This action cannot be undone. All your data will be permanently deleted.',
                            textAlign: TextAlign.center,
                            style: textStyleCaption.copyWith(
                              fontSize: 13,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Buttons Section
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(color: Colors.grey.shade200, width: 1),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: textStyleBody.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: colorGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Delete Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isDeletingAccount
                                    ? null
                                    : () async {
                                        setState(() {
                                          isDeletingAccount = true;
                                        });
                                        // Close dialog first
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        // Perform delete account immediately - navigation will happen in _performDeleteAccount
                                        await _performDeleteAccount(context);
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: isDeletingAccount
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                            ),
                                          )
                                        : Text(
                                            'Delete',
                                            style: textStyleBody.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red.shade600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _performLogout(
    BuildContext context,
  ) async {
    try {
      // Get JWT token and FCM token BEFORE clearing them
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      
      // Remove FCM token from API BEFORE clearing local storage
      if (jwtToken != null && jwtToken.isNotEmpty) {
        await _removeFcmToken(jwtToken);
      }

      // Clear local storage - use SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPreference.jwtToken);
      await prefs.remove(SharedPreference.refreshToken);
      await prefs.remove(SharedPreference.fcmToken);
      await preferences.putBool(SharedPreference.isLogIn, false);

      // Clear AuthController
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.signOut();
      }

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Logged out successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );
      }

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.mobileLogin);
    } catch (e) {
      print('ProfileScreen: Error logging out: $e');
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to logout: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _removeFcmToken(String jwtToken) async {
    try {
      final fcmApiService = FcmApiService();
      
      // Get FCM token from FCMService or shared preferences
      String? fcmToken;
      if (Get.isRegistered<FCMService>()) {
        final fcmService = Get.find<FCMService>();
        fcmToken = await fcmService.getToken();
      } else {
        // If FCMService is not registered, try to get token from shared preferences
        fcmToken = preferences.getString(SharedPreference.fcmToken);
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        // Remove FCM token from API
        final response = await fcmApiService.removeFcmToken(
          jwtToken: jwtToken,
          token: fcmToken,
        );

        if (response.success) {
          print('ProfileScreen: FCM token removed successfully');
        } else {
          print('ProfileScreen: Failed to remove FCM token: ${response.message}');
        }
      } else {
        print('ProfileScreen: FCM token not available');
      }
    } catch (e) {
      print('ProfileScreen: Error removing FCM token: $e');
      // Don't show error to user - FCM token removal failure shouldn't block logout
    }
  }

  Future<void> _performDeleteAccount(
    BuildContext context,
  ) async {
    try {
      // Clear all local storage
      preferences.clearUserItem();

      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.signOut();
      }

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Account deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );
      }

      // Navigate to home screen after account deletion
      // Navigate immediately after account deletion completes
      Get.offAllNamed(AppRoutes.master);
    } catch (e) {
      print('ProfileScreen: Error deleting account: $e');
      if (context.mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to delete account: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    }
  }
}
