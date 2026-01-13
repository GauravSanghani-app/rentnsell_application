import '../utils/shared_pref.dart';

class ApiUrl {
  static String baseUrl = "https://api-oms.softclues.in/api/";
  static String getLeaveRequestBaseUrl =
      "https://digiischool.guildarts.online/leave_requests/status/student/";
  static String receiveImagesBaseUrl =
      "https://digiischool.com/recieve_images.php";
  static String documentBaseUrl = "https://digiischool.com";
}

class MethodNames {
  /// server endpoint
  static const String login = "auth/login";
  static const String signup = "auth/signup";
  static const String category = "admin/category";
  static const String subcategory = "admin/subcategory";
  static const String attributeTemplate = "admin/attribute-template";
  static const String productsList = "products/list";
  static const String productCreate = "products/create";
  static const String productUpdate = "products";
  static const String productImageDelete = "upload/delete-image";
  static const String locations = "locations";
  static const String applyLeaveType = "leave_types";
  static const String submitStudentLeaveRequest = "leave_requests";
  static const String leaveHistory = "/history";
  static const String studentMonthAttendanceView = "attendances/user";
  static const String contactDetailsTeacher =
      "auth/classes/class_teacher/profile";
  static const String contactDetailsStudent = "auth/schools/contact_us/details";
  static const String userProfile = "user/profile";
  static const String siblingProfiles = "students/siblings";
  static const String studentYearAttendance = "digiischool/mock_response";
  static const String getLeaveRequestPending = "pending";
  static const String getLeaveRequestApproved = "approved";
  static const String getLeaveRequestRejected = "rejected";
  static const String getAttendanceStudentList = "attendances/by_date";
  static const String getLeaveStudentDetailsById = "leave_requests";
  static const String studentAttendanceClass = "attendances/mark_class";
  static const String studentLeaveRequestStatus = "leave_requests/mark";
  static const String teacherStudentLeaveHistory = "/user_history";
  static const String refreshToken = "token/refresh";
  static const String logOut = "users/logout";
  static const String about = "digiischool/about_us";
  static const String helpAndSupportContact = "digiischool/contact_details";
  static const String sendOtp = "auth/users/send_otp";
  static const String updatePassword = "auth/users/update_password";
  static const String saveFcmToken = "user/save-fcm-token";
  static const String removeFcmToken = "user/remove-fcm-token";
  static const String unreadNotificationCount = "notifications/unread-count";
  static const String allNotifications = "notifications/all-notification";
}

class RequestHeaderKey {
  static const String contentType = "Content-Type";
  static const String refreshToken = "refresh_token";
  static const String cookie = "Cookie";
  static const String authorization = "Authorization";
}

class RequestParam {
  static const String service = "Service";
  static const String showError = "show_error";
}

const String showError = "false";

Map<String, String> requestHeaders({
  required bool passAuthToken,
  bool passRefreshToken = false,
}) {
  String refreshToken =
      preferences.getString(SharedPreference.refreshToken) ?? '';
  if (refreshToken.isNotEmpty) {
    refreshToken = "refresh_token=$refreshToken";
  }

  String? authToken = preferences.getString(SharedPreference.jwtToken);
  if (authToken == null || authToken.isEmpty) {
    authToken = preferences.getString(SharedPreference.userToken);
  }

  return {
    RequestHeaderKey.contentType: "application/json",
    if (passRefreshToken) RequestHeaderKey.cookie: refreshToken,
    if (passAuthToken)
      RequestHeaderKey.authorization: 'Bearer ${authToken ?? ''}',
  };
}
