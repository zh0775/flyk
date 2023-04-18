import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class RefundProgressPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<RefundProgressPageController>(RefundProgressPageController());
  }
}

class RefundProgressPageController extends GetxController {
  // 退款进度 头部数据
  Map refundInfo = {"orderNo": 'SF130123056460', "orderStatus": 1, "refundAmount": 953, "refundMarked": '(7个工作日内到账）'};

  String orderStatuSwitch(index) {
    String title = "";
    switch (index) {
      case 1:
        title = "申请退款中";
        break;
      case 2:
        title = "申请退货退款中";
        break;
      default:
    }
    return title;
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class RefundProgressPage extends GetView<RefundProgressPageController> {
  const RefundProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '退款进度'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [orderStatusBox(), stepsWrpper()],
        ),
      ),
    );
  }

  Widget orderStatusBox() {
    return Container(
      width: 375.w - 15.w * 2,
      padding: EdgeInsets.fromLTRB(14.5.w, 23.5.w, 14.5.w, 23.5.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        children: [
          Row(
            children: [
              getSimpleText("订单编号", 14, const Color(0xFF999999)),
              gwb(14.5),
              getSimpleText("${controller.refundInfo['orderNo']}", 14, const Color(0xFF333333)),
            ],
          ),
          ghb(16),
          Row(
            children: [
              getSimpleText("订单状态", 14, const Color(0xFF999999)),
              gwb(14.5),
              getSimpleText(controller.orderStatuSwitch(controller.refundInfo['orderStatus']), 14, const Color(0xFFFF6231)),
            ],
          ),
          ghb(16),
          Row(
            children: [
              getSimpleText("退款金额", 14, const Color(0xFF999999)),
              gwb(14.5),
              getSimpleText("953积分（7个工作日内到账）", 14, const Color(0xFF333333)),
            ],
          ),
        ],
      ),
    );
  }

  Widget stepsWrpper() {
    return Container(
      width: 375.w - 15.w * 2,
      margin: EdgeInsets.only(top: 15.w),
      padding: EdgeInsets.fromLTRB(10.w, 20.w, 10.w, 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        children: [
          stepsItem(4, 4),
          stepsItem(3, 4),
          stepsItem(2, 4),
          stepsItem(1, 4),
        ],
      ),
    );
  }

  Widget stepsItem(int index, int current) {
    return Container(
        width: 375.w - 15.w * 2,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 3.w, right: 10.w),
                    width: 2.w,
                    color: Color(0XFFEEEEEE),
                  ),
                  index == current
                      ? Image.asset(
                    assetsName("business/sale/icon_refund_success"),
                    width: 14.w,
                    height: 14.w,
                    fit: BoxFit.fitWidth,
                  )
                      : Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(color: Color(0xFFCCCCCC), borderRadius: BorderRadius.all(Radius.circular(7.w))),
                  )
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "您的订单正在进行审核，请耐心等待",
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14.w,
                      ),
                    ),
                    ghb(14),
                    Text(
                      "2022-11-29 23:49:7",
                      style: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12.w,
                      ),
                    ),
                    ghb(33),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
