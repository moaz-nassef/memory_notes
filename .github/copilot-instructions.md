# Memory Notes - AI Coding Assistant Instructions

## Project Overview
Flutter notes app (local-first, no backend) supporting text, images, audio recordings, and checklists. Targets iOS, Android, macOS, Windows, Linux, Web.

## Architecture: Feature-First + BLoC (Cubit) + Repository + GetIt DI

```
View → Cubit (state) → Repo (business logic) → Hive box (local storage)
```

### Structure
- **[lib/main.dart](../lib/main.dart)**: Hive init → `initDi()` → `BlocProvider<NotesCubit>` → MaterialApp
- **[lib/app_router.dart](../lib/app_router.dart)**: Named routes via `onGenerateRoute`; `/add-note` accepts an optional `NoteModel` argument for edit mode
- **lib/core/**
  - `constants/` - `AppColors` (note palette, gradients), `HiveKeys` (box name + typeIds)
  - `services/` - `AudioRecorderController` (record/pause/stop + amplitude & duration streams), `AudioRecorderFileHelper` (file storage under app docs/records_note)
  - `theme/app_theme.dart` - dark `ThemeData`
  - `di_container.dart` - GetIt `sl`: singletons (services, box, repo, NotesCubit), factories (AudioRecorderController, AddNoteCubit)
- **lib/features/** - one folder per feature: `cubit/` + `data/` + `views/` + `widgets/`
  - `notes/` - list screen: `NotesCubit` watches `NotesRepo.watchNotes()` stream; sealed states `NotesInitial/Loading/Loaded/Error`
  - `add_note/` - editor: `AddNoteCubit` owns the recorder + form state (`AddNoteState` = single immutable state + copyWith; one-shot `snackMessage`/`savedNote` consumed by BlocListener then cleared)
- **lib/models/** - Hive models (`NoteModel` typeId 0, `TaskModel` typeId 1) with generated `.g.dart` adapters
- **lib/shared/** - reusable widgets (audio player, voice overlay, color picker, image widgets, text fields, checklist preview, `showCustomSnack`)

### Key Conventions
- **Never** call `Hive.box` or `note.save()/delete()` from views — go through `NotesCubit`/`NotesRepo`
- New feature = new folder under `lib/features/` with the 4 sub-layers
- New shared widget → `lib/shared/`; new color/box key → `lib/core/constants/`
- New dependency → register in `lib/core/di_container.dart` (singleton for services/repos, factory for per-screen cubits)
- Route args: `Navigator.pushNamed(context, AppRoutes.addNote, arguments: note)`

## Development Workflow
- **Run**: `flutter run` | **Analyze**: `flutter analyze` (flutter_lints) | **Test**: `flutter test`
- **Regenerate Hive adapters** after changing model fields: `dart run build_runner build --delete-conflicting-outputs`
- Audio recording needs mic permission (handled via `permission_handler` in `AudioRecorderController`)

## Gotchas
- `NoteModel.rawChecklist` is `dynamic` for backward-compatible Hive migration — always use the `checklist` getter/setter
- `Box.listenable()` returns `ValueListenable` (hive_flutter), not a Stream — `NotesRepo.watchNotes()` already converts it
- `test/` contains pure model unit tests; widget tests that pump `MyApp` need Hive initialized first (use `Hive.init` with a temp dir)
