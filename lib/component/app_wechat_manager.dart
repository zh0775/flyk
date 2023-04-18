import 'dart:typed_data';

import 'package:cxhighversion2/util/app_thirdparty_config.dart';
import 'package:flutter/foundation.dart';
// import 'package:wechat_kit/wechat_kit.dart';
import 'package:fluwx/fluwx.dart';

class AppWechatManager {
  AppWechatManager._internal() {
    init();
  }
  static final AppWechatManager _singleton = AppWechatManager._internal();
  factory AppWechatManager() => _singleton;
  void init() {
    weChatResponseEventHandler.listen((res) {
      // print("res.isSuccessful === ${res}");
      if (res is WeChatPaymentResponse) {
      } else if (res is WeChatShareResponse) {
      } else if (res is WeChatAuthResponse) {}
    });
  }

  Future<void> registApp() async {
    if (kIsWeb) return;
    await registerWxApi(
      appId: WECHAT_APPID,
      doOnAndroid: true,
      doOnIOS: true,
      universalLink: WECHAT_UNIVERSAL_LINK,
    );
  }

  Future<void> sharePriendWithFile(Uint8List? imageData) async {
    if (imageData == null) {
      return;
    }
    await shareToWeChat(WeChatShareImageModel(WeChatImage.binary(imageData),
        scene: WeChatScene.SESSION));
  }

  Future<void> shareTimelineWithFile(Uint8List? imageData) async {
    if (imageData == null) {
      return;
    }
    await shareToWeChat(WeChatShareImageModel(WeChatImage.binary(imageData),
        scene: WeChatScene.TIMELINE));
  }
}
