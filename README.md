# Task Manager Pro

Offline-first task manager built with Flutter 3.x, Clean Architecture, and Hive persistence. No network layer — the app is fully functional in airplane mode.

## How to Run

**Prerequisites:** Flutter 3.x (Dart SDK ^3.12), Xcode (iOS) or Android Studio / SDK (Android). Verify with `flutter doctor`.

```bash
git clone https://github.com/Saransh711/techity.git
cd techity
flutter pub get
flutter run
```

Pick a connected device or emulator when prompted. No `.env` file or API keys are required — all data is stored on-device via Hive.

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

### Why flutter_bloc?

This app has many asynchronous, user-driven flows — task CRUD, drag reorder, filter changes, swipe-to-delete with a timed undo window, and search debouncing. **Bloc** fits that shape because every user action is an explicit **event**, and the UI reacts to immutable **states** emitted after use cases complete.

| Approach | Why not here |
|----------|--------------|
| **`setState`** | Business logic would live inside widgets. Hard to trace, test, or reuse across screens (e.g. undo countdown + list reload after delete). |
| **Provider** | Works for simple value propagation, but lacks a first-class event model for multi-step async flows and side effects. |
| **Riverpod** | Strong for dependency graphs and compile-time safety, but adds codegen / provider-tree complexity that is unnecessary for a fully offline, Hive-backed app of this size. |
| **flutter_bloc** | Event → handler → state maps cleanly onto Clean Architecture: Blocs call **use cases only**, never repositories or Hive directly. `BlocProvider` composes well with `get_it`, and event logs make complex flows (reorder, restore, filter) easy to follow during review. |

Local UI-only concerns (text field focus, animation controllers, search debounce timers) stay in widgets — business state never uses `setState`.

### Why this folder structure?

The project is organised **by feature** under `lib/features/`, with **Clean Architecture layers inside each feature**:

```
features/<feature>/
├── domain/       # entities, repository contracts, use cases (pure Dart)
├── data/         # Hive models, datasources, repository implementations
└── presentation/ # blocs, pages, widgets
```

**`core/`** holds cross-cutting code shared by every feature — theme, routing, constants, DI, and error mapping — so features do not import each other’s internals.

This layout keeps domain rules testable in isolation, makes it obvious where to add a new capability (e.g. a new use case in `domain/usecases/`), and scales without a single monolithic `lib/` dump as features grow.

## Trade-offs

Deliberate simplifications made to keep the codebase focused and maintainable:

| Decision | Trade-off | Reasoning |
|----------|-----------|-----------|
| **Offline-only, no network layer** | No sync, multi-device, or remote backup | Assignment scope is on-device task management. Hive gives fast reads/writes without HTTP, auth, or conflict resolution. |
| **Fixed categories** (Work / Personal / Urgent) | Users cannot create custom categories | Covers filtering and visual grouping without category CRUD, validation, and migration logic (YAGNI). |
| **Pull-based `Future` reads** instead of Hive `Stream`s | UI reloads via Bloc events after mutations rather than reactive auto-updates | Simpler mental model for a small dataset; explicit reload points after create, update, delete, reorder, and filter changes. |
| **One use case per user action** | More files than a single “task service” | Each action (`CreateTask`, `ReorderTasks`, `RestoreTask`, …) has a single responsibility and a clear Bloc → use case boundary. |
| **Undo window in presentation** | Countdown timer is not persisted | Soft-delete snapshot is stored in the repository; the 5-second undo SnackBar is a UI concern. If the app is killed, the delete is already persisted — acceptable for this scope. |
| **`get_it` service locator** instead of Riverpod for DI | Less compile-time wiring safety | Straightforward registration in one file (`injection.dart`); Blocs receive use cases via constructor injection without a parallel provider graph. |
| **Hive over SQLite** | No relational queries or migrations at SQL scale | Task documents map naturally to key–value boxes; batched writes on reorder are fast and simple. |
| **No automated tests** | Regression safety relies on manual verification | Assignment excludes test packages beyond `flutter_lints`; a debug seed (100 tasks) supports scroll performance checks instead. |
| **Local notifications (bonus)** | Platform permission prompts; schedules are not synced | Optional reminder scheduling via `flutter_local_notifications` — scoped to due-date alerts, not a full notification platform. |

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
| Due-date reminders | Local notifications for tasks with a due date (optional bonus) |

## Project Structure

```
lib/
├── core/           # constants, theme, routing, DI, errors
├── features/
│   ├── tasks/      # task CRUD, reorder, progress
│   ├── filters/    # active filter persistence
│   ├── settings/   # theme preference
│   ├── reminders/  # local notification scheduling (bonus)
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
