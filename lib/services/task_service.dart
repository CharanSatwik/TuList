// File: lib/services/task_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  String _localKey(String uid) => 'cached_tasks_$uid';

  /// Generates a unique task ID client-side
  String newTaskId(String uid) {
    return _userTasksRef(uid).doc().id;
  }

  /// Loads tasks from local persistent storage (fast, offline-first)
  Future<List<Task>> loadLocalTasks(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localKey(uid));
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded
            .map((item) => Task.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading local tasks: $e');
    }
    return [];
  }

  /// Saves all tasks to local persistent storage
  Future<void> saveLocalTasks(String uid, List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await prefs.setString(_localKey(uid), encoded);
    } catch (e) {
      debugPrint('Error saving local tasks: $e');
    }
  }

  /// Real-time stream from Firestore with graceful error fallback
  Stream<List<Task>> getTasksStream(String uid) {
    return _userTasksRef(uid)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      debugPrint(
        'Firestore stream notice (enable Cloud Firestore in Firebase Console): $error',
      );
      return <Task>[];
    });
  }

  /// Background cloud sync for adding/updating a task
  Future<void> syncTaskToCloud(String uid, Task task) async {
    try {
      await _userTasksRef(uid)
          .doc(task.id)
          .set(task.toMap())
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint(
        'Cloud sync notice (enable Cloud Firestore in Firebase Console): $e',
      );
    }
  }

  /// Background cloud sync for deleting a task
  Future<void> deleteTaskFromCloud(String uid, String taskId) async {
    try {
      await _userTasksRef(uid)
          .doc(taskId)
          .delete()
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Cloud delete notice: $e');
    }
  }

  /// Background cloud sync for toggling task completion
  Future<void> toggleCompleteInCloud(String uid, Task task) async {
    try {
      await _userTasksRef(uid)
          .doc(task.id)
          .update({'isCompleted': task.isCompleted})
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Cloud toggle notice: $e');
    }
  }
}
