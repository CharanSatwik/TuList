// File: lib/providers/task_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

enum PriorityFilter { all, low, medium, high }
enum StatusFilter { all, incomplete, completed }

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  StreamSubscription<List<Task>>? _tasksSubscription;

  List<Task> _allTasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  PriorityFilter _selectedPriorityFilter = PriorityFilter.all;
  StatusFilter _selectedStatusFilter = StatusFilter.all;
  String _searchQuery = '';

  Task? _lastDeletedTask;
  String? _currentUid;

  TaskProvider({TaskService? taskService})
      : _taskService = taskService ?? TaskService();

  List<Task> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PriorityFilter get priorityFilter => _selectedPriorityFilter;
  StatusFilter get statusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  Task? get lastDeletedTask => _lastDeletedTask;
  String? get currentUid => _currentUid;

  void clear() {
    _currentUid = null;
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _allTasks = [];
    _lastDeletedTask = null;
    _isLoading = false;
    _errorMessage = null;
    _selectedPriorityFilter = PriorityFilter.all;
    _selectedStatusFilter = StatusFilter.all;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> initialize(String? uid) async {
    if (uid == _currentUid && _tasksSubscription != null) return;

    _currentUid = uid;
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _lastDeletedTask = null;
    _allTasks = []; // Completely reset in-memory tasks so no user bleed occurs

    if (uid == null || uid.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. Immediately load locally cached tasks strictly for this user
    final localTasks = await _taskService.loadLocalTasks(uid);
    if (_currentUid == uid) {
      _allTasks = localTasks;
      _sortTasks();
      _isLoading = false;
      notifyListeners();
    }

    // 2. Listen to real-time Cloud Firestore updates strictly for this user
    _tasksSubscription = _taskService.getTasksStream(uid).listen(
      (tasks) {
        if (_currentUid == uid) {
          _allTasks = tasks;
          _sortTasks();
          _taskService.saveLocalTasks(uid, _allTasks);
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
        }
      },
      onError: (error) {
        if (_currentUid == uid) {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  void _sortTasks() {
    _allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void setPriorityFilter(PriorityFilter filter) {
    if (_selectedPriorityFilter != filter) {
      _selectedPriorityFilter = filter;
      notifyListeners();
    }
  }

  void setStatusFilter(StatusFilter filter) {
    if (_selectedStatusFilter != filter) {
      _selectedStatusFilter = filter;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  List<Task> get filteredTasks {
    List<Task> list = List.from(_allTasks);

    // Apply Priority filter
    if (_selectedPriorityFilter != PriorityFilter.all) {
      final target = _selectedPriorityFilter.name.toLowerCase();
      list = list.where((t) => t.priority.toLowerCase() == target).toList();
    }

    // Apply Status filter
    if (_selectedStatusFilter == StatusFilter.incomplete) {
      list = list.where((t) => !t.isCompleted).toList();
    } else if (_selectedStatusFilter == StatusFilter.completed) {
      list = list.where((t) => t.isCompleted).toList();
    }

    // Apply Search Query filter (title or description)
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q);
      }).toList();
    }

    // Ensure sorted by dueDate ascending (earliest to latest)
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  Map<String, List<Task>> get groupedFilteredTasks {
    final Map<String, List<Task>> grouped = {
      'Today': [],
      'Tomorrow': [],
      'This week': [],
      'Later': [],
    };

    final tasks = filteredTasks;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final task in tasks) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      final diff = taskDate.difference(today).inDays;

      if (diff <= 0) {
        grouped['Today']!.add(task);
      } else if (diff == 1) {
        grouped['Tomorrow']!.add(task);
      } else if (diff <= 7) {
        grouped['This week']!.add(task);
      } else {
        grouped['Later']!.add(task);
      }
    }

    return grouped;
  }

  Future<void> addTask(Task task) async {
    if (_currentUid == null) return;
    
    // Assign a unique client ID if not already present
    final taskId = task.id.isNotEmpty
        ? task.id
        : _taskService.newTaskId(_currentUid!);
    final newTask = task.copyWith(id: taskId);

    // 1. Immediately update UI & local storage
    _allTasks.add(newTask);
    _sortTasks();
    await _taskService.saveLocalTasks(_currentUid!, _allTasks);
    notifyListeners();

    // 2. Non-blocking background sync to Cloud Firestore
    _taskService.syncTaskToCloud(_currentUid!, newTask);
  }

  Future<void> updateTask(Task task) async {
    if (_currentUid == null) return;

    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = task;
      _sortTasks();
      await _taskService.saveLocalTasks(_currentUid!, _allTasks);
      notifyListeners();
    }

    // Non-blocking background sync to Cloud Firestore
    _taskService.syncTaskToCloud(_currentUid!, task);
  }

  Future<void> toggleComplete(Task task) async {
    if (_currentUid == null) return;

    final updated = task.copyWith(isCompleted: !task.isCompleted);
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasks[index] = updated;
      await _taskService.saveLocalTasks(_currentUid!, _allTasks);
      notifyListeners();
    }

    // Non-blocking background sync
    _taskService.toggleCompleteInCloud(_currentUid!, updated);
  }

  Future<void> deleteTask(Task task) async {
    if (_currentUid == null) return;
    _lastDeletedTask = task;

    _allTasks.removeWhere((t) => t.id == task.id);
    await _taskService.saveLocalTasks(_currentUid!, _allTasks);
    notifyListeners();

    // Non-blocking background sync
    _taskService.deleteTaskFromCloud(_currentUid!, task.id);
  }

  Future<void> undoDelete() async {
    if (_currentUid == null || _lastDeletedTask == null) return;
    final taskToRestore = _lastDeletedTask!;
    _lastDeletedTask = null;

    _allTasks.add(taskToRestore);
    _sortTasks();
    await _taskService.saveLocalTasks(_currentUid!, _allTasks);
    notifyListeners();

    // Non-blocking background sync
    _taskService.syncTaskToCloud(_currentUid!, taskToRestore);
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
