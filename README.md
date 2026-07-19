# Offline Notes 📝

A robust, offline-first note-taking application built with Flutter.

## 🚀 Features

- **Offline First**: Write and access your notes anytime, anywhere. Your data is stored locally using [Hive](https://pub.dev/packages/hive), a fast and lightweight NoSQL database.
- **Masonry Layout**: Beautifully organized notes using `flutter_staggered_grid_view` for a modern look.
- **State Management**: Scalable and predictable state management using `flutter_bloc`.
- **Network Awareness**: Monitors connectivity status via `connectivity_plus` to handle data synchronization intelligently.
- **API Integration**: Ready for backend synchronization using `dio`.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [equatable](https://pub.dev/packages/equatable)
- **Local Database**: [Hive](https://pub.dev/packages/hive_flutter)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Connectivity**: [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- **UI Components**: [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)

## 📦 Getting Started

### Prerequisites

- Flutter SDK (v3.11.5 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone <your-repository-url>
   ```

2. Navigate to the project directory:
   ```bash
   cd offline_notes
   ```

3. Install the dependencies:
   ```bash
   flutter pub get
   ```

4. Run the code generation (for Hive):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## 📁 Project Structure

```text
lib/
├── blocs/          # BLoC state management (events, states, blocs)
├── models/         # Data models and Hive type adapters
├── repositories/   # Data repositories
├── screens/        # UI screens (e.g., HomeScreen)
├── services/       # API and local storage services
├── theme/          # App themes and styling
├── widgets/        # Reusable UI components
└── main.dart       # Application entry point
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## 📄 License

This project is licensed under the MIT License.
