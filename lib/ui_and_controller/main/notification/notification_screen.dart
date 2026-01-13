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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: colorMainTheme,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: textStyleSubHeading.copyWith(color: colorWhite),
        ),
      ),
      body: GetBuilder<NotificationController>(
        builder: (NotificationController controller) {
          return RefreshIndicator(
            onRefresh: controller.refreshNotifications,
            color: colorMainTheme,
            child: CustomScrollView(
              slivers: [
                // Notifications List
                if (controller.isLoading && controller.notifications.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: colorMainTheme),
                    ),
                  )
                else if (controller.hasError && controller.notifications.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                size: 80, color: colorGrey),
                            const SizedBox(height: 20),
                            Text(
                              'Connection Error',
                              style: textStyleSubHeading.copyWith(
                                color: colorGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage ??
                                  'Failed to load notifications',
                              style: textStyleBody.copyWith(color: colorGrey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: controller.refreshNotifications,
                              style: primaryButtonStyle,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (controller.notifications.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded,
                              size: 80, color: colorGrey),
                          const SizedBox(height: 20),
                          Text(
                            'No notifications',
                            style: textStyleSubHeading.copyWith(
                              color: colorGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You\'re all caught up!',
                            style: textStyleBody.copyWith(color: colorGrey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == controller.notifications.length) {
                          // Load more indicator
                          if (controller.hasNextPage) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.loadMoreNotifications();
                            });
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: colorMainTheme,
                                ),
                              ),
                            );
                          }
                          return const SizedBox(height: 20);
                        }
                        final notification = controller.notifications[index];
                        return _buildNotificationCard(notification, controller);
                      },
                      childCount: controller.notifications.length + 1,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    NotificationController controller,
  ) {
    return InkWell(
      onTap: () => controller.handleNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : colorMainTheme.withOpacity(0.3),
            width: notification.isRead ? 0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon/Image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: notification.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        notification.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getNotificationIcon(notification.type),
                            color: _getNotificationColor(notification.type),
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: textStyleSubHeading.copyWith(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorMainTheme,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: textStyleBody.copyWith(
                      fontSize: 13,
                      color: colorGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: colorGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(notification.createdAt),
                        style: textStyleCaption.copyWith(fontSize: 11),
                      ),
                      const Spacer(),
                      // Delete button
                      GestureDetector(
                        onTap: () => controller.deleteNotification(notification.id),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: colorGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'app_update':
        return Colors.green;
      case 'category_added':
        return Colors.orange;
      case 'product_added':
        return Colors.pink;
      case 'offer':
        return Colors.purple;
      case 'order':
        return Colors.blue;
      default:
        return colorMainTheme;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'app_update':
        return Icons.system_update_rounded;
      case 'category_added':
        return Icons.category_rounded;
      case 'product_added':
        return Icons.shopping_bag_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      case 'order':
        return Icons.receipt_long_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

