abstract final class InvitationTimeSlotUtils {
  InvitationTimeSlotUtils._();

  static const Map<String, String> _labels = {
    'morning_1': 'Morning (7 AM – 10 AM)',
    'morning_2': 'Late morning (10 AM – 1 PM)',
    'afternoon_1': 'Afternoon (1 PM – 4 PM)',
    'afternoon_2': 'Evening (4 PM – 7 PM)',
  };

  static List<String> labels(List<String> slotIds) {
    return slotIds.map((id) => _labels[id] ?? id).toList(growable: false);
  }

  static String formatTime(String value) {
    if (value.trim().isEmpty) return '';

    final parts = value.split(':');
    if (parts.length < 2) return value;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return value;

    final date = DateTime(2020, 1, 1, hour, minute);
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final suffix = date.hour >= 12 ? 'PM' : 'AM';

    return '$h:${minute.toString().padLeft(2, '0')} $suffix';
  }
}