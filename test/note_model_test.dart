import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';

void main() {
  NoteModel buildNote({
    String title = '',
    String? text,
    List<String>? imagePaths,
    String? audioPath,
    List<TaskModel>? checklist,
  }) {
    return NoteModel(
      title: title,
      text: text,
      imagePaths: imagePaths,
      audioPath: audioPath,
      checklist: checklist,
      createdAt: DateTime(2026, 1, 1),
      color: 0xFF667EEA,
    );
  }

  group('NoteModel.hasAnyContent / isEmpty', () {
    test('empty note has no content', () {
      expect(buildNote().hasAnyContent, isFalse);
      expect(buildNote().isEmpty, isTrue);
    });

    test('blank-only text counts as empty', () {
      expect(buildNote(text: '   ').isEmpty, isTrue);
    });

    test('any single content type counts as content', () {
      expect(buildNote(text: 'hello').hasAnyContent, isTrue);
      expect(buildNote(imagePaths: ['a.png']).hasAnyContent, isTrue);
      expect(buildNote(audioPath: 'a.m4a').hasAnyContent, isTrue);
      expect(
        buildNote(checklist: [TaskModel(title: 'task')]).hasAnyContent,
        isTrue,
      );
    });
  });

  group('NoteModel.type', () {
    test('detects single-content types', () {
      expect(buildNote(text: 'hi').type, NoteType.text);
      expect(buildNote(imagePaths: ['a.png']).type, NoteType.image);
      expect(buildNote(audioPath: 'a.m4a').type, NoteType.audio);
      expect(
        buildNote(checklist: [TaskModel(title: 'task')]).type,
        NoteType.checklist,
      );
    });

    test('multiple content types resolve to mixed', () {
      expect(buildNote(text: 'hi', audioPath: 'a.m4a').type, NoteType.mixed);
    });
  });

  group('NoteModel.copyWith', () {
    test('overrides only provided fields', () {
      final original = buildNote(
        title: 'old',
        text: 'body',
        imagePaths: ['a.png', 'b.png'],
      );

      final copy = original.copyWith(title: 'new');

      expect(copy.title, 'new');
      expect(copy.text, 'body');
      expect(copy.imagePaths, ['a.png', 'b.png']);
    });

    test('accepts a full image list', () {
      final copy = buildNote().copyWith(imagePaths: ['x.png', 'y.png']);
      expect(copy.imagePaths, ['x.png', 'y.png']);
    });
  });
}
