import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineAftersaleSelectBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineAftersaleSelectController>(
        MachineAftersaleSelectController(datas: Get.arguments));
  }
}

class MachineAftersaleSelectController extends GetxController {
  final dynamic datas;
  MachineAftersaleSelectController({this.datas});
  List machines = [];
  Map orderData = {};
  int aftersaleType = 0;

  final _btnEnable = true.obs;
  bool get btnEnable => _btnEnable.value;
  set btnEnable(v) => _btnEnable.value = v;

  final _count = 0.obs;
  int get count => _count.value;
  set count(v) => _count.value = v;

  final _allselect = false.obs;
  bool get allselect => _allselect.value;
  set allselect(v) => _allselect.value = v;

  final _isFrap = false.obs;
  bool get isFrap => _isFrap.value;
  set isFrap(v) => _isFrap.value = v;

  bool haveFrap = false;

  Function(List addMachines)? addMachines;

  int aftersaleIdx = 0;

  Map productData = {};

  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      machines = datas["machines"] ?? [];
      aftersaleType = datas["type"] ?? 0;
      aftersaleIdx = datas["aftersaleIdx"] ?? 0;
      orderData = datas["orderData"] ?? {};
      addMachines = datas["addMachines"];

      List commodityList = orderData["commodity"] ?? [];
      if (aftersaleIdx < commodityList.length) {
        productData = commodityList[aftersaleIdx];
      }
      // productData =
      if (machines.length > 5) {
        isFrap = true;
        haveFrap = true;
      }
      checkSelect();
    }
    super.onInit();
  }

  allSelectAction() {
    checkSelect(allSelect: !allselect);
    update();
  }

  checkSelect({bool? allSelect}) {
    bool isAllSelect = true;

    for (var e in machines) {
      if (allSelect != null) {
        e["selected"] = allSelect;
        isAllSelect = allSelect;
      } else {
        if (!(e["selected"] ?? false)) {
          isAllSelect = false;
          break;
        }
      }
    }
    allselect = isAllSelect;
  }

  confirmAction() {
    if (addMachines != null) {
      addMachines!(machines);
    }
  }
}

class MachineAftersaleSelect extends GetView<MachineAftersaleSelectController> {
  const MachineAftersaleSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
          context,
          "选择${controller.aftersaleType == 0 ? "换" : controller.aftersaleType == 1 ? "退" : "发"}货设备"),
      body: Stack(
        children: [
          Positioned.fill(
              bottom: 55.w + paddingSizeBottom(context),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    gwb(375),
                    ghb(15),
                    Container(
                      width: 345.w,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.w)),
                      child: Column(
                        children: [
                          gwb(345),
                          sbhRow([
                            getSimpleText(
                                "订单编号：${controller.orderData["orderNo"] ?? ""}",
                                10,
                                AppColor.text3),
                          ], width: 315, height: 40),
                          Container(
                            width: 315.w,
                            padding: EdgeInsets.symmetric(vertical: 10.w),
                            decoration: BoxDecoration(
                                color: AppColor.pageBackgroundColor,
                                borderRadius: BorderRadius.circular(8.w)),
                            child: Center(
                                child: sbRow([
                              centRow([
                                CustomNetworkImage(
                                  src: AppDefault().imageUrl +
                                      (controller.productData["shopImg"] ?? ""),
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.fill,
                                ),
                                gwb(8),
                                centClm([
                                  getSimpleText(
                                      controller.productData["shopName"] ?? "",
                                      12,
                                      AppColor.text,
                                      isBold: true),
                                  ghb(5),
                                  getSimpleText(
                                    controller.productData["shopModel"] ?? "",
                                    12,
                                    AppColor.text3,
                                  ),
                                  ghb(2),
                                  getSimpleText(
                                      "￥${priceFormat(controller.productData["nowPrice"] ?? 0)}",
                                      15,
                                      AppColor.red,
                                      isBold: true,
                                      textHeight: 1.3),
                                ],
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start),
                              ]),
                              getSimpleText(
                                  "x${controller.productData["num"] ?? 1}",
                                  12,
                                  AppColor.text3)
                            ], width: 315 - 10 * 2)),
                          ),
                          sbhRow([
                            getSimpleText(
                              "设备列表(共${controller.machines.length}台)",
                              12,
                              AppColor.text3,
                            ),
                            controller.haveFrap
                                ? CustomButton(
                                    onPressed: () {
                                      controller.isFrap = !controller.isFrap;
                                    },
                                    child: SizedBox(
                                      height: 55.w,
                                      child: centRow([
                                        getSimpleText("收回", 12, AppColor.text3),
                                        GetX<MachineAftersaleSelectController>(
                                          builder: (_) {
                                            return AnimatedRotation(
                                              turns:
                                                  controller.isFrap ? 0.5 : 1,
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              child: Icon(
                                                Icons
                                                    .keyboard_double_arrow_down_rounded,
                                                color: AppColor.text3,
                                                size: 19.w,
                                              ),
                                            );
                                          },
                                        )
                                      ]),
                                    ),
                                  )
                                : ghb(0)
                          ], width: 315, height: 55),
                          GetX<MachineAftersaleSelectController>(
                            builder: (_) {
                              return AnimatedContainer(
                                width: 315.w,
                                height: 65.5.w *
                                    (controller.isFrap
                                        ? 5
                                        : controller.machines.length),
                                duration: const Duration(milliseconds: 200),
                                child: GetBuilder<
                                    MachineAftersaleSelectController>(
                                  builder: (_) {
                                    return SingleChildScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: centClm(List.generate(
                                          controller.machines.length,
                                          (index) => machineCell(index,
                                              controller.machines[index]))),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    ghb(15)
                  ],
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 55.w + paddingSizeBottom(context),
              child: Container(
                padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)
                ]),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: sbhRow([
                      CustomButton(
                        onPressed: () {
                          controller.allSelectAction();
                        },
                        child: GetX<MachineAftersaleSelectController>(
                            builder: (_) {
                          return SizedBox(
                            height: 55,
                            child: centRow([
                              Image.asset(
                                assetsName(
                                    "machine/checkbox_${controller.allselect ? "selected" : "normal"}"),
                                width: 16.w,
                                fit: BoxFit.fitWidth,
                              ),
                              gwb(12),
                              getSimpleText(
                                  "${controller.allselect ? "反" : "全"}选",
                                  14,
                                  AppColor.text,
                                  textHeight: 1.3),
                            ]),
                          );
                        }),
                      ),
                      CustomButton(
                        onPressed: () {
                          if (!controller.btnEnable) {
                            ShowToast.normal("选择的设备超出数量");
                            return;
                          }
                          controller.confirmAction();

                          // push(
                          //     AppSuccessResult(
                          //       title:
                          //           "${controller.aftersaleType == 0 ? "换" : "退"}货结果",
                          //       contentTitle: "提交成功",
                          //       buttonTitles: const ["查看订单", "返回列表"],
                          //       backPressed: () {
                          //         popToUntil();
                          //       },
                          //       onPressed: (index) {
                          //         if (index == 0) {
                          //           popToUntil(
                          //               page: const MachineOrderList(),
                          //               binding: MachineOrderListBinding());
                          //         } else if (index == 1) {
                          //           popToUntil(
                          //               page: const MachineOrderList(),
                          //               binding: MachineOrderListBinding());
                          //         }
                          //       },
                          //     ),
                          //     context);
                        },
                        child: GetX<MachineAftersaleSelectController>(
                            builder: (_) {
                          return Opacity(
                            opacity: controller.btnEnable ? 1 : 0.5,
                            child: Container(
                              width: 90.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                  color: AppColor.theme,
                                  borderRadius: BorderRadius.circular(15.w)),
                              child: Center(
                                child: getSimpleText("确认", 14, Colors.white,
                                    textHeight: 1.3),
                              ),
                            ),
                          );
                        }),
                      )
                    ], width: 375 - 15 * 2, height: 55)),
              ))
        ],
      ),
    );
  }

  machineCell(int index, Map data) {
    return CustomButton(
        onPressed: () {
          data["selected"] = !data["selected"];
          controller.checkSelect();
          controller.update();
        },
        child: centClm([
          index == 0 ? gline(315, 0.5) : ghb(0),
          sbhRow([
            centRow([
              gwb(3),
              Image.asset(
                assetsName(
                    "machine/checkbox_${(data["selected"] ?? false) ? "selected" : "normal"}"),
                width: 16.w,
                fit: BoxFit.fitWidth,
              ),
              gwb(15),
              centClm([
                getSimpleText(data["name"] ?? "", 12, AppColor.text2),
                ghb(5),
                getSimpleText("设备编号：${data["tNo"] ?? ""}", 12, AppColor.text3)
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ]),
            getSimpleText(data["stateStr"] ?? "", 12, AppColor.text2)
          ], width: 315, height: 65),
          index != controller.machines.length - 1 ? gline(315, 0.5) : ghb(0),
        ]));
  }
}
