import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:procode/services/notification_service.dart';
import 'package:procode/widgets/common/loading_widget.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  late bool _achievementNotifications;
  late bool _dailyReminders;
  late bool _streakReminders;
  late bool _weeklyProgress;
  late bool _courseUpdates;
  late TimeOfDay _dailyReminderTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _achievementNotifications =
          prefs.getBool('achievement_notifications') ?? true;
      _dailyReminders = prefs.getBool('daily_reminders') ?? true;
      _streakReminders = prefs.getBool('streak_reminders') ?? true;
      _weeklyProgress = prefs.getBool('weekly_progress') ?? true;
      _courseUpdates = prefs.getBool('course_updates') ?? true;

      final hour = prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
          'achievement_notifications', _achievementNotifications);
      await prefs.setBool('daily_reminders', _dailyReminders);
      await prefs.setBool('streak_reminders', _streakReminders);
      await prefs.setBool('weekly_progress', _weeklyProgress);
      await prefs.setBool('course_updates', _courseUpdates);
      await prefs.setInt('daily_reminder_hour', _dailyReminderTime.hour);
      await prefs.setInt('daily_reminder_minute', _dailyReminderTime.minute);

      // Since the NotificationService only handles in-app notifications,
      // we'll just save the preferences for now. In a real app, you'd
      // integrate with a proper notification scheduling system like
      // flutter_local_notifications or Firebase Cloud Messaging

      if (mounted) {
        _notificationService.showSuccessNotification(
          'Notification settings saved successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        _notificationService.showErrorNotification(
          'Failed to save settings: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
    );

    if (picked != null && picked != _dailyReminderTime) {
      setState(() {
        _dailyReminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Notification Info Card
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                              'About Notifications',
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
                        Text(
                          'These settings control in-app notifications. '
                          'Push notifications are not yet available but will be added in a future update.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Learning Notifications
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learning Notifications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Achievement Notifications'),
                          subtitle: const Text(
                            'Show notifications when you unlock achievements',
                          ),
                          value: _achievementNotifications,
                          onChanged: (value) {
                            setState(() => _achievementNotifications = value);
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Daily Reminders'),
                          subtitle: const Text(
                            'Remind me to practice daily (coming soon)',
                          ),
                          value: _dailyReminders,
                          onChanged: (value) {
                            setState(() => _dailyReminders = value);
                          },
                        ),
                        if (_dailyReminders) ...[
                          ListTile(
                            title: const Text('Reminder Time'),
                            subtitle: Text(
                              _dailyReminderTime.format(context),
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectTime,
                          ),
                        ],
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Streak Reminders'),
                          subtitle: const Text(
                            'Show notifications for streak milestones',
                          ),
                          value: _streakReminders,
                          onChanged: (value) {
                            setState(() => _streakReminders = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Updates
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress Updates',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Weekly Progress Report'),
                          subtitle: const Text(
                            'Get a summary of your weekly progress (coming soon)',
                          ),
                          value: _weeklyProgress,
                          onChanged: (value) {
                            setState(() => _weeklyProgress = value);
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Course Updates'),
                          subtitle: const Text(
                            'Notify me about new courses and content',
                          ),
                          value: _courseUpdates,
                          onChanged: (value) {
                            setState(() => _courseUpdates = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notification Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview Notifications',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.emoji_events),
                          title: const Text('Achievement Notification'),
                          subtitle: const Text('Tap to see a preview'),
                          onTap: () {
                            _notificationService.showSuccessNotification(
                              'Achievement Unlocked! 🏆 First Steps',
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.local_fire_department),
                          title: const Text('Streak Notification'),
                          subtitle: const Text('Tap to see a preview'),
                          onTap: () {
                            _notificationService.showStreakNotification(7);
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.star),
                          title: const Text('XP Notification'),
                          subtitle: const Text('Tap to see a preview'),
                          onTap: () {
                            _notificationService.showXPEarnedNotification(50);
                          },
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
