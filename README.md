# Offline Notes 📝

A highly optimized, offline-first note-taking application built with Flutter, demonstrating best practices in state management and clean architecture principles.

## 🏗️ Architecture & Design

This project adheres to **Clean Architecture** principles to ensure a decoupled, scalable, and maintainable codebase.

- **Presentation Layer**: Built with Flutter UI components (`widgets` and `screens`). It solely listens to states and delegates user actions to BLoCs.
- **Domain/State Management Layer**: Powered by `flutter_bloc`. It encapsulates the business logic, processing events, and emitting predictable states.
- **Data Layer**: Contains `repositories` and `services`. It abstracts the data sources (local database vs. remote API), providing a single source of truth for the app.

### State Management: BLoC Pattern
The application uses the **BLoC (Business Logic Component)** pattern for robust state management.
- **Separation of Concerns**: UI components are completely decoupled from business logic.
- **Predictability**: State changes are strictly driven by discrete events.
- **Testing**: Business logic can be easily unit tested without mocking the UI.
- `equatable` is used extensively to optimize state comparisons and prevent unnecessary widget rebuilds.

## ⚡ Performance & Optimization

- **Offline-First Strategy**: The app prioritizes local data reads/writes using [Hive](https://pub.dev/packages/hive), a remarkably fast, lightweight NoSQL database. This ensures instant load times and zero network-latency bottlenecks for the user.
- **Efficient UI Rebuilds**: Uses localized `BlocBuilder` and `BlocListener` to rebuild only the necessary parts of the widget tree.
- **Masonry Layout**: Implements `flutter_staggered_grid_view` to render dynamically sized notes efficiently without jank.
- **Smart Synchronization**: Listens to network state changes via `connectivity_plus` and synchronizes data with the backend using `dio` only when an active connection is established, saving battery and bandwidth.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) & [equatable](https://pub.dev/packages/equatable)
- **Local Database**: [Hive](https://pub.dev/packages/hive_flutter)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Connectivity**: [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- **UI Components**: [flutter_staggered_grid_view](https://pub.dev/packages/flutter_staggered_grid_view)

## 📁 Project Structure

```text
lib/
├── blocs/          # Business logic, events, and states
├── models/         # Data models and Hive type adapters
├── repositories/   # Data repositories handling data orchestration
├── screens/        # Presentation layer screens
├── services/       # Remote APIs and local storage interfaces
├── theme/          # App-wide theming and design tokens
├── widgets/        # Reusable, stateless UI components
└── main.dart       # Application entry point and dependency injection
```

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

4. Run the code generation (for Hive type adapters):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## 📄 License

This project is licensed under the MIT License.
