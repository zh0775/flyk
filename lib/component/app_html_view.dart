import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_html_view.dart';
import 'package:cxhighversion2/util/app_default.dart';

class AppHtmlView extends StatelessWidget {
  final String title;
  final String src;
  const AppHtmlView({
    Key? key,
    this.title = "",
    this.src = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, title),
      body: src == null || src.isEmpty ? ghb(0) : CustomHtmlView(src: src),
    );
  }
}
