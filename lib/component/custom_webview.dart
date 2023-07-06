import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/native_ui.dart' if (dart.library.html) 'package:cxhighversion2/util/web_ui.dart' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:universal_html/html.dart' as html;
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final String title;
  final String url;
  final bool inside;
  const CustomWebView({Key? key, this.title = "", this.url = "", this.inside = false}) : super(key: key);

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  String viewId = "CustomWebViewViewId";
  // InAppWebViewController? webCtrl;
  late WebViewController webCtrl;

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
    } else {
      webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            // print("onProgress $progress");
          },
          onPageStarted: (String url) {
            // print("onPageStarted $url");
          },
          onPageFinished: (String url) {
            // print("onPageFinished $url");
          },
          onWebResourceError: (WebResourceError error) {},
          // onNavigationRequest: (NavigationRequest request) {
          //   if (request.url.startsWith('https://www.youtube.com/')) {
          //     return NavigationDecision.prevent;
          //   }
          //   return NavigationDecision.navigate;
          // },
        ))
        ..loadRequest(Uri.parse(widget.url));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.inside
        ? contentView()
        : Scaffold(
            appBar: getDefaultAppBar(context, widget.title, elevation: 4, shadowColor: AppColor.lineColor, color: Colors.white), body: contentView());
    // WebView(
    //     javascriptMode: JavascriptMode.unrestricted,
    //     initialUrl: widget.url,
    //   ));
  }

  Widget contentView() {
    return widget.url.isEmpty
        ? const CustomEmptyView(
            isLoading: true,
          )
        : kIsWeb
            ? HtmlElementView(viewType: viewId, onPlatformViewCreated: (id) {})
            :
            // : InAppWebView(
            //     initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            // onWebViewCreated: (ctrl) {
            //   ctrl.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url)));
            //   // webCtrl = ctrl;
            //   // webCtrl.loadData(data: controller.certificateHtml);
            // },
            // );
            WebViewWidget(controller: webCtrl);
  }
}
