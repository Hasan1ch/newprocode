import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/course_provider.dart';
import 'package:procode/screens/courses/widgets/course_card.dart';
import 'package:procode/widgets/common/custom_app_bar.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Enrolled',
    'Python',
    'JavaScript',
    'Web Dev'
  ];

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final courses = courseProvider.courses;
    final enrolledCourses = courseProvider.enrolledCourses;
    final theme = Theme.of(context);

    // Filter courses based on selection
    List<dynamic> filteredCourses = [];
    if (_selectedFilter == 'All') {
      filteredCourses = courses;
    } else if (_selectedFilter == 'Enrolled') {
      filteredCourses = enrolledCourses;
    } else {
      filteredCourses = courses.where((course) {
        if (_selectedFilter == 'Python') {
          return course.language == 'python';
        }
        if (_selectedFilter == 'JavaScript') {
          return course.language == 'javascript';
        }
        if (_selectedFilter == 'Web Dev') {
          return course.language == 'html' || course.language == 'css';
        }
        return false;
      }).toList();
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Courses',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    checkmarkColor: theme.colorScheme.onPrimary,
                  ),
                );
              },
            ),
          ),
          // Courses grid
          Expanded(
            child: courseProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary),
                    ),
                  )
                : filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 80,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'Enrolled'
                                  ? 'No enrolled courses yet'
                                  : 'No courses available',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (_selectedFilter == 'Enrolled') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedFilter = 'All';
                                  });
                                },
                                child: const Text('Browse all courses'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => courseProvider.loadCourses(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final course = filteredCourses[index];
                            final isEnrolled =
                                enrolledCourses.any((c) => c.id == course.id);
                            final completionPercentage = isEnrolled
                                ? courseProvider
                                    .getCourseCompletionPercentage(course.id)
                                : 0.0;

                            return CourseCard(
                              course: course,
                              isEnrolled: isEnrolled,
                              completionPercentage: completionPercentage,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
