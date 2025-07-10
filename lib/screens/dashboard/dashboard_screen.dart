import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/course_provider.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/screens/dashboard/widgets/stats_card.dart';
import 'package:procode/screens/dashboard/widgets/continue_learning_card.dart';
import 'package:procode/screens/dashboard/widgets/daily_challenge_card.dart';
import 'package:procode/screens/courses/courses_list_screen.dart';
import 'package:procode/screens/ai_advisor/ai_advisor_screen.dart';
import 'package:procode/screens/code_editor/code_editor_screen.dart';
import 'package:procode/screens/quiz/quiz_categories_screen.dart';
import 'package:procode/screens/profile/profile_screen.dart';
import 'package:procode/utils/app_logger.dart';

/// Main dashboard screen that serves as the app's navigation hub
/// Uses IndexedStack to maintain state across tab switches
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Currently selected tab
  bool _isInitialized = false; // Prevents duplicate initialization

  // All main screens accessible from bottom navigation
  final List<Widget> _screens = [
    const HomeTab(),
    const CoursesListScreen(),
    const AIAdvisorScreen(),
    const CodeEditorScreen(),
    const QuizCategoriesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data after the first frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadInitialData();
        _isInitialized = true;
      }
    });
  }

  /// Loads all necessary data when dashboard initializes
  /// This includes user data, courses, and real-time listeners
  Future<void> _loadInitialData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final courseProvider = context.read<CourseProvider>();
      final userProvider = context.read<UserProvider>();

      if (authProvider.firebaseUser != null) {
        final userId = authProvider.firebaseUser!.uid;

        // Load user profile data first
        await userProvider.loadUser(userId);

        // Load all available and enrolled courses
        await courseProvider.loadCourses();

        // Set up real-time updates if available
        if (courseProvider.runtimeType
            .toString()
            .contains('initializeRealTimeListeners')) {
          await courseProvider.initializeRealTimeListeners();
        }

        // Update user's streak for gamification
        await _updateStreakOnLogin(userId);

        AppLogger.info('Dashboard initialized successfully');
      }
    } catch (e) {
      AppLogger.error('Error initializing dashboard: $e');
    }
  }

  /// Updates the user's daily streak when they log in
  /// Important for maintaining engagement through gamification
  Future<void> _updateStreakOnLogin(String userId) async {
    try {
      final databaseService = DatabaseService();
      await databaseService.updateStreak(userId);
    } catch (e) {
      AppLogger.error('Error updating streak: $e');
    }
  }

  /// Public method to allow child widgets to navigate to different tabs
  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // IndexedStack maintains widget state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          // Subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.book_rounded, 'Courses', 1),
                _buildNavItem(Icons.auto_awesome_rounded, 'AI', 2),
                _buildNavItem(Icons.code_rounded, 'Practice', 3),
                _buildNavItem(Icons.quiz_rounded, 'Quiz', 4),
                _buildNavItem(Icons.person_rounded, 'Profile', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation bar items with selection state
  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home tab showing user stats, progress, and quick actions
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Watch providers for real-time updates
    final userProvider = context.watch<UserProvider>();
    final courseProvider = context.watch<CourseProvider>();

    // Extract data from providers
    final user = userProvider.user;
    final isLoading = userProvider.isLoading || courseProvider.isLoading;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          // Pull to refresh functionality
          onRefresh: () async {
            await Future.wait([
              courseProvider.refresh(),
              userProvider.refresh(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome header with user name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onBackground
                                      .withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.displayName ?? 'Learner',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            color: theme.colorScheme.onBackground,
                            onPressed: () {
                              // TODO: Implement notifications screen
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Real-time stats cards showing user progress
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Total XP',
                              value: user?.totalXP.toString() ?? '0',
                              icon: Icons.bolt,
                              color: Colors.amber,
                              isLoading: isLoading && user == null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Level',
                              value: user?.level.toString() ?? '1',
                              icon: Icons.star,
                              color: Colors.purple,
                              isLoading: isLoading && user == null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Streak',
                              value: '${user?.currentStreak ?? 0}🔥',
                              icon: Icons.local_fire_department,
                              color: Colors.orange,
                              isLoading: isLoading && user == null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Continue Learning section for enrolled courses
                      if (courseProvider.enrolledCourses.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Continue Learning',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Show "View All" if more than 2 courses enrolled
                            if (courseProvider.enrolledCourses.length > 2)
                              TextButton(
                                onPressed: () {
                                  // Navigate to courses tab
                                  final parent =
                                      context.findAncestorStateOfType<
                                          _DashboardScreenState>();
                                  if (parent != null) {
                                    parent.navigateToTab(1);
                                  }
                                },
                                child: const Text('View All'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Show up to 2 enrolled courses
                        ...courseProvider.enrolledCourses.take(2).map((course) {
                          final progress =
                              courseProvider.getProgressForCourse(course.id);
                          final completionPercentage = courseProvider
                              .getCourseCompletionPercentage(course.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ContinueLearningCard(
                              course: course,
                              progress: progress,
                              completionPercentage: completionPercentage,
                            ),
                          );
                        }).toList(),
                      ] else if (!isLoading) ...[
                        // Empty state when no courses enrolled
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 64,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No courses enrolled yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start your learning journey today!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to courses tab
                                    final parent =
                                        context.findAncestorStateOfType<
                                            _DashboardScreenState>();
                                    if (parent != null) {
                                      parent.navigateToTab(1);
                                    }
                                  },
                                  child: const Text('Browse Courses'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Loading indicator while fetching courses
                      if (isLoading &&
                          courseProvider.enrolledCourses.isEmpty) ...[
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Additional progress statistics
                      if (user != null && userProvider.userStats != null) ...[
                        Text(
                          'Your Progress',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildProgressItem(
                                    'Lessons',
                                    userProvider.userStats!.lessonsCompleted
                                        .toString(),
                                    Icons.book_outlined,
                                    theme,
                                  ),
                                  _buildProgressItem(
                                    'Quizzes',
                                    userProvider.userStats!.quizzesCompleted
                                        .toString(),
                                    Icons.quiz_outlined,
                                    theme,
                                  ),
                                  _buildProgressItem(
                                    'Courses',
                                    courseProvider.enrolledCourses.length
                                        .toString(),
                                    Icons.school_outlined,
                                    theme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Daily Challenge section
                      Text(
                        'Daily Challenge',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const DailyChallengeCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual progress item for the stats section
  Widget _buildProgressItem(
      String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
