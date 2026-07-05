# Task Manager Pro — Agent Guide

## Product

**Task Manager Pro** is an offline-first task manager assignment app. All task, category, filter, sort, and theme data lives on-device. There is no network layer.

## Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| Architecture | Clean Architecture + DDD |
| DI | get_it |
| State | flutter_bloc |
| Functional errors | dartz (`Either<Failure, T>`) |
| Value equality | equatable |
| Persistence | Hive (+ hive_flutter) |

## Non-Goals

- **No tests** — do not write unit, widget, or integration tests (only `flutter_lints` in dev_dependencies).
- **No network layer** — no HTTP clients, APIs, or remote sync.
- **No over-engineering** — one use case per user action; no premature abstractions or unused indirection.

## Dependency Flow

```
Presentation → UseCase → Repository (interface) → RepositoryImpl → DataSource → Hive
```

| Layer | May depend on | Must NOT depend on |
|-------|---------------|-------------------|
| `domain/` | Pure Dart only | Flutter, Hive, get_it |
| `data/` | domain, Hive | presentation |
| `presentation/` | domain, core | Hive, datasources directly |
| `core/` | shared utilities | feature-specific code |

## Folder Layout

```
lib/
  core/
    constants/     # AppStrings, AppAssets, AppKeys, Hive box names
    di/            # injection.dart, register modules
    errors/        # Failure, ErrorMapper
    theme/         # AppColors, AppTypography, AppSpacing, AppTheme (light/dark)
    routing/       # AppRouter, custom transitions
    utils/         # debouncer, date helpers, extensions
  features/
    tasks/
      domain/entities|repositories|usecases/
      data/datasources|models|repositories/
      presentation/bloc|pages|widgets/
    categories/
    filters/
    settings/      # theme toggle persistence
  app.dart
  bootstrap.dart
  main.dart
```

## Package Policy

Before adding dependencies, run `flutter pub outdated` and prefer latest stable compatible versions:

- **Required:** `flutter_bloc`, `equatable`, `dartz`, `get_it`, `hive`, `hive_flutter`, `intl`, `uuid`
- **Optional bonus:** `flutter_local_notifications`
- **Dev only:** `flutter_lints` — no other test-only packages

## Assignment Features (reference — implement later)

- CRUD tasks with Hive persistence
- Categories + filters persisted
- Drag reorder with `sortIndex` persisted immediately
- Animated FAB (expand/collapse)
- Swipe-to-delete with undo SnackBar + visible countdown timer
- Progress ring for today's completion %
- Theme toggle (light/dark) persisted in settings
- Custom page transitions (no default `MaterialPageRoute`)
- Offline-first; repository pattern; no main-thread DB blocking
- 100+ task scroll performance; undo restores exact task at exact position

## Cursor Rules & Commands

| Resource | Purpose |
|----------|---------|
| `.cursor/rules/00-architecture-master.mdc` | Layer boundaries, SOLID, package policy |
| `.cursor/rules/01-constants-theme.mdc` | No magic strings/colors in widgets |
| `.cursor/rules/02-bloc-pattern.mdc` | Bloc file structure and Either folding |
| `.cursor/rules/03-dependency-injection.mdc` | get_it registration patterns |
| `.cursor/rules/04-errors-dartz.mdc` | Failure hierarchy, ErrorMapper |
| `.cursor/rules/05-data-hive.mdc` | Hive persistence rules |
| `.cursor/rules/06-ui-animations.mdc` | FAB, swipe undo, progress ring, transitions |
| `.cursor/rules/07-forbidden-patterns.mdc` | Hard bans (setState, Cubit, tests, etc.) |
| `.cursor/commands/scaffold-feature.md` | Scaffold a new feature folder |
| `.cursor/commands/add-usecase.md` | Add a use case + DI + Bloc wiring |
| `.cursor/commands/review-architecture.md` | Audit changes against all rules |
| `.cursor/commands/verify-assignment.md` | Checklist against assignment rubric |

## Bootstrap Order

1. `main.dart` → `bootstrap.dart` (Hive init, `configureDependencies()`)
2. `app.dart` (theme loaded before first frame — no white flash)
3. `runApp`

## Domain conventions

### Repository reads (Future vs Stream)

Domain repositories use **pull-based** `Future<Either<Failure, T>>` for list reads (e.g. `TaskRepository.getTasks`). There are no domain `Stream`s or `watch*` methods. Presentation reloads task data via Bloc events after create, update, delete, reorder, or filter changes.

### Domain invariants

- **sortIndex** — 0-based, contiguous across the full ordered list after every reorder. Data layer persists immediately on reorder.
- **Soft-delete buffer** — `deleteTask` removes the task from the active list and returns a full `Task` snapshot (including original `sortIndex`). `restoreTask` reinserts that snapshot at the exact position. The undo countdown window is a presentation concern (`AppDurations.undoCountdown`).
- **Categories** — fixed presets (Work / Personal / Urgent) defined in `core/constants/category_constants.dart` and `TaskCategory.defaults`. No custom category CRUD (YAGNI).
- **Theme** — domain uses `AppThemePreference` (pure Dart). Maps to Flutter `ThemeMode` only in presentation via `ThemeModeMapper`.
