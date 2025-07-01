import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/course_provider.dart';
import 'package:procode/screens/dashboard/widgets/stats_card.dart';
import 'package:procode/screens/dashboard/widgets/continue_learning_card.dart';
import 'package:procode/screens/dashboard/widgets/daily_challenge_card.dart';
import 'package:procode/screens/courses/courses_list_screen.dart';
import 'package:procode/screens/code_editor/code_editor_screen.dart';
import 'package:procode/screens/quiz/quiz_categories_screen.dart';
import 'package:procode/screens/profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const CoursesListScreen(),
    const CodeEditorScreen(),
    const QuizCategoriesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final courseProvider = context.read<CourseProvider>();
    final userProvider = context.read<UserProvider>();

    await Future.wait([
      courseProvider.loadCourses(),
      userProvider.loadUserStats(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
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
                _buildNavItem(Icons.code_rounded, 'Practice', 2),
                _buildNavItem(Icons.quiz_rounded, 'Quiz', 3),
                _buildNavItem(Icons.person_rounded, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    final color = isSelected ? theme.colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final user = authProvider.user;
    final userStats = userProvider.userStats;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              courseProvider.loadCourses(),
              userProvider.loadUserStats(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              // Show notifications
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: StatsCard(
                              title: 'Total XP',
                              value: userStats?.totalXP.toString() ?? '0',
                              icon: Icons.bolt,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Level',
                              value: userStats?.level.toString() ?? '1',
                              icon: Icons.star,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsCard(
                              title: 'Streak',
                              value: '${userStats?.currentStreak ?? 0}🔥',
                              icon: Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Continue Learning
                      if (courseProvider.enrolledCourses.isNotEmpty) ...[
                        Text(
                          'Continue Learning',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...courseProvider.enrolledCourses.take(2).map((course) {
                          final progress =
                              courseProvider.getProgressForCourse(course.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ContinueLearningCard(
                              course: course,
                              progress: progress,
                              completionPercentage: courseProvider
                                  .getCourseCompletionPercentage(course.id),
                            ),
                          );
                        }).toList(),
                      ],
                      const SizedBox(height: 24),
                      // Daily Challenge
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
}
