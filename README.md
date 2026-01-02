# **Case Zero: Detective Investigation Game**  

## **🎮 Project Overview**  
**Case Zero** is an immersive detective investigation game built with Flutter and Firebase. Players become detectives solving complex criminal cases through interactive crime scene investigation, forensic analysis, and logical puzzle-solving.


---

## **📱 Features**

### **🔐 Authentication & User Management**
- Email/Password authentication with Firebase
- Google Sign-In integration
- User profile management with detective rankings
- Terms & Privacy policy enforcement

### **🕵️ Investigation Gameplay**
- Interactive crime scenes with hidden clues
- Evidence collection and analysis system
- Witness interview system with branching dialogue
- Case progress tracking and statistics
- Detective ranking system (Novice → Master Detective)

### **📊 Dashboard & Analytics**
- Real-time progress tracking
- Performance metrics (accuracy, efficiency, time spent)
- Achievement system with 50+ accomplishments
- Statistics visualization

### **🎨 UI/UX Features**
- Noir detective theme with neon accents
- Glass morphism design elements
- Responsive layout for all screen sizes
- Smooth animations and transitions
- Accessibility features (colorblind mode, adjustable text)

### **⚙️ Technical Features**
- Riverpod state management
- Firebase Firestore real-time sync
- Huawei Mobile Services ready
- Offline capability with cloud backup
- Multi-language architecture

---

## **🛠️ Tech Stack**

| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform mobile framework |
| **Dart 3.x** | Programming language |
| **Firebase** | Backend services (Auth, Firestore) |
| **Riverpod** | State management |
| **Go Router** | Navigation and routing |
| **HMS Core** | Huawei Mobile Services (future) |

---

## **🚀 Getting Started**

### **Prerequisites**
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Firebase account
- Java JDK 11+

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/case-zero-detective.git
   cd case-zero-detective
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase
   firebase init
   ```

4. **Configure Firebase**
   - Create a new Firebase project
   - Enable Authentication (Email/Password, Google)
   - Create Firestore database
   - Download `google-services.json` to `android/app/`
   - Configure Firebase rules (see `firebase_rules.md`)

5. **Configure Huawei (Optional)**
   ```bash
   # For Huawei AppGallery deployment
   # Follow HMS Core integration guide
   ```

6. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release build
   flutter build apk --release
   ```

---

## **📁 Project Structure**

```
lib/
├── core/
│   ├── constants/          # App colors, images, strings
│   ├── providers/          # Riverpod providers
│   ├── services/           # Business logic (Auth, Firestore)
│   ├── theme/              # App theming
│   └── utils/              # Validators, helpers
├── features/
│   ├── auth/               # Login, signup, password reset
│   ├── dashboard/          # Main dashboard screen
│   ├── cases/              # Case list and gameplay
│   ├── profile/            # User profile and achievements
│   └── settings/           # App settings
├── widgets/                # Reusable UI components
└── main.dart               # App entry point
```

---

## **🔥 Firebase Configuration**

### **Firestore Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /cases/{caseId} {
      allow read: if request.auth != null;
    }
    match /progress/{userId}/{caseId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **Authentication Setup**
1. Enable Email/Password authentication
2. Enable Google Sign-In
3. Configure authorized domains
4. Set up password reset templates

---

## **📦 Dependencies**

Key packages used:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.14.0
  cloud_firestore: ^4.15.1
  google_sign_in: ^6.1.5
  flutter_riverpod: ^2.4.9
  go_router: ^12.1.5
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

---

## **🎯 Development Guidelines**

### **Code Style**
- Follow Dart/Flutter best practices
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

### **Commit Convention**
```
feat:     New feature
fix:      Bug fix
docs:     Documentation
style:    Code formatting
refactor: Code restructuring
test:     Adding tests
chore:    Maintenance tasks
```

### **Branch Strategy**
```
main        → Production ready
develop     → Development branch
feature/*   → New features
bugfix/*    → Bug fixes
release/*   → Release preparation
```

---

## **🧪 Testing**

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

---

## **📱 Build & Deployment**

### **Android APK**
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle
```

### **Huawei AppGallery**
1. Generate signing certificate
2. Configure HMS Core in project
3. Build with Huawei dependencies
4. Submit to AppGallery console

### **Versioning**
Follow semantic versioning: `MAJOR.MINOR.PATCH`
- `1.0.0` - Initial release
- `1.1.0` - New features
- `1.1.1` - Bug fixes


---

## **🤝 Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## **📄 License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## **👥 Team**

- **Zunaina Yasir** - Project Lead & Developer

---

## **📞 Support & Contact**

- **Email:** zyasir444@gmail.com
- **Support:** support@casezero.pk
- **Issues:** [GitHub Issues](https://github.com/yourusername/case-zero-detective/issues)

---

## **🎯 Roadmap**

- [x] Authentication system
- [x] Basic investigation gameplay
- [x] Dashboard and statistics
- [x] Terms & Privacy compliance
-

---



---

## **💡 Acknowledgments**

- Flutter & Dart teams for amazing framework
- Firebase for backend services
- Riverpod community for state management solutions
- Open source contributors of used packages

---

## **⭐ Show Your Support**

If you find this project useful, please give it a star ⭐ on GitHub!

---

**Happy Investigating!** 🕵️‍♀️🕵️‍♂️

*"Every clue matters, every detail counts."*
