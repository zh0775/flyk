import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/machine/machine_order_aftersale.dart';
import 'package:cxhighversion2/machine/machine_order_list.dart';
import 'package:cxhighversion2/machine/machine_order_receive.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineOrderShipBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineOrderShipController>(
        MachineOrderShipController(datas: Get.arguments));
  }
}

class MachineOrderShipController extends GetxController {
  final dynamic datas;
  MachineOrderShipController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();

  TextEditingController shipNoCtrl = TextEditingController();
  // TextEditingController shipCoCtrl = TextEditingController();

  confirmShipAction({Function(bool succ)? result}) {
    if (shipNoCtrl.text.isEmpty) {
      ShowToast.normal("请填写快递单号");
      return;
    }
    if (realShipcompanyIdx < 0) {
      ShowToast.normal("请选择快递公司");
      return;
    }

    int maxCount = 0;
    int selectCount = 0;

    for (var e in selectMachines) {
      int num = e["num"] ?? 1;
      List sMachines = e["selectMachines"] ?? [];
      if (num != sMachines.length) {
        if (sMachines.length > num) {
          ShowToast.normal(
              "您的${e["shopName"] ?? ""}多选了${sMachines.length - num}台，请重新选择");
        } else {
          ShowToast.normal(
              "您的${e["shopName"] ?? ""}少选了${num - sMachines.length}台，请重新选择");
        }
        return;
      }
      maxCount += num;
      selectCount += sMachines.length;
    }
    if (selectCount != maxCount) {
      if (selectCount > maxCount) {
        ShowToast.normal("您多选了${selectCount - maxCount}台设备，请重新选择");
      } else {
        ShowToast.normal("您少选了${maxCount - selectCount}台设备，请重新选择");
      }
      return;
    }

    List deliveryNote = [];
    for (var p in selectMachines) {
      List sMachines = p["selectMachines"] ?? [];
      for (var m in sMachines) {
        deliveryNote.add({
          "id": m["tId"],
          "tNo": m["tNo"],
          "name": m["tbName"],
          "levleConfig_ID": p["levleConfig_ID"]
        });
      }
    }

    simpleRequest(
      url: isAftersale
          ? Urls.userLevelUpAfterSaleShipments
          : Urls.userLevelUpOrderConfirm,
      params: {
        "id": isAftersale ? aftersaleOrderData["id"] : orderData["id"],
        "deliveryNote": deliveryNote,
        "courier_ON": shipNoCtrl.text,
        "courierCompany_ID": shipcompanys[realShipcompanyIdx]["id"]
      },
      success: (success, json) {
        if (result != null) {
          result(success);
        }
      },
      after: () {},
    );
  }

  int status = 0;
  Map orderData = {};

  List productList = [];
  List machineList = [];
  String orderTypeName = "";

  int orderNum = 0;

  final _machines = Rx<List>([]);
  List get machines => _machines.value;
  set machines(v) => _machines.value = v;

  final _selectMachines = Rx<List>([]);
  List get selectMachines => _selectMachines.value;
  set selectMachines(v) => _selectMachines.value = v;

  final _selectCount = 0.obs;
  int get selectCount => _selectCount.value;
  set selectCount(v) => _selectCount.value = v;

  unSelectAction(int index) {
    selectMachines = selectMachines.where((e) => e["selected"]).toList();
    selectCount = selectMachines.length;
  }

  unSelectListAction(int index, int listIdx) {
    selectMachines[listIdx]["selectMachines"] =
        (selectMachines[listIdx]["selectMachines"] as List)
            .where((e) => e["selected"])
            .toList();
    int length = 0;
    for (var p in selectMachines) {
      for (var e in p["selectMachines"]) {
        length++;
      }
    }
    selectCount = length;
    update();
  }

  addMachines(List addMachines) {
    List adds = addMachines.map((e) {
      e["selected"] = true;
      return e;
    }).toList();

    machines = adds;
    selectMachines = adds;
    selectCount = selectMachines.length;
    Get.back();
  }

  getOrderFormat() {
    productList = orderData["commodity"] ?? [];
    for (var e in productList) {
      orderNum += (e["num"] ?? 1) as int;
    }
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
    // Map data = productList.isNotEmpty ? productList[0] : {};
    // selectCount = data.isEmpty ? 0 : data["num"];
    // selectCount = 6;
    // machines = List.generate(
    //     selectCount,
    //     (index) => {
    //           "id": index,
    //           "name": data["name"],
    //           "tNo": "T550006696",
    //           "img": data["img"],
    //           "status": index == 2 || index == 5 ? 1 : 0,
    //           "selected": true
    //         });
    // selectMachines = machines;
    // switch (status) {
    //   case 0:
    //     // orderTitle = "待支付";
    //     // orderSubTitle = "正在等待买家付款";
    //     break;
    //   case 1:
    //     // orderTitle = "待时候";
    //     // orderSubTitle = "正在等待卖家";
    //     break;
    // }
    // orderData["sponsor"] = "李明哲";

    // orderData["time"] =
    //     DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    // orderData["receiveName"] = "李泽民";
    // orderData["receivePhone"] = "13871982309";
    // orderData["receiveAddress"] = "武汉市共东西湖区金银滩大道碧桂园2栋1812";

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
  }

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

  bool isAftersale = false;
  Map aftersaleOrderData = {};

  @override
  void onInit() {
    if (datas != null && datas is Map && datas.isNotEmpty) {
      orderData = datas["orderData"] ?? {};
      isAftersale = datas["aftersale"] ?? false;
      aftersaleOrderData = datas["aftersaleOrderData"] ?? {};
      getOrderFormat();
    }
    shipcompanys = AppDefault().publicHomeData["logisticeListInfo"] ?? [];
    super.onInit();
  }

  @override
  void onClose() {
    shipNoCtrl.dispose();
    // shipCoCtrl.dispose();
    super.onClose();
  }
}

class MachineOrderShip extends GetView<MachineOrderShipController> {
  const MachineOrderShip({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "确认发货"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              ghb(15),
              machineInfoView(),
              ghb(15),
              GetBuilder<MachineOrderShipController>(
                builder: (_) {
                  return GetX<MachineOrderShipController>(
                    builder: (_) {
                      return controller.util.getOrSetMachineList(
                        2,
                        controller.machines,
                        controller.selectMachines,
                        controller.orderData,
                        addMachines: (machines) {
                          controller.addMachines(machines);
                        },
                        unSelectAction: (index) {
                          controller.unSelectAction(index);
                        },
                        unSelectListAction: (index, listIdx) {
                          controller.unSelectListAction(index, listIdx);
                        },
                      );
                    },
                  );
                },
              ),
              ghb(15),
              inputView(),
              ghb(31.5),
              getSubmitBtn("确认", () {
                takeBackKeyboard(context);
                controller.confirmShipAction(
                  result: (succ) {
                    if (succ) {
                      Get.find<MachineOrderListController>().loadData(index: 1);
                      push(
                          AppSuccessResult(
                            title: "发货结果",
                            contentTitle: "设备已发货",
                            buttonTitles: const ["查看订单", "返回列表"],
                            onPressed: (index) {
                              if (index == 0) {
                                if (controller.isAftersale) {
                                  controller.util.popToList(
                                      page: const MachineOrderAftersale(),
                                      binding: MachineOrderAftersaleBinding(),
                                      arguments: {
                                        "orderData":
                                            controller.aftersaleOrderData,
                                      });
                                } else {
                                  controller.util.popToList(
                                      page: const MachineOrderReceive(),
                                      binding: MachineOrderReceiveBinding(),
                                      arguments: {
                                        "orderData": controller.orderData,
                                      });
                                }
                              } else {
                                controller.util.popToList();
                              }
                            },
                            backPressed: () {
                              controller.util.popToList();
                            },
                          ),
                          context);
                    }
                  },
                );
              }, width: 345, height: 45, color: AppColor.theme),
              ghb(20),
            ],
          ),
        ),
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
          controller.util.orderDetailInfoCell("采购类型", t2: "正常采购"),
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

  Widget inputView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: List.generate(
            3,
            (index) => index == 1
                ? gline(315, 1)
                : Row(
                    children: [
                      gwb(15),
                      getWidthText(index == 0 ? "快递单号" : "快递公司", 14,
                          AppColor.text3, 75, 1,
                          textHeight: 1.3),
                      index == 0
                          ? CustomInput(
                              width: 315.w - 75.w - 1.w,
                              heigth: 55.w,
                              placeholder: "点击填写快递单号",
                              textEditCtrl: controller.shipNoCtrl,
                              placeholderStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColor.assisText,
                                  height: 1.3),
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColor.text,
                                  height: 1.3),
                            )
                          : CustomButton(
                              onPressed: () {
                                showShipCompanySelect();
                              },
                              child: sbhRow([
                                GetX<MachineOrderShipController>(
                                  builder: (_) {
                                    return getSimpleText(
                                        controller.realShipcompanyIdx >= 0 &&
                                                controller
                                                    .shipcompanys.isNotEmpty
                                            ? controller.shipcompanys[controller
                                                        .realShipcompanyIdx]
                                                    ["logistics_Name"] ??
                                                ""
                                            : "请选择快递公司",
                                        14,
                                        controller.realShipcompanyIdx >= 0
                                            ? AppColor.text
                                            : AppColor.assisText);
                                  },
                                ),
                                Image.asset(
                                  assetsName("mine/icon_right_arrow"),
                                  width: 12.w,
                                  fit: BoxFit.fitWidth,
                                )
                              ], height: 55, width: 315 - 75 - 1),
                            )
                    ],
                  )),
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
                    return GetX<MachineOrderShipController>(
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
