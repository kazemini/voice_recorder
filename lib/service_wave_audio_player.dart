import 'package:audio_waveforms/audio_waveforms.dart';

class ServiceWaveAudioPlayer {

  static bool isPlaying(PlayerController controller) =>
      controller.playerState.isPlaying;

  static Future<void> initWavePlayer(PlayerController controller,String path) async {
     await controller.preparePlayer(
      path: path,
      shouldExtractWaveform: true,
      volume: 1.0,
      noOfSamples: 100,
    );
  }

  static Future<void> play(PlayerController controller) async {
    await controller.startPlayer(finishMode: FinishMode.pause);
  }

  static Future<void> pause(PlayerController controller) async {
    await controller.pausePlayer();
  }


  static Future<void> playPause(PlayerController controller) async {
    isPlaying(controller) ? await pause(controller) : await play(controller);
  }
}