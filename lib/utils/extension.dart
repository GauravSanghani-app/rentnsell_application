import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rent_n_sell/utils/theme_manager.dart';

extension StringExtension on String {
  bool get isEmailValid => RegExp(
    r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(this);

  String format({required String outputFormat, required String inputFormat}) {
    DateTime dateTime = DateTime.now();
    dateTime = DateFormat(inputFormat).parse(this);
    return DateFormat(outputFormat).format(dateTime);
  }
}

extension ContextExtension on BuildContext {
  void hideKeyboard() {
    return FocusScope.of(this).requestFocus(FocusNode());
  }

  void showAppSnackBar({
    required String message,
    Color? backgroundColor,
    Color? textColor,
  }) {
    try {
      _hideCurrentToast();
      final overlay = Overlay.of(this, rootOverlay: true);
      final overlayEntry = OverlayEntry(
        builder: (context) => _CustomToastWidget(
          message: message,
          backgroundColor: backgroundColor ?? colorMainTheme,
          textColor: textColor ?? Colors.white,
          onDismiss: () => _hideCurrentToast(),
        ),
      );

      _currentToastEntry = overlayEntry;
      overlay.insert(overlayEntry);
      Future.delayed(const Duration(seconds: 3), () {
        _hideCurrentToast();
      });
    } catch (e) {
      // If overlay fails, use Fluttertoast as fallback
      try {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: backgroundColor ?? colorMainTheme,
          textColor: textColor ?? Colors.white,
          fontSize: 14.0,
        );
      } catch (toastError) {
        // If Fluttertoast also fails, just log the message
        debugPrint('Toast message (all methods failed): $message');
      }
    }
  }

  static OverlayEntry? _currentToastEntry;

  static void _hideCurrentToast() {
    _currentToastEntry?.remove();
    _currentToastEntry = null;
  }

  void showSuccessToast({required String message, Duration? duration}) {
    showAppSnackBar(
      message: message,
      backgroundColor: colorGreen,
      textColor: colorWhite,
    );
  }

  void showErrorToast({required String message, Duration? duration}) {
    showAppSnackBar(
      message: message,
      backgroundColor: colorRedCalendar,
      textColor: colorWhite,
    );
  }

  void showWarningToast({required String message, Duration? duration}) {
    showAppSnackBar(
      message: message,
      backgroundColor: Colors.orange,
      textColor: colorWhite,
    );
  }

  void showInfoToast({required String message, Duration? duration}) {
    showAppSnackBar(
      message: message,
      backgroundColor: colorCustomButton,
      textColor: colorWhite,
    );
  }

  Future showAppDialog({
    Widget? titleWidget,
    required Widget contentWidget,
    List<Widget>? actionWidget,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: titleWidget ?? Container(),
          content: contentWidget,
          actions: actionWidget ?? [],
        );
      },
    );
  }

  Future showAppBottomSheet({required Widget contentWidget}) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return contentWidget;
      },
    );
  }
}

String formatNotificationDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  final dateWithoutTime = DateTime(date.year, date.month, date.day);

  if (dateWithoutTime == today) {
    return "Today, ${DateFormat('hh:mm a').format(date)}";
  } else if (dateWithoutTime == yesterday) {
    return "Yesterday, ${DateFormat('hh:mm a').format(date)}";
  } else {
    return DateFormat('E, hh:mm a').format(date);
  }
}

String convertToISOWithOffset(String inputDate) {
  DateTime date = DateFormat('dd/MM/yyyy').parse(inputDate);
  date = DateTime(date.year, date.month, date.day, 14, 30);
  final offset = date.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  final offsetStr = '$sign$hours:$minutes';
  final formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(date);
  return '$formattedDate$offsetStr';
}

String formatDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String formatWithFixedOffset(DateTime utcTime, Duration offset) {
  final adjustedTime = utcTime.add(offset);
  final formattedDate = adjustedTime.toIso8601String().split('.').first;
  final sign = offset.isNegative ? '-' : '+';
  final hours = offset.inHours.abs().toString().padLeft(2, '0');
  final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '$formattedDate$sign$hours:$minutes';
}

class _CustomToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onDismiss;

  const _CustomToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.onDismiss,
  });

  @override
  State<_CustomToastWidget> createState() => _CustomToastWidgetState();
}

class _CustomToastWidgetState extends State<_CustomToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Slide up from bottom
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80, // Position at bottom with padding
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(Icons.close, color: widget.textColor, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
