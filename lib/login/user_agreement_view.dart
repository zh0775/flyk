import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cxhighversion2/util/native_ui.dart'
    if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:universal_html/html.dart' as html;

class UserAgreementViewBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserAgreementViewController>(UserAgreementViewController());
  }
}

class UserAgreementViewController extends GetxController {
  String viewType = "UserAgreementView_web";
  bool isFirst = true;
  String url = "";
  dataInit(String u) {
    if (!isFirst) return;
    isFirst = false;
    url = u;
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
        return html.IFrameElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = url
          ..style.border = 'none';
      });
    }
  }
}

class UserAgreementView extends GetView<UserAgreementViewController> {
  final bool isPrivacy;
  final String title;
  final String url;
  const UserAgreementView(
      {Key? key, this.isPrivacy = true, this.title = "", this.url = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(url);
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        title,
      ),
      body: getContent(),
    );
  }

  Widget getContent() {
    if (isPrivacy) {
      return url == null || url.isEmpty
          ? const CustomEmptyView(
              isLoading: true,
            )
          : kIsWeb
              ? HtmlElementView(viewType: controller.viewType)
              : WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: url,
                );
    } else {
      return url == null || url.isEmpty
          ? ghb(0)
          : Align(
              alignment: Alignment.topCenter,
              child: CustomHtmlView(
                src: url,
                width: 345.w,
                topMargin: 15.w,
              ),
            );
    }
  }
}
