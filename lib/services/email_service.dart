import 'package:firebase_auth/firebase_auth.dart';
import 'package:procode/utils/app_logger.dart';

/// Email Service handles all email-related operations in the app
/// Currently uses Firebase Auth for verification/reset emails
/// Future implementation would integrate with email services like SendGrid
class EmailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email templates - these would typically be stored in a config file
  static const String _appName = 'ProCode';
  static const String _supportEmail = 'support@procode.app';

  /// Sends email verification to newly registered users
  /// This is crucial for ensuring valid email addresses and preventing spam accounts
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      // Only send if user exists and hasn't verified their email yet
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.info('Verification email sent to ${user.email}');
      }
    } catch (e) {
      AppLogger.error('Error sending verification email', error: e);
      rethrow;
    }
  }

  /// Handles password reset flow through Firebase Auth
  /// Sends a secure link allowing users to reset their password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to $email');
    } catch (e) {
      AppLogger.error('Error sending password reset email', error: e);
      rethrow;
    }
  }

  /// Placeholder for welcome email functionality
  /// In production, this would trigger a Cloud Function to send personalized welcome emails
  /// This improves user engagement and provides onboarding information
  Future<void> sendWelcomeEmail(String email, String username) async {
    try {
      // In a production app, this would trigger a Cloud Function or backend service
      // For now, we'll just log it
      AppLogger.info(
          'Welcome email would be sent to $email for user $username');

      // You could integrate with a service like SendGrid, Mailgun, etc.
      // Or use Firebase Extensions for email sending
    } catch (e) {
      AppLogger.error('Error sending welcome email', error: e);
    }
  }

  /// Notifies users when they unlock achievements - great for engagement
  /// This gamification element encourages continued learning
  Future<void> sendAchievementEmail(
      String email, String achievementName) async {
    try {
      // This would normally trigger a backend service
      AppLogger.info(
          'Achievement email would be sent to $email for achievement: $achievementName');
    } catch (e) {
      AppLogger.error('Error sending achievement email', error: e);
    }
  }

  /// Celebrates course completion milestones with users
  /// Helps maintain motivation and provides a sense of accomplishment
  Future<void> sendCourseCompletionEmail(
      String email, String courseName) async {
    try {
      // This would normally trigger a backend service
      AppLogger.info(
          'Course completion email would be sent to $email for course: $courseName');
    } catch (e) {
      AppLogger.error('Error sending course completion email', error: e);
    }
  }

  /// Reminder emails help maintain user engagement and learning streaks
  /// Studies show consistent reminders improve course completion rates
  Future<void> sendStreakReminderEmail(String email, int currentStreak) async {
    try {
      // This would normally trigger a backend service
      AppLogger.info(
          'Streak reminder email would be sent to $email. Current streak: $currentStreak');
    } catch (e) {
      AppLogger.error('Error sending streak reminder email', error: e);
    }
  }

  /// Checks if user has verified their email address
  /// We use this to restrict access to certain features until email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Reload user to get latest verification status from Firebase
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking email verification status', error: e);
      return false;
    }
  }

  /// Allows users to request another verification email if they missed the first one
  /// Common scenario: email went to spam or expired
  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.info('Verification email resent to ${user.email}');
      } else if (user != null && user.emailVerified) {
        throw Exception('Email is already verified');
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      AppLogger.error('Error resending verification email', error: e);
      rethrow;
    }
  }

  /// Allows users to change their email address
  /// Automatically sends verification to the new email for security
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        // Security measure: always verify new email addresses
        await user.sendEmailVerification();
        AppLogger.info('Email updated to $newEmail and verification sent');
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      AppLogger.error('Error updating email', error: e);
      rethrow;
    }
  }

  /// Email templates for future server-side implementation
  /// These demonstrate the email content structure we plan to use

  /// Welcome email template - sent after successful registration
  static Map<String, String> getWelcomeEmailTemplate(String username) {
    return {
      'subject': 'Welcome to $_appName!',
      'body': '''
        <h2>Welcome to $_appName, $username!</h2>
        <p>We're excited to have you join our community of learners.</p>
        <p>Start your coding journey today and unlock achievements along the way!</p>
        <p>If you have any questions, feel free to reach out to us at $_supportEmail</p>
        <p>Happy coding!</p>
        <p>The $_appName Team</p>
      '''
    };
  }

  /// Achievement email template - celebrates user progress
  static Map<String, String> getAchievementEmailTemplate(
      String username, String achievementName) {
    return {
      'subject': '🎉 Achievement Unlocked: $achievementName',
      'body': '''
        <h2>Congratulations, $username!</h2>
        <p>You've unlocked a new achievement: <strong>$achievementName</strong></p>
        <p>Keep up the great work and continue your learning journey!</p>
        <p>View all your achievements in the $_appName app.</p>
        <p>The $_appName Team</p>
      '''
    };
  }

  /// Course completion email template - motivates continued learning
  static Map<String, String> getCourseCompletionEmailTemplate(
      String username, String courseName) {
    return {
      'subject': '🎓 Course Completed: $courseName',
      'body': '''
        <h2>Congratulations, $username!</h2>
        <p>You've successfully completed the <strong>$courseName</strong> course!</p>
        <p>You're making excellent progress on your coding journey.</p>
        <p>Ready for your next challenge? Check out more courses in the $_appName app.</p>
        <p>The $_appName Team</p>
      '''
    };
  }
}
