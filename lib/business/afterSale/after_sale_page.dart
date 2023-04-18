import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cxhighversion2/business/afterSale/apply_for_refund.dart';

import 'package:get/get.dart';

class AfterSalePageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AfterSalePageController>(() => AfterSalePageController());
  }
}

class AfterSalePageController extends GetxController {}

class AfterSalePage extends GetView<AfterSalePageController> {
  const AfterSalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(
          context,
          "我的售后",
          action: [],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(top: 15.w),
              width: 345.w,
              padding: EdgeInsets.fromLTRB(12.w, 0.w, 12.w, 0.w),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: List.generate(2, (index) {
                  List data = [
                    {"title": "我要退款（无需退货）", "subtitle": "没收到货，或与卖家协商后只退款不退货", "iconImg": "business/sale/icon_refund_speed"},
                    {"title": "我要退款退货", "subtitle": "已收到货，需要退还货物", "iconImg": "business/sale/icon_return_goods"}
                  ];
                  return SizedBox(
                    child: AfterSaleItem(data[index], index),
                  );
                }),
              ),
            ),
          ),
        ));
  }

  Widget AfterSaleItem(item, index) {
    return Container(
      width: 345.w,
      padding: EdgeInsets.only(top: 23.w),
      child: CustomButton(
        onPressed: () {
          if (index == 0) {
            push(const ApplyForRefundPage(), null, binding: ApplyForRefundPageBinding());
          }
        },
        child: Column(
          children: [
            sbRow(
              [
                Image.asset(
                  assetsName(item['iconImg']),
                  height: 30.w,
                  fit: BoxFit.fitHeight,
                ),
                Center(
                  child: sbRow([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getSimpleText(item['title'], 14, const Color(0xFF565B66), textHeight: 1.1),
                        getSimpleText(item['subtitle'], 12, const Color(0xFF565B66), textHeight: 1.1),
                      ],
                    ),
                    Image.asset(
                      assetsName('mine/icon_right_arrow'),
                      width: 12.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ], width: 345.w - 30.w - 23.w * 2 - 10.w),
                )
              ],
            ),
            ghb(23),
            index == 1 ? ghb(0) : gline(345.w, 1.w)
          ],
        ),
      ),
    );
  }
}
