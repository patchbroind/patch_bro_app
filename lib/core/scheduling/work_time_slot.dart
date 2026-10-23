enum WorkTimeSlot {
  morningOne('morning_1', '8–10 AM', '8:00 AM – 10:00 AM'),
  morningTwo('morning_2', '10 AM–12 PM', '10:00 AM – 12:00 PM'),
  afternoonOne('afternoon_1', '1–3 PM', '1:00 PM – 3:00 PM'),
  afternoonTwo('afternoon_2', '3–5 PM', '3:00 PM – 5:00 PM');

  const WorkTimeSlot(this.id, this.shortLabel, this.label);

  final String id;
  final String shortLabel;
  final String label;

  int get startHour => switch (this) {
    WorkTimeSlot.morningOne => 8,
    WorkTimeSlot.morningTwo => 10,
    WorkTimeSlot.afternoonOne => 13,
    WorkTimeSlot.afternoonTwo => 15,
  };

  static WorkTimeSlot? fromId(String id) {
    for (final slot in values) {
      if (slot.id == id) return slot;
    }
    return null;
  }
}

enum WorkerSlotAvailability { unavailable, available, booked }

String formatScheduleDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
