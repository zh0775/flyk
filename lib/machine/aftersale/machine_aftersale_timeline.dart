import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MachineAftersaleTimelineBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineAftersaleTimelineController>(
        MachineAftersaleTimelineController(datas: Get.arguments));
  }
}

class MachineAftersaleTimelineController extends GetxController {
  final dynamic datas;
  MachineAftersaleTimelineController({this.datas});

  Map aftersaleOrderData = {};

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  int serviceType = 0;
  int status = -1;

  loadDetail() {
    // if (orderData["id"] == null) {
    //   return;
    // }
    if (aftersaleOrderData.isEmpty || !(aftersaleOrderData.values.length > 1)) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.userLevelGiftAfterSaleShow(aftersaleOrderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          aftersaleOrderData = json["data"] ?? {};
          getOrderFormat();
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  String orderTitle = "";
  String orderSubTitle = "";
  getOrderFormat() {
    serviceType = aftersaleOrderData["serviceType"] ?? 0;
    status = aftersaleOrderData["serviceState"] ?? -1;

    switch (status) {
      case 0:
        orderTitle = "待审核";
        orderSubTitle = isMine
            ? "申请已提交，等待平台同意"
            : "用户发起${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退货"}申请，等待平台同意。";
        break;
      case 1:
        orderTitle =
            "待${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退货"}";
        orderSubTitle = isMine
            ? "平台已同意${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退款"}，请填写${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退货"}物流信息。"
            : "已同意${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退货"}申请，等待用户寄回。";
        break;
      case 2:
        orderTitle = "待回收";
        orderSubTitle = isMine
            ? "${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退货"}商品已寄回，等待回收。"
            : "${(aftersaleOrderData["serviceType"] ?? 1) == 1 ? "换货" : "退货"}商品已寄回，等待回收。物流单号：${aftersaleOrderData["cpiroerON"] ?? ""}";
        break;
      case 3:
        orderTitle =
            (aftersaleOrderData["serviceType"] ?? 1) == 1 ? "已确认回收" : "退货完成";
        orderSubTitle = (aftersaleOrderData["serviceType"] ?? 1) == 1
            ? "换货商品已确认回收"
            : isMine
                ? "退款成功，款项已退回原支付账户"
                : "订单退货完成";
        break;
      case 4:
        orderTitle = "已发货";
        orderSubTitle = "平台已重新发货，等待买家确认。";
        break;
      case 5:
        orderTitle = "已作废";
        orderSubTitle = "订单已作废";
        break;
      case 6:
        orderTitle = "已取消";
        orderSubTitle = "订单已取消";
        break;
    }
  }

  bool isMine = true;

  @override
  void onInit() {
    aftersaleOrderData = datas["orderData"] ?? {};
    isMine = datas["isMine"] ?? true;
    getOrderFormat();
    loadDetail();
    super.onInit();
  }
}

class MachineAftersaleTimeline
    extends GetView<MachineAftersaleTimelineController> {
  const MachineAftersaleTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "售后进度"),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              titleView(),
            ],
          )),
    );
  }

  Widget titleView() {
    double cellHeight = 30;
    double vMargin = 9;
    double width = 315;
    return GetBuilder<MachineAftersaleTimelineController>(
      builder: (_) {
        return Container(
          width: 345.w,
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 15.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w), color: Colors.white),
          child: Column(
            children: [
              ghb(vMargin),
              sbhRow([
                getWidthText("服务单号", 14, AppColor.text3, 70, 1,
                    textHeight: 1.3),
                getWidthText(controller.aftersaleOrderData["serviceNo"] ?? "",
                    14, AppColor.text2, width - 70, 1,
                    textHeight: 1.3),
              ], width: width, height: cellHeight),
              sbhRow([
                getWidthText("订单状态", 14, AppColor.text3, 70, 1,
                    textHeight: 1.3),
                getWidthText(
                    controller.orderTitle, 14, AppColor.theme, width - 70, 1,
                    textHeight: 1.3),
              ], width: width, height: cellHeight),
              controller.aftersaleOrderData["returnAmount"] != null &&
                      controller.aftersaleOrderData["returnAmount"] > 0
                  ? sbhRow([
                      getWidthText("退款金额", 14, AppColor.text3, 70, 1,
                          textHeight: 1.3),
                      getWidthText(
                          "￥${priceFormat(controller.aftersaleOrderData["returnAmount"] ?? 0)}",
                          14,
                          AppColor.red,
                          width - 70,
                          1,
                          isBold: true,
                          textHeight: 1.3),
                    ], width: width, height: cellHeight)
                  : ghb(0),
              ghb(vMargin),
            ],
          ),
        );
      },
    );
  }
}
