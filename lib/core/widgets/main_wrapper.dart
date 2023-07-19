import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

class _MainWrapperState extends State<MainWrapper> {
  final recorder = FlutterSoundRecorder();
  late final String _path;
  @override
  void initState() {
    super.initState();
    initRecorder();
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
        height: 60,
        margin: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 8.0),

        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.green
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    StreamBuilder<RecordingDisposition>(
                        stream: recorder.onProgress,
                        builder: (context, snapshot) {
                          final duration = snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                          String twoDigits(int n) => n.toString().padLeft(2, '0');
                          final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
                          final twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));

                          return Text(
                            '$twoDigitMinutes:$twoDigitsSeconds',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white),
                          );
                        }),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(6.0),
              child: ElevatedButton(
                onPressed: () async {
                  recorder.isRecording ? await stop() : await record();
                  setState(() {});
                },
                child: Icon(recorder.isRecording ? Icons.pause : Icons.mic, size: 35),
              ),
            )
          ],
        ),
      ),
    );
  }
}
