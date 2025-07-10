/// Form validation utilities for consistent input validation
/// This class centralizes all validation logic to ensure
/// data integrity and provide clear user feedback
class Validators {
  /// Validates email addresses using RFC-compliant regex
  /// Ensures proper format before attempting Firebase authentication
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Basic email regex pattern - covers most common email formats
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null; // null means validation passed
  }

  /// Strong password validation for registration
  /// Enforces Firebase Authentication security requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character (Firebase requirement)
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    // Check maximum length (Firebase max is 4096)
    if (value.length > 4096) {
      return 'Password is too long';
    }

    return null;
  }

  /// Simplified password validation for login
  /// Only checks minimum requirements since password already exists
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  /// Confirms password match during registration
  /// Prevents typos in password field
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates username for uniqueness and format
  /// Usernames are used in leaderboards and social features
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }

    // Only allow alphanumeric characters and underscores
    // This prevents injection attacks and display issues
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Validates display name for public profile
  /// More flexible than username but still has restrictions
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }

    if (value.length < 2) {
      return 'Display name must be at least 2 characters long';
    }

    if (value.length > 30) {
      return 'Display name must be less than 30 characters';
    }

    // Allow letters, numbers, spaces, and some special characters
    final displayNameRegex = RegExp(r'^[a-zA-Z0-9\s\-_.]+$');
    if (!displayNameRegex.hasMatch(value)) {
      return 'Display name can only contain letters, numbers, spaces, hyphens, underscores, and dots';
    }

    return null;
  }

  /// Validates full name for certificates and formal documents
  /// Allows international characters and common name formats
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Only allow letters, spaces, and basic punctuation
    // Supports names like "O'Brien" or "Mary-Jane"
    final nameRegex = RegExp(r"^[a-zA-Z\s\-'.]+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validates phone numbers for two-factor authentication
  /// Accepts international formats
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }

    return null;
  }

  /// Validates age for COPPA compliance
  /// Ensures users are 13+ as required by law
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age < 13) {
      return 'You must be at least 13 years old'; // COPPA requirement
    }

    if (age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  /// Validates URLs for portfolio links and resources
  /// Optional field but must be valid if provided
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    // Basic URL regex pattern
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates user bio for profile
  /// Limits length to prevent database bloat
  static String? validateBio(String? value) {
    if (value != null && value.length > 500) {
      return 'Bio must be less than 500 characters';
    }

    return null;
  }

  /// Generic required field validation
  /// Reusable for any mandatory field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validates code submissions in code editor
  /// Prevents empty submissions and limits size
  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some code';
    }

    if (value.length > 10000) {
      return 'Code must be less than 10,000 characters';
    }

    return null;
  }

  /// Validates quiz answer selection
  /// Ensures user has selected an option
  static String? validateQuizAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an answer';
    }

    return null;
  }

  /// Validates credit card numbers using Luhn algorithm
  /// Basic validation for payment forms
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Card number is required';
    }

    // Remove spaces and dashes
    final cardNumber = value.replaceAll(RegExp(r'[\s-]'), '');

    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return 'Invalid card number';
    }

    // Luhn algorithm for credit card validation
    if (!_isValidLuhn(cardNumber)) {
      return 'Invalid card number';
    }

    return null;
  }

  /// Validates CVV security code
  /// 3 digits for most cards, 4 for American Express
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }

    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }

    return null;
  }

  /// Validates credit card expiry date
  /// Ensures card hasn't expired
  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Invalid format (MM/YY)';
    }

    // Check if card is expired
    final parts = value.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');
    final now = DateTime.now();

    if (year < now.year || (year == now.year && month < now.month)) {
      return 'Card has expired';
    }

    return null;
  }

  /// Luhn algorithm implementation for credit card validation
  /// Standard checksum formula used by payment cards
  static bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    // Process digits from right to left
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Validates file size for uploads
  /// Prevents server overload from large files
  static String? validateFileSize(int sizeInBytes, int maxSizeInMB) {
    final sizeInMB = sizeInBytes / (1024 * 1024);

    if (sizeInMB > maxSizeInMB) {
      return 'File size must be less than ${maxSizeInMB}MB';
    }

    return null;
  }

  /// Validates file extensions for security
  /// Prevents upload of potentially dangerous file types
  static String? validateFileExtension(
      String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return 'Invalid file type. Allowed: ${allowedExtensions.join(', ')}';
    }

    return null;
  }

  /// Getter for required field validator
  /// Provides convenient access for form fields
  static String? Function(String?) get required => (String? value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };
}
