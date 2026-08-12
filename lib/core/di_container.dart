import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:memory_notes/core/constants/hive_keys.dart';
import 'package:memory_notes/core/services/audio_playback_coordinator.dart';
import 'package:memory_notes/core/services/audio_recorder_controller.dart';
import 'package:memory_notes/core/services/audio_recorder_file_helper.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_cubit.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:memory_notes/features/notes/cubit/notes_cubit.dart';
import 'package:memory_notes/features/notes/data/notes_repo.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_cubit.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_repository.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_note_context.dart';
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
  sl.registerLazySingleton<http.Client>(http.Client.new);

  // ── Repos (Singletons) ────────────────────────────────────────────
  sl.registerLazySingleton<NotesRepo>(
    () => NotesRepo(sl<Box<NoteModel>>(), sl<AudioRecorderFileHelper>()),
  );
  sl.registerLazySingleton<VoiceAnalysisRepository>(
    () => VoiceAnalysisRepository(
      sl<http.Client>(),
      noteContextProvider: () {
        return sl<Box<NoteModel>>().values
            .where((note) => note.title.trim().isNotEmpty || note.hasAnyContent)
            .take(20)
            .map(
              (note) => VoiceNoteContext(
                title: note.title.trim(),
                // Keep the context bounded so voice analysis stays fast and private.
                text: _truncateContext(note.text ?? '', 400),
              ),
            )
            .toList(growable: false);
      },
    ),
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
  sl.registerFactory<VoiceAnalysisCubit>(
    () => VoiceAnalysisCubit(sl<VoiceAnalysisRepository>()),
  );
}

String _truncateContext(String value, int maxLength) {
  final trimmed = value.trim();
  return trimmed.length <= maxLength
      ? trimmed
      : trimmed.substring(0, maxLength);
}
