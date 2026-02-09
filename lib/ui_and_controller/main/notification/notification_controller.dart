import 'package:get/get.dart';
import '../../../models/notification_model.dart';
import '../../../services/notification_api_service.dart';
import '../../../utils/shared_pref.dart';

class NotificationController extends GetxController {
  final NotificationApiService _notificationApiService =
      NotificationApiService();

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
    // This is the ONLY API call that should happen on Home Screen
    _loadUnreadCount();
  }

  @override
  void onReady() {
    super.onReady();
    // DO NOT load notifications here!
    // Notifications should only be loaded when user opens the Notification Screen
    // This prevents the all-notification API from being called on the Home Screen
  }

  // Call this when Notification Screen becomes visible
  // This is the ONLY place where loadNotifications() should be triggered
  void onScreenVisible() {
    // Load notifications when user opens the Notification Screen
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      loadNotifications();
    } else if (_notifications.isEmpty && !_isLoading && !_hasError) {
      // Reload if list is empty and not loading
      loadNotifications();
    }
    // Note: Don't refresh unread count here as loading all notifications
    // will mark them as read on the backend
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

      // Reset unread count to 0 since calling all-notification API
      // marks all notifications as read on the backend
      _unreadCount = 0;

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
}
