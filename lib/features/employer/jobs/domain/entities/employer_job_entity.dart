import 'package:flutter/foundation.dart';

enum EmployerJobStatus { active, completed, cancelled }

@immutable
class EmployerJobEntity {
  const EmployerJobEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    required this.amount,
    required this.currency,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final EmployerJobStatus status;
  final double amount;
  final String currency;
  final String? imageUrl;

  String get statusLabel {
    switch (status) {
      case EmployerJobStatus.active:
        return 'Active';
      case EmployerJobStatus.completed:
        return 'Completed';
      case EmployerJobStatus.cancelled:
        return 'Cancelled';
    }
  }

  static EmployerJobStatus statusFromBackend(String value) {
    switch (value.trim().toLowerCase()) {
      case 'completed':
        return EmployerJobStatus.completed;
      case 'cancelled':
      case 'canceled':
        return EmployerJobStatus.cancelled;
      case 'pending':
      case 'assigned':
      case 'accepted':
      case 'in_progress':
      case 'in-progress':
        return EmployerJobStatus.active;
      default:
        throw ArgumentError('Unsupported employer job status: $value');
    }
  }
}
