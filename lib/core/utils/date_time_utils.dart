
class DateTimeUtils {
  DateTimeUtils._();

  static const List<String> _months = [
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

  static String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return '${_months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  static String formatTime(DateTime? time) {
    if (time == null) {
      return 'Select time';
    }

    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
