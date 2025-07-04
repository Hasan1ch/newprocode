import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/code_challenge_model.dart';
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
  List<CodeChallengeModel> _challenges = [];
  bool _isLoading = true;

  final List<String> _languages = [
    'All',
    'Python',
    'JavaScript',
    'Java',
    'C++'
  ];
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

  List<CodeChallengeModel> get _filteredChallenges {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to submission history
            },
            tooltip: 'Submission History',
          ),
        ],
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
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _createSampleChallenges,
                              child: const Text('Create Sample Challenges'),
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

  Widget _buildChallengeCard(CodeChallengeModel challenge) {
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
              builder: (context) => CodeEditorScreen(
                challenge: challenge,
              ),
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

  // Create sample challenges for testing
  Future<void> _createSampleChallenges() async {
    final sampleChallenges = [
      {
        'title': 'Two Sum',
        'description':
            'Given an array of integers and a target sum, return indices of two numbers that add up to the target.',
        'language': 'Python',
        'difficulty': 'Easy',
        'category': 'Arrays',
        'initialCode': '''def twoSum(nums, target):
    # Your code here
    pass

# Test your solution
nums = [2, 7, 11, 15]
target = 9
print(twoSum(nums, target))''',
        'solution': '''def twoSum(nums, target):
    seen = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:
            return [seen[complement], i]
        seen[num] = i
    return []''',
        'testCases': [
          {
            'input': '[2,7,11,15]\n9',
            'expectedOutput': '[0, 1]',
            'description': 'Basic test case',
          },
          {
            'input': '[3,2,4]\n6',
            'expectedOutput': '[1, 2]',
            'description': 'Different order',
          },
        ],
        'xpReward': 10,
        'hints': {
          'hint1': 'Try using a hash map to store values you\'ve seen.',
          'hint2':
              'For each number, check if target - number exists in your map.',
        },
      },
      {
        'title': 'Palindrome Check',
        'description':
            'Write a function to check if a given string is a palindrome.',
        'language': 'JavaScript',
        'difficulty': 'Easy',
        'category': 'Strings',
        'initialCode': '''function isPalindrome(str) {
    // Your code here
    return false;
}

// Test your solution
console.log(isPalindrome("racecar"));
console.log(isPalindrome("hello"));''',
        'solution': '''function isPalindrome(str) {
    const cleaned = str.toLowerCase().replace(/[^a-z0-9]/g, '');
    return cleaned === cleaned.split('').reverse().join('');
}''',
        'testCases': [
          {
            'input': 'racecar',
            'expectedOutput': 'true',
            'description': 'Simple palindrome',
          },
          {
            'input': 'hello',
            'expectedOutput': 'false',
            'description': 'Not a palindrome',
          },
        ],
        'xpReward': 10,
        'hints': {
          'hint1':
              'Convert to lowercase and remove non-alphanumeric characters first.',
          'hint2': 'Compare the string with its reverse.',
        },
      },
      {
        'title': 'Fibonacci Sequence',
        'description': 'Generate the nth Fibonacci number.',
        'language': 'Python',
        'difficulty': 'Medium',
        'category': 'Algorithms',
        'initialCode': '''def fibonacci(n):
    # Your code here
    pass

# Test your solution
print(fibonacci(10))''',
        'solution': '''def fibonacci(n):
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b''',
        'testCases': [
          {
            'input': '10',
            'expectedOutput': '55',
            'description': '10th Fibonacci number',
          },
          {
            'input': '0',
            'expectedOutput': '0',
            'description': 'Base case',
          },
        ],
        'xpReward': 20,
        'hints': {
          'hint1': 'Use iterative approach for better performance.',
          'hint2': 'Keep track of the last two numbers.',
        },
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final challenge in sampleChallenges) {
        final docRef =
            FirebaseFirestore.instance.collection('challenges').doc();
        batch.set(docRef, {
          ...challenge,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample challenges created!')),
        );
        _loadChallenges();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating challenges: $e')),
        );
      }
    }
  }
}
