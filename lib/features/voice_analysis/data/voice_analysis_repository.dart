import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_note_context.dart';

class VoiceAnalysisException implements Exception {
  const VoiceAnalysisException(this.message);

  final String message;

  @override
  String toString() => message;
}

class VoiceAnalysisRepository {
  VoiceAnalysisRepository(
    this._client, {
    String? baseUrl,
    List<VoiceNoteContext> Function()? noteContextProvider,
  }) : _noteContextProvider = noteContextProvider,
       _baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'VOICE_ANALYSIS_API_BASE_URL',
             defaultValue: _defaultBaseUrl,
           );

  static const _defaultBaseUrl =
      'https://gwjzrtsiscqroesliulr.supabase.co/functions/v1';

  static const _maxAudioBytes = 10 * 1024 * 1024;
  static const _requestTimeout = Duration(seconds: 90);

  final http.Client _client;
  final List<VoiceNoteContext> Function()? _noteContextProvider;
  final String _baseUrl;

  Future<VoiceAnalysisResult> analyzeAudio(
    File audioFile, {
    VoiceAnalysisResult? previous,
  }) async {
    if (_baseUrl.isEmpty) {
      throw const VoiceAnalysisException(
        'Voice analysis is not configured for this build.',
      );
    }

    final size = await audioFile.length();
    if (size == 0) {
      throw const VoiceAnalysisException('The recording is empty.');
    }
    if (size > _maxAudioBytes) {
      throw const VoiceAnalysisException(
        'This recording is too large to analyze. Please record a shorter note.',
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/voice-analyze'),
      );
      final noteContext = _noteContextProvider?.call() ?? const [];
      if (noteContext.isNotEmpty) {
        request.fields['note_context'] = jsonEncode(
          noteContext.map((note) => note.toJson()).toList(growable: false),
        );
      }
      if (previous != null) {
        request.fields['previous'] = jsonEncode({
          'title': previous.title,
          'text': previous.text,
          'tasks':
              previous.tasks
                  .map(
                    (task) => {
                      'title': task.title,
                      'durationMinutes': task.durationMinutes,
                    },
                  )
                  .toList(),
        });
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: _contentTypeFor(audioFile.path),
        ),
      );

      final streamedResponse = await _client
          .send(request)
          .timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw VoiceAnalysisException(_messageForError(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected an object response.');
      }
      return VoiceAnalysisResult.fromJson(decoded);
    } on VoiceAnalysisException {
      rethrow;
    } on TimeoutException {
      throw const VoiceAnalysisException(
        'Analysis took too long. Check your connection and try again.',
      );
    } on SocketException {
      throw const VoiceAnalysisException(
        'No internet connection. Your recording is still saved locally.',
      );
    } on FileSystemException {
      throw const VoiceAnalysisException(
        'The recording file is no longer available.',
      );
    } on StateError {
      throw const VoiceAnalysisException(
        'Voice analysis security is not configured for this build.',
      );
    } on FormatException {
      throw const VoiceAnalysisException(
        'The analysis service returned an invalid result. Please try again.',
      );
    } catch (_) {
      throw const VoiceAnalysisException(
        'Could not analyze this recording. Please try again.',
      );
    }
  }

  MediaType _contentTypeFor(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'm4a':
      case 'mp4':
        return MediaType('audio', 'mp4');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'wav':
        return MediaType('audio', 'wav');
      case 'aac':
        return MediaType('audio', 'aac');
      default:
        return MediaType('audio', 'mp4');
    }
  }

  String _messageForError(http.Response response) {
    if (response.statusCode == 429) {
      return 'Too many analysis requests. Please try again shortly.';
    }
    if (response.statusCode == 413) {
      return 'This recording is too large to analyze.';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded case {
        'message': final String message,
      } when message.isNotEmpty) {
        return message;
      }
    } on FormatException {
      // Use the safe generic message below for non-JSON error responses.
    }
    return 'The analysis service is unavailable. Please try again.';
  }
}
