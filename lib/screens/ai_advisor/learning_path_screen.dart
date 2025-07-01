import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/course_provider.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/widgets/common/gradient_container.dart';
import 'package:procode/config/theme.dart';

class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({super.key});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  final GeminiService _geminiService = GeminiService();

  bool _isLoading = true;
  LearningPath? _learningPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLearningPath();
  }

  Future<void> _loadLearningPath() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = context.read<UserProvider>().user;
      final courses = context.read<CourseProvider>().courses;

      if (user == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }

      // Check if user has completed skill assessment
      if (user.skillLevel == null || user.learningStyle == null) {
        // For now, show a dialog instead of navigating to non-existent screen
        if (!mounted) return;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Skill Assessment Required'),
            content: const Text(
              'Please complete your profile settings to generate a personalized learning path.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to profile settings
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        );
        return;
      }

      // Generate learning path
      final path = await _geminiService.generateLearningPath(
        userId: user.id,
        skillLevel: user.skillLevel ?? 'beginner',
        learningGoal: user.learningGoal ?? 'Full Stack Development',
        availableCourses: courses,
        completedCourses: user.completedCourses,
        weeklyHours: user.weeklyHours ?? 10,
      );

      setState(() {
        _learningPath = path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate learning path: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Retry',
                        onPressed: _loadLearningPath,
                      ),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Header
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: GradientContainer(
                          child: SafeArea(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.route,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your Learning Path',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (_learningPath != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_learningPath!.totalWeeks} weeks • ${_learningPath!.phases.length} phases',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    if (_learningPath != null) ...[
                      // Overview Card
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Overview',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(_learningPath!.description),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _InfoChip(
                                        icon: Icons.calendar_today,
                                        label: 'Duration',
                                        value:
                                            '${_learningPath!.totalWeeks} weeks',
                                      ),
                                      const SizedBox(width: 12),
                                      _InfoChip(
                                        icon: Icons.access_time,
                                        label: 'Weekly',
                                        value: '${_learningPath!.weeklyHours}h',
                                      ),
                                      const SizedBox(width: 12),
                                      _InfoChip(
                                        icon: Icons.trending_up,
                                        label: 'Difficulty',
                                        value: _learningPath!.difficulty,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Phases
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final phase = _learningPath!.phases[index];
                              return _PhaseCard(
                                phase: phase,
                                phaseNumber: index + 1,
                              );
                            },
                            childCount: _learningPath!.phases.length,
                          ),
                        ),
                      ),

                      // Action Buttons
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              CustomButton(
                                text: 'Start Learning',
                                onPressed: () {
                                  // Navigate to first course
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/dashboard',
                                  );
                                },
                                width: double.infinity,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _loadLearningPath,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Regenerate Path'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final LearningPhase phase;
  final int phaseNumber;

  const _PhaseCard({
    required this.phase,
    required this.phaseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$phaseNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          title: Text(
            phase.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle:
              Text('${phase.weeks} weeks • ${phase.courses.length} courses'),
          children: [
            Text(
              phase.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ...phase.courses.map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            course['icon'] ?? '📚',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['title'] ?? '',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              course['duration'] ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            if (phase.milestones.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Milestones',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...phase.milestones.map((milestone) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(milestone)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
