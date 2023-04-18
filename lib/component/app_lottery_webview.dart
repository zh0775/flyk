import 'dart:convert' as convert;

import 'package:cxhighversion2/component/app_lottery_history_web.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/util/storage_default.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cxhighversion2/util/native_ui.dart'
    if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:universal_html/js.dart' as js;

class AppLotteryWebViewBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AppLotteryWebViewController>(AppLotteryWebViewController());
  }
}

class AppLotteryWebViewController extends GetxController {
  WebViewController? _webCtrl;
  WebViewController? get webCtrl => _webCtrl;
  set webCtrl(v) {
    _webCtrl = v;
    lotteryChannel ??= LotteryChannel(webViewCtrl: _webCtrl);
  }

  LotteryChannel? lotteryChannel;
  String title = "";
  @override
  void onReady() {
    if (!AppDefault().loginStatus) {
      ShowToast.normal("请先登录");
      Future.delayed(const Duration(seconds: 1), () {
        setUserDataFormat(false, {}, {}, {}).then((value) => toLogin());
      });
    }
    super.onReady();
  }

  bool isFirst = true;
  String lcNo = "";

  String lotteryViewId = "AppLotteryWebViewViewId";

  int? eCount;

  String lotteryUrl = "";
  bool insideView = false;
  Function(double scrollHeight)? getScollerHeight;

  dataInit(String id, String url, bool inside,
      Function(double height)? getHeight, BuildContext ctx) async {
    // if (!isFirst) return;
    lcNo = id;
    insideView = inside;
    getScollerHeight = getHeight;
    eCount = await const LotteryChannel().setCount();
    lotteryUrl = "$url&ec=$eCount";
    // lotteryUrl = "$url&ec=3";
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(lotteryViewId, (int viewId) {
        return html.IFrameElement()
          ..id = lotteryViewId
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = lotteryUrl
          ..style.border = 'none';
      });
    } else if (webCtrl != null) {
      webCtrl!.loadUrl(lotteryUrl);
    }
    if (isFirst) {
      isFirst = false;
      update();
    }
  }

  Map homeData = {};

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    super.onInit();
  }
}

enum LotteryType {
  laohu,
  fanpai,
  zhuan,
}

class AppLotteryWebView extends StatefulWidget {
  final LotteryType type;
  final String id;
  final String title;
  final bool insideView;
  final Function(double scrollHeight)? getScollerHeight;
  const AppLotteryWebView(
      {Key? key,
      this.type = LotteryType.fanpai,
      this.id = "",
      this.title = "",
      this.insideView = false,
      this.getScollerHeight})
      : super(key: key);

  @override
  State<AppLotteryWebView> createState() => _AppLotteryWebViewState();
}

class _AppLotteryWebViewState extends State<AppLotteryWebView> {
  WebViewController? myWebCtrl;
  int? eCount;
  String lotteryViewId = "AppLotteryWebViewViewId";
  LotteryChannel? lotteryChannel;
  String lotteryUrl = "";
  @override
  void initState() {
    if (kIsWeb) {
      lotteryChannel =
          LotteryChannel(getScollerHeight: widget.getScollerHeight);
    }
    loadUrl();
    super.initState();
  }

  loadUrl() async {
    Map homeData = AppDefault().homeData;
    if (AppDefault().token.isEmpty || homeData.isEmpty) {
      return gemp();
    }
    String params = "";
    if (homeData["lotteryConfig"] != null &&
        homeData["lotteryConfig"] is List &&
        homeData["lotteryConfig"].isNotEmpty) {
      Map lData = homeData["lotteryConfig"][0];
      params += "&prizeList=${convert.jsonEncode(lData["prizeList"] ?? [])}";
      params += "&costAmount=${lData["costAmount"] ?? 0}";
      params += "&lotteryDesc=${lData["lotteryDesc"] ?? ""}";
      params += "&no=${lData["no"] ?? ""}";
    } else {
      return gemp();
    }
    if ((homeData["u_Account"] ?? []).isNotEmpty) {
      for (var e in (homeData["u_Account"] ?? [])) {
        if (e["a_No"] == 4) {
          params += "&amout=${e["amout"] ?? 0}";
        }
      }
    }
    lotteryUrl =
        "${HttpConfig.lotteryUrl}?token=${AppDefault().token}&baseUrl=${HttpConfig.baseUrl}$params&imageUrl=${AppDefault().imageUrl}&inside=${widget.insideView}";
    eCount = await const LotteryChannel().setCount();

    lotteryUrl = "$lotteryUrl&ec=$eCount";
    if (kIsWeb) {
      setState(() {});
      ui.platformViewRegistry.registerViewFactory(lotteryViewId, (int viewId) {
        return html.IFrameElement()
          ..id = lotteryViewId
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = lotteryUrl
          ..style.border = 'none';
      });
    } else {
      if (myWebCtrl != null) {
        myWebCtrl!.loadUrl(lotteryUrl);
      } else {
        setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(covariant AppLotteryWebView oldWidget) {
    loadUrl();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // controller.dataInit(
    //     id, lotteryUrl, widget.insideView, widget.getScollerHeight, context);
    return !widget.insideView
        ? lotteryView(lotteryUrl, lotteryChannel)
        : Scaffold(
            appBar: getDefaultAppBar(
              context,
              widget.title,
            ),
            body: lotteryView(lotteryUrl, lotteryChannel));
  }

  Widget lotteryView(String url, LotteryChannel? lotteryChannel) {
    return eCount == null
        ? gemp()
        : kIsWeb
            ? HtmlElementView(
                viewType: lotteryViewId,
                onPlatformViewCreated: (id) {
                  List<html.Node> es =
                      html.document.getElementsByTagName("flt-platform-view");
                  if (es.isNotEmpty) {
                    html.Node node = es[0];
                    // node.append(styleElement);
                    html.Element? e =
                        node.ownerDocument!.getElementById(lotteryViewId);
                    // node.insertBefore(node, e);
                    if (e != null) {
                      e.onScroll.listen((event) {
                        consoleLog("onScroll", event);
                      });
                      e.onLoad.listen((event) {
                        // 监听
                        js.context.callMethod("htmlAddCallback", [
                          lotteryViewId,
                          "setFlutterECount",
                          lotteryChannel!.setFlutterECount
                        ]);

                        js.context.callMethod("htmlAddCallback", [
                          lotteryViewId,
                          "webScrollHeight",
                          lotteryChannel.webScrollHeight
                        ]);

                        js.context.callMethod("htmlAddCallback",
                            [lotteryViewId, "payStr", lotteryChannel.payStr]);
                        js.context.callMethod("htmlAddCallback", [
                          lotteryViewId,
                          "toHistory",
                          lotteryChannel.toHistory
                        ]);
                        js.context.callMethod("htmlAddCallback", [
                          lotteryViewId,
                          "toLoginAction",
                          lotteryChannel.toLoginAction
                        ]);
                        String height = js.context.callMethod(
                            "getParamsToIframe",
                            [lotteryViewId, "getScrollHeight"]);
                        if (widget.getScollerHeight != null &&
                            double.tryParse(height) != null) {
                          widget.getScollerHeight!(double.parse(height));
                        }
                      });
                    }
                  }
                },
              )
            : WebView(
                initialUrl: lotteryUrl,
                // debuggingEnabled: true,
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (url) {
                  // if (controller.webCtrl != null) {
                  //   controller.lotteryChannel!.setCount();
                  // }
                },
                onWebViewCreated: (webctrl) {
                  myWebCtrl = webctrl;
                },
                javascriptChannels:
                    LotteryChannel(getScollerHeight: widget.getScollerHeight)
                        .getChannelSet(),
              );
  }
}

class LotteryChannel {
  final WebViewController? webViewCtrl;
  final Function(double scrollHeight)? getScollerHeight;
  const LotteryChannel({this.webViewCtrl, this.getScollerHeight});
  // static LotteryChannel? _instance;
  // LotteryChannel.init() {
  //   _instance = this;
  // }
  // factory LotteryChannel() => _instance ?? LotteryChannel.init();

  JavascriptChannel titleJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'setFlutterECount',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message.isNotEmpty) {
          setFlutterECount(message.message);
        }
      },
    );
  }

  JavascriptChannel toLoginJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'toLoginAction',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message.isNotEmpty) {
          toLoginAction(message.message);
        }
      },
    );
  }

  JavascriptChannel playJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'payStr',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message.isNotEmpty) {
          payStr(message.message);
          // if (int.tryParse(message.message) != null) {
          //   int count = int.parse(message.message);
          //   UserDefault.saveInt(USER_EXPERIENCES_COUNT_DATA, count);
          // }
        }
      },
    );
  }

  JavascriptChannel getScrollHeightJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'webScrollHeight',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message.isNotEmpty) {
          if (getScollerHeight != null) {
            getScollerHeight!(webScrollHeight(message.message));
          }
          // if (int.tryParse(message.message) != null) {
          //   int count = int.parse(message.message);
          //   UserDefault.saveInt(USER_EXPERIENCES_COUNT_DATA, count);
          // }
        }
      },
    );
  }

  JavascriptChannel toHistoryJSChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'toHistory',
      onMessageReceived: (JavascriptMessage message) {
        toHistory();
      },
    );
  }

  Set<JavascriptChannel> getChannelSet() {
    return {
      titleJavascriptChannel(Global.navigatorKey.currentContext!),
      playJavascriptChannel(Global.navigatorKey.currentContext!),
      getScrollHeightJavascriptChannel(Global.navigatorKey.currentContext!),
      toHistoryJSChannel(Global.navigatorKey.currentContext!),
      toLoginJavascriptChannel(Global.navigatorKey.currentContext!),
    };
  }

  Future<int> setCount() async {
    // UserDefault.saveInt(USER_EXPERIENCES_COUNT_DATA, 3);
    int? count = await UserDefault.get(USER_EXPERIENCES_COUNT_DATA);
    String? time = await UserDefault.get(USER_EXPERIENCES_TIME_DATA);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    now = dateFormat.parse(dateFormat.format(now));
    // UserDefault.saveStr(USER_EXPERIENCES_TIME_DATA, dateFormat.format(now));
    if (time == null && count == null) {
      await UserDefault.saveInt(USER_EXPERIENCES_COUNT_DATA, 3);
      await UserDefault.saveStr(
          USER_EXPERIENCES_TIME_DATA, dateFormat.format(now));
      //传count set3
      // if (kIsWeb) {
      //   // js.context.callMethod("callFunction",
      //   //     ["AppLotteryWebViewViewId", "setExperiencesCount", 3]);
      //   // js.context.callMethod("setExperiencesCount", [3]);
      // } else if (webViewCtrl != null) {
      //   await webViewCtrl!
      //       .runJavascriptReturningResult("setExperiencesCount(3)");
      // }
      return 3;
    } else {
      if (now.isAfter(dateFormat.parse(time!))) {
        UserDefault.saveInt(USER_EXPERIENCES_COUNT_DATA, 3);
        UserDefault.saveStr(USER_EXPERIENCES_TIME_DATA, dateFormat.format(now));
        //传count set3
        // if (kIsWeb) {
        //   // js.context.callMethod("setExperiencesCount", [3]);
        //   // js.context.callMethod("callFunction",
        //   //     ["AppLotteryWebViewViewId", "setExperiencesCount", 3]);
        // } else if (webViewCtrl != null) {
        //   await webViewCtrl!
        //       .runJavascriptReturningResult("setExperiencesCount(3)");
        // }
        return 3;
      } else {
        //传count setCount
        // if (kIsWeb) {
        //   // js.context.callMethod("setExperiencesCount", [count]);
        //   // js.context.callMethod("callFunction",
        //   //     ["AppLotteryWebViewViewId", "setExperiencesCount", count]);
        // } else if (webViewCtrl != null) {
        //   await webViewCtrl!
        //       .runJavascriptReturningResult("setExperiencesCount($count)");
        // }
        return count!;
      }
    }
  }

  dispos() {}

  setFlutterECount(String message) {
    if (int.tryParse(message) != null) {
      int count = int.parse(message);
      UserDefault.saveInt(USER_EXPERIENCES_COUNT_DATA, count);
    }
    consoleLog("flutter_setCount", message);
  }

  double webScrollHeight(String message) {
    double? height = double.tryParse(message);
    if (height != null) {
      return height;
    }
    return 0;
  }

  toHistory() {
    push(const AppLotteryHistoryWeb(), Global.navigatorKey.currentContext!);
  }

  toLoginAction(dynamic msg) {
    int errorCode = 0;
    if (msg is int) {
      errorCode = msg;
    } else if (msg is String) {
      errorCode = int.tryParse(msg) != null ? int.parse(msg) : 0;
    }
    setUserDataFormat(false, {}, {}, {})
        .then((value) => toLogin(errorCode: errorCode));
  }

  payStr(String message) {
    if (int.tryParse(message) != null || double.tryParse(message) != null) {
      String payStr = numFormat(message);
      // print(" payStr ==== $payStr");
      // return;
      Get.find<HomeController>().refreshHomeData(format: false);
      AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.setLoopMode(LoopMode.off);
      int i = -1;
      audioPlayer.playerStateStream.listen((state) {
        switch (state.processingState) {
          // case ProcessingState.idle: ...
          // case ProcessingState.loading: ...
          // case ProcessingState.buffering: ...
          case ProcessingState.ready:
            break;
          case ProcessingState.completed:
            Future.delayed(Duration(milliseconds: i == -1 ? 120 : 60),
                () async {
              if (i + 2 > payStr.length) {
                audioPlayer.stop();
                audioPlayer.dispose();
                i = -1;
              } else {
                playMoneyAudio(payStr, ++i, audioPlayer);
              }
            });
            break;
          case ProcessingState.idle:
            break;
          case ProcessingState.loading:
            break;
          case ProcessingState.buffering:
            break;
        }
      });
      if (i == -1) {
        audioPlayer.setAsset("assets/audio/lottery/soundsuccess.wav");
        audioPlayer.play();
      }
      return;
    }
  }

  numFormat(String num) {
    List list = num.split(".");
    String text = "";
    String integeStr = list[0];
    String splitStr = "";
    // let integeNum = +(integeStr);
    for (var i = 0; i < integeStr.length; i++) {
      String str = integeStr.substring(i, i + 1);
      splitStr = integeStr.substring(i, integeStr.length);
      String step = textFormat(str);
      text += step;
      // int subNum = int.parse(integeStr.substring(i + 1, integeStr.length));
      String lastStr = text.substring(text.length - 1, text.length);

      if (lastStr != "万" &&
          lastStr != "千" &&
          lastStr != "百" &&
          lastStr != "十" &&
          lastStr != "零") {
        if (splitStr.length == 5) {
          text += "万";
        } else if (splitStr.length == 4) {
          text += "千";
        } else if (splitStr.length == 3) {
          text += "百";
        } else if (splitStr.length == 2) {
          text += "十";
        }
      }

      if (((lastStr == "万" && splitStr.length <= 3) ||
              (lastStr == "千" && splitStr.length <= 2) ||
              (lastStr == "百" && splitStr.length <= 2) ||
              (lastStr == "十" && splitStr.length <= 1)) &&
          int.tryParse(splitStr) != null &&
          int.parse(splitStr) > 0) {
        text += "零";
      }
      // if (splitStr.length == 1) {
      //   text += "元";
      // }
    }
    if (list.length > 1) {
      text += "点";
      String pointStr = list[1];
      if (pointStr.length > 2) {
        pointStr = pointStr.substring(0, 2);
      } else if (pointStr.length < 2) {
        pointStr = "${pointStr}0";
      }
      String pointSplitStr = "";
      for (var i = 0; i < pointStr.length; i++) {
        String str = pointStr.substring(i, i + 1);
        pointSplitStr = pointStr.substring(i, pointStr.length);
        String step = textFormat(str, zero: pointSplitStr.length != 1);
        text += step;
        // if (step != "") {
        //   if (pointSplitStr.length == 2) {
        //     text += "角";
        //   } else if (pointSplitStr.length == 1) {
        //     text += "分";
        //   }
        // }
        // let subNum = +(pointStr.substring(i + 1, pointStr.length));
      }
    }
    text += "元";
    // if (num)
    return text;
  }

  textFormat(text, {bool zero = false}) {
    switch (text) {
      case "0":
        return zero ? "零" : "";
      case "1":
        return "一";

      case "2":
        return "二";

      case "3":
        return "三";

      case "4":
        return "四";

      case "5":
        return "五";

      case "6":
        return "六";

      case "7":
        return "七";

      case "8":
        return "八";

      case "9":
        return "九";

      case ".":
        return "点";

      default:
        break;
    }
  }

  playMoneyAudio(String num, int index, AudioPlayer player) async {
    // int i = index;
    consoleLog("index", index);
    consoleLog("str", num.substring(index, index + 1));
    String src = "assets/audio/lottery/sound";

    switch (num.substring(index, index + 1)) {
      case "一":
        src += "1.wav";
        break;
      case "二":
        src += "2.wav";
        break;
      case "三":
        src += "3.wav";
        break;
      case "四":
        src += "4.wav";
        break;
      case "五":
        src += "5.wav";
        break;
      case "六":
        src += "6.wav";
        break;
      case "七":
        src += "7.wav";
        break;
      case "八":
        src += "8.wav";
        break;
      case "九":
        src += "9.wav";
        break;
      case "万":
        src += "wan.wav";
        break;
      case "千":
        src += "qian.wav";
        break;
      case "百":
        src += "bai.wav";
        break;
      case "十":
        src += "shi.wav";
        break;
      case "元":
        src += "yuan.wav";
        break;
      case "角":
        src += "jiao.wav";
        break;
      case "分":
        src += "fen.wav";
        break;
      case "点":
        src += "dot.wav";
        break;
      case "零":
        src += "0.wav";
        break;
      // case "元":
      // 	break;
      // case "元":
      // 	break;
      // case "元":
      // break;
      default:
        break;
    }
    if (src.contains("wav") || src.contains("mp3")) {
      await player.setAsset(src);
      await player.play();
    }

    // this.audioCtrl.src = src;
    // console.log("src === ", src);
    // this.audioCtrl.play();

    // switch () {
    // 	case value:
    // 		break;
    // 	default:
    // 		break;
    // }
  }
}
