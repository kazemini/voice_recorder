import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class ServiceAudioPlayer {
  final AudioPlayer player = AudioPlayer();
  late String path;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  bool isPlaying = false;

  void initialize(BuildContext context) {}

  Future<void> play() async {
    await player.resume();
  }

  Future pause() async {
    await player.pause();
  }

  Future deallocate() async{
    await player.release();
  }

  Future<void> setUpAudio(String tempPath) async {
    await player.setSourceDeviceFile(tempPath);
    await player.setReleaseMode(ReleaseMode.stop);
  }

}