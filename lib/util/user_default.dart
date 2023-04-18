import 'package:cxhighversion2/util/storage_default.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDefault {
  static const String userDefaultBoxName = "hzy_userdefault";
  static UserDefault? _instance;
  factory UserDefault() => _instance ?? UserDefault.init();
  UserDefault.init() {
    _instance = this;
  }
  // static Future<bool> saveBool(String key, bool value) async {
  //   userDefault.write("key", {});
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.setBool(key, value);
  // }
  static Future<bool> saveBool(String key, bool value) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.setBool(key, value);
    }
    var box = await UserDefault().openBox();
    box.put(key, value);
    box.flush();
    // box.close();
    return true;
  }

  static Future<bool> saveStr(String key, String value) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.setString(key, value);
    }
    var box = await UserDefault().openBox();
    box.put(key, value);
    box.flush();
    // box.close();
    return true;
  }

  static Future<bool> saveImage(String key, Uint8List value) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      return sharedPreferences.setString(key, toHex(value));
    }

    var box = await UserDefault().openBox();
    box.put(key, value);
    box.flush();
    // box.close();
    return true;
  }

  static Future<bool> saveStrList(String key, List<String> value) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.setStringList(key, value);
    }

    var box = await UserDefault().openBox();
    box.put(key, value);
    box.flush();
    // box.close();
    return true;
  }

  static Future<bool> saveInt(String key, int value) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.setInt(key, value);
    }

    var box = await UserDefault().openBox();
    box.put(key, value);
    box.flush();
    // box.close();
    return true;
  }

  static Future<bool> saveDouble(String key, double value) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.setDouble(key, value);
    }

    var box = await UserDefault().openBox();
    box.put(key, value);
    box.flush();
    // box.close();
    return true;
  }

  static Future<dynamic> get(String key) async {
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      if (key == QR_IMAGE_DATA) {
        dynamic tmp = sharedPreferences.get(key);

        if (tmp != null && tmp is String && tmp.isNotEmpty) {
          Uint8List byte = toUnitList(tmp);
          return byte;
        }
        return null;
      }
      return sharedPreferences.get(key);
    }
    var box = await UserDefault().openBox();
    dynamic boxValue = box.get(key);
    if (boxValue != null) {
      return boxValue;
    }
  }

  static Future<dynamic> removeByKey(String key) async {
    var box = await UserDefault().openBox();
    if (box.get(key) != null) {
      await box.delete(key);
      box.flush();
      // box.close();
    } else {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      return sharedPreferences.remove(key);
    }
  }

  // static Box? box;
  Future<Box> openBox() async {
    // return box == null
    //     ? (await Hive.openBox(userDefaultBoxName))
    //     : box!.isOpen
    //         ? box!
    //         : (await Hive.openBox(userDefaultBoxName));
    return await Hive.openBox(userDefaultBoxName);
  }

  // static void set(String key, dynamic data) {
  //   GetStorage().write(key, data);
  //   setToDisk(key, data);
  // }

  // static void setToDisk(String key, dynamic data) async {
  //   await GetStorage().write(key, data);
  // }

  // static dynamic get(String key) {
  //   return GetStorage().read(key);
  // }

  // static Future<dynamic> getToDisk(String key) async {
  //   return await GetStorage().read(key);
  // }

  static toHex(Uint8List bArr) {
    int length;
    if (bArr == null || (length = bArr.length) <= 0) {
      return "";
    }
    Uint8List cArr = Uint8List(length << 1);
    int i = 0;
    for (int i2 = 0; i2 < length; i2++) {
      int i3 = i + 1;
      var cArr2 = [
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F'
      ];

      var index = (bArr[i2] >> 4) & 15;
      cArr[i] = cArr2[index].codeUnitAt(0);
      i = i3 + 1;
      cArr[i3] = cArr2[bArr[i2] & 15].codeUnitAt(0);
    }
    return String.fromCharCodes(cArr);
  }

  static hex(int c) {
    if (c >= '0'.codeUnitAt(0) && c <= '9'.codeUnitAt(0)) {
      return c - '0'.codeUnitAt(0);
    }
    if (c >= 'A'.codeUnitAt(0) && c <= 'F'.codeUnitAt(0)) {
      return (c - 'A'.codeUnitAt(0)) + 10;
    }
  }

  static toUnitList(String str) {
    int length = str.length;
    if (length % 2 != 0) {
      str = "0" + str;
      length++;
    }
    List<int> s = str.toUpperCase().codeUnits;
    Uint8List bArr = Uint8List(length >> 1);
    for (int i = 0; i < length; i += 2) {
      bArr[i >> 1] = ((hex(s[i]) << 4) | hex(s[i + 1]));
    }
    return bArr;
  }
}
