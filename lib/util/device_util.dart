import 'package:universal_platform/universal_platform.dart';

class DeviceUtil {
  static bool get isDesktop => !isWeb && (isWindows || isLinux || isMacOS);

  static bool get isMobile => isAndroid || isIOS;

  static bool get isWeb => UniversalPlatform.isWeb;

  static bool get isWindows => UniversalPlatform.isWindows;

  static bool get isLinux => UniversalPlatform.isLinux;

  static bool get isMacOS => UniversalPlatform.isMacOS;

  static bool get isAndroid => UniversalPlatform.isAndroid;

  static bool get isFuchsia => UniversalPlatform.isFuchsia;

  static bool get isIOS => UniversalPlatform.isIOS;
}
