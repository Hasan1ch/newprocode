# ProCode - AI-Powered Programming Learning App

<p align="center">
  <img src="assets/logo.png" alt="ProCode Logo" width="200"/>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#usage">Usage</a> •
  <a href="#technologies">Technologies</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

## 📱 About ProCode

ProCode is an innovative mobile application designed to revolutionize programming education through AI-powered personalized learning experiences. Built with Flutter for cross-platform compatibility, ProCode combines gamification elements with intelligent tutoring to make coding education more accessible and engaging for learners of all levels.

## ✨ Features

- **AI-Powered Learning Assistant**: Personalized guidance using Google's Gemini AI
- **Interactive Code Editor**: Write, test, and debug code directly in the app
- **Gamified Learning Path**: Earn points, badges, and track progress
- **Multi-Language Support**: Learn Python, JavaScript, Java, and more
- **Smart Quiz System**: Adaptive questions based on your learning progress
- **Real-time Code Analysis**: Instant feedback and suggestions
- **Progress Tracking**: Detailed analytics of your learning journey

## 🚀 Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / Xcode (for mobile development)
- Git
- Firebase CLI (for backend services)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/Hasan1ch/newprocode.git
   cd newprocode
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install Firebase CLI if not already installed
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   flutterfire configure
   ```

4. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   FIREBASE_PROJECT_ID=your_project_id
   ```

5. **Run the application**
   
   For Android:
   ```bash
   flutter run
   ```
   
   For iOS:
   ```bash
   flutter run -d ios
   ```
   
   For Web:
   ```bash
   flutter run -d chrome
   ```

## 📖 Usage

### First Time Setup

1. Launch the ProCode app
2. Create an account or sign in with Google
3. Complete the initial skill assessment
4. Choose your preferred programming language
5. Start your personalized learning journey

### Key Features Usage

- **Learning Modules**: Navigate to the "Learn" tab to access structured lessons
- **Practice Mode**: Use the code editor to practice with guided exercises
- **AI Advisor**: Click the AI assistant button for personalized help
- **Progress Dashboard**: View your statistics and achievements in the "Profile" section

## 🛠️ Technologies

- **Frontend**: Flutter & Dart
- **Backend**: Firebase (Firestore, Authentication, Cloud Functions)
- **AI Integration**: Google Gemini AI API
- **State Management**: Provider/Riverpod
- **Database**: Cloud Firestore
- **Authentication**: Firebase Auth
- **Code Editor**: Flutter Code Editor package
- **Analytics**: Firebase Analytics

## 📱 Supported Platforms

- ✅ Android (5.0+)
- ✅ iOS (11.0+)
- ✅ Web (Chrome, Safari, Firefox)
- 🚧 Desktop (Windows, macOS, Linux) - Coming Soon

## 🤝 Contributing

We welcome contributions to ProCode! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter's [style guide](https://flutter.dev/docs/development/tools/formatting)
- Write unit tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## 🧪 Testing

Run the test suite:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Generate coverage report
flutter test --coverage
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Hasan** - Lead Developer - [GitHub](https://github.com/Hasan1ch)

## 🙏 Acknowledgments

- University supervisor for guidance and support
- Beta testers for valuable feedback
- Open source community for amazing packages
- Google for Gemini AI access

## 📞 Contact

For questions or support, please email: hkadirov.com@gmail.com

---

<p align="center">Made with ❤️ by Hasan</p>
