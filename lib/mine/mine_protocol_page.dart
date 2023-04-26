/*
  协议展示
*/
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class MineProtocolPage extends StatelessWidget {
  final String title;
  final String src;
  final double paddingVertical;
  final double paddingHorizontal;

  const MineProtocolPage(
      {super.key,
      this.title = "",
      this.src = "",
      this.paddingVertical = 15,
      this.paddingHorizontal = 15});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, title),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: paddingVertical.w,
                      horizontal: paddingHorizontal.w),
                  child: HtmlWidget(
                    src,
                    textStyle:
                        TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
                  )),
              SizedBox(height: paddingSizeBottom(context))
            ],
          ),
        ));
  }
}
