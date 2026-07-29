import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:memory_notes/core/constants/hive_keys.dart';
import 'package:memory_notes/core/services/audio_playback_coordinator.dart';
import 'package:memory_notes/core/services/audio_recorder_controller.dart';
import 'package:memory_notes/core/services/audio_recorder_file_helper.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_cubit.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:memory_notes/features/notes/cubit/notes_cubit.dart';
import 'package:memory_notes/features/notes/data/notes_repo.dart';
import 'package:memory_notes/models/note_model.dart';

/// Service locator (GetIt).
final sl = GetIt.instance;

/// Registers all app dependencies.
///
/// Call after Hive boxes are opened (see [main]).
void initDi() {
  // ── Core / Services (Singletons) ──────────────────────────────────
  sl.registerLazySingleton<AudioRecorderFileHelper>(
    () => AudioRecorderFileHelper(),
  );
  sl.registerLazySingleton<AudioPlaybackCoordinator>(
    () => AudioPlaybackCoordinator(),
  );
  sl.registerLazySingleton<Box<NoteModel>>(
    () => Hive.box<NoteModel>(HiveKeys.notesBox),
  );

  // ── Repos (Singletons) ────────────────────────────────────────────
  sl.registerLazySingleton<NotesRepo>(
    () => NotesRepo(sl<Box<NoteModel>>(), sl<AudioRecorderFileHelper>()),
  );

  // ── Cubits ────────────────────────────────────────────────────────
  // App-wide list cubit → singleton.
  sl.registerLazySingleton<NotesCubit>(() => NotesCubit(sl<NotesRepo>()));
  sl.registerLazySingleton<ConnectivityCubit>(() => ConnectivityCubit());

  // Per-screen → factories (fresh instance every time).
  sl.registerFactory<AudioRecorderController>(
    () => AudioRecorderController(sl<AudioRecorderFileHelper>()),
  );
  sl.registerFactory<AddNoteCubit>(
    () => AddNoteCubit(sl<AudioRecorderController>()),
  );
}
