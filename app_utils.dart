import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
  
  static String formatDateTimeShort(DateTime dateTime) {
    return DateFormat('dd/MM HH:mm').format(dateTime);
  }
  
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE', 'it_IT').format(date);
  }
  
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'it_IT').format(date);
  }
  
  // Time calculations
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  static String getTimeUntilEvent(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now);
    
    if (difference.isNegative) {
      return 'Passato';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays} giorni';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ore';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuti';
    } else {
      return 'Ora';
    }
  }
  
  // String utilities
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }
  
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }
  
  // Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPhone(String phone) {
    return RegExp(r'^[\+]?[0-9]{10,13}$').hasMatch(phone.replaceAll(' ', ''));
  }
  
  static bool isValidPlayerNumber(String number) {
    final num = int.tryParse(number);
    return num != null && num >= 1 && num <= 99;
  }
  
  // Color utilities
  static Color getPositionColor(String position) {
    switch (position.toLowerCase()) {
      case 'portiere':
        return Colors.orange;
      case 'difensore centrale':
      case 'terzino destro':
      case 'terzino sinistro':
        return Colors.blue;
      case 'mediano':
      case 'centrocampista':
      case 'trequartista':
        return Colors.green;
      case 'ala destra':
      case 'ala sinistra':
      case 'seconda punta':
      case 'centravanti':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  static Color getAttendanceColor(String status) {
    switch (status.toLowerCase()) {
      case 'presente':
        return Colors.green;
      case 'assente':
        return Colors.red;
      case 'giustificato':
        return Colors.orange;
      case 'infortunato':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  static Color getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'vittoria':
        return Colors.green;
      case 'pareggio':
        return Colors.orange;
      case 'sconfitta':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Statistics calculations
  static double calculateAttendancePercentage(int present, int total) {
    if (total == 0) return 0.0;
    return (present / total) * 100;
  }
  
  static Map<String, int> calculateMatchStats(List<Map<String, dynamic>> matches) {
    int wins = 0;
    int draws = 0;
    int losses = 0;
    
    for (final match in matches) {
      final result = match['result']?.toString().toLowerCase() ?? '';
      switch (result) {
        case 'vittoria':
          wins++;
          break;
        case 'pareggio':
          draws++;
          break;
        case 'sconfitta':
          losses++;
          break;
      }
    }
    
    return {
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'total': wins + draws + losses,
    };
  }
  
  // UI Helpers
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.green);
  }
  
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: Colors.red);
  }
  
  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }
  
  static void showLoadingDialog(BuildContext context, {String message = 'Caricamento...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
  
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Performance optimizations
  static Widget buildOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
  }) {
    return ListView.builder(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 200,
    );
  }
  
  // File and data utilities
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // Animation helpers
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }
  
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }
}

// Extension methods
extension StringExtensions on String {
  String get capitalized => AppUtils.capitalize(this);
  String get capitalizedWords => AppUtils.capitalizeWords(this);
  String get initials => AppUtils.getInitials(this);
  bool get isValidEmail => AppUtils.isValidEmail(this);
  bool get isValidPhone => AppUtils.isValidPhone(this);
}

extension DateTimeExtensions on DateTime {
  String get formatted => AppUtils.formatDate(this);
  String get formattedDateTime => AppUtils.formatDateTime(this);
  String get dayOfWeek => AppUtils.formatDayOfWeek(this);
  String get monthYear => AppUtils.formatMonthYear(this);
  String get timeUntil => AppUtils.getTimeUntilEvent(this);
  
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
}

extension TimeOfDayExtensions on TimeOfDay {
  String get formatted => AppUtils.formatTime(this);
}
