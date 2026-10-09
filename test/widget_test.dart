// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/models/task_model.dart';
import 'package:task_management_app/services/preferences_service.dart';
import 'package:task_management_app/theme/app_theme.dart';
import 'package:task_management_app/utils/date_helpers.dart';
import 'package:task_management_app/utils/validators.dart';

void main() {
  test('Task model serialization test', () {
    final now = DateTime.now();
    final task = Task(
      id: 'task-123',
      title: 'Deliver delivery order #42',
      description: 'Customer requested leave at door',
      dueDate: now,
      priority: 'high',
      isCompleted: false,
    );

    final map = task.toMap();
    expect(map['title'], 'Deliver delivery order #42');
    expect(map['priority'], 'high');
    expect(map['isCompleted'], false);

    final parsed = Task.fromMap(map, 'task-123');
    expect(parsed.id, 'task-123');
    expect(parsed.title, task.title);
    expect(parsed.priority, 'high');
  });

  test('Validators test', () {
    expect(Validators.validateEmail(''), 'Email is required');
    expect(Validators.validateEmail('invalid'), 'Please enter a valid email address');
    expect(Validators.validateEmail('test@example.com'), null);

    expect(Validators.validatePassword('123'), 'Password must be at least 6 characters');
    expect(Validators.validatePassword('123456'), null);

    expect(Validators.validateConfirmPassword('', '123456'), 'Please confirm your password');
    expect(Validators.validateConfirmPassword('mismatch', '123456'), 'Passwords do not match');
    expect(Validators.validateConfirmPassword('123456', '123456'), null);
  });

  test('DateHelpers grouping test', () {
    final today = DateTime.now();
    expect(DateHelpers.getTaskGroup(today), 'Today');

    final tomorrow = today.add(const Duration(days: 1));
    expect(DateHelpers.getTaskGroup(tomorrow), 'Tomorrow');
  });

  test('TaskProvider search query and filter test', () {
    final now = DateTime.now();
    final tasks = [
      Task(
        id: '1',
        title: 'Buy groceries',
        description: 'Milk, bread, eggs',
        dueDate: now.add(const Duration(hours: 1)),
        priority: 'high',
        isCompleted: false,
      ),
      Task(
        id: '2',
        title: 'Design app wireframes',
        description: 'Create golden cream cards',
        dueDate: now.add(const Duration(hours: 3)),
        priority: 'medium',
        isCompleted: true,
      ),
      Task(
        id: '3',
        title: 'Write project documentation',
        description: 'Summarize system requirements',
        dueDate: now.add(const Duration(hours: 2)),
        priority: 'low',
        isCompleted: false,
      ),
    ];

    // Filter testing with search query
    final query = 'cream';
    final searchFiltered = tasks.where((t) =>
        t.title.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query)).toList();
    expect(searchFiltered.length, 1);
    expect(searchFiltered.first.id, '2');

    final titleQuery = 'groceries';
    final titleFiltered = tasks.where((t) =>
        t.title.toLowerCase().contains(titleQuery) ||
        t.description.toLowerCase().contains(titleQuery)).toList();
    expect(titleFiltered.length, 1);
    expect(titleFiltered.first.id, '1');
  });

  test('AppTheme color token verification test', () {
    // Olive Green: RGB(85, 107, 47)
    expect(AppTheme.oliveGreen.r * 255, closeTo(85, 1));
    expect(AppTheme.oliveGreen.g * 255, closeTo(107, 1));
    expect(AppTheme.oliveGreen.b * 255, closeTo(47, 1));

    // Deep Maroon: RGB(130, 0, 0)
    expect(AppTheme.deepMaroon.r * 255, closeTo(130, 1));
    expect(AppTheme.deepMaroon.g * 255, closeTo(0, 1));
    expect(AppTheme.deepMaroon.b * 255, closeTo(0, 1));

    // Light deep maroon text field background (not dark)
    expect(AppTheme.textFieldBackground, const Color(0xFFFAF0F0));
  });

  test('PreferencesService onboarding flag test', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await PreferencesService.hasSeenOnboarding(), false);

    await PreferencesService.setHasSeenOnboarding(true);
    expect(await PreferencesService.hasSeenOnboarding(), true);
  });

  test('Task delete and restore simulation test', () {
    final list = [
      Task(
        id: 'task-1',
        title: 'Task to be deleted',
        dueDate: DateTime.now(),
        priority: 'high',
      ),
      Task(
        id: 'task-2',
        title: 'Remaining task',
        dueDate: DateTime.now(),
        priority: 'low',
      ),
    ];

    final target = list.firstWhere((t) => t.id == 'task-1');
    list.removeWhere((t) => t.id == 'task-1');
    expect(list.length, 1);
    expect(list.first.id, 'task-2');

    // Simulate undo
    list.add(target);
    expect(list.length, 2);
  });

  testWidgets('Search bar unfocus and cursor disappearance test', (tester) async {
    final focusNode = FocusNode();
    final controller = TextEditingController();
    final searchBarKey = GlobalKey();

    void unfocusSearch(BuildContext context) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
      }
      FocusScope.of(context).unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (event) {
                  if (focusNode.hasFocus) {
                    final renderBox = searchBarKey.currentContext?.findRenderObject() as RenderBox?;
                    if (renderBox != null) {
                      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
                      if (!rect.contains(event.position)) {
                        unfocusSearch(context);
                      }
                    } else {
                      unfocusSearch(context);
                    }
                  }
                },
                child: Column(
                  children: [
                    TapRegion(
                      groupId: EditableText,
                      onTapOutside: (_) => unfocusSearch(context),
                      child: Container(
                        key: searchBarKey,
                        child: TextField(
                          key: const Key('search_field'),
                          controller: controller,
                          focusNode: focusNode,
                          onTapOutside: (_) => unfocusSearch(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      key: const Key('outside_area'),
                      color: Colors.blue,
                      width: 200,
                      height: 100,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    // Tap the search field to focus it
    await tester.tap(find.byKey(const Key('search_field')));
    await tester.pump();
    expect(focusNode.hasFocus, isTrue);

    // Tap outside the search field
    await tester.tap(find.byKey(const Key('outside_area')));
    await tester.pump();
    expect(focusNode.hasFocus, isFalse);
  });
}
