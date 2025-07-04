import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

class OutputConsole extends StatefulWidget {
  final String output;
  final String error;
  final bool isRunning;
  final List<Map<String, dynamic>>? testResults;
  final VoidCallback onClear;
  final VoidCallback? onStop;

  const OutputConsole({
    Key? key,
    required this.output,
    required this.error,
    required this.isRunning,
    this.testResults,
    required this.onClear,
    this.onStop,
  }) : super(key: key);

  @override
  State<OutputConsole> createState() => _OutputConsoleState();
}

class _OutputConsoleState extends State<OutputConsole>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _outputScrollController = ScrollController();
  final ScrollController _testScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.testResults != null ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(OutputConsole oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.testResults != null) != (oldWidget.testResults != null)) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.testResults != null ? 2 : 1,
        vsync: this,
      );
    }

    // Auto-scroll to bottom when new output is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_outputScrollController.hasClients) {
        _outputScrollController.animateTo(
          _outputScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _outputScrollController.dispose();
    _testScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.terminal,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Console',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.isRunning) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: widget.onStop,
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('Stop'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.clear_all, size: 20),
                  onPressed: widget.onClear,
                  tooltip: 'Clear Console',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar (if test results exist)
          if (widget.testResults != null)
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'Output'),
                  Tab(text: 'Test Results'),
                ],
              ),
            ),

          // Content
          Expanded(
            child: widget.testResults != null
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOutputView(),
                      _buildTestResultsView(),
                    ],
                  )
                : _buildOutputView(),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputView() {
    final theme = Theme.of(context);
    final hasContent = widget.output.isNotEmpty || widget.error.isNotEmpty;

    if (!hasContent && !widget.isRunning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Run your code to see output',
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        controller: _outputScrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.output.isNotEmpty)
              SelectableText(
                widget.output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            if (widget.error.isNotEmpty) ...[
              if (widget.output.isNotEmpty) const SizedBox(height: 16),
              SelectableText(
                widget.error,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFFFF6B6B),
                  height: 1.5,
                ),
              ),
            ],
            if (widget.isRunning) ...[
              const SizedBox(height: 8),
              const Text(
                'Running...',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultsView() {
    final theme = Theme.of(context);
    final results = widget.testResults ?? [];

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No test results available',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final passedTests = results.where((r) => r['passed'] == true).length;
    final totalTests = results.length;
    final allPassed = passedTests == totalTests;

    return Column(
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: allPassed
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: Row(
            children: [
              Icon(
                allPassed ? Icons.check_circle : Icons.error,
                color: allPassed ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                '$passedTests / $totalTests tests passed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: allPassed ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        // Test Results List
        Expanded(
          child: ListView.builder(
            controller: _testScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final passed = result['passed'] == true;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ExpansionTile(
                  leading: Icon(
                    passed ? Icons.check_circle : Icons.cancel,
                    color: passed ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    result['testCase'] ?? 'Test Case ${index + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    passed ? 'Passed' : 'Failed',
                    style: TextStyle(
                      color: passed ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTestDetail('Input:', result['input']),
                          const SizedBox(height: 12),
                          _buildTestDetail('Expected:', result['expected']),
                          const SizedBox(height: 12),
                          _buildTestDetail('Actual:', result['actual']),
                          if (result['executionTime'] != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Execution Time: ${result['executionTime']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestDetail(String label, dynamic value) {
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: SelectableText(
            value?.toString() ?? 'null',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
