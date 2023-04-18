import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/machine/aftersale/machine_aftersale.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineOrderLaunchBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineOrderLaunchController>(
        MachineOrderLaunchController(datas: Get.arguments));
  }
}

class MachineOrderLaunchController extends GetxController {
  final dynamic datas;
  MachineOrderLaunchController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();

  bool needAftersale = false;

  int status = 0;
  Map orderData = {};

  String orderTitle = "";
  String orderSubTitle = "";

  List machineList = [];
  List productList = [];
  String orderTypeName = "";
  int orderNum = 0;

  buttonsClick(MachineOrderBtnType type) {
    if (type == MachineOrderBtnType.cancel) {
      util.loadCancelOrder(
        orderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.delete) {
      util.loadDeleteOrder(
        orderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.confirmTake) {
      util.loadConfirmTake(
        orderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    }
  }

  loadDetail() {
    if (orderData["id"] == null) {
      return;
    }
    simpleRequest(
      url: Urls.userLevelGiftOrderShow(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          orderData = json["data"] ?? {};
          productList = orderData["commodity"] ?? [];
          for (var e in productList) {
            productCount += (e["num"] ?? 1) as int;
          }
          getOrderFormat();
          update();
        }
      },
      after: () {},
    );
  }

  toAfterSafe(Map data, int index) {
    push(
        MachineAftersale(
          orderData: orderData,
          aftersaleIndex: index,
        ),
        Global.navigatorKey.currentContext!);
  }

  getOrderFormat() {
    // needAftersale = status == 2 || status == 3;
    // productList = orderData["product"] ?? [];
    // for (var e in productList) {
    //   orderNum += (e["num"] ?? 0) as int;
    //   for (var i = 0; i < (e["num"] ?? 1); i++) {
    //     machineList.add({
    //       "no": "T550006698",
    //       "name": e["name"] ?? "",
    //       "img": e["img"] ?? "",
    //       "status": 0,
    //     });
    //   }
    // }
    status = orderData["orderState"] ?? -1;
    switch (status) {
      case 0:
        orderTitle = "待支付";
        orderSubTitle = "正在等待买家付款";
        break;
      case 1:
        orderTitle = "待发货";
        orderSubTitle = "等待卖家发货";
        break;
      case 2:
        orderTitle = "待收货";
        orderSubTitle =
            "正在等待买家确认收货，${orderData["courierNo"] != null && orderData["courierNo"].isNotEmpty ? "物流单号：" : ""}${orderData["courierNo"] ?? ""}";
        break;
      case 3:
        orderTitle = "已完成";
        orderSubTitle = "订单已完成";
        break;
      case 4:
        orderTitle = "已作废";
        orderSubTitle = "订单已作废";
        break;
      case 5:
        orderTitle = "售后中";
        orderSubTitle = "订单正在售后中";
        break;
      case 6:
        orderTitle = "支付超时";
        orderSubTitle = "订单支付超时";
        break;
      case 7:
        orderTitle = "已取消";
        orderSubTitle = "订单已取消";
        break;
    }
    // int orderType = util.getOrderStatus(status);
    switch (orderData["orderType2"] ?? -1) {
      case 1:
        orderTypeName = "采购单";
        break;
      case 2:
        orderTypeName = "换货单";
        break;
      case 3:
        orderTypeName = "退货单";
        break;
      default:
    }
    machineList = orderData["deliveryNote"] ?? [];
  }

  int productCount = 0;
  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      orderData = datas["orderData"] ?? {};
      status = orderData["orderState"] ?? -1;
      productList = orderData["commodity"] ?? [];
      for (var e in productList) {
        productCount += (e["num"] ?? 1) as int;
      }
      loadDetail();
      getOrderFormat();
    }
    super.onInit();
  }
}

class MachineOrderLaunch extends GetView<MachineOrderLaunchController> {
  const MachineOrderLaunch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "订单详情"),
      body: Stack(children: [
        Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: 120.w,
            child: GetBuilder<MachineOrderLaunchController>(
              builder: (_) {
                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    const Color(0xFF5081F9),
                    AppColor.theme,
                  ])),
                  child: Column(
                    children: [
                      ghb(23),
                      sbRow([
                        getSimpleText(controller.orderTitle, 18, Colors.white,
                            isBold: true),
                      ], width: 375 - 30 * 2),
                      ghb(8),
                      sbRow([
                        getSimpleText(
                            controller.orderSubTitle, 12, Colors.white),
                      ], width: 375 - 30 * 2),
                    ],
                  ),
                );
              },
            )),
        GetBuilder<MachineOrderLaunchController>(
          builder: (_) {
            return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: controller.util.haveBtn(
                  controller.status,
                  orderType: MachineOrderType.sponsor,
                  detail: true,
                )
                    ? 50.w + paddingSizeBottom(context)
                    : 0,
                child: Container(
                  padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: const Color(0x0D000000), blurRadius: 4.w)
                  ]),
                  child: Center(
                    child: sbhRow([
                      gwb(0),
                      controller.util.getButtons(
                        controller.status,
                        onPressed: controller.buttonsClick,
                      )
                    ], width: 375 - 16 * 2, height: 50),
                  ),
                ));
          },
        ),
        GetBuilder<MachineOrderLaunchController>(
          builder: (_) {
            return Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: controller.util.haveBtn(
                  controller.status,
                  orderType: MachineOrderType.sponsor,
                  detail: true,
                )
                    ? 50.w + paddingSizeBottom(context)
                    : 0,
                child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: GetBuilder<MachineOrderLaunchController>(
                      builder: (_) {
                        return Column(
                          children: [
                            ghb(94),
                            gwb(375),
                            Container(
                              width: 345.w,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.w)),
                              child: Column(
                                children: [
                                  ...List.generate(
                                      controller.productList.length, (index) {
                                    return centClm([
                                      controller.util.orderDetailProductCell(
                                          index,
                                          controller.productList[index],
                                          controller.productList.length,
                                          bottomMargin:
                                              controller.status == 3 ? 0 : 7.5),
                                      controller.status == 3 ||
                                              controller.status == 5
                                          ? CustomButton(
                                              onPressed: () {
                                                controller.toAfterSafe(
                                                    controller
                                                        .productList[index],
                                                    index);
                                              },
                                              child: Container(
                                                width: 65.w,
                                                height: 25.w,
                                                margin: EdgeInsets.only(
                                                    right: 10.w, bottom: 5.w),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.w / 2),
                                                    border: Border.all(
                                                        width: 0.5.w,
                                                        color: AppColor
                                                            .textGrey5)),
                                                child: getSimpleText(
                                                    "申请售后", 12, AppColor.text2),
                                              ),
                                            )
                                          : ghb(0),
                                    ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end);
                                  }),
                                  ghb(21.5),
                                  controller.util.orderDetailInfoCell("订单类型",
                                      t2: controller.orderTypeName),
                                  controller.util.orderDetailInfoCell("采购类型",
                                      t2: (controller.orderData["purType"] ??
                                                  0) ==
                                              0
                                          ? ""
                                          : (controller.orderData["purType"] ??
                                                      0) ==
                                                  1
                                              ? "正常采购"
                                              : "续约奖励采购"),
                                  // controller.util.orderDetailInfoCell("商品单价",
                                  //     t2: "￥${controller.orderData["totalPrice"] ?? 0}"),
                                  controller.util.orderDetailInfoCell("数量",
                                      t2: "${controller.productCount}"),
                                  controller.util.orderDetailInfoCell(
                                    "总计",
                                    rightWidget: getSimpleText(
                                        "￥${priceFormat((controller.orderData["totalPrice"] ?? 0))}",
                                        15,
                                        AppColor.red,
                                        isBold: true),
                                  ),
                                  ghb(10)
                                ],
                              ),
                            ),
                            ghb(15),
                            Container(
                              width: 345.w,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.w)),
                              child: Column(
                                children: [
                                  ghb(15),
                                  controller.util.orderDetailInfoCell("订单编号",
                                      t2: controller.orderData["orderNo"],
                                      type: 1,
                                      height: 28),
                                  controller.util.orderDetailInfoCell("兑换时间",
                                      t2: controller.orderData["processTime"] ??
                                          "",
                                      type: 1,
                                      height: 28),
                                  controller.util.orderDetailInfoCell("付款方式",
                                      t2: "线下付款", type: 1, height: 28),
                                  controller.util.orderDetailInfoCell("订单状态",
                                      t2: controller
                                              .orderData["orderStateStr"] ??
                                          "",
                                      type: 1,
                                      height: 28),
                                  (controller.orderData["deliveryMetho"] ??
                                              1) ==
                                          0
                                      ? ghb(0)
                                      : (controller.orderData[
                                                      "deliveryMetho"] ??
                                                  1) ==
                                              2
                                          ? controller.util.orderDetailInfoCell(
                                              "收货方式",
                                              t2: "线下自提",
                                              type: 1,
                                              height: 28)
                                          : centClm([
                                              controller.util
                                                  .orderDetailInfoCell("收货人",
                                                      t2: controller.orderData[
                                                              "recipient"] ??
                                                          "",
                                                      type: 1,
                                                      height: 28),
                                              controller.util.orderDetailInfoCell(
                                                  "手机号码",
                                                  t2: controller.orderData[
                                                          "recipientMobile"] ??
                                                      "",
                                                  type: 1,
                                                  height: 28),
                                              controller.util
                                                  .orderDetailInfoCell("收货地址",
                                                      t2: controller.orderData[
                                                          "userAddress"],
                                                      type: 1,
                                                      maxLines: 10),
                                            ]),
                                  ghb(15)
                                ],
                              ),
                            ),
                            ghb(15),
                            controller.machineList.isEmpty
                                ? ghb(0)
                                : controller.util.orderMachineListView(
                                    controller.machineList),
                            ghb(20)
                          ],
                        );
                      },
                    )));
          },
        )
      ]),
    );
  }
}
