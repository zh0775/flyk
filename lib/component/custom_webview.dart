import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cxhighversion2/util/native_ui.dart'
    if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:universal_html/html.dart' as html;

class CustomWebView extends StatefulWidget {
  final String title;
  final String url;
  const CustomWebView({Key? key, this.title = "", this.url = ""})
      : super(key: key);

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  String viewId = "CustomWebViewViewId";

  @override
  void initState() {
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(viewId, (int id) {
        return html.IFrameElement()
          ..id = viewId
          ..style.width = '100%'
          ..style.height = '100%'
          ..src = widget.url
          ..style.border = 'none';
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, widget.title,
            elevation: 4, shadowColor: AppColor.lineColor, color: Colors.white),
        body: widget.url.isEmpty
            ? const CustomEmptyView(
                isLoading: true,
              )
            : kIsWeb
                ? HtmlElementView(
                    viewType: viewId,
                    onPlatformViewCreated: (id) {},
                  )
                : WebView(
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: widget.url,
                  ));
  }
}
