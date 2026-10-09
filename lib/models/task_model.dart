// File: lib/models/task_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'low', 'medium', 'high'
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = 'medium',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.toLowerCase(),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toLowerCase(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task.fromMap(json, json['id'] as String? ?? '');
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Task(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: parseTimestamp(map['dueDate']),
      priority: (map['priority'] as String? ?? 'medium').toLowerCase(),
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
}
