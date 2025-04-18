// lib/Presentation/order/presentation/Page/utils/date_utils.dart

import 'package:hanouty/Presentation/order/domain/entities/order.dart';

class OrderDateUtils {
  // Helper function to safely get DateTime from order
  static DateTime getOrderDate(Order order) {
    try {
      if (order.dateOrder is DateTime) {
        return order.dateOrder as DateTime;
      } else if (order.dateOrder is String) {
        return DateTime.parse(order.dateOrder as String);
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now(); // Fallback
  }

  // Helper method to check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}