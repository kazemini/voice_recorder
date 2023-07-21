import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyVoiceRecorder {
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterSoundRecorder instance = FlutterSoundRecorder();

  late String _path;
  bool _isTemp = false;
  File? audioFile;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get isTemp => _isTemp;

  set isTemp(bool value) {
    _isTemp = value;
  }

  bool isRecording() => instance.isRecording;

  bool isRecordedTemp() => instance.isStopped & _isTemp;

  Duration get duration => _duration;

  Duration get position => _position;

  set duration(Duration value) {
    _duration = value;
  }

  set position(Duration value) {
    _position = value;
  }

  Future initRecorder([Duration duration = const Duration(milliseconds: 500)]) async {
    final _directory = await getExternalStorageDirectory();
    _path = '/storage/emulated/0/Download';

    await getPermission();
    await instance.openRecorder();
    instance.setSubscriptionDuration(duration);
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
    await instance.startRecorder(toFile: '$_path/audio-test');
    _isTemp = true;
  }

  Future stop() async {
    final path = await instance.stopRecorder();
    audioFile = File(path!);
    print('Recorded path is : $path');
    //isTemp = false;
    setAudio();
  }

  Future<void> play() async {
    await audioPlayer.resume();
  }

  Future pause() async {
    await audioPlayer.pause();
    isPlaying = false;
  }

  Future<void> deleteTempAudio() async {
    await audioPlayer.stop();
    audioFile = null;
    position = Duration.zero;
    duration = Duration.zero;
    _isTemp = false;
    isPlaying = false;
  }

  Future<void> setAudio() async {
    audioPlayer.setSourceDeviceFile(audioFile!.path);
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
}
