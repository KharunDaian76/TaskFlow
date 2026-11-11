# TaskFlow 2.0

A Flutter task manager with Dashboard, Tasks, Planner and Settings.

## Features

- Dashboard with task progress and statistics
- Task list with search, filters, add, edit, complete and delete
- Planner with a calendar and temporary task-to-date assignments
- Settings with light and dark mode
- DummyJSON REST API with Dio, Retrofit and async/await
- flutter_bloc state management
- JSON serialization with generated code
- Simple data/domain/presentation layers

DummyJSON is a mock API. Task changes are not permanently saved on its server. Planner dates and theme selection are kept only in app memory.

## Local run

```bash
flutter create --platforms=android,ios,web .
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run -d edge
```

To run Android, use `flutter run -d emulator-5554` with a running emulator.

## Docker

```bash
docker compose up --build
```

Open http://localhost:8080 after the build completes. Docker builds Flutter Web and serves it using Nginx. The first build downloads Flutter SDK and can take a long time. Docker has not been verified end-to-end in this environment.

## Project structure

- `lib/data` API, models and repository implementation
- `lib/domain` repository contract
- `lib/presentation/bloc` BLoC, events and state
- `lib/presentation/pages` application screens

Generated `.g.dart` files are created by build_runner and should not be edited manually.
