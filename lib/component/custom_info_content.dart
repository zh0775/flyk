import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class CustomInfoContent extends StatelessWidget {
  final String content;
  final String name;
  final String title;
  final bool isText;
  const CustomInfoContent(
      {super.key,
      this.content = "",
      this.name = "",
      this.title = "",
      this.isText = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, title,
          leading: CustomButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: centRow([
              defaultBackButtonView(),
              getSimpleText("关闭", 14, AppColor.text2, textHeight: 1.5)
            ]),
          ),
          leadingWidth: 80.w),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: 375.w,
              color: Colors.white,
              constraints: BoxConstraints(minHeight: 300.w),
              child: Column(
                children: [
                  gwb(375),
                  Visibility(visible: name.isNotEmpty, child: ghb(18)),
                  Visibility(
                    visible: name.isNotEmpty,
                    child: getWidthText(name, 15, AppColor.text, 345, 10,
                        isBold: true),
                  ),
                  ghb(18),
                  isText
                      ? getWidthText(content, 14, AppColor.text2, 345, 1000)
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: HtmlWidget(content),
                        ),
                  ghb(50)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
