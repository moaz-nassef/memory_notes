import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AudioRecorderFileHelper {
  final String _recordsDirName = 'records_note';
  String? _audioDirPath;

  Future<String> get _getAudioDirPath async {
    _audioDirPath ??= (await getApplicationDocumentsDirectory()).path;
    return _audioDirPath!;
  }

  Future<Directory> get getRecordsDirectory async {
    Directory recordsDir = Directory(
      path.join((await _getAudioDirPath), _recordsDirName),
    );

    if (!await recordsDir.exists()) {
      await recordsDir.create(recursive: true);
    }
    return recordsDir;
  }

  Future<void> deleteRecord(String filePath) async {
    final file = File(filePath);
    try {
      if (await file.exists()) {
        await file.delete();
      } else {
        throw Exception("File does not exist");
      }
    } on Exception catch (e) {
      // TODO
      throw e;
    }
  }
}
