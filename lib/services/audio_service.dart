import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AudioService {
  final Record _record = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentRecordingPath;

  /// Checks if the app has permission to record audio.
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        return result.isGranted;
      }
      return true;
    } catch (e) {
      // Log or handle permission check error
      return false;
    }
  }

  /// Starts recording audio if permission is granted.
  /// Throws an exception if permission is denied or recording fails.
  Future<void> startRecording() async {
    try {
      final permissionGranted = await hasPermission();
      if (!permissionGranted) {
        throw Exception('Recording permission denied');
      }

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _record.start(
        path: path,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 44100,
      );

      _currentRecordingPath = path;
    } catch (e) {
      // Handle or rethrow error
      rethrow;
    }
  }

  /// Stops the current recording and returns the file path.
  /// Returns the last known recording path if stop returns null.
  Future<String?> stopRecording() async {
    try {
      final path = await _record.stop();
      return path ?? _currentRecordingPath;
    } catch (e) {
      // Handle or rethrow error
      rethrow;
    }
  }

  /// Plays the audio recording from the given file path.
  /// Checks if the file exists before playing.
  Future<void> playRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await _audioPlayer.play(DeviceFileSource(path));
      } else {
        throw Exception('Audio file does not exist at path: $path');
      }
    } catch (e) {
      // Handle or rethrow error
      rethrow;
    }
  }

  /// Stops audio playback.
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      // Handle or rethrow error
      rethrow;
    }
  }

  /// Deletes the audio recording file at the given path if it exists.
  Future<void> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle or rethrow error
      rethrow;
    }
  }

  /// Disposes resources used by the audio service.
  Future<void> dispose() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } catch (e) {
      // Log error if needed
    }
  }
}
