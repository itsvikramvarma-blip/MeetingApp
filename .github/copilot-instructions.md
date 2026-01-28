<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Flutter Meeting App

This is a Flutter mobile application for managing meetings. The app allows users to add and view meetings with a simple, clean interface.

## Project Structure

- `lib/main.dart` - Main application entry point with meeting management functionality
- `pubspec.yaml` - Project dependencies and configuration
- `test/widget_test.dart` - Widget tests for the application
- `.vscode/tasks.json` - VS Code tasks for Flutter development

## Development Setup

### Prerequisites
1. Install Flutter SDK from https://flutter.dev/docs/get-started/install
2. Ensure Flutter is added to your system PATH
3. Run `flutter doctor` to verify installation

### Getting Started
1. Install dependencies: Run the "Flutter: Get Dependencies" task or `flutter pub get`
2. Run the app: Use the "Flutter: Run App" task or `flutter run`
3. Build APK: Use the "Flutter: Build APK" task or `flutter build apk`

### VS Code Tasks Available
- **Flutter: Get Dependencies** - Downloads project dependencies
- **Flutter: Run App** - Launches the app in debug mode
- **Flutter: Build APK** - Builds an Android APK

### Features
- Add new meetings with timestamp
- View list of scheduled meetings
- Material Design 3 UI
- Responsive layout

## Debugging
Use F5 or the debug panel to launch the app in debug mode once Flutter is properly installed.