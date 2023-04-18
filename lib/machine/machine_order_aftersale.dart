import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/machine/aftersale/machine_aftersale_agree.dart';
import 'package:cxhighversion2/machine/aftersale/machine_aftersale_timeline.dart';
import 'package:cxhighversion2/machine/machine_order_launch.dart';
import 'package:cxhighversion2/machine/machine_order_receive.dart';
import 'package:cxhighversion2/machine/machine_order_ship.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineOrderAftersaleBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineOrderAftersaleController>(
        MachineOrderAftersaleController(datas: Get.arguments));
  }
}

class MachineOrderAftersaleController extends GetxController {
  final dynamic datas;
  MachineOrderAftersaleController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();

  final shipNoInputCtrl = TextEditingController();

  int status = 0;
  Map orderData = {};
  Map aftersaleOrderData = {};

  List productList = [];
  List machineList = [];
  String orderTypeName = "";

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  buttonsClick(MachineOrderBtnType type) {
    if (type == MachineOrderBtnType.backoutApply) {
      util.loadAfterSaleCancel(
        aftersaleOrderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.aftersaleTimeLine) {
      push(const MachineAftersaleTimeline(), null,
          binding: MachineAftersaleTimelineBinding());
    } else if (type == MachineOrderBtnType.invalidAftersale) {
      util.loadAfterSaleDestroy(
        aftersaleOrderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.agreeAftersale) {
      push(const MachineAftersaleAgree(), null,
          binding: MachineAftersaleAgreeBinding(),
          arguments: {
            "orderData": aftersaleOrderData,
          });
    } else if (type == MachineOrderBtnType.returnGoods) {
      returnGoodsAction();
    } else if (type == MachineOrderBtnType.confirmReceive) {
      util.loadAfterSaleRecycle(
        aftersaleOrderData["id"],
        result: (succ) {
          if (succ) {
            loadDetail();
          }
        },
      );
    } else if (type == MachineOrderBtnType.immediatedelivery) {
      if (orderData.isEmpty) {
        loadNormalDetail(
          succ: () {
            push(const MachineOrderShip(), null,
                binding: MachineOrderShipBinding(),
                arguments: {
                  "orderData": orderData,
                  "aftersale": true,
                  "aftersaleOrderData": aftersaleOrderData
                });
          },
        );
      } else {
        push(const MachineOrderShip(), null,
            binding: MachineOrderShipBinding(),
            arguments: {
              "orderData": orderData,
              "aftersale": true,
              "aftersaleOrderData": aftersaleOrderData
            });
      }
    } else if (type == MachineOrderBtnType.confirmTake) {
      if (orderData.isEmpty) {
        loadNormalDetail(
          succ: () {
            util.loadConfirmTake(
              orderData["id"],
              result: (succ) {
                if (succ) {
                  loadDetail();
                }
              },
            );
          },
        );
      } else {
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
  }

  returnGoodsAction() {
    if (realShipcompanyIdx < 0) {
      ShowToast.normal("请选择物流公司");
      return;
    }
    if (shipNoInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写物流单号");
      return;
    }

    util.myAlert("是否确定寄回商品", () {
      simpleRequest(
        url: Urls.userLevelUpAfterSaleReturn,
        params: {
          "id": aftersaleOrderData["id"],
          "courier_ON": shipNoInputCtrl.text,
          "courierCompany_ID": shipcompanys[realShipcompanyIdx]["id"]
        },
        success: (success, json) {
          if (success) {
            loadDetail();
          }
        },
        after: () {},
      );
    });
  }

  loadNormalDetail({Function()? succ}) {
    if (aftersaleOrderData["newOrder_ID"] == null) {
      return;
    }
    simpleRequest(
      url: Urls.userLevelGiftOrderShow(aftersaleOrderData["newOrder_ID"]),
      params: {},
      success: (success, json) {
        if (success) {
          orderData = json["data"] ?? {};
          if (succ != null) {
            succ();
          }
          // getOrderFormat();
          // update();
        }
      },
      after: () {
        // isLoading = false;
      },
    );
  }

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
          if (showAfterShip) {
            loadNormalDetail();
          }
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  int orderNum = 0;
  int serviceType = 0;

  String orderTitle = "";
  String orderSubTitle = "";
  String shipCompany = "";

  bool showAfterShip = false;
  bool showAfterShipReceive = false;

  getOrderFormat() {
    productList = aftersaleOrderData["commodity"] ?? [];
    serviceType = aftersaleOrderData["serviceType"] ?? 0;
    orderNum = 0;
    for (var e in productList) {
      orderNum += (e["num"] ?? 1) as int;
    }

    //serviceState
    //-1:全部 0:申请中/待审核 1:同意换货/同意退款 2:买家退货(寄回) 3:确认回收/退货完成 4:换货完成 5:已作废(卖家) 6:买家取消
    //serviceType
    //-1:全部 1:换货 2:退货

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

    switch (aftersaleOrderData["orderType2"] ?? -1) {
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

    showAfterShip =
        !isMine && (status == 2 || (status == 3 && serviceType == 1));

    showAfterShipReceive = (isMine && status == 1) ||
        !isMine && ((status == 2 || status == 3) && serviceType == 1);

    machineList = aftersaleOrderData["deliveryNote"] ?? [];

    if (showAfterShip) {
      for (var e in shipcompanys) {
        if (aftersaleOrderData["cpiroerID"] == e["id"]) {
          shipCompany = e["logistics_Name"];
          break;
        }
      }
    }
  }

  bool isMine = true;

  // 选择地址
  List shipcompanys = [];
  final _shipcompanyIdx = (-1).obs;
  int get shipcompanyIdx => _shipcompanyIdx.value;
  set shipcompanyIdx(v) => _shipcompanyIdx.value = v;

  final _realShipcompanyIdx = (-1).obs;
  int get realShipcompanyIdx => _realShipcompanyIdx.value;
  set realShipcompanyIdx(v) => _realShipcompanyIdx.value = v;

  closeShipSelect() {
    Get.back();
    shipcompanyIdx = realShipcompanyIdx;
  }

  confirmShipSelect() {
    Get.back();
    realShipcompanyIdx = shipcompanyIdx;
  }

  @override
  void onInit() {
    shipcompanys = AppDefault().publicHomeData["logisticeListInfo"] ?? [];
    if (datas != null && datas is Map && datas.isNotEmpty) {
      aftersaleOrderData = datas["orderData"] ?? {};
      isMine = datas["isMine"] ?? true;
      // getOrderFormat();
      loadDetail();
    }
    super.onInit();
  }

  @override
  void onClose() {
    shipNoInputCtrl.dispose();
    super.onClose();
  }
}

class MachineOrderAftersale extends GetView<MachineOrderAftersaleController> {
  const MachineOrderAftersale({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
          appBar: getDefaultAppBar(context, "售后订单"),
          body: Stack(
            children: [
              GetBuilder<MachineOrderAftersaleController>(
                builder: (_) {
                  return !(controller.aftersaleOrderData.values.length > 1)
                      ? GetX<MachineOrderAftersaleController>(
                          builder: (_) {
                            return Align(
                              alignment: Alignment.topCenter,
                              child: CustomEmptyView(
                                isLoading: controller.isLoading,
                              ),
                            );
                          },
                        )
                      : Positioned.fill(
                          bottom: controller.util.haveBtn(controller.status,
                                  orderType: MachineOrderType.aftersale,
                                  aftersaleType: controller.isMine ? 0 : 1,
                                  serviceType: controller.serviceType)
                              ? 50.w + paddingSizeBottom(context)
                              : 0,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                gwb(375),
                                ghb(20),
                                sbRow([
                                  centClm([
                                    CustomButton(
                                      onPressed: () {
                                        push(const MachineAftersaleTimeline(),
                                            context,
                                            binding:
                                                MachineAftersaleTimelineBinding(),
                                            arguments: {
                                              "orderData":
                                                  controller.aftersaleOrderData,
                                              "isMine": controller.isMine
                                            });
                                      },
                                      child: SizedBox(
                                        height: 33.w,
                                        child: Center(
                                          child: centRow([
                                            getSimpleText(controller.orderTitle,
                                                18, AppColor.text,
                                                isBold: true, textHeight: 1.25),
                                            gwb(5),
                                            Image.asset(
                                              assetsName(
                                                  "mine/icon_right_arrow"),
                                              width: 14.w,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                    getWidthText(controller.orderSubTitle, 12,
                                        AppColor.text2, 375 - 30 * 2, 10),
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start)
                                ], width: 375 - 30 * 2),
                                ghb(25),
                                // addressView(),
                                // ghb(15),
                                upAddressView(),
                                upReturnGoodsShipNoView(),
                                returnGoodsShipNoView(),
                                machineInfoView(),
                                // ghb(15),
                                orderInfoView(),
                                ghb(15),
                                controller.machineList.isEmpty
                                    ? ghb(0)
                                    : controller.util.orderMachineListView(
                                        controller.machineList),
                                ghb(20)
                              ],
                            ),
                          ),
                        );
                },
              ),
              GetBuilder<MachineOrderAftersaleController>(
                builder: (_) {
                  return controller.util.haveBtn(controller.status,
                              orderType: MachineOrderType.aftersale,
                              aftersaleType: controller.isMine ? 0 : 1,
                              serviceType: controller.serviceType) &&
                          controller.aftersaleOrderData.values.length > 1
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
                                    orderType: MachineOrderType.aftersale,
                                    onPressed: controller.buttonsClick,
                                    detail: true,
                                    aftersaleType: controller.isMine ? 0 : 1,
                                    serviceType: controller.serviceType)
                              ], width: 375 - 16 * 2, height: 50),
                            ),
                          ))
                      : gemp();
                },
              ),
            ],
          )),
    );
  }

  Widget upAddressView() {
    return GetBuilder<MachineOrderAftersaleController>(
      builder: (_) {
        return controller.showAfterShipReceive
            ? CustomButton(
                onPressed: () {
                  copyClipboard(
                      "${controller.aftersaleOrderData[!controller.isMine ? "recipient" : "recipient2"] ?? ""} ${controller.aftersaleOrderData[!controller.isMine ? "recipientMobile" : "recipientMobile2"] ?? ""}\n${controller.aftersaleOrderData[!controller.isMine ? "userAddress" : "userAddress"] ?? ""}",
                      toastText:
                          "已复制${controller.isMine ? "平台收货地址" : "用户收货地址"}");
                },
                child: Container(
                  width: 345.w,
                  margin: EdgeInsets.only(bottom: 15.w),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.w)),
                  child: Column(
                    children: [
                      ghb(15),
                      sbRow([
                        getSimpleText(controller.isMine ? "平台收货地址" : "用户收货地址",
                            14, AppColor.text2),
                      ], width: 315),
                      ghb(10),
                      sbRow([
                        centRow([
                          gwb(15),
                          getSimpleText(
                              controller.aftersaleOrderData[!controller.isMine
                                      ? "recipient"
                                      : "recipient2"] ??
                                  "",
                              15,
                              AppColor.text,
                              isBold: true),
                          gwb(10),
                          getSimpleText(
                              controller.aftersaleOrderData[!controller.isMine
                                      ? "recipientMobile"
                                      : "recipientMobile2"] ??
                                  "",
                              15,
                              AppColor.text,
                              isBold: true),
                        ]),
                      ], width: 345),
                      ghb(5),
                      getWidthText(
                          controller.aftersaleOrderData[!controller.isMine
                                  ? "userAddress"
                                  : "userAddress2"] ??
                              "",
                          12,
                          AppColor.text3,
                          315,
                          5),
                      ghb(15)
                    ],
                  ),
                ),
              )
            : ghb(0);
      },
    );
  }

  Widget upReturnGoodsShipNoView() {
    return GetBuilder<MachineOrderAftersaleController>(
      builder: (_) {
        return controller.showAfterShip
            ? Container(
                width: 345.w,
                margin: EdgeInsets.only(bottom: 15.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.w)),
                child: Column(
                  children: [
                    ghb(5),
                    ...List.generate(2, (index) {
                      return sbhRow([
                        getWidthText(index == 0 ? "物流公司" : "物流单号", 14,
                            AppColor.text3, 80, 1,
                            textHeight: 1.3),
                        CustomButton(
                          onPressed: () {
                            if (index == 1) {
                              copyClipboard(
                                  controller.aftersaleOrderData["cpiroerON"] ??
                                      "",
                                  toastText: "已复制物流单号");
                            }
                          },
                          child: getWidthText(
                              index == 0
                                  ? controller.shipCompany
                                  : controller.aftersaleOrderData["cpiroerON"],
                              14,
                              AppColor.text2,
                              315 - 80 - 1,
                              1,
                              textHeight: 1.3),
                        ),
                      ], width: 315, height: 40);
                    }),
                    ghb(5),
                  ],
                ),
              )
            : ghb(0);
      },
    );
  }

  Widget returnGoodsShipNoView() {
    return GetBuilder<MachineOrderAftersaleController>(
      builder: (_) {
        return !controller.isMine
            ? ghb(0)
            : controller.status != 1
                ? ghb(0)
                : Container(
                    width: 345.w,
                    margin: EdgeInsets.only(bottom: 15.w),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.w)),
                    child: Column(
                      children: [
                        ghb(5),
                        ...List.generate(3, (index) {
                          return index == 1
                              ? gline(315, 0.5)
                              : sbhRow([
                                  getWidthText(index == 0 ? "物流公司" : "物流单号", 14,
                                      AppColor.text3, 80, 1,
                                      textHeight: 1.3),
                                  index == 0
                                      ? CustomButton(
                                          onPressed: () {
                                            showShipCompanySelect();
                                          },
                                          child: sbhRow([
                                            GetX<
                                                MachineOrderAftersaleController>(
                                              builder: (_) {
                                                return getSimpleText(
                                                    controller.realShipcompanyIdx >=
                                                                0 &&
                                                            controller
                                                                .shipcompanys
                                                                .isNotEmpty
                                                        ? controller.shipcompanys[
                                                                    controller
                                                                        .realShipcompanyIdx]
                                                                [
                                                                "logistics_Name"] ??
                                                            ""
                                                        : "请选择快递公司",
                                                    14,
                                                    controller.realShipcompanyIdx >=
                                                            0
                                                        ? AppColor.text
                                                        : AppColor.assisText);
                                              },
                                            ),
                                            Image.asset(
                                              assetsName(
                                                  "mine/icon_right_arrow"),
                                              width: 12.w,
                                              fit: BoxFit.fitWidth,
                                            )
                                          ], width: 315 - 80 - 1, height: 45))
                                      : CustomInput(
                                          width: (315 - 80 - 1).w,
                                          heigth: 45.w,
                                          placeholder: "请输入物流单号",
                                          textEditCtrl:
                                              controller.shipNoInputCtrl,
                                          placeholderStyle: TextStyle(
                                              fontSize: 14.sp,
                                              height: 1.3,
                                              color: AppColor.assisText),
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              height: 1.3,
                                              color: AppColor.text2),
                                        ),
                                ], height: 45, width: 315);
                        }),
                        ghb(5),
                      ],
                    ),
                  );
      },
    );
  }

  Widget machineInfoView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.w))),
      child: Column(
        children: [
          ...List.generate(
              controller.productList.length,
              (index) => controller.util.orderDetailProductCell(
                  index,
                  controller.productList[index],
                  controller.productList.length)),
          gline(315, 0.5)
          // ghb(21.5),
          // controller.util
          //     .orderDetailInfoCell("订单类型", t2: controller.orderTypeName),
          // controller.util.orderDetailInfoCell("采购类型", t2: "正常采购"),
          // controller.util
          //     .orderDetailInfoCell("数量", t2: "${controller.orderNum}"),
          // controller.util.orderDetailInfoCell(
          //   "总计",
          //   rightWidget: getSimpleText(
          //       "￥${priceFormat(controller.orderData["totalPrice"] ?? 0)}",
          //       15,
          //       AppColor.red,
          //       isBold: true),
          // ),
        ],
      ),
    );
  }

  Widget orderInfoView() {
    double cellHeight = 32;
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.w))),
      child: Column(
        children: [
          ghb(25),
          controller.util.orderDetailInfoCell("原订单号",
              rightWidget: CustomButton(
                onPressed: () {
                  if (controller.isMine) {
                    push(const MachineOrderLaunch(), null,
                        binding: MachineOrderLaunchBinding(),
                        arguments: {
                          "orderData": {
                            "id": controller.aftersaleOrderData["oldOrder_ID"]
                          }
                        });
                  } else {
                    push(const MachineOrderReceive(), null,
                        binding: MachineOrderReceiveBinding(),
                        arguments: {
                          "orderData": {
                            "id": controller.aftersaleOrderData["oldOrder_ID"]
                          }
                        });
                  }
                },
                child: getWidthText(
                    controller.aftersaleOrderData["oldOrderNo"] ?? "",
                    14,
                    AppColor.theme,
                    315 - 75,
                    1,
                    alignment: Alignment.topLeft,
                    textAlign: TextAlign.start),
              ),
              type: 2,
              height: cellHeight),
          controller.util.orderDetailInfoCell("服务单号",
              t2: controller.aftersaleOrderData["serviceNo"] ?? "",
              type: 1,
              height: cellHeight),
          controller.util.orderDetailInfoCell("申请时间",
              t2: controller.aftersaleOrderData["addTime"] ?? "",
              type: 1,
              height: cellHeight),
          controller.aftersaleOrderData["newOrderNo"] != null &&
                  controller.aftersaleOrderData["newOrderNo"].isNotEmpty
              ? controller.util.orderDetailInfoCell("换新订单",
                  rightWidget: CustomButton(
                    onPressed: () {
                      if (controller.isMine) {
                        push(const MachineOrderLaunch(), null,
                            binding: MachineOrderLaunchBinding(),
                            arguments: {
                              "orderData": {
                                "id":
                                    controller.aftersaleOrderData["newOrder_ID"]
                              }
                            });
                      } else {
                        push(const MachineOrderReceive(), null,
                            binding: MachineOrderReceiveBinding(),
                            arguments: {
                              "orderData": {
                                "id":
                                    controller.aftersaleOrderData["newOrder_ID"]
                              }
                            });
                      }
                    },
                    child: getWidthText(
                        controller.aftersaleOrderData["newOrderNo"] ?? "",
                        14,
                        AppColor.theme,
                        315 - 75,
                        1,
                        alignment: Alignment.topLeft,
                        textAlign: TextAlign.start),
                  ),
                  type: 2,
                  height: cellHeight)
              : ghb(0),
          controller.util.orderDetailInfoCell("售后类型",
              t2: (controller.serviceType) == 1 ? "换货" : "退货",
              type: 1,
              height: cellHeight),
          controller.util.orderDetailInfoCell("申请原因",
              t2: controller.aftersaleOrderData["userReason"] ?? "",
              type: 1,
              height: cellHeight,
              maxLines: 10),
          ghb(cellHeight - 20),
          (controller.serviceType) == 2
              ? controller.util.orderDetailInfoCell(
                  "退款金额",
                  rightWidget: getWidthText(
                      "￥${priceFormat(controller.aftersaleOrderData["returnAmount"] ?? 0)}",
                      15,
                      AppColor.red,
                      315 - 75,
                      1,
                      isBold: true,
                      alignment: Alignment.topLeft,
                      textAlign: TextAlign.start,
                      textHeight: 1.2),
                  type: 2,
                  height: cellHeight,
                )
              : ghb(0),
          ghb(20)
        ],
      ),
    );
  }

  showShipCompanySelect() {
    Get.bottomSheet(
        Container(
          height: 250.w,
          width: 375.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
          child: Column(
            children: [
              sbhRow(
                  List.generate(
                      2,
                      (index) => CustomButton(
                            onPressed: () {
                              if (index == 0) {
                                controller.closeShipSelect();
                              } else {
                                controller.confirmShipSelect();
                              }
                            },
                            child: SizedBox(
                              width: 65.w,
                              height: 52.w,
                              child: Center(
                                child: getSimpleText(
                                    index == 0 ? "取消" : "确定",
                                    14,
                                    index == 0
                                        ? AppColor.text3
                                        : AppColor.text),
                              ),
                            ),
                          )),
                  height: 52,
                  width: 375),
              gline(375, 1),
              SizedBox(
                width: 375.w,
                height: 250.w - 52.w - 1.w,
                child: CupertinoPicker.builder(
                  scrollController: FixedExtentScrollController(
                      initialItem: controller.realShipcompanyIdx),
                  itemExtent: 40.w,
                  childCount: controller.shipcompanys.length,
                  onSelectedItemChanged: (value) {
                    controller.shipcompanyIdx = value;
                  },
                  itemBuilder: (context, index) {
                    return GetX<MachineOrderAftersaleController>(
                      builder: (_) {
                        return Center(
                          child: getWidthText(
                              controller.shipcompanys[index]
                                      ["logistics_Name"] ??
                                  "",
                              15,
                              AppColor.text,
                              345,
                              1,
                              fw: controller.shipcompanyIdx == index
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              alignment: Alignment.center,
                              textAlign: TextAlign.center,
                              textHeight: 1.3),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
        enableDrag: false,
        isDismissible: false);
  }
}
