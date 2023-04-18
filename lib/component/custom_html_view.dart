import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import 'package:get/get.dart';

class CustomHtmlViewController extends GetxController {
  double scale = 1;
}

class CustomHtmlView extends StatelessWidget {
  final String src;
  final Widget? loadingWidget;
  final double width;
  final double? height;
  final double topMargin;
  const CustomHtmlView({
    Key? key,
    required this.src,
    this.loadingWidget,
    this.width = 375,
    this.height,
    this.topMargin = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomHtmlViewController>(
      init: CustomHtmlViewController(),
      initState: (_) {},
      builder: (controller) {
        // dom.Document document = htmlparser.parse(src);
        return Transform.scale(
          scale: controller.scale,
          child: SizedBox(
            width: width.w,
            // height: height != null ? height!.w : null,
            child:
                // WebViewPlus(
                //   javascriptMode: JavascriptMode.unrestricted,
                //   onWebViewCreated: (controller) {},
                // ),
                SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ghb(topMargin),
                        src.isNotEmpty ? HtmlWidget(src) : ghb(0)
                      ],
                    )),
          ),
        );
      },
    );
  }
}
