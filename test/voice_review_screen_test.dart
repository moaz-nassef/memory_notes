import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:memory_notes/core/services/audio_recorder_controller.dart';
import 'package:memory_notes/core/services/audio_recorder_file_helper.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_cubit.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_cubit.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_repository.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';
import 'package:memory_notes/features/voice_analysis/views/voice_review_screen.dart';
import 'package:memory_notes/models/note_model.dart';

void main() {
  testWidgets('edits an analysis result before saving the note', (
    tester,
  ) async {
    NoteModel? savedNote;
    final analysis = VoiceAnalysisResult.fromJson({
      'title': 'عنوان مقترح',
      'text': 'اتصل بأحمد وحدد الاجتماع',
      'tasks': [
        {'title': 'اتصل بأحمد', 'durationMinutes': 30},
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<VoiceAnalysisCubit>(
              create: (_) => VoiceAnalysisCubit(_testRepository()),
            ),
            BlocProvider<AddNoteCubit>(
              create: (_) => AddNoteCubit(
                AudioRecorderController(AudioRecorderFileHelper()),
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () async {
                  savedNote = await Navigator.of(context).push<NoteModel>(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider<VoiceAnalysisCubit>.value(
                            value: context.read<VoiceAnalysisCubit>(),
                          ),
                          BlocProvider<AddNoteCubit>.value(
                            value: context.read<AddNoteCubit>(),
                          ),
                        ],
                        child: VoiceReviewScreen(
                          analysis: analysis,
                          audioPaths: const [],
                          audioDurationsMs: const [],
                          imagePaths: const [],
                          initialTitle: '',
                          initialText: '',
                          initialTasks: const [],
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Open review'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();

    final titleField = find.descendant(
      of: find.byKey(const Key('voice_review_title')),
      matching: find.byType(TextField),
    );
    await tester.ensureVisible(titleField);
    await tester.enterText(titleField, 'عنوان عدله المستخدم');

    final addTaskButton = find.byKey(const Key('voice_review_add_task'));
    await tester.ensureVisible(addTaskButton);
    await tester.tap(addTaskButton);
    await tester.pump();
    final taskOneField = find.byKey(const Key('voice_review_task_1'));
    await tester.ensureVisible(taskOneField);
    await tester.enterText(taskOneField, 'أرسل موعد الاجتماع');

    final saveButton = find.byKey(const Key('voice_review_save'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(savedNote, isNotNull);
    expect(savedNote!.title, 'عنوان عدله المستخدم');
    expect(savedNote!.text, 'اتصل بأحمد وحدد الاجتماع');
    expect(savedNote!.checklist!.map((task) => task.title), [
      '30 min - اتصل بأحمد',
      'أرسل موعد الاجتماع',
    ]);
  });
}

VoiceAnalysisRepository _testRepository() {
  return VoiceAnalysisRepository(
    MockClient((request) async => http.Response('{}', 200)),
  );
}
