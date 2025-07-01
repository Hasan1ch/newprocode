import 'package:firebase_auth/firebase_auth.dart';
import 'package:procode/utils/app_logger.dart';

class EmailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email templates
  static const String _appName = 'ProCode';
  static const String _supportEmail = 'support@procode.app';

  // Send verification email
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.info('Verification email sent to ${user.email}');
      }
    } catch (e) {
      AppLogger.error('Error sending verification email', error: e);
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to $email');
    } catch (e) {
      AppLogger.error('Error sending password reset email', error: e);
      rethrow;
    }
  }

  // Send welcome email (this would normally be done server-side)
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

  // Send achievement unlocked email
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

  // Send course completion email
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

  // Send streak reminder email
  Future<void> sendStreakReminderEmail(String email, int currentStreak) async {
    try {
      // This would normally trigger a backend service
      AppLogger.info(
          'Streak reminder email would be sent to $email. Current streak: $currentStreak');
    } catch (e) {
      AppLogger.error('Error sending streak reminder email', error: e);
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking email verification status', error: e);
      return false;
    }
  }

  // Resend verification email
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

  // Update email address
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
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

  // Email templates (for reference - would be used server-side)
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
