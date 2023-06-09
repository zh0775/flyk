import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/util/app_default.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:cxhighversion2/util/native_ui.dart' if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;

class FLFullBackController extends GetxController {
  String webUrl = "";
  String viewId = "FLFullBackControllerViewId";

  setToken() {
    /// 在iframe的情况下请求H5方法
    js.context.callMethod("callFunction", ["FLFullBackControllerViewId", "setToken", AppDefault().token]);
  }

  back() {
    Get.back();
  }

  logout() {
    setUserDataFormat(false, {}, {}, {}).then((value) => toLogin(isErrorStatus: true, errorCode: 203));
  }

  needLogin() {
    popToLogin();
  }

  // WebViewController? webCtrl;
  InAppWebViewController? webCtrl;
  @override
  void onInit() {
    webUrl = "${HttpConfig.flUrl}?token=${AppDefault().token}";
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
        return html.IFrameElement()
          ..id = viewId
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = webUrl
          ..style.border = 'none';
      });
    } else {
      // webCtrl = WebViewController()
      //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
      //   ..addJavaScriptChannel("setOldAppStatus", onMessageReceived: (message) {
      //     back();
      //   })
      //   ..addJavaScriptChannel("logout", onMessageReceived: (message) {
      //     logout();
      //   })
      //   ..loadRequest(Uri.parse(webUrl));
    }
    super.onInit();
  }
}

class FLFullBack extends StatelessWidget {
  /// 付利全返 旧版付立优客H5
  const FLFullBack({super.key});

  @override
  Widget build(BuildContext context) {
    paddingSizeBottom(context);
    return AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            // appBar: getDefaultAppBar(context, "付利全返"),
            body: SafeArea(
                child: GetBuilder<FLFullBackController>(
                    init: FLFullBackController(),
                    builder: (controller) {
                      return kIsWeb
                          ? HtmlElementView(
                              viewType: controller.viewId,
                              onPlatformViewCreated: (id) {
                                List<html.Node> es = html.document.getElementsByTagName("flt-platform-view");
                                if (es.isNotEmpty) {
                                  html.Node node = es[0];
                                  // node.append(styleElement);
                                  html.Element? e = node.ownerDocument!.getElementById(controller.viewId);
                                  // node.insertBefore(node, e);
                                  if (e != null) {
                                    e.onClick.listen((event) {
                                      //   // 监听
                                      // js.context.callMethod("htmlAddCallback", [controller.viewId, "setOldAppStatus", controller.back]);
                                      // // js.context.callMethod("htmlAddCallback", [controller.viewId, "setOldAppStatus", controller.needLogin]);
                                      // js.context.callMethod("htmlAddCallback", [controller.viewId, "logout", controller.logout]);
                                    });
                                    e.onLoad.listen((event) {
                                      //   // 监听
                                      js.context.callMethod("htmlAddCallback", [controller.viewId, "setOldAppStatus", controller.back]);
                                      // js.context.callMethod("htmlAddCallback", [controller.viewId, "setOldAppStatus", controller.needLogin]);
                                      js.context.callMethod("htmlAddCallback", [controller.viewId, "logout", controller.logout]);
                                    });
                                    // js.context.callMethod("htmlAddCallback", [controller.viewId, "setOldAppStatus", controller.back]);
                                    // js.context.callMethod("htmlAddCallback", [controller.viewId, "logout", controller.logout]);
                                  }
                                }
                              })
                          : InAppWebView(onWebViewCreated: (webCtrl) {
                              controller.webCtrl = webCtrl;
                              webCtrl.loadUrl(urlRequest: URLRequest(url: Uri.parse(controller.webUrl)));
                              webCtrl.addWebMessageListener(WebMessageListener(
                                jsObjectName: "setOldAppStatus",
                                onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
                                  controller.back();
                                },
                              ));
                              webCtrl.addJavaScriptHandler(
                                  handlerName: "setOldAppStatus",
                                  callback: (arguments) {
                                    controller.back();
                                  });
                              webCtrl.addJavaScriptHandler(
                                  handlerName: "logout",
                                  callback: (arguments) {
                                    controller.logout();
                                  });
                            });

                      // WebViewWidget(controller: controller.webCtrl!);
                    }))));
  }

  // Set<JavascriptChannel> getChannelSet() {
  //   return {backChannel()};
  // }

  // JavascriptChannel backChannel() {
  //   return JavascriptChannel(
  //       name: 'setOldAppStatus',
  //       onMessageReceived: (JavascriptMessage message) {
  //         if (message.message.isNotEmpty) {}
  //         back();
  //       });
  // }

  // JavascriptChannel needLoginChannel() {
  //   return JavascriptChannel(
  //       name: 'setOldAppStatus',
  //       onMessageReceived: (JavascriptMessage message) {
  //         if (message.message.isNotEmpty) {}
  //         needLogin();
  //       });
  // }
}
