import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:template/config/theme/theme_cubit.dart';
import 'package:template/service_voice_recorder.dart';

import '../../config/utils/enums_config.dart';
import '../../locator.dart';
import '../database/shared_preferences_db.dart';
import '../interface/app_router.dart';

// TODO this page only for test, pls convert to clean arch :)
//? contain page route & change theme test ;)

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> with TickerProviderStateMixin {
  MyVoiceRecorder recorder = MyVoiceRecorder();
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  String twoDigitMinutes = '00', twoDigitsSeconds = '00';
  bool wth = false;
  @override
  void initState() {
    super.initState();
    recorder.initRecorder();

    // Listen to states : playing , paused, stopped
    recorder.audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        recorder.isPlaying = (event.name == 'playing');
      });
    });

    // Listen to audio duration
    recorder.audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        recorder.duration = event;
      });
    });

    recorder.audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        recorder.position = event;
      });
    });

    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 1), lowerBound: 0.5, upperBound: 1)
      ..forward()
      ..addStatusListener((status) {
        if (_controller.isCompleted) {
          _controller.repeat(reverse: true);
        }
      });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    recorder.instance.closeRecorder();
    recorder.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ضبط کننده صدا'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [SizedBox()],
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: 62,
        margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: Stack(
          children: [
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0, top: 4.0),
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 3)],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: !recorder.isRecordedTemp(),
                  replacement: _RecordedTempWidget(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      _microphoneWidget(),
                      Visibility(
                        visible: recorder.isRecording(),
                        replacement: _messageBody(),
                        child: _recorderBody(),
                      ),
                      !recorder.isRecording()
                          ? IconButton(
                              tooltip: 'انتخاب فایل',
                              onPressed: () {},
                              icon: Icon(
                                Icons.attach_file,
                                color: Colors.blueGrey,
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        !recorder.isRecording()
            ? Container(
                margin: EdgeInsets.only(bottom: 8.0, right: 8.0),
                padding: EdgeInsets.zero,
                decoration: ShapeDecoration(color: Colors.blue, shape: CircleBorder()),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: () {},
                ),
              )
            : const SizedBox()
      ],
    );
  }

  Container _microphoneWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 8.0),
      child: Listener(
        onPointerDown: (details) async {
          await recorder.record();
          setState(() {});
        },
        onPointerUp: (details) async {
          await recorder.stop();
          setState(() {});
        },
        child: recorder.isRecording()
            ? const RippleAnimation(
                color: Colors.cyanAccent,
                delay: Duration(milliseconds: 200),
                repeat: true,
                minRadius: 20,
                ripplesCount: 3,
                duration: Duration(milliseconds: 6 * 300),
                child: Icon(
                  Icons.mic,
                  color: Colors.blue,
                  size: 30,
                ),
              )
            : const Icon(
                Icons.mic,
                color: Colors.blueGrey,
                size: 30,
              ),
      ),
    );
  }

  Expanded _messageBody() {
    return const Expanded(
      child: TextField(
        style: TextStyle(fontFamily: "vazir"),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 7,
        decoration: InputDecoration(border: InputBorder.none, hintText: "متن پیام"),
        autofocus: false,
      ),
    );
  }

  Expanded _recorderBody() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 24),
        child: StreamBuilder<RecordingDisposition>(
            stream: recorder.instance.onProgress,
            builder: (context, snapshot) {
              final duration = snapshot.hasData ? snapshot.data!.duration : Duration.zero;
              String twoDigits(int n) => n.toString().padLeft(2, '0');
              twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
              twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));

              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      '$twoDigitMinutes:$twoDigitsSeconds',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: FadeTransition(
                      opacity: _animation,
                      child: const Text(
                        'درحال ضبط صدا...',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Row _RecordedTempWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            onPressed: () {
              recorder.deleteTempAudio();
              setState(() {});
            },
            icon: const Icon(
              Icons.delete_forever,
              size: 25,
              color: Colors.red,
            )),
        Text(recorder.formatTime(recorder.position)),
        Expanded(
            child: Slider(
              min: 0,
              max: recorder.duration.inSeconds.toDouble(),
              value: recorder.position.inSeconds.toDouble(),
              onChanged: (double value) async{
                final position = Duration(seconds: value.toInt());
                await  recorder.audioPlayer.seek(position);
              },
            )
        ),
      Text(recorder.formatTime(recorder.duration)),
        IconButton(
                onPressed: () async {
                  recorder.isPlaying ? await recorder.pause() :
                  await recorder.play();
                  },
                icon: Icon(
                  recorder.isPlaying ? Icons.pause_circle_outline :
                  Icons.play_circle_outline,
                  color: Colors.blue,
                  size: 25,
                ),
              )
      ],
    );
  }
}
