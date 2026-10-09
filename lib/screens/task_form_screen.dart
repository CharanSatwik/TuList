// File: lib/screens/task_form_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/responsive.dart';
import '../utils/validators.dart';
import '../widgets/app_error_banner.dart';
import '../widgets/delete_task_dialog.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? taskToEdit;

  const TaskFormScreen({
    super.key,
    this.taskToEdit,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDueDate;
  late TimeOfDay _selectedDueTime;
  late String _selectedPriority; // 'low', 'medium', 'high'
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');

    final initialDate =
        task?.dueDate ?? DateTime.now().add(const Duration(hours: 2));
    _selectedDueDate =
        DateTime(initialDate.year, initialDate.month, initialDate.day);
    _selectedDueTime =
        TimeOfDay(hour: initialDate.hour, minute: initialDate.minute);
    _selectedPriority = task?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDueDate.year,
      _selectedDueDate.month,
      _selectedDueDate.day,
      _selectedDueTime.hour,
      _selectedDueTime.minute,
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.oliveGreen,
              onPrimary: AppTheme.pureWhite,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.oliveGreen,
              onPrimary: AppTheme.pureWhite,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDueTime = pickedTime;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (taskProvider.currentUid == null && authProvider.currentUser != null) {
      await taskProvider.initialize(authProvider.currentUser!.uid);
    }

    try {
      if (widget.taskToEdit == null) {
        final newTask = Task(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _combinedDateTime,
          priority: _selectedPriority,
          isCompleted: false,
          createdAt: DateTime.now(),
        );
        await taskProvider.addTask(newTask);
      } else {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _combinedDateTime,
          priority: _selectedPriority,
        );
        await taskProvider.updateTask(updatedTask);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save task: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    final task = widget.taskToEdit;
    if (task == null) return;

    final confirmed = await showDeleteTaskDialog(
      context,
      taskTitle: task.title,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.deleteTask(task);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to delete task: ${e.toString()}';
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isEditing = widget.taskToEdit != null;

    final isWide = Responsive.isTablet(context) || Responsive.isDesktop(context);
    final horizPadding = Responsive.horizontalPadding(context);

    Widget formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              if (_errorMessage != null) ...[
                AppErrorBanner(
                  message: _errorMessage!,
                  onDismiss: () => setState(() => _errorMessage = null),
                ),
                const SizedBox(height: 16),
              ],
              // Title Field
              Text(
                'TASK TITLE *',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (val) =>
                    Validators.validateRequired(val, 'Task title'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Prepare meeting slide deck',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppTheme.textFieldBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.textFieldBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.textFieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppTheme.deepMaroon,
                      width: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Description Field
              Text(
                'DESCRIPTION (OPTIONAL)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add details, deliverables, or checklist...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppTheme.textFieldBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.textFieldBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.textFieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppTheme.deepMaroon,
                      width: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Due Date & Time Pickers
              Text(
                'DUE DATE & TIME',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textFieldBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.textFieldBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateHelpers.formatShortDate(_selectedDueDate),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textFieldBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.textFieldBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: AppTheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedDueTime.format(context),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Priority Selector
              Text(
                'PRIORITY LEVEL',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildPriorityOption('low', 'Low', AppTheme.priorityLow),
                  const SizedBox(width: 8),
                  _buildPriorityOption(
                    'medium',
                    'Medium',
                    AppTheme.priorityMedium,
                  ),
                  const SizedBox(width: 8),
                  _buildPriorityOption('high', 'High', AppTheme.priorityHigh),
                ],
              ),

              const SizedBox(height: 36),

              // Action Button with Periwinkle button glow
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.pureWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.pureWhite,
                            ),
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Create Task',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.pureWhite,
                          ),
                        ),
                ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _deleteTask,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                    label: Text(
                      'Delete Task',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.secondary.withValues(alpha: 0.7),
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.textPrimary,
            size: 22,
          ),
        ),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              onPressed: _isSaving ? null : _deleteTask,
              tooltip: 'Delete Task',
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.secondary,
                size: 22,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: 16,
              left: horizPadding,
              right: horizPadding,
              bottom: bottomPadding + 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Responsive.formMaxWidth),
              child: isWide
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: formContent,
                    )
                  : formContent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String key, String label, Color dotColor) {
    final isSelected = _selectedPriority == key;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = key;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppTheme.borderLight,
              width: 1.4,
            ),
            boxShadow: isSelected ? AppTheme.buttonShadow : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.pureWhite : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.pureWhite : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
