import 'package:get/get.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_api_service.dart';
import '../../../utils/extension.dart';
import '../../../utils/shared_pref.dart';

class NotificationController extends GetxController {
  final NotificationApiService _notificationApiService = NotificationApiService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasError = false;
  String? _errorMessage;
  int _unreadCount = 0;
  int _currentPage = 1;
  bool _hasNextPage = false;
  String? _selectedFilter; // 'all', 'unread', or notification type
  bool _hasInitialLoad = false;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  bool get hasNextPage => _hasNextPage;
  String? get selectedFilter => _selectedFilter;

  @override
  void onInit() {
    super.onInit();
    _selectedFilter = 'all';
    // Load unread count if user is logged in
    _loadUnreadCount();
  }

  @override
  void onReady() {
    super.onReady();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      await loadNotifications();
    }
  }

  // Call this when screen becomes visible
  void onScreenVisible() {
    // Load data if not already loaded or if list is empty and not currently loading
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      loadNotifications();
    } else if (_notifications.isEmpty && !_isLoading && !_hasError) {
      // Reload if list is empty and not loading
      loadNotifications();
    }
    // Refresh unread count when screen becomes visible
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        _unreadCount = 0;
        update();
        return;
      }

      final response = await _notificationApiService.getUnreadCount(
        jwtToken: jwtToken,
      );

      if (response.success) {
        _unreadCount = response.unreadCount;
        update();
      }
    } catch (e) {
      print('NotificationController: Error loading unread count: $e');
      // Don't update UI on error - keep existing count
    }
  }

  // Public method to refresh unread count (can be called from anywhere)
  Future<void> refreshUnreadCount() async {
    await _loadUnreadCount();
  }

  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
      _currentPage = 1;
    } else if (_currentPage == 1) {
      _isLoading = true;
    }
    _hasError = false;
    _errorMessage = null;
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        _hasError = true;
        _errorMessage = 'Please login to view notifications';
        _notifications = [];
        _unreadCount = 0;
        _hasNextPage = false;
        _isLoading = false;
        _isRefreshing = false;
        update();
        return;
      }

      final notifications = await _notificationApiService.getAllNotifications(
        jwtToken: jwtToken,
      );

      if (isRefresh || _currentPage == 1) {
        _notifications = notifications;
      } else {
        _notifications.addAll(notifications);
      }

      // Update unread count
      _unreadCount = notifications.where((n) => !n.isRead).length;
      
      // Since API returns all notifications, we don't have pagination info
      // Set hasNextPage to false
      _hasNextPage = false;

      _hasError = false;
      _errorMessage = null;
    } catch (e) {
      print('NotificationController: Error loading notifications: $e');
      _hasError = true;
      _errorMessage = 'Failed to load notifications. Please try again.';
      if (isRefresh || _currentPage == 1) {
        _notifications = [];
      }
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      update();
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(isRefresh: true);
  }

  Future<void> loadMoreNotifications() async {
    if (_hasNextPage && !_isLoading) {
      _currentPage++;
      await loadNotifications();
    }
  }

  void setFilter(String? filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      _currentPage = 1;
      _notifications = [];
      loadNotifications();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // API not available yet
    final context = Get.context;
    if (context != null) {
      context.showErrorToast(
        message: 'Notification API is not available yet',
      );
    }
  }

  Future<void> markAllAsRead() async {
    // API not available yet
    final context = Get.context;
    if (context != null) {
      context.showErrorToast(
        message: 'Notification API is not available yet',
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    // API not available yet
    final context = Get.context;
    if (context != null) {
      context.showErrorToast(
        message: 'Notification API is not available yet',
      );
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    // According to requirements: "When tapping on any notification item, no navigation to another screen should happen."
    // So we just mark as read if not already read, but don't navigate
    if (!notification.isRead) {
      markAsRead(notification.id);
    }
  }
}

