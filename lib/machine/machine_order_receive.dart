import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/machine/machine_order_ship.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineOrderReceiveBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineOrderReceiveController>(
        MachineOrderReceiveController(datas: Get.arguments));
  }
}

class MachineOrderReceiveController extends GetxController {
  final dynamic datas;
  MachineOrderReceiveController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();
  int status = 0;
  Map orderData = {};

  List productList = [];
  List machineList = [];
  String orderTypeName = "";

  buttonsClick(MachineOrderBtnType type) {
    if (type == MachineOrderBtnType.applyAfterSafe) {
      push(const MachineOrderShip(), null,
          binding: MachineOrderShipBinding(),
          arguments: {"orderData": orderData});
    } else if (type == MachineOrderBtnType.confirmPay) {
      util.loadCheckPayOrder(
        orderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.invalid) {
      util.loadInvalidOrder(
        orderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.immediatedelivery) {
      push(const MachineOrderShip(), null,
          binding: MachineOrderShipBinding(),
          arguments: {
            "orderData": orderData,
          });
    } else if (type == MachineOrderBtnType.aftersaleImmediatedelivery) {
      ShowToast.normal("请到售后订单中发货");
      return;
    }
  }

  int parenID = 0;

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
          status = orderData["orderState"] ?? -1;
          getOrderFormat();
          update();
        }
      },
      after: () {},
    );
  }

  int orderNum = 0;
  getOrderFormat() {
    productList = orderData["commodity"] ?? [];
    orderNum = 0;
    for (var e in productList) {
      orderNum += (e["num"] ?? 1) as int;
    }
    status = orderData["orderState"] ?? -1;

    parenID = orderData["parenID"] ?? 0;
    switch (status) {
      case 0:
        // orderTitle = "待支付";
        // orderSubTitle = "正在等待买家付款";
        break;
      case 1:
        // orderTitle = "待时候";
        // orderSubTitle = "正在等待卖家";
        break;
    }

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

  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      orderData = datas["orderData"] ?? {};
      getOrderFormat();
      loadDetail();
    }
    super.onInit();
  }
}

class MachineOrderReceive extends GetView<MachineOrderReceiveController> {
  const MachineOrderReceive({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "订单详情"),
        body: Stack(
          children: [
            GetBuilder<MachineOrderReceiveController>(
              builder: (_) {
                return Positioned.fill(
                  bottom: controller.util.haveBtn(controller.status,
                          orderType: MachineOrderType.receive, detail: true)
                      ? 50.w + paddingSizeBottom(context)
                      : 0,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        gwb(375),
                        sbhRow([
                          getSimpleText(
                              "订单编号：${controller.orderData["orderNo"]}",
                              12,
                              AppColor.text3),
                          getSimpleText(
                              "${controller.orderData["processTime"]}",
                              12,
                              AppColor.text3),
                        ], width: 375 - 15 * 2, height: 60),
                        Row(
                          children: [
                            gwb(15),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12.w),
                                child: CustomNetworkImage(
                                  src: AppDefault().imageUrl +
                                      (controller.orderData["u_Avatar"] ?? ""),
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.cover,
                                )),
                            gwb(10),
                            getSimpleText(
                                controller.orderData["u_Name"] != null &&
                                        controller
                                            .orderData["u_Name"].isNotEmpty
                                    ? controller.orderData["u_Name"]
                                    : controller.orderData["u_Mobile"] ?? "",
                                15,
                                AppColor.text,
                                isBold: true,
                                textHeight: 1.3),
                            gwb(5),
                            getSimpleText("发起的", 15, AppColor.text3,
                                textHeight: 1.3),
                          ],
                        ),
                        ghb(16.5),
                        addressView(),
                        ghb(15),
                        machineInfoView(),
                        ghb(15),
                        orderInfoView(),
                        ghb(15),
                        controller.machineList.isEmpty
                            ? ghb(0)
                            : controller.util
                                .orderMachineListView(controller.machineList),
                        ghb(20)
                      ],
                    ),
                  ),
                );
              },
            ),
            GetBuilder<MachineOrderReceiveController>(
              builder: (_) {
                return controller.util.haveBtn(controller.status,
                        orderType: MachineOrderType.receive, detail: true)
                    ? Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 50.w + paddingSizeBottom(context),
                        child: Container(
                          padding: EdgeInsets.only(
                              bottom: paddingSizeBottom(context)),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x0D000000),
                                    blurRadius: 4.w)
                              ]),
                          child: Center(
                            child: sbhRow([
                              gwb(0),
                              controller.util.getButtons(controller.status,
                                  orderType: MachineOrderType.receive,
                                  onPressed: controller.buttonsClick,
                                  parenID: controller.parenID,
                                  detail: true)
                            ], width: 375 - 16 * 2, height: 50),
                          ),
                        ))
                    : gemp();
              },
            ),
          ],
        ));
  }

  Widget addressView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          ghb(5),
          sbhRow([
            getSimpleText("用户收货地址", 14, AppColor.text2),
          ], height: 40, width: 345 - 15 * 2),
          (controller.orderData["deliveryMetho"] ?? 1) == 0
              ? ghb(0)
              : (controller.orderData["deliveryMetho"] ?? 1) == 2
                  ? sbRow([
                      getSimpleText("线下自提", 14, AppColor.text2),
                    ], width: 345 - 15 * 2)
                  : centClm([
                      sbRow([
                        getSimpleText(
                            "${controller.orderData["recipient"] ?? ""}  ${controller.orderData["recipientMobile"] ?? ""}",
                            15,
                            AppColor.text,
                            isBold: true,
                            textHeight: 1.3),
                      ], width: 345 - 15 * 2),
                      ghb(5),
                      getWidthText(controller.orderData["userAddress"] ?? "",
                          12, AppColor.text3, 345 - 15 * 2, 5),
                    ]),
          ghb(15)
        ],
      ),
    );
  }

  Widget machineInfoView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          ...List.generate(
              controller.productList.length,
              (index) => controller.util.orderDetailProductCell(
                  index,
                  controller.productList[index],
                  controller.productList.length)),
          ghb(21.5),
          controller.util
              .orderDetailInfoCell("订单类型", t2: controller.orderTypeName),
          controller.util.orderDetailInfoCell("采购类型",
              t2: (controller.orderData["purType"] ?? 0) == 0
                  ? ""
                  : (controller.orderData["purType"] ?? 0) == 1
                      ? "正常采购"
                      : "续约奖励采购"),
          controller.util
              .orderDetailInfoCell("数量", t2: "${controller.orderNum}"),
          controller.util.orderDetailInfoCell(
            "总计",
            rightWidget: getSimpleText(
                "￥${priceFormat(controller.orderData["totalPrice"] ?? 0)}",
                15,
                AppColor.red,
                isBold: true),
          ),
        ],
      ),
    );
  }

  Widget orderInfoView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          ghb(15),
          controller.util.orderDetailInfoCell("订单编号",
              t2: controller.orderData["orderNo"], type: 1, height: 28),
          controller.util.orderDetailInfoCell("兑换时间",
              t2: controller.orderData["processTime"], type: 1, height: 28),
          controller.util
              .orderDetailInfoCell("付款方式", t2: "线下付款", type: 1, height: 28),
          controller.util.orderDetailInfoCell("订单状态",
              t2: controller.orderData["orderStateStr"], type: 1, height: 28),
          ghb(5)
        ],
      ),
    );
  }
}
