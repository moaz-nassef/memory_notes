import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/notes/data/notes_search.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';

void main() {
  NoteModel buildNote({
    String title = '',
    String? text,
    List<TaskModel>? checklist,
    DateTime? createdAt,
  }) {
    return NoteModel(
      title: title,
      text: text,
      checklist: checklist,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
      color: 0xFF667EEA,
    );
  }

  group('normalizeSearchText', () {
    test('lowercases and trims', () {
      expect(normalizeSearchText('  Hello World  '), 'hello world');
    });

    test('removes Arabic diacritics and tatweel', () {
      expect(normalizeSearchText('مُهِمّ'), 'مهم');
      expect(normalizeSearchText('الـعـلـم'), 'العلم');
    });

    test('unifies alef forms', () {
      expect(normalizeSearchText('أحمد إبراهيم آدم'), 'احمد ابراهيم ادم');
    });

    test('unifies ta-marbuta and alif-maqsura', () {
      expect(normalizeSearchText('مدرسة'), 'مدرسه');
      expect(normalizeSearchText('مستشفى'), 'مستشفي');
    });
  });

  group('filterNotes', () {
    test('empty query returns nothing', () {
      final notes = [buildNote(title: 'hello')];
      expect(filterNotes(notes, ''), isEmpty);
      expect(filterNotes(notes, '   '), isEmpty);
    });

    test('matches by title, case-insensitive', () {
      final notes = [
        buildNote(title: 'Shopping List'),
        buildNote(title: 'Work Plan'),
      ];
      final results = filterNotes(notes, 'shopping');
      expect(results.length, 1);
      expect(results.first.title, 'Shopping List');
    });

    test('matches by body text', () {
      final notes = [
        buildNote(title: 'Note A', text: 'remember to buy milk'),
        buildNote(title: 'Note B', text: 'call the dentist'),
      ];
      final results = filterNotes(notes, 'milk');
      expect(results.single.title, 'Note A');
    });

    test('matches checklist item titles', () {
      final notes = [
        buildNote(
          title: 'Tasks',
          checklist: [TaskModel(title: 'fix the sink')],
        ),
        buildNote(title: 'Other', text: 'nothing here'),
      ];
      final results = filterNotes(notes, 'sink');
      expect(results.single.title, 'Tasks');
    });

    test('Arabic query matches regardless of diacritics/alef form', () {
      final notes = [
        buildNote(title: 'مُلاحَظات', text: 'أهداف هذا الأسبوع'),
        buildNote(title: 'Random', text: 'unrelated'),
      ];
      // Query without diacritics, plain alef.
      final results = filterNotes(notes, 'ملاحظات');
      expect(results.single.title, 'مُلاحَظات');

      final results2 = filterNotes(notes, 'اهداف');
      expect(results2.single.title, 'مُلاحَظات');
    });

    test('multi-word query requires ALL words (AND logic)', () {
      final notes = [
        buildNote(title: 'buy milk and eggs'),
        buildNote(title: 'buy bread'),
      ];
      final results = filterNotes(notes, 'buy milk');
      expect(results.length, 1);
      expect(results.first.title, 'buy milk and eggs');
    });

    test('title matches rank above body matches', () {
      final notes = [
        buildNote(title: 'Random', text: 'flutter is great'),
        buildNote(title: 'Flutter ideas'),
      ];
      final results = filterNotes(notes, 'flutter');
      expect(results.first.title, 'Flutter ideas');
    });

    test('no match returns empty list', () {
      final notes = [buildNote(title: 'hello', text: 'world')];
      expect(filterNotes(notes, 'zzz'), isEmpty);
    });
  });
}
