import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:template/service_voice_recorder.dart';

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
  PlayerController controller = PlayerController();


  @override
  void initState() {
    super.initState();
    recorder.initRecorder();
    initInChatVoice();


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
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children:  [

            Align(alignment: Alignment.topRight, child: audio_message_model(true)),
            SizedBox(height: 12,),
            Align(alignment: Alignment.topLeft, child: audio_message_model(false)),
          ],
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








Future<void> initInChatVoice() async {
  await controller.preparePlayer(
    path: '/storage/emulated/0/Download/audio.mp3',
    shouldExtractWaveform: true,
    volume: 1.0,
    noOfSamples: 100,
  );
  await controller.startPlayer(finishMode: FinishMode.loop);
}

  Widget audio_message_model(bool isMine) {
    final r8 = Radius.circular(24.0);
    final r6 = Radius.circular(6.0);
    return Container(
      margin: isMine ? EdgeInsets.only(right: 8.0) : EdgeInsets.only(left: 8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      height: 100,
      decoration: BoxDecoration(
        color: isMine ? Color(0xFF1D91D4).withOpacity(0.9) :Colors.white70,
        borderRadius: isMine ? BorderRadius.only(
          bottomLeft: r8,
          bottomRight: const Radius.circular(12.0),
          topLeft: r8,
          topRight: r6
        ) :
        BorderRadius.only(
            bottomLeft:const Radius.circular(12.0),
            bottomRight: r8,
            topLeft: r6,
            topRight: r8
        )
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              audioFileWaveforms(isMine),
              Container(
                margin: EdgeInsets.only(top: 8.0,right: 12.0),
                  child: IconButton(
                    icon: Icon(Icons.play_circle_outline,size: 30,),
                    color: isMine ? Colors.white : Colors.blue,
                    onPressed: () { },
                  )),
              Container(
                  margin: const EdgeInsets.only(right: 4.0),
                  child:  Icon(Icons.more_vert,color:
                  isMine ? Colors.white : Colors.blue,)),
            ],
          ),
          Container(
              margin: const EdgeInsets.all(8.0),
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('12:49',style: TextStyle(
                      color: isMine ? Colors.white70 : Colors.blue),),
                  SizedBox(width: 4.0,),
                  Icon(Icons.check,color:
                  isMine ? Colors.white70 : Colors.blue,)
                ],),
          )],
      )
    );
  }


Widget audioFileWaveforms(bool sender){
    return Container(
      margin: const EdgeInsets.only(left: 16.0,top: 8.0),
      child: AudioFileWaveforms(
        size: Size(MediaQuery.of(context).size.width * 0.50, 40.0),
        playerController: controller,
        enableSeekGesture: true,
        waveformType: WaveformType.long,
        decoration: BoxDecoration(
            color: sender ? Colors.lightBlueAccent.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6.0)
        ),
        playerWaveStyle: sender ? PlayerWaveStyle(
          fixedWaveColor: Colors.white,
          liveWaveColor: Colors.blue,
          seekLineColor: Colors.blueGrey,
          spacing: 8,
        ) :
        PlayerWaveStyle(
          fixedWaveColor: Colors.lightBlueAccent,
          liveWaveColor: Colors.blueAccent,
          seekLineColor: Colors.indigo,
          spacing: 8,
        )
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
                  replacement: _recordedTempWidget(),
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

  Row _recordedTempWidget() {
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
              activeColor: Colors.lightBlueAccent,
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
