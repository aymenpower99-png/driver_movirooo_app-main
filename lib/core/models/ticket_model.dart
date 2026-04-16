import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Ticket statuses from the backend.
enum TicketStatus {
  open,
  inProgress,
  waitingForUser,
  resolved;

  static TicketStatus fromString(String s) {
    switch (s) {
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'waiting_for_user':
        return TicketStatus.waitingForUser;
      case 'resolved':
        return TicketStatus.resolved;
      default:
        return TicketStatus.open;
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.waitingForUser:
        return 'Waiting';
      case TicketStatus.resolved:
        return 'Resolved';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.waitingForUser:
        return Colors.amber;
      case TicketStatus.resolved:
        return AppColors.gray7B;
    }
  }
}

/// Backend ticket categories.
enum TicketCategory {
  account,
  payment,
  ride,
  technical,
  other;

  static TicketCategory fromString(String s) {
    switch (s) {
      case 'payment':
        return TicketCategory.payment;
      case 'ride':
        return TicketCategory.ride;
      case 'technical':
        return TicketCategory.technical;
      case 'other':
        return TicketCategory.other;
      default:
        return TicketCategory.account;
    }
  }

  String get apiValue => name;
}

/// Maps the 6 Flutter localized-category indices to backend enum values.
/// Order: account, payment, trip→ride, bug→technical, safety→other, other
const List<TicketCategory> kCategoryMapping = [
  TicketCategory.account,
  TicketCategory.payment,
  TicketCategory.ride,
  TicketCategory.technical,
  TicketCategory.other,
  TicketCategory.other,
];

// ─── Models ──────────────────────────────────────────────────────────────────

class TicketMessageModel {
  final String id;
  final String body;
  final String senderId;
  final String? senderName;
  final DateTime createdAt;

  const TicketMessageModel({
    required this.id,
    required this.body,
    required this.senderId,
    this.senderName,
    required this.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> j) {
    final sender = j['sender'] as Map<String, dynamic>?;
    String? name;
    if (sender != null) {
      final first = sender['firstName'] as String? ?? '';
      final last  = sender['lastName']  as String? ?? '';
      name = '$first $last'.trim();
    }
    return TicketMessageModel(
      id:         j['id'] as String,
      body:       j['body'] as String? ?? '',
      senderId:   j['senderId'] as String? ?? sender?['id'] as String? ?? '',
      senderName: name,
      createdAt:  DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class TicketModel {
  final String id;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TicketMessageModel> messages;

  const TicketModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  /// Preview of the last message (or description if no messages).
  String get lastMessagePreview {
    if (messages.isNotEmpty) return messages.last.body;
    return description;
  }

  factory TicketModel.fromJson(Map<String, dynamic> j) {
    final msgs = (j['messages'] as List<dynamic>?)
            ?.map((m) => TicketMessageModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];
    return TicketModel(
      id:          j['id'] as String,
      subject:     j['subject'] as String? ?? '',
      description: j['description'] as String? ?? '',
      status:      TicketStatus.fromString(j['status'] as String? ?? 'open'),
      category:    TicketCategory.fromString(j['category'] as String? ?? 'other'),
      createdAt:   DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:   DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
      messages:    msgs,
    );
  }
}
