import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/widgets/common/loading_widget.dart';

/// Privacy settings screen for controlling what information is visible to others
/// Allows users to manage their privacy preferences for profile and leaderboard
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  // Privacy preference flags
  late bool _showEmail;
  late bool _showProgress;
  late bool _showOnLeaderboard;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load current privacy settings from user data
    _loadSettings();
  }

  /// Loads privacy settings from the current user's profile
  void _loadSettings() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      setState(() {
        // Load each setting with default values if not set
        _showEmail = user.privacySettings['showEmail'] ?? false;
        _showProgress = user.privacySettings['showProgress'] ?? true;
        _showOnLeaderboard = user.privacySettings['showOnLeaderboard'] ?? true;
      });
    }
  }

  /// Saves privacy settings to Firebase through UserProvider
  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // Update privacy settings in Firebase
      await context.read<UserProvider>().updatePrivacySettings(
            showEmail: _showEmail,
            showProgress: _showProgress,
            showOnLeaderboard: _showOnLeaderboard,
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Privacy settings updated')),
        );
      }
    } catch (e) {
      // Show error message if update fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Visibility section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Visibility',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        // Email visibility toggle
                        SwitchListTile(
                          title: const Text('Show Email'),
                          subtitle: const Text(
                            'Allow other users to see your email address',
                          ),
                          value: _showEmail,
                          onChanged: (value) {
                            setState(() => _showEmail = value);
                          },
                        ),
                        const Divider(),
                        // Progress visibility toggle
                        SwitchListTile(
                          title: const Text('Show Progress'),
                          subtitle: const Text(
                            'Display your learning progress on your profile',
                          ),
                          value: _showProgress,
                          onChanged: (value) {
                            setState(() => _showProgress = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Leaderboard Settings section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leaderboard',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        // Leaderboard visibility toggle
                        SwitchListTile(
                          title: const Text('Appear on Leaderboard'),
                          subtitle: const Text(
                            'Show your username and stats in public rankings',
                          ),
                          value: _showOnLeaderboard,
                          onChanged: (value) {
                            setState(() => _showOnLeaderboard = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Privacy Information card - explains data handling
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Privacy Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Key privacy points
                        const Text(
                          '• Your learning data is always private\n'
                          '• Only the information you choose is shared\n'
                          '• You can change these settings anytime\n'
                          '• Achievements and badges are always visible',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Settings'),
                  ),
                ),
              ],
            ),
    );
  }
}
