import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cxhighversion2/util/native_ui.dart'
    if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:universal_html/js.dart' as js;

class AppLotteryHistoryWeb extends StatefulWidget {
  const AppLotteryHistoryWeb({super.key});

  @override
  State<AppLotteryHistoryWeb> createState() => _AppLotteryHistoryWebState();
}

class _AppLotteryHistoryWebState extends State<AppLotteryHistoryWeb> {
  String viewId = "AppLotteryHistoryWebViewId";
  String initialUrl =
      "${HttpConfig.lotteryUrl}pages_award/my_prize/my_prize?token=${AppDefault().token}&baseUrl=${HttpConfig.baseUrl}";

  @override
  void initState() {
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
        return html.IFrameElement()
          ..id = viewId
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = initialUrl
          ..style.border = 'none';
      });
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppLotteryHistoryWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "中奖记录"),
      body: kIsWeb
          ? HtmlElementView(
              viewType: viewId,
              onPlatformViewCreated: (id) {
                List<html.Node> es =
                    html.document.getElementsByTagName("flt-platform-view");
                if (es.isNotEmpty) {
                  html.Node node = es[0];
                  // node.append(styleElement);
                  html.Element? e = node.ownerDocument!.getElementById(viewId);
                  // node.insertBefore(node, e);
                  if (e != null) {
                    // e.onScroll.listen((event) {
                    //   consoleLog("onScroll", event);
                    // });
                    e.onLoad.listen((event) {
                      // 监听
                      js.context.callMethod("htmlAddCallback",
                          [viewId, "toLoginAction", toLoginAction]);
                    });
                  }
                }
              },
            )
          : WebView(
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (url) {},
              onWebViewCreated: (controller) {},
              javascriptChannels: {
                backJsChannel(context),
                toLoginJsChannel(context)
              },
            ),
    );
  }

  JavascriptChannel backJsChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'back',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message.isNotEmpty) {
          backAction();
        }
      },
    );
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

  JavascriptChannel toLoginJsChannel(BuildContext context) {
    return JavascriptChannel(
      name: 'toLoginAction',
      onMessageReceived: (JavascriptMessage message) {
        if (message.message.isNotEmpty) {
          toLoginAction(message.message);
        }
      },
    );
  }

  backAction() {
    Get.back();
  }
}
