import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_state.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_repository.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';

class VoiceAnalysisCubit extends Cubit<VoiceAnalysisState> {
  VoiceAnalysisCubit(this._repository) : super(const VoiceAnalysisState());

  final VoiceAnalysisRepository _repository;

  Future<void> analyze(
    File audioFile, {
    VoiceAnalysisResult? previous,
  }) async {
    if (state.status == VoiceAnalysisStatus.loading) return;

    emit(const VoiceAnalysisState(status: VoiceAnalysisStatus.loading));
    try {
      final result = await _repository.analyzeAudio(audioFile, previous: previous);
      if (isClosed) return;
      emit(
        VoiceAnalysisState(status: VoiceAnalysisStatus.success, result: result),
      );
    } on VoiceAnalysisException catch (error) {
      if (isClosed) return;
      emit(
        VoiceAnalysisState(
          status: VoiceAnalysisStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }

  void clearEvent() {
    if (!isClosed) emit(const VoiceAnalysisState());
  }
}
