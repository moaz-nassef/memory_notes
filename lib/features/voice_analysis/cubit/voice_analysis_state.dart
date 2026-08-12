import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';

enum VoiceAnalysisStatus { idle, loading, success, failure }

class VoiceAnalysisState {
  const VoiceAnalysisState({
    this.status = VoiceAnalysisStatus.idle,
    this.result,
    this.errorMessage,
  });

  final VoiceAnalysisStatus status;
  final VoiceAnalysisResult? result;
  final String? errorMessage;

  VoiceAnalysisState copyWith({
    VoiceAnalysisStatus? status,
    VoiceAnalysisResult? result,
    String? errorMessage,
  }) {
    return VoiceAnalysisState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
