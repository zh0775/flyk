import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:matcher/matcher.dart';

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class ApplyForRefundPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplyForRefundPageController>(() => ApplyForRefundPageController());
  }
}

class ApplyForRefundPageController extends GetxController {
  List RefundTyleList = [
    {"id": 1, "name": "退款方式1"},
    {"id": 2, "name": "退款方式2"}
  ];
}

class ApplyForRefundPage extends GetView<ApplyForRefundPageController> {
  const ApplyForRefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "申请退款",
        action: [],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              RefundFormInput(),
            ],
          ),
        ),
      ),
    );
  }

  // 退款原因  select
  Widget RefundFormInput() {
    return Container(
      width: 345.w,
      padding: EdgeInsets.all(15.w),
      margin: EdgeInsets.only(top: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        children: [
          sbRow([
            getSimpleText('退款原因', 14, const Color(0xFF565B66), textHeight: 1.1),
            gwb(14.5.w),
            CustomButton(
              onPressed: () {},
              child: SizedBox(
                width: (345.w - 15 * 2.w - 60.w - 14.5.w - 0.1.w),
                height: 45.w,
                child: sbRow([
                  getSimpleText('请选择', 14, Color(0xFFCCCCCC), textHeight: 1.1),
                  Image.asset(
                    assetsName('mine/icon_right_arrow'),
                    width: 12.w,
                    fit: BoxFit.fitWidth,
                  ),
                ]),
              ),
            )
          ]),
          gline(345.w - 15.w * 2 - 0.1.w, 1.w),
          sbRow([
            getSimpleText('退款金额', 14, const Color(0xFF565B66), textHeight: 1.1),
            gwb(14.5.w),
            SizedBox(
              width: (345.w - 15 * 2.w - 60.w - 14.5.w - 0.1.w),
              height: 45.w,
              child: sbRow([
                getSimpleText('953积分', 14, Color(0xFF333333), textHeight: 1.1),
              ]),
            ),
          ]),
          gline(345.w - 15.w * 2 - 0.1.w, 1.w),
          ghb(18.5.w),
          sbRow(crossAxisAlignment: CrossAxisAlignment.start, [
            getSimpleText('退款说明', 14, const Color(0xFF565B66), textHeight: 1.1),
            gwb(14.5.w),
            SizedBox(
              width: (345.w - 15 * 2.w - 60.w - 14.5.w - 0.1.w),
              child: Text("此页面已存在 复制+修改即可"),
            )
          ])
        ],
      ),
    );
  }
}
