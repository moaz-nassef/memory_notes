import 'package:flutter_test/flutter_test.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';

void main() {
  group('VoiceAnalysisResult', () {
    test('parses a valid structured analysis response', () {
      final result = VoiceAnalysisResult.fromJson({
        'title': '  شراء احتياجات المنزل  ',
        'text': '  اشتري الحليب والخبز اليوم.  ',
        'tasks': [
          {'title': 'شراء الحليب'},
          {'title': 'شراء الخبز'},
        ],
      });

      expect(result.title, 'شراء احتياجات المنزل');
      expect(result.text, 'اشتري الحليب والخبز اليوم.');
      expect(result.tasks.map((task) => task.title), [
        'شراء الحليب',
        'شراء الخبز',
      ]);
    });

    test('uses a safe fallback title and ignores an omitted task list', () {
      final result = VoiceAnalysisResult.fromJson({
        'title': ' ',
        'text': 'اتصل بأحمد غدا',
      });

      expect(result.title, 'Voice note');
      expect(result.tasks, isEmpty);
    });

    test('keeps an optional duration for a small planned task', () {
      final result = VoiceAnalysisResult.fromJson({
        'title': 'خطة مذاكرة',
        'text': 'خمس ساعات مقسمة إلى عشر جلسات.',
        'tasks': [
          {'title': 'مراجعة الرياضيات', 'durationMinutes': 30},
        ],
      });

      expect(result.tasks.single.durationMinutes, 30);
    });

    test('rejects an empty transcript', () {
      expect(
        () => VoiceAnalysisResult.fromJson({'title': 'Title', 'text': ' '}),
        throwsFormatException,
      );
    });
  });
}
