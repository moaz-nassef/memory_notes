# Memory Notes - AI Coding Assistant Instructions

## Project Overview
This is a Flutter application (currently a boilerplate starter) targeting multiple platforms: iOS, Android, macOS, Windows, Linux, and Web. The app follows Flutter's standard project structure with platform-specific code in platform folders.

## Architecture & Key Components

### Dart/Flutter Structure
- **[lib/main.dart](../lib/main.dart)**: Entry point with `MyApp` (root StatelessWidget) and `MyHomePage` (stateful demo widget)
- **lib/**: All Dart source code (currently minimal - just main.dart with a counter demo)
- **Test Suite**: [test/widget_test.dart](../test/widget_test.dart) - widget testing examples

### Platform Code
- **Android**: `android/app/src/` - Java/Kotlin native code and resources
- **iOS/macOS**: `ios/` and `macos/` - Swift/Objective-C code, includes `AppDelegate` and `GeneratedPluginRegistrant`
- **Windows/Linux**: `windows/` and `linux/` - C++ runner code with CMake build system
- **Web**: `web/` - HTML entry point (index.html) with web manifest and icons

### Configuration
- **[pubspec.yaml](../pubspec.yaml)**: Dependencies (flutter SDK ^3.7.0, cupertino_icons) and build metadata
- **[analysis_options.yaml](../analysis_options.yaml)**: Dart/Flutter lint rules using `package:flutter_lints`

## Development Workflow

### Building & Running
- **Debug**: `flutter run` (hot reload enabled)
- **Release**: `flutter build [android|ios|linux|macos|web|windows]`
- **Analyze**: `flutter analyze` (validates against lint rules in analysis_options.yaml)
- **Test**: `flutter test` (runs widget tests)

### Hot Reload Convention
Flutter's hot reload preserves app state - use **hot restart** to reset state between test runs. This is mentioned in code comments and critical for development velocity.

### Platform-Specific Concerns
- **Android**: Uses Gradle build system (gradle.properties, build.gradle.kts)
- **iOS/macOS**: Xcode projects with cocoapods support via GeneratedPluginRegistrant
- **Web**: Standard Flutter web build outputs to `build/web/`

## Dart & Flutter Patterns

### Widget Structure
- **Stateless Widgets**: Immutable widgets (e.g., `MyApp`) - use for widgets that don't change
- **Stateful Widgets**: Mutable widgets (e.g., `MyHomePage`) - pair with State class
- **Naming Convention**: State classes prefixed with `_` (e.g., `_MyHomePageState`)
- **Theme Access**: Use `Theme.of(context)` for dynamic theming

### State Management (Current)
Currently using simple `setState()` callbacks. When refactoring for complexity, consider:
- Provider pattern (common in modern Flutter)
- Riverpod or BLoC if needed

### Linting & Code Style
- Lint rules enforced via flutter_lints package (see [analysis_options.yaml](../analysis_options.yaml))
- Use `// ignore: rule_name` for suppressing specific lints inline
- Run `flutter analyze` before committing

## Integration Points & Build Process

### Material Design
App uses Material 3 theme with `ColorScheme.fromSeed()` - modify `seedColor` in [lib/main.dart](../lib/main.dart) to change the app theme globally.

### Plugin System
- **Android/iOS**: `GeneratedPluginRegistrant` files auto-generated when adding Flutter packages
- **Modifying native code**: Changes in platform folders require rebuilding (invalidates hot reload cache)

### No External Dependencies Currently
Project uses only Flutter SDK and default material components - no external packages beyond cupertino_icons.

## Special Considerations

### Counter Demo State
The `_counter` in `_MyHomePageState` is the only mutable state currently. When expanding the app, follow this pattern:
1. Create StatefulWidget for interactive components
2. Define State class with mutable fields
3. Update via `setState()` callbacks

### Asset & Font Management
- **Assets**: Uncomment `assets:` section in pubspec.yaml to add images
- **Fonts**: Define custom fonts in pubspec.yaml under `flutter: fonts:`
- **Icons**: Uses Material Icons via Material Design (uses-material-design: true)

### Avoiding Common Pitfalls
- Don't call setState during build() - causes infinite loops
- Use const constructors where possible (improves performance)
- Platform-specific code changes require full rebuild (Ctrl+Shift+L in some IDEs)
- Test on actual devices/emulators, not just web browser (platform differences)

## Suggested Next Steps for Implementation
When extending this app:
1. Extract demo widgets into separate files in lib/screens/ or lib/widgets/
2. Add a data model (lib/models/) as needed
3. Implement proper dependency injection before adding multiple services
4. Consider package structure once lib/ grows beyond a few files
