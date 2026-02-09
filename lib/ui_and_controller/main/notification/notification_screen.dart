import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_const.dart';
import '../../../utils/theme_manager.dart';
import '../../../models/notification_model.dart';
import 'notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    final controller = Get.put(NotificationController());

    // Trigger load when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onScreenVisible();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: textStyleSubHeading.copyWith(
            color: colorWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<NotificationController>(
        builder: (NotificationController controller) {
          return RefreshIndicator(
            onRefresh: controller.refreshNotifications,
            color: colorMainTheme,
            backgroundColor: colorWhite,
            child: _buildBody(controller),
          );
        },
      ),
    );
  }

  Widget _buildBody(NotificationController controller) {
    // Loading state
    if (controller.isLoading && controller.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorMainTheme.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: colorMainTheme,
                  strokeWidth: 3.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading notifications...',
              style: textStyleBody.copyWith(
                color: colorMainTheme,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (controller.hasError && controller.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colorRedCalendar.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorRedCalendar.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: colorRedCalendar,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Connection Error',
                style: textStyleSubHeading.copyWith(
                  color: colorMainTheme,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                controller.errorMessage ?? 'Failed to load notifications',
                style: textStyleBody.copyWith(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: controller.refreshNotifications,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: primaryButtonStyle,
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (controller.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: colorMainTheme.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorMainTheme.withOpacity(0.25),
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  Icons.notifications_off_rounded,
                  size: 52,
                  color: colorMainTheme,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'No Notifications Yet',
                style: textStyleSubHeading.copyWith(
                  color: colorMainTheme,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You\'re all caught up!\nWe\'ll notify you when something new arrives.',
                style: textStyleBody.copyWith(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Notifications list
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: controller.notifications.length,
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];
        final isFirst = index == 0;
        final isLast = index == controller.notifications.length - 1;

        return _buildNotificationCard(
          notification,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final notificationColor = _getNotificationColor(notification.type);

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isFirst ? 4 : 6,
        bottom: isLast ? 16 : 6,
      ),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade300
              : notificationColor.withOpacity(0.5),
          width: notification.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: notification.isRead
                ? Colors.black.withOpacity(0.06)
                : notificationColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: notification.isRead
                    ? Colors.grey.shade400
                    : notificationColor,
                width: 5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              _buildNotificationIcon(notification),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with unread indicator
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: textStyleSubHeading.copyWith(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: notification.isRead
                                  ? Colors.grey.shade700
                                  : colorMainTheme,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: notificationColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Body / Message
                    Text(
                      notification.message,
                      style: textStyleBody.copyWith(
                        fontSize: 13.5,
                        color: notification.isRead
                            ? Colors.grey.shade600
                            : Colors.grey.shade800,
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Date & Time
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? Colors.grey.shade200
                            : notificationColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 14,
                            color: notification.isRead
                                ? Colors.grey.shade600
                                : notificationColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateTime(notification.createdAt),
                            style: textStyleCaption.copyWith(
                              fontSize: 12,
                              color: notification.isRead
                                  ? Colors.grey.shade700
                                  : notificationColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.grey.shade200
            : color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade300
              : color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: notification.imageUrl != null && notification.imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                notification.imageUrl!,
                fit: BoxFit.cover,
                width: 52,
                height: 52,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    icon,
                    color: notification.isRead ? Colors.grey.shade500 : color,
                    size: 26,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
            )
          : Icon(
              icon,
              color: notification.isRead ? Colors.grey.shade500 : color,
              size: 26,
            ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'app_update':
      case 'update':
        return const Color(0xFF059669); // Darker green
      case 'category_added':
      case 'category':
        return const Color(0xFFD97706); // Darker orange/amber
      case 'product_added':
      case 'product':
        return const Color(0xFFDB2777); // Darker pink
      case 'offer':
      case 'promotion':
        return const Color(0xFF7C3AED); // Darker purple
      case 'order':
        return const Color(0xFF2563EB); // Darker blue
      case 'message':
      case 'chat':
        return const Color(0xFF0891B2); // Darker cyan
      case 'alert':
      case 'warning':
        return colorRedCalendar; // App's red color
      default:
        return colorMainTheme; // App's main theme color
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'app_update':
      case 'update':
        return Icons.system_update_rounded;
      case 'category_added':
      case 'category':
        return Icons.category_rounded;
      case 'product_added':
      case 'product':
        return Icons.shopping_bag_rounded;
      case 'offer':
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'order':
        return Icons.receipt_long_rounded;
      case 'message':
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'alert':
      case 'warning':
        return Icons.warning_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    final timeString = _formatTime(dateTime);

    if (notificationDate == today) {
      final difference = now.difference(dateTime);
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 6) {
        return '${difference.inHours}h ago';
      }
      return 'Today at $timeString';
    } else if (notificationDate == yesterday) {
      return 'Yesterday at $timeString';
    } else if (now.difference(dateTime).inDays < 7) {
      final weekday = _getWeekday(dateTime.weekday);
      return '$weekday at $timeString';
    } else {
      return '${dateTime.day} ${_getMonth(dateTime.month)} ${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
