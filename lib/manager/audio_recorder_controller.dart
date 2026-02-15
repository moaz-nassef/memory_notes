import 'dart:async';

import 'package:memory_notes/manager/audio_recorder_file_helper.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderController {
  final AudioRecorderFileHelper _audioRecorderFileHelper;

  AudioRecorderController(this._audioRecorderFileHelper);

  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _timer;
  int _elapsedMs = 0;
  String? _currentRecordingPath;

  final StreamController<int> _durationMsController =
      StreamController<int>.broadcast()..add(0);

  Stream<double> get amplitudeStream => _audioRecorder
      .onAmplitudeChanged(const Duration(milliseconds: 100))
      .map((event) => _normalizeAmplitude(event.current));

  Stream<int> get durationMsStream => _durationMsController.stream;

  Stream<RecordState> get recordStateStream => _audioRecorder.onStateChanged();

  String? get currentRecordingPath => _currentRecordingPath;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _elapsedMs += 100;
      _durationMsController.add(_elapsedMs);
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _elapsedMs = 0;
    _durationMsController.add(0);
  }

  Future<void> startRecording() async {
    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    final dir = await _audioRecorderFileHelper.getRecordsDirectory;
    final filePath =
        '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';

    _currentRecordingPath = filePath;

    try {
      await _audioRecorder.start(const RecordConfig(), path: filePath);
      _startTimer();
    } catch (e) {
      _currentRecordingPath = null;
      rethrow;
    }
  }

  Future<void> resume() async {
    await _audioRecorder.resume();
    _startTimer();
  }

  Future<String?> stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path == null) {
      _resetTimer();
      throw Exception('Failed to stop recording');
    }

    _currentRecordingPath = path;
    _resetTimer();
    return path;
  }

  Future<void> cancelRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      try {
        await _audioRecorderFileHelper.deleteRecord(path);
      } catch (_) {
        // keep flow stable if file is already gone
      }
    }

    _currentRecordingPath = null;
    _resetTimer();
  }

  Future<void> pause() async {
    await _audioRecorder.pause();
    _timer?.cancel();
  }

  Future<void> delete(String filePath) async {
    await _audioRecorderFileHelper.deleteRecord(filePath);
    if (_currentRecordingPath == filePath) {
      _currentRecordingPath = null;
    }
  }

  Future<bool> isRecording() async {
    return _audioRecorder.isRecording();
  }

  Future<bool> _checkPermission() async {
    final micPermission = Permission.microphone;
    if (await micPermission.isGranted) {
      return true;
    }

    final result = await micPermission.request();
    return result.isGranted || result.isLimited;
  }

  double _normalizeAmplitude(double db) {
    if (!db.isFinite) return 0;

    const minDb = -60.0;
    final clamped = db.clamp(minDb, 0.0).toDouble();
    return (clamped - minDb) / (0 - minDb);
  }

  void dispose() {
    _audioRecorder.dispose();
    _durationMsController.close();
    _timer?.cancel();
  }
}
