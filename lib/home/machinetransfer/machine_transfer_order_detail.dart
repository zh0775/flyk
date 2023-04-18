import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_express_detail.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_shipments.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class MachineTransferOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferOrderDetailController>(
        MachineTransferOrderDetailController());
  }
}

class MachineTransferOrderDetailController extends GetxController {
  bool isFisrt = true;

  @override
  void onInit() {
    super.onInit();
  }

  // 0:别人向自己划拨未发货 （拒绝 同意）
  // 1:别人向自己划拨已发货 （查看物流 同意）
  // 2:向别人划拨（取消划拨）
  // 3:积分给别人划拨 （取消划拨 立即发货）
  // 4:别人向自己划拨同意后 （查看物流）
  // 5:我的兑换未被接受 （取消兑换）
  // 6:我的兑换已被接受 （查看物流）
  final _orderStatus = 1.obs;
  get orderStatus => _orderStatus.value;
  set orderStatus(value) => _orderStatus.value = value;

  final _orderData = Rx<Map>({});
  Map get orderData => _orderData.value;
  set orderData(value) => _orderData.value = value;

  final _countOpen = false.obs;
  get countOpen => _countOpen.value;
  set countOpen(value) => _countOpen.value = value;

  final _countButtonIdx = RxInt(-1);
  get countButtonIdx => _countButtonIdx.value;
  set countButtonIdx(value) => _countButtonIdx.value = value;

  String orderContent = "";

  int orderType = 0;
  bool haveButton() {
    if (orderData.isEmpty) {
      return false;
    }
    if (orderType == 2) {
      return false;
    }
    if (orderType == 0 && (orderStatus == 1 || orderStatus == 2)) {
      return false;
    }
    if (orderType == 1 && orderStatus == 2) {
      return false;
    }
    return true;
  }

  bool isIntegral() {
    // if (orderData.isEmpty) {
    //   return false;
    // }
    // return orderData["applyType"] != 2;
    return false;
  }

  loadDetail() {
    simpleRequest(
      url: Urls.terminalTransferDetail(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          orderData = json["data"];
          orderContentFormat(orderType, orderData["applyFlag"]);
          update();
        }
      },
      after: () {},
    );
  }

  changeStatusAction(int status) {
    simpleRequest(
      url: Urls.userTerminalTransferStatus(orderData["id"], status),
      params: {},
      success: (success, json) {
        if (success) {
          loadDetail();
        }
      },
      after: () {},
    );
  }

  orderContentFormat(int type, int status) {
    orderStatus = status;
    if (orderType == 0) {
      switch (status) {
        case 0:
          if (!isIntegral()) {
            orderContent = "向您划拨机具";
          } else {
            orderContent = "使用积分向您兑换机具";
          }
          break;
        case 1:
          if (!isIntegral()) {
            orderContent = "已同意向您划拨机具";
          } else {
            orderContent = "已同意使用积分向您兑换机具";
          }
          break;
        case 2:
          if (!isIntegral()) {
            orderContent = "已取消向您划拨机具";
          } else {
            orderContent = "已取消使用积分向您兑换机具";
          }
          break;
        case 3:
          if (!isIntegral()) {
            orderContent = "向您划拨的机具已发货";
          } else {
            orderContent = "使用积分向您兑换机具已发货";
          }
          break;
        case 4:
          if (!isIntegral()) {
            orderContent = "向您划拨的机具已收货";
          } else {
            orderContent = "使用积分向您兑换的机具已收货";
          }
          break;
        default:
      }
    } else if (orderType == 1) {
      switch (status) {
        case 0:
          if (!isIntegral()) {
            orderContent = "您划拨的机具";
          } else {
            orderContent = "您使用积分兑换机具";
          }
          break;
        case 1:
          if (!isIntegral()) {
            orderContent = "您划拨的机具已同意";
          } else {
            orderContent = "您使用积分兑换的机具已同意";
          }
          break;
        case 2:
          if (!isIntegral()) {
            orderContent = "已取消您划拨的机具";
          } else {
            orderContent = "已取消您使用积分兑换机具";
          }
          break;
        case 3:
          if (!isIntegral()) {
            orderContent = "您划拨的机具已发货";
          } else {
            orderContent = "您使用积分兑换的机具已发货";
          }
          break;
        case 4:
          if (!isIntegral()) {
            orderContent = "您划拨的机具已收货";
          } else {
            orderContent = "您使用积分兑换的机具已收货";
          }
          break;
        default:
      }
      // if (orderData["applyType"] == 3) {
      //   orderContent = "您划拨的机具";
      // } else {
      //   orderContent = "您使用积分兑换机具";
      // }
    } else if (orderType == 2) {
      orderContent = "已完成";
      // if (orderData["applyType"] == 3) {
      //   orderContent = "向您划拨机具";
      // } else {
      //   orderContent = "使用积分向您兑换机具";
      // }
    }
  }

  confirmOrderAction() {
    simpleRequest(
      url: Urls.userTerminalTransferConfirm(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadDetail();
        }
      },
      after: () {},
    );
  }

  dataFormat(Map data, int type) {
    if (!isFisrt) {
      return;
    }
    isFisrt = false;
    orderData = data;
    orderType = type;
    loadDetail();
    orderContentFormat(orderType, orderData["applyFlag"]);
    update();
  }
}

class MachineTransferOrderDetail
    extends GetView<MachineTransferOrderDetailController> {
  final Map orderData;
  final int type;
  const MachineTransferOrderDetail(
      {Key? key, required this.orderData, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataFormat(orderData, type);
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        "订单详情",
        // elevation: 0.5,
        // shadowColor: const Color(0xFFF7F7F7),
      ),
      body: GetBuilder<MachineTransferOrderDetailController>(
        builder: (_) {
          return Stack(
            children: [
              !controller.isIntegral()
                  ? Positioned(
                      top: (145.5 + 44).w,
                      bottom: !controller.haveButton()
                          ? 0
                          : 80.w + paddingSizeBottom(context),
                      left: 0,
                      right: 0,
                      child: ListView.builder(
                        itemCount: controller.orderData.isNotEmpty &&
                                controller.orderData["detail"] != null
                            ? controller.orderData["detail"].length
                            : 0,
                        itemBuilder: (context, index) {
                          return snCell(
                              index, controller.orderData["detail"][index]);
                        },
                      ))
                  : const Align(
                      child: SizedBox(),
                    ),
              !controller.isIntegral()
                  ? GetX<MachineTransferOrderDetailController>(
                      init: controller,
                      builder: (_) {
                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          top: (145.5 + 44).w -
                              (controller.countOpen ? 0 : 44.w),

                          // !controller.countOpen
                          //     ? (145.5 + 44).w -
                          //         (44 *
                          //                 ((controller.orderData[
                          //                                 "detailGroup"] !=
                          //                             null
                          //                         ? controller
                          //                             .orderData[
                          //                                 "detailGroup"]
                          //                             .length
                          //                         : 0) +
                          //                     1))
                          //             .w
                          //     : (145.5 + 44).w,
                          left: 0,
                          right: 0,
                          height: controller.countOpen
                              ? (44 *
                                      ((controller.orderData["detailGroup"] !=
                                                  null
                                              ? controller
                                                  .orderData["detailGroup"]
                                                  .length
                                              : 0) +
                                          1))
                                  .w
                              : 44.w,
                          child: Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  CustomButton(
                                    onPressed: () {
                                      controller.countButtonIdx = -1;
                                      controller.countOpen =
                                          !controller.countOpen;
                                    },
                                    child: Container(
                                      color: Colors.white,
                                      width: 375.w,
                                      height: 44.w,
                                      child: Center(
                                        child: sbRow([
                                          centRow(
                                            [
                                              getSimpleText("全部： ", 14,
                                                  AppColor.textBlack,
                                                  isBold: true),
                                              getRichText(
                                                  "${controller.orderData["detail"] == null ? "" : controller.orderData["detail"].length}",
                                                  "台",
                                                  14,
                                                  const Color(0xFFEB5757),
                                                  14,
                                                  AppColor.textBlack,
                                                  fw: AppDefault.fontBold,
                                                  fw2: AppDefault.fontBold),
                                            ],
                                          ),
                                        ], width: 375 - 15 * 2),
                                      ),
                                    ),
                                  ),
                                  ...((controller.orderData["detailGroup"] ??
                                          []) as List)
                                      .asMap()
                                      .entries
                                      .map(
                                        (e) => CustomButton(
                                          onPressed: () {
                                            controller.countButtonIdx = e.key;
                                            controller.countOpen =
                                                !controller.countOpen;
                                          },
                                          child: Container(
                                            width: 375.w,
                                            height: 44.w,
                                            color: Colors.white,
                                            child: Center(
                                              child: sbRow([
                                                centRow([
                                                  getSimpleText(
                                                      "${e.value["key"]}： ",
                                                      14,
                                                      AppColor.textBlack,
                                                      isBold: true),
                                                  getRichText(
                                                      "${e.value["value"]}",
                                                      "台",
                                                      14,
                                                      const Color(0xFFEB5757),
                                                      14,
                                                      AppColor.textBlack,
                                                      fw: AppDefault.fontBold,
                                                      fw2: AppDefault.fontBold),
                                                ]),
                                              ], width: 375 - 15 * 2),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList()
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Align(
                      child: SizedBox(),
                    ),
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 145.5.w,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        sbRow([
                          Text.rich(TextSpan(
                              text: "接收人：",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColor.textGrey,
                                  fontWeight: AppDefault.fontBold),
                              children: [
                                TextSpan(
                                    text:
                                        "${controller.orderData.isNotEmpty && controller.orderData["suName"] != null ? controller.orderData["suName"] : hidePhoneNum(controller.orderData["suMobile"] ?? "")}(${controller.orderData.isNotEmpty && controller.orderData["suMobile"] != null ? hidePhoneNum(controller.orderData["suMobile"]) : ""})",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColor.textBlack,
                                        fontWeight: AppDefault.fontBold))
                              ]))
                        ], width: 375 - 15 * 2),
                        ghb(20.5),
                        sbRow([
                          Text.rich(TextSpan(
                              text: "接收时间：",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColor.textGrey,
                                  fontWeight: AppDefault.fontBold),
                              children: [
                                TextSpan(
                                    text:
                                        "${controller.orderData.isNotEmpty && controller.orderData["applyTime"] != null ? controller.orderData["applyTime"] : ""}",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColor.textBlack,
                                        fontWeight: AppDefault.fontBold))
                              ]))
                        ], width: 375 - 15 * 2),
                        ghb(20.5),
                        sbRow([
                          Text.rich(TextSpan(
                              text: "接收状态：",
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColor.textGrey,
                                  fontWeight: AppDefault.fontBold),
                              children: [
                                TextSpan(
                                    text: controller.orderContent,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        color: AppColor.textBlack,
                                        fontWeight: AppDefault.fontBold))
                              ]))
                        ], width: 375 - 15 * 2),
                      ],
                    ),
                  )),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: !controller.haveButton()
                      ? 0
                      : 80.w + paddingSizeBottom(context),
                  child: !controller.haveButton()
                      ? const Align(
                          child: SizedBox(),
                        )
                      : Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 80.w,
                                width: 375.w,
                                child: Center(
                                    child: GetX<
                                        MachineTransferOrderDetailController>(
                                  init: controller,
                                  builder: (_) {
                                    List buttons = [];

                                    if (controller.orderType == 0) {
                                      switch (controller.orderStatus) {
                                        case 0:
                                          buttons = [
                                            rejectOrderButotn(context),
                                            gwb(20),
                                            confirmOrderButotn(context)
                                          ];
                                          break;
                                        case 1:
                                          buttons = [];
                                          break;
                                        case 2:
                                          buttons = [];
                                          break;
                                        case 3:
                                          buttons = [
                                            checkWLButotn(context),
                                            gwb(20),
                                            confirmSHButotn(context)
                                          ];
                                          break;
                                        case 4:
                                          buttons = [checkWLButotn(context)];
                                          break;
                                      }
                                    } else if (controller.orderType == 1) {
                                      switch (controller.orderStatus) {
                                        case 0:
                                          buttons = [cancelButotn(context)];
                                          break;
                                        case 1:
                                          buttons = [sendButotn(context)];
                                          break;
                                        case 2:
                                          buttons = [];
                                          break;
                                        case 3:
                                          buttons = [checkWLButotn(context)];
                                          break;
                                        case 4:
                                          buttons = [checkWLButotn(context)];
                                          break;
                                      }
                                    }

                                    return centRow([...buttons]
                                        //   [
                                        //   CustomButton(
                                        //     onPressed: () {
                                        //       if (controller.orderStatus == 1) {
                                        //         Get.to(
                                        //             const MachineTransferExpressDetail(),
                                        //             binding:
                                        //                 MachineTransferExpressDetailBinding());
                                        //       }
                                        //     },
                                        //     child: Container(
                                        //       width: 150.w,
                                        //       height: 37.w,
                                        //       decoration: decoration1,
                                        //       child: Center(
                                        //         child: getSimpleText(
                                        //             title1, 15, textColor1,
                                        //             isBold: true),
                                        //       ),
                                        //     ),
                                        //   ),
                                        //   gwb(13),
                                        //   CustomButton(
                                        //     onPressed: () {
                                        //       // if ()
                                        //       Get.to(
                                        //           const MachineTransferShipments(),
                                        //           binding:
                                        //               MachineTransferShipmentsBinding());
                                        //     },
                                        //     child: Container(
                                        //       width: 150.w,
                                        //       height: 37.w,
                                        //       decoration: decoration2,
                                        //       child: Center(
                                        //         child: getSimpleText(
                                        //             title2, 15, textColor2,
                                        //             isBold: true),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ]
                                        );
                                  },
                                )),
                              ),
                              SizedBox(
                                height: paddingSizeBottom(context),
                              ),
                            ],
                          ),
                        )),
              !controller.isIntegral()
                  ? Positioned(
                      top: 145.5.w,
                      left: 0,
                      right: 0,
                      height: 44.w,
                      child: CustomButton(
                        onPressed: () {
                          controller.countOpen = !controller.countOpen;
                        },
                        child: Container(
                          color: const Color(0xFFFFF2F3),
                          width: 375.w,
                          height: 44.w,
                          child: Center(
                            child: sbRow([
                              GetX<MachineTransferOrderDetailController>(
                                init: controller,
                                builder: (_) {
                                  String title = "";
                                  int count = 0;
                                  if (controller.countButtonIdx == -1) {
                                    title = "全部";
                                    count = controller.orderData["detail"] ==
                                            null
                                        ? 0
                                        : controller.orderData["detail"].length;
                                  } else {
                                    title = controller.orderData["detailGroup"]
                                        [controller.countButtonIdx]["key"];
                                    count = controller.orderData["detailGroup"]
                                        [controller.countButtonIdx]["value"];
                                  }
                                  return centRow([
                                    getSimpleText(
                                        "$title： ", 14, AppColor.textBlack,
                                        isBold: true),
                                    getRichText(
                                        "$count",
                                        "台",
                                        14,
                                        const Color(0xFFEB5757),
                                        14,
                                        AppColor.textBlack,
                                        fw: AppDefault.fontBold,
                                        fw2: AppDefault.fontBold),
                                  ]);
                                },
                              ),
                              GetX<MachineTransferOrderDetailController>(
                                init: controller,
                                builder: (_) {
                                  return AnimatedRotation(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      turns: controller.countOpen ? 1 : 0.5,
                                      child: Icon(
                                        Icons.arrow_drop_down_rounded,
                                        size: 25.w,
                                        color: AppColor.textGrey,
                                      ));
                                },
                              )
                            ], width: 375 - 15 * 2),
                          ),
                        ),
                      ),
                    )
                  : const Align(
                      child: SizedBox(),
                    ),
              controller.isIntegral()
                  ? Positioned(
                      top: 145.5.w,
                      left: 0,
                      right: 0,
                      bottom: 80 + paddingSizeBottom(context),
                      child: Column(
                        children: [
                          ghb(21.5),
                          sbRow([
                            getSimpleText("兑换内容", 17, AppColor.textBlack,
                                isBold: true),
                          ], width: 375 - 16.5 * 2),
                          ghb(15),
                          sbRow([
                            centClm([
                              Container(
                                width: 130.w,
                                height: 130.w,
                                decoration: getDefaultWhiteDec(),
                                child: Center(
                                  child: Image.asset(
                                    assetsName("home/icon_coin"),
                                    width: 78.w,
                                    height: 78.w,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              )
                            ]),
                            SizedBox(
                              height: 130.w,
                              child: Center(
                                child: centClm([
                                  Image.asset(
                                    assetsName(
                                        "home/machinetransfer/icon_jfdh_waitorder"),
                                    width: 35.w,
                                    height: 35.w,
                                    fit: BoxFit.fill,
                                  ),
                                  ghb(5),
                                  getSimpleText("兑换", 14, AppColor.textGrey,
                                      isBold: true)
                                ]),
                              ),
                            ),
                            centClm([
                              Image.asset(
                                assetsName("home/icon_machine"),
                                width: 130.w,
                                height: 130.w,
                                fit: BoxFit.fill,
                              ),
                              ghb(5),
                              getSimpleText("盛付通大POS", 15, AppColor.textBlack,
                                  isBold: true),
                              ghb(2),
                              getSimpleText(
                                  "电签0.6%服务费版", 11, AppColor.textGrey),
                              ghb(5),
                              getSimpleText("10台", 16, const Color(0xFFEB5757),
                                  isBold: true),
                            ]),
                          ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                              width: 375 - 15 * 2),
                        ],
                      ))
                  : const Align(
                      child: SizedBox(),
                    ),
            ],
          );
        },
      ),
    );
  }

  ////订单操作按钮
  //取消划拨
  Widget cancelButotn(BuildContext context) {
    return CustomButton(
      onPressed: () {
        showAlert(
          context,
          "确定要取消吗？",
          confirmOnPressed: () {
            controller.changeStatusAction(1);
            Get.back();
          },
        );
      },
      child: Container(
        width: 150.w,
        height: 37.w,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18.5.w),
            border: Border.all(width: 0.5.w, color: const Color(0xFFA20606))),
        child: Center(
          child: getSimpleText(controller.isIntegral() ? "取消兑换" : "取消划拨", 15,
              const Color(0xFFA20606),
              isBold: true),
        ),
      ),
    );
  }

  //查看物流
  Widget checkWLButotn(BuildContext context) {
    return CustomButton(
      onPressed: () {
        Get.to(
            MachineTransferExpressDetail(
              orderData: controller.orderData,
              type: type,
            ),
            binding: MachineTransferExpressDetailBinding());
      },
      child: Container(
        width: 150.w,
        height: 37.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(18.5.w),
        ),
        child: Center(
            child: getSimpleText("查看物流", 15, AppColor.textBlack, isBold: true)),
      ),
    );
  }

  //同意划拨
  Widget confirmOrderButotn(BuildContext context) {
    return CustomButton(
      onPressed: () {
        showAlert(
          context,
          "是否同意${controller.isIntegral() ? "兑换" : "划拨"}",
          confirmOnPressed: () {
            controller.confirmOrderAction();
            Get.back();
          },
        );
      },
      child: Container(
        width: 150.w,
        height: 37.w,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF4282EB),
                  Color(0XFF5BA3F7),
                ]),
            borderRadius: BorderRadius.circular(18.5.w)),
        child:
            Center(child: getSimpleText("同意", 15, Colors.white, isBold: true)),
      ),
    );
  }

  //确认收货
  Widget confirmSHButotn(BuildContext context) {
    return CustomButton(
      onPressed: () {
        showAlert(
          context,
          "是否确认收货",
          confirmOnPressed: () {
            controller.changeStatusAction(2);
            Get.back();
          },
        );
      },
      child: Container(
        width: 150.w,
        height: 37.w,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF4282EB),
                  Color(0XFF5BA3F7),
                ]),
            borderRadius: BorderRadius.circular(18.5.w)),
        child: Center(
            child: getSimpleText("确认收货", 15, Colors.white, isBold: true)),
      ),
    );
  }

  //拒绝划拨
  Widget rejectOrderButotn(BuildContext context) {
    return CustomButton(
      onPressed: () {
        showAlert(
          context,
          "是否拒绝${controller.isIntegral() ? "兑换" : "划拨"}",
          confirmOnPressed: () {
            controller.changeStatusAction(1);
            Get.back();
          },
        );
      },
      child: Container(
        width: 150.w,
        height: 37.w,
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18.5.w),
            border: Border.all(width: 0.5.w, color: AppColor.textGrey)),
        child: Center(
            child: getSimpleText("拒绝", 15, AppColor.textGrey, isBold: true)),
      ),
    );
  }

  //划拨发货
  Widget sendButotn(BuildContext context) {
    return CustomButton(
      onPressed: () {
        Get.to(MachineTransferShipments(orderData: controller.orderData),
            binding: MachineTransferShipmentsBinding());
      },
      child: Container(
        width: 150.w,
        height: 37.w,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF4282EB),
                  Color(0XFF5BA3F7),
                ]),
            borderRadius: BorderRadius.circular(18.5.w)),
        child: Center(
            child: getSimpleText("立即发货", 15, Colors.white, isBold: true)),
      ),
    );
  }

  Widget snCell(int idx, Map data) {
    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 18.5.w),
        height: 50.w,
        width: (375 - 15.5 * 2).w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            getSimpleText("机具编号（SN号）", 14, const Color(0xFF808080)),
            ghb(10),
            getTerminalNoText(data["terminal_NO"]),
          ],
        ),
      ),
    );
  }
}
