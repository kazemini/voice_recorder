import 'dart:io';
import 'dart:math';

import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:template/core/database/shared_preferences_db.dart';

class MyVoiceRecorder {
  final FlutterSoundRecorder soundRecorder = FlutterSoundRecorder();

  String tempPath = '';
  bool isTemp = false;
  File? audioFile;
  String get path => tempPath;

  late Directory saveDir;

  bool isRecording() => soundRecorder.isRecording;

  bool isRecordedTemp() => soundRecorder.isStopped & isTemp;

  Future initRecorder([Duration duration = const Duration(milliseconds: 500)]) async {
    final directory = await getApplicationDocumentsDirectory();
    saveDir = (await getExternalStorageDirectory())!;

    tempPath = directory.path;

    await getPermission();
    await soundRecorder.openRecorder();
    soundRecorder.setSubscriptionDuration(duration);
  }

  Future<void> getPermission() async {
    final status = await Permission.microphone.request();
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted!';
    }
  }

  Future record() async {
    await soundRecorder.startRecorder(toFile: getTempPath());
    isTemp = true;
  }

  Future<String> stop() async {
    final path = await soundRecorder.stopRecorder();
    audioFile = File(path!);
    return audioFile!.path;
  }

  Future<void> deleteTempVoice() async {
    isTemp = false;
   final deleted = await audioFile!.delete();
   print('DELETED PATH IS: ${deleted.path}');
  }

  Future<void> saveToDirectory() async {
    SharedPreferencesDB.setPath(getSavePath());
    audioFile!.copySync(getSavePath());
    audioFile = null;
    isTemp = false;
  }


  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  String getTempPath() {
    int length = 8;
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String generatedString = String.fromCharCodes(Iterable.generate(
        length , (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    return '$tempPath/cached_voice_$generatedString}';
  }
  String getSavePath() {
    int length = 8;
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String generatedString = String.fromCharCodes(Iterable.generate(
        length , (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    return '${saveDir.path}/voice_$generatedString}';
  }


}

