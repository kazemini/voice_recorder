import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/utils/enums_config.dart';


class SharedPreferencesDB {

  static const String _theme = 'theme';
  static const String _paths = 'path';

  static late SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();


  //? save Theme mode into db
  static void setThemeMode(ThemeEnum themeEnum) {
    _preferences.setInt(_theme,themeEnum.index);
  }

  //? get theme from db, if is null => light mode
 static int getThemeMode() {
    return _preferences.getInt(_theme) ?? 0;
  }



  //? save path into db
  static void setPath(String newPath) async {
    List<String> path = getPaths();
    path.add(newPath);
    await _preferences.setStringList(_paths,path);
  }

  //? get path from db
  static List<String> getPaths() {
    return _preferences.getStringList(_paths) ?? <String>[];
  }
}