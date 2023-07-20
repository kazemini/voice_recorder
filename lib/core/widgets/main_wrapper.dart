import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:template/config/theme/theme_cubit.dart';

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
  final recorder = FlutterSoundRecorder();
  late final String _path;
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    initRecorder();
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
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final _directory = await getExternalStorageDirectory();
    _path = '/storage/emulated/0/Download';
    final status = await Permission.microphone.request();
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted!';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

  Future record() async {
    await recorder.startRecorder(toFile: '$_path/audio-test');
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print('Recorded path is : $path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ضبط کننده صدا'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            /*
                Center(
                child: ElevatedButton(
                    onPressed: () {
                      //? here is test of AppRouter using di & extend from dynamic abstract
                      //? class, u can send anything you want to the next page
                      //? like below(Map of dynamic thing) or just int-string
                      Navigator.of(context).push(locator<AppRouter>().call(name:'/second',
                          param: {'txt1':'wellcome to second page   ;)  ','txt2':'powered by di'}));
                    },
                    child: const Text('بریم صفحه دوم')
                ),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      SharedPreferencesDB.setThemeMode(ThemeEnum.light);
                      BlocProvider.of<ThemeCubit>(context).lightMode();
                    },
                    child: const Text('حالت روشن')
                ),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      SharedPreferencesDB.setThemeMode(ThemeEnum.dark);
                      BlocProvider.of<ThemeCubit>(context).darkMode();
                    },
                    child: const Text('حالت تیره')
                ),
              ),
              Center(
                child: ElevatedButton(
                    onPressed: () {
                      SharedPreferencesDB.setThemeMode(ThemeEnum.system);
                      BlocProvider.of<ThemeCubit>(context).system();
                    },
                    child: const Text('حالت سیستم')
                ),
              ),
               */
            SizedBox()
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
            /*
               Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32), color: Colors.green),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 8.0, right: 8.0),
                      alignment: Alignment.centerRight,
                      child: StreamBuilder<RecordingDisposition>(
                          stream: recorder.onProgress,
                          builder: (context, snapshot) {
                            final duration =
                            snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                            String twoDigits(int n) => n.toString().padLeft(2, '0');
                            final twoDigitMinutes =
                            twoDigits(duration.inMinutes.remainder(60));
                            final twoDigitsSeconds =
                            twoDigits(duration.inSeconds.remainder(60));

                            return Text(
                              '$twoDigitMinutes:$twoDigitsSeconds',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            );
                          }),
                    ),
                    recorder.isRecording ? Text('برای لغو به راست بکشید') : SizedBox()
                  ],
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSection() {
    if (_isRecording) {
      record();
    }
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
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8.0),
                      child: Listener(
                          onPointerUp: (details) async {
                            await stop();
                            _isRecording = false;
                            setState(() {});
                          },
                          child: const RippleAnimation(
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
                          )),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: StreamBuilder<RecordingDisposition>(
                            stream: recorder.onProgress,
                            builder: (context, snapshot) {
                              final duration =
                                  snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                              String twoDigits(int n) => n.toString().padLeft(2, '0');
                              final twoDigitMinutes =
                                  twoDigits(duration.inMinutes.remainder(60));
                              final twoDigitsSeconds =
                                  twoDigits(duration.inSeconds.remainder(60));
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      '$twoDigitMinutes:$twoDigitsSeconds',
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  FadeTransition(
                                    opacity: _animation,
                                    child: Text(
                                      'درحال ضبط صدا...',
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 8.0),
                      child: Listener(
                        onPointerDown: (details) async {
                          await record();
                          setState(() {
                            _isRecording = true;
                          });
                        },
                        onPointerUp: (details) async {
                          await stop();
                          setState(() {
                            _isRecording = false;
                          });
                        },
                        child: recorder.isRecording
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
                    ),
                    Visibility(
                      visible: !_isRecording,
                      replacement: Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: StreamBuilder<RecordingDisposition>(
                              stream: recorder.onProgress,
                              builder: (context, snapshot) {
                                final duration =
                                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                                String twoDigits(int n) => n.toString().padLeft(2, '0');
                                final twoDigitMinutes =
                                    twoDigits(duration.inMinutes.remainder(60));
                                final twoDigitsSeconds =
                                    twoDigits(duration.inSeconds.remainder(60));
                                return Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        '$twoDigitMinutes:$twoDigitsSeconds',
                                        style: const TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    FadeTransition(
                                      opacity: _animation,
                                      child: Text(
                                        'درحال ضبط صدا...',
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ),
                      child: const Expanded(
                        child: TextField(
                          style: TextStyle(fontFamily: "vazir"),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 7,
                          decoration:
                              InputDecoration(border: InputBorder.none, hintText: "متن پیام"),
                          autofocus: false,
                        ),
                      ),
                    ),
                    !_isRecording ? IconButton(
                      tooltip: 'انتخاب فایل',
                      onPressed: () {},
                      icon: Icon(
                        Icons.attach_file,
                        color: Colors.blueGrey,
                      ),
                    ) : const SizedBox()
                  ],
                ),
              ],
            ),
          ),
        ),
        !_isRecording ? Container(
          margin: EdgeInsets.only(bottom: 8.0, right: 8.0),
          padding: EdgeInsets.zero,
          decoration: ShapeDecoration(color: Colors.blue, shape: CircleBorder()),
          child: IconButton(
            icon: Icon(Icons.send_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ) : SizedBox()
      ],
    );
  }
}
