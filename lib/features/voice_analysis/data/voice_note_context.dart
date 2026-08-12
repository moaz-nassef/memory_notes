class VoiceNoteContext {
  const VoiceNoteContext({required this.title, required this.text});

  final String title;
  final String text;

  Map<String, String> toJson() => {'title': title, 'text': text};
}
