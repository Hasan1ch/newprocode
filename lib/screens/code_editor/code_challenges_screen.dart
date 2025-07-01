import 'package:flutter/material.dart';
import 'package:procode/models/code_challenge_model.dart' as models;
import 'package:procode/screens/code_editor/code_editor_screen.dart';
import 'package:procode/services/code_editor_service.dart';
import 'package:procode/widgets/animations/fade_animation.dart';
import 'package:procode/widgets/common/loading_widget.dart';

class CodeChallengesScreen extends StatefulWidget {
  const CodeChallengesScreen({super.key});

  @override
  State<CodeChallengesScreen> createState() => _CodeChallengesScreenState();
}

class _CodeChallengesScreenState extends State<CodeChallengesScreen> {
  final CodeEditorService _codeService = CodeEditorService();

  String _selectedLanguage = 'All';
  String _selectedDifficulty = 'All';
  String _selectedCategory = 'All';
  List<models.CodeChallenge> _challenges = [];
  bool _isLoading = true;

  final List<String> _languages = ['All', 'Python', 'JavaScript', 'Java'];
  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];
  final List<String> _categories = [
    'All',
    'Arrays',
    'Strings',
    'Algorithms',
    'Data Structures',
    'Math',
    'Debug'
  ];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);

    try {
      final challenges = await _codeService.getCodeChallenges();
      setState(() {
        _challenges = challenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load challenges')),
        );
      }
    }
  }

  List<models.CodeChallenge> get _filteredChallenges {
    return _challenges.where((challenge) {
      if (_selectedLanguage != 'All' &&
          challenge.language.toLowerCase() != _selectedLanguage.toLowerCase()) {
        return false;
      }
      if (_selectedDifficulty != 'All' &&
          challenge.difficulty != _selectedDifficulty) {
        return false;
      }
      if (_selectedCategory != 'All' &&
          challenge.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        title: const Text('Code Challenges'),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Language',
                        value: _selectedLanguage,
                        items: _languages,
                        onChanged: (value) {
                          setState(() => _selectedLanguage = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: 'Difficulty',
                        value: _selectedDifficulty,
                        items: _difficulties,
                        onChanged: (value) {
                          setState(() => _selectedDifficulty = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFilterDropdown(
                  label: 'Category',
                  value: _selectedCategory,
                  items: _categories,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
              ],
            ),
          ),

          // Challenges List
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _filteredChallenges.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.code_off,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No challenges found',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredChallenges.length,
                        itemBuilder: (context, index) {
                          final challenge = _filteredChallenges[index];
                          return FadeAnimation(
                            delay: index * 0.1,
                            child: _buildChallengeCard(challenge),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard(models.CodeChallenge challenge) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CodeEditorScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(challenge.difficulty)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      challenge.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(challenge.difficulty),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                challenge.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(
                    Icons.code,
                    challenge.language,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    Icons.category,
                    challenge.category,
                    Colors.purple,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.xpReward} XP',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
