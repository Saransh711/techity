# Task Manager Pro

Offline-first task manager built with Flutter 3.x, Clean Architecture, and Hive persistence. No network layer — the app is fully functional in airplane mode.

## How to Run

```bash
flutter pub get
flutter run
```

**Debug scroll test:** In debug builds, tap the bug icon in the app bar to seed 100 tasks for scroll performance verification.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation                           │
│  Pages · Widgets · Bloc (events → states)                   │
└──────────────────────────┬──────────────────────────────────┘
                           │ UseCases only
┌──────────────────────────▼──────────────────────────────────┐
│                        Domain                               │
│  Entities · Repository interfaces · UseCases (pure Dart)    │
└──────────────────────────┬──────────────────────────────────┘
                           │ Either<Failure, T>
┌──────────────────────────▼──────────────────────────────────┐
│                         Data                                │
│  RepositoryImpl · DataSources · Hive models/adapters        │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    Hive (on-device)                         │
│  tasks · filters · settings boxes                           │
└─────────────────────────────────────────────────────────────┘
```

**Bootstrap order:** `main.dart` → `bootstrap.dart` (Hive init, DI) → `app.dart` (theme resolved before first frame).

**Dependency injection:** `get_it` via `configureDependencies()` in `lib/core/di/injection.dart`.

## Features

| Feature | Description |
|---------|-------------|
| Task CRUD | Create, read, update, delete with Hive persistence |
| Categories | Fixed presets (Work / Personal / Urgent) |
| Filters | Status, category, due date — persisted across sessions |
| Drag reorder | `sortIndex` persisted immediately via batched writes |
| Swipe-to-delete | Undo SnackBar with visible 5s countdown timer |
| Progress ring | Today's due-date completion percentage |
| Animated FAB | Expand/collapse with filter shortcut |
| Theme toggle | Light / dark / system — persisted, no white flash on cold start |
| Custom transitions | No default `MaterialPageRoute` |
| Undo restore | Restores exact task data at original `sortIndex` |

## Project Structure

```
lib/
├── core/           # constants, theme, routing, DI, errors
├── features/
│   ├── tasks/      # task CRUD, reorder, progress
│   ├── filters/    # active filter persistence
│   ├── settings/   # theme preference
│   └── shell/      # home page shell
├── app.dart
├── bootstrap.dart
└── main.dart
```

## Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| State | flutter_bloc |
| DI | get_it |
| Errors | dartz (`Either<Failure, T>`) |
| Persistence | Hive + hive_flutter |
| Equality | equatable |

## Splash / Theme Alignment

Native splash backgrounds match `AppColors.lightBackground` (#F8FAFC) and `AppColors.darkBackground` (#0F172A) on both Android and iOS. Theme preference is read synchronously in `bootstrap.dart` before `runApp` to prevent a white flash on cold start.
