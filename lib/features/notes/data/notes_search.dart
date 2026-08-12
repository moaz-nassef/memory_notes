import 'package:memory_notes/models/note_model.dart';

/// Normalizes text so search matching is accurate for both
/// English and Arabic notes:
/// - lowercases + trims (English "Hello" == "hello")
/// - removes Arabic diacritics and tatweel (مُهِمّ == مهم)
/// - unifies Alef forms  (أ / إ / آ / ٱ  →  ا)
/// - unifies Alif-Maqsura → Ya (ى → ي) and Ta-Marbuta → Ha (ة → ه)
String normalizeSearchText(String input) {
  var text = input.toLowerCase().trim();
  // Tatweel (ـ), harakat/tanween/shadda/sukun (ً..ْ), superscript alef (ٰ).
  text = text.replaceAll(RegExp(r'[ـً-ْٰ]'), '');
  text = text.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
  text = text.replaceAll('ى', 'ي').replaceAll('ة', 'ه');
  return text.replaceAll(RegExp(r'\s+'), ' ');
}

/// Returns the notes matching [query], best matches first.
///
/// High-accuracy rules:
/// - Every word in the query must be found (AND logic), so results
///   never contain irrelevant notes.
/// - A note matches when words appear in its **title**, **body text**
///   or **checklist items**.
/// - Results are ranked: exact/title matches first, then body text,
///   then checklist; ties fall back to newest notes first.
List<NoteModel> filterNotes(List<NoteModel> notes, String query) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) return const [];

  final terms = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();

  final scored = <MapEntry<NoteModel, int>>[];
  for (final note in notes) {
    final score = _matchScore(note, normalizedQuery, terms);
    if (score > 0) scored.add(MapEntry(note, score));
  }

  scored.sort((a, b) {
    final byScore = b.value.compareTo(a.value);
    if (byScore != 0) return byScore;
    return b.key.createdAt.compareTo(a.key.createdAt);
  });

  return scored.map((e) => e.key).toList();
}

/// Scores one note against the query. 0 means "no match".
int _matchScore(NoteModel note, String query, List<String> terms) {
  final title = normalizeSearchText(note.title);
  final body = normalizeSearchText(note.text ?? '');
  final checklistText = normalizeSearchText(
    (note.checklist ?? const []).map((t) => t.title).join(' '),
  );

  // AND logic — every term must exist in at least one field.
  for (final term in terms) {
    final inTitle = title.contains(term);
    final inBody = body.contains(term);
    final inChecklist = checklistText.contains(term);
    if (!inTitle && !inBody && !inChecklist) return 0;
  }

  var score = 0;

  // Whole-phrase bonuses (title is the strongest signal).
  if (title == query) {
    score += 200;
  } else if (title.startsWith(query)) {
    score += 120;
  } else if (title.contains(query)) {
    score += 100;
  }
  if (body.contains(query)) score += 40;
  if (checklistText.contains(query)) score += 25;

  // Per-term bonuses.
  for (final term in terms) {
    if (title.contains(term)) score += 20;
    if (body.contains(term)) score += 8;
    if (checklistText.contains(term)) score += 5;
  }

  return score;
}
