// File: lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helpers.dart';
import '../utils/responsive.dart';
import '../widgets/app_error_banner.dart';
import '../widgets/filter_box.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchBarKey = GlobalKey();
  String? _errorMessage;
  String? _actionBannerMessage;
  VoidCallback? _undoAction;
  Timer? _undoTimer;

  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _undoTimer?.cancel();
    super.dispose();
  }

  void _showTaskSummaryModal(BuildContext context, TaskProvider taskProvider) {
    final allTasks = taskProvider.allTasks;
    final completedCount = allTasks.where((t) => t.isCompleted).length;
    final pendingCount = allTasks.length - completedCount;
    final highCount = allTasks.where((t) => t.priority.toLowerCase() == 'high').length;
    final medCount = allTasks.where((t) => t.priority.toLowerCase() == 'medium').length;
    final lowCount = allTasks.where((t) => t.priority.toLowerCase() == 'low').length;

    final completionPct = allTasks.isEmpty
        ? 0
        : ((completedCount / allTasks.length) * 100).toInt();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: Responsive.modalMaxWidth),
      builder: (modalCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(modalCtx).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Task Overview',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSage,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completionPct% completed',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: allTasks.isEmpty ? 0 : (completedCount / allTasks.length),
                  backgroundColor: AppTheme.cardSageDark,
                  color: AppTheme.primary,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  _buildStatTile('Total', '${allTasks.length}', AppTheme.textPrimary),
                  const SizedBox(width: 10),
                  _buildStatTile('Pending', '$pendingCount', AppTheme.primary),
                  const SizedBox(width: 10),
                  _buildStatTile('Completed', '$completedCount', const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 14),

              // Priority breakdown
              Text(
                'PRIORITY BREAKDOWN',
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
                  _buildPriorityPill('High', highCount, AppTheme.priorityHigh, AppTheme.priorityHighBg),
                  const SizedBox(width: 8),
                  _buildPriorityPill('Medium', medCount, AppTheme.priorityMedium, AppTheme.priorityMediumBg),
                  const SizedBox(width: 8),
                  _buildPriorityPill('Low', lowCount, AppTheme.priorityLow, AppTheme.priorityLowBg),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardSageLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityPill(String label, int count, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$label: ',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final horizPadding = Responsive.horizontalPadding(context);

    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final groupedTasks = taskProvider.groupedFilteredTasks;
    final totalFilteredCount = taskProvider.filteredTasks.length;
    final totalTasksCount = taskProvider.allTasks.length;
    final pendingCount =
        taskProvider.allTasks.where((t) => !t.isCompleted).length;

    final hasActiveFilter =
        taskProvider.priorityFilter != PriorityFilter.all ||
            taskProvider.statusFilter != StatusFilter.all;

    final hasSearch = taskProvider.searchQuery.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppTheme.secondaryButtonShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskFormScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.secondary,
          elevation: 0,
          child: const Icon(
            Icons.add_rounded,
            size: 30,
            color: AppTheme.pureWhite,
          ),
        ),
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (_searchFocusNode.hasFocus) {
            final renderBox =
                _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final searchBarRect =
                  renderBox.localToGlobal(Offset.zero) & renderBox.size;
              if (!searchBarRect.contains(event.position)) {
                _unfocusSearch();
              }
            } else {
              _unfocusSearch();
            }
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _unfocusSearch,
          child: SafeArea(
            top: false,
            bottom: false,
            child: ResponsiveContainer(
              maxWidth: Responsive.mainContentMaxWidth,
            child: Column(
              children: [
                // Signature Olive Green Curved Header Banner
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF556B2F), // Olive Green (85, 107, 47)
                        Color(0xFF3B4B20), // Dark Olive
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryDark.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(
                    top: mediaQuery.padding.top + 12,
                    bottom: 22,
                    left: horizPadding,
                    right: horizPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Live Search Bar + Options Menu
                      Row(
                        children: [
                          // Live Search & Filter Bar in crisp Pure White (Dashboard icon removed)
                          Expanded(
                            child: TapRegion(
                              groupId: EditableText,
                              onTapOutside: (_) => _unfocusSearch(),
                              child: Container(
                                key: _searchBarKey,
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.pureWhite,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search_rounded,
                                      color: AppTheme.textSecondary,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),

                                    // Real-time Search TextField
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        onTapOutside: (_) => _unfocusSearch(),
                                        onSubmitted: (_) => _unfocusSearch(),
                                        onChanged: (val) {
                                          taskProvider.setSearchQuery(val);
                                          setState(() {});
                                        },
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Search tasks...',
                                          hintStyle: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: AppTheme.textTertiary,
                                          ),
                                          isDense: true,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),

                                    // Clear search query button
                                    if (_searchController.text.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          _searchController.clear();
                                          taskProvider.setSearchQuery('');
                                          _unfocusSearch();
                                          setState(() {});
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 4),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: AppTheme.textSecondary,
                                            size: 16,
                                          ),
                                        ),
                                      ),

                                    // Divider
                                    Container(
                                      height: 18,
                                      width: 1,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      color: AppTheme.borderLight,
                                    ),

                                    // Filter trigger button
                                    GestureDetector(
                                      onTap: () {
                                        _unfocusSearch();
                                        FilterBox.show(
                                          context,
                                          selectedPriority: taskProvider.priorityFilter,
                                          selectedStatus: taskProvider.statusFilter,
                                          totalTasksCount: totalTasksCount,
                                          onPriorityChanged: (f) =>
                                              taskProvider.setPriorityFilter(f),
                                          onStatusChanged: (f) =>
                                              taskProvider.setStatusFilter(f),
                                          onReset: () {
                                            taskProvider.setPriorityFilter(PriorityFilter.all);
                                            taskProvider.setStatusFilter(StatusFilter.all);
                                          },
                                        );
                                      },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        color: hasActiveFilter
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        size: 18,
                                      ),
                                      if (hasActiveFilter)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.secondary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                        // Right: More Options / Sign Out
                        PopupMenuButton<String>(
                          icon: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.pureWhite.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.more_horiz_rounded,
                              color: AppTheme.pureWhite,
                              size: 20,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppTheme.borderLight),
                          ),
                          elevation: 4,
                          onSelected: (value) async {
                            if (value == 'overview') {
                              _showTaskSummaryModal(context, taskProvider);
                            } else if (value == 'logout') {
                              taskProvider.clear();
                              await authProvider.signOut();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'overview',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.insights_rounded,
                                    color: AppTheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Task Summary',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.logout_rounded,
                                    color: AppTheme.deleteRed,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Sign Out',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.deleteRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Date and "My tasks" Title
                    Text(
                      DateHelpers.formatHeaderDate(DateTime.now()),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.pureWhite.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'My tasks',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.pureWhite,
                            letterSpacing: -0.6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showTaskSummaryModal(context, taskProvider),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondaryDark.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$pendingCount pending',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.pureWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Active filter or search pills row right beneath banner
              if (hasActiveFilter || hasSearch) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizPadding),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        if (hasSearch) ...[
                          _buildFilterBadge(
                            label: 'Search: "${taskProvider.searchQuery}"',
                            onRemove: () {
                              _searchController.clear();
                              taskProvider.setSearchQuery('');
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (taskProvider.statusFilter != StatusFilter.all) ...[
                          _buildFilterBadge(
                            label: taskProvider.statusFilter ==
                                    StatusFilter.completed
                                ? 'Completed'
                                : 'Incomplete',
                            onRemove: () =>
                                taskProvider.setStatusFilter(StatusFilter.all),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (taskProvider.priorityFilter !=
                            PriorityFilter.all) ...[
                          _buildFilterBadge(
                            label:
                                '${taskProvider.priorityFilter.name[0].toUpperCase()}${taskProvider.priorityFilter.name.substring(1)} Priority',
                            onRemove: () => taskProvider
                                .setPriorityFilter(PriorityFilter.all),
                          ),
                          const SizedBox(width: 8),
                        ],
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            taskProvider.setSearchQuery('');
                            taskProvider.setPriorityFilter(PriorityFilter.all);
                            taskProvider.setStatusFilter(StatusFilter.all);
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondarySoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.secondary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              'Reset all',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // In-app Notification Banners
              if (_errorMessage != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizPadding,
                    vertical: 4,
                  ),
                  child: AppErrorBanner(
                    message: _errorMessage!,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                ),
              ],

              if (_actionBannerMessage != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizPadding,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppTheme.pureWhite,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _actionBannerMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.pureWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_undoAction != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final action = _undoAction;
                              _undoTimer?.cancel();
                              setState(() {
                                _actionBannerMessage = null;
                                _undoAction = null;
                              });
                              action?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.pureWhite,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'UNDO',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            _undoTimer?.cancel();
                            setState(() {
                              _actionBannerMessage = null;
                              _undoAction = null;
                            });
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.pureWhite,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 6),

              // Task List Body
              Expanded(
                child: taskProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                          strokeWidth: 2.5,
                        ),
                      )
                    : totalFilteredCount == 0
                        ? _buildEmptyState(
                            context,
                            hasFilter: hasActiveFilter || hasSearch,
                            onClearFilters: () {
                              _searchController.clear();
                              taskProvider.setSearchQuery('');
                              taskProvider.setPriorityFilter(PriorityFilter.all);
                              taskProvider.setStatusFilter(StatusFilter.all);
                              setState(() {});
                            },
                          )
                        : NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification ||
                                  notification is ScrollUpdateNotification) {
                                if (_searchFocusNode.hasFocus) {
                                  _unfocusSearch();
                                }
                              }
                              return false;
                            },
                            child: ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                              left: horizPadding,
                              right: horizPadding,
                              top: 6,
                              bottom: bottomPadding + 88,
                            ),
                            children: [
                              _buildTaskSection(
                                context: context,
                                title: 'Today',
                                tasks: groupedTasks['Today'] ?? [],
                                taskProvider: taskProvider,
                              ),
                              _buildTaskSection(
                                context: context,
                                title: 'Tomorrow',
                                tasks: groupedTasks['Tomorrow'] ?? [],
                                taskProvider: taskProvider,
                              ),
                              _buildTaskSection(
                                context: context,
                                title: 'This week',
                                tasks: groupedTasks['This week'] ?? [],
                                taskProvider: taskProvider,
                              ),
                              _buildTaskSection(
                                context: context,
                                title: 'Later',
                                tasks: groupedTasks['Later'] ?? [],
                                taskProvider: taskProvider,
                              ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildFilterBadge({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSection({
    required BuildContext context,
    required String title,
    required List<Task> tasks,
    required TaskProvider taskProvider,
  }) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMultiColumn =
            constraints.maxWidth >= Responsive.multiColumnBreakpoint;

        Widget buildCard(Task task) {
          return TaskCard(
            task: task,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskFormScreen(taskToEdit: task),
                ),
              );
            },
            onToggle: () async {
              try {
                await taskProvider.toggleComplete(task);
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _errorMessage =
                        e.toString().replaceFirst('Exception: ', '');
                  });
                }
              }
            },
            onDelete: () async {
              try {
                await taskProvider.deleteTask(task);
                if (mounted) {
                  _undoTimer?.cancel();
                  setState(() {
                    _errorMessage = null;
                    _actionBannerMessage = 'Task deleted';
                    _undoAction = () async {
                      try {
                        await taskProvider.undoDelete();
                      } catch (e) {
                        if (mounted) {
                          setState(() {
                            _errorMessage =
                                e.toString().replaceFirst('Exception: ', '');
                          });
                        }
                      }
                    };
                  });
                  _undoTimer = Timer(const Duration(seconds: 4), () {
                    if (mounted) {
                      setState(() {
                        _actionBannerMessage = null;
                        _undoAction = null;
                      });
                    }
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _errorMessage =
                        e.toString().replaceFirst('Exception: ', '');
                  });
                }
              }
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 8, left: 4),
              child: Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSage,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isMultiColumn) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 0; i < tasks.length; i += 2)
                          buildCard(tasks[i]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      children: [
                        for (int i = 1; i < tasks.length; i += 2)
                          buildCard(tasks[i]),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Column(
                children: tasks.map(buildCard).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required bool hasFilter,
    required VoidCallback onClearFilters,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppTheme.cardSage,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 38,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilter ? 'No matching tasks' : 'No tasks yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try adjusting your search query or filters to find tasks.'
                  : 'Tap the button below to add your first task.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            if (hasFilter)
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Clear Search / Filters',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskFormScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Add Task',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.pureWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
