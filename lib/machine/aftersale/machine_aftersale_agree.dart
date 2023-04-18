import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/machine/machine_order_aftersale.dart';
import 'package:cxhighversion2/machine/machine_order_list.dart';
import 'package:cxhighversion2/machine/machine_order_util.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachineAftersaleAgreeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineAftersaleAgreeController>(
        MachineAftersaleAgreeController(datas: Get.arguments));
  }
}

class MachineAftersaleAgreeController extends GetxController {
  final dynamic datas;
  MachineAftersaleAgreeController({this.datas});

  MachineOrderUtil util = MachineOrderUtil();

  final nameInputCtrl = TextEditingController();
  final addressInputCtrl = TextEditingController();
  final phoneInputCtrl = TextEditingController();
  final backMoneyInputCtrl = TextEditingController();
  final backMoneyNode = FocusNode();

  final _editMoney = false.obs;
  bool get editMoney => _editMoney.value;
  set editMoney(v) => _editMoney.value = v;

  final _btnEnablue = true.obs;
  bool get btnEnablue => _btnEnablue.value;
  set btnEnablue(v) => _btnEnablue.value = v;

  int serviceType = 1;
  Map aftersaleOrderData = {};
  int orderNum = 0;
  List productList = [];

  backMoneyNodeListener() {
    if (!backMoneyNode.hasFocus) {
      editMoney = false;
    }
  }

  final _backMoneyStr = "".obs;
  String get backMoneyStr => _backMoneyStr.value;
  set backMoneyStr(v) => _backMoneyStr.value = v;

  backMoneyInputListener() {
    backMoneyStr = priceFormat(backMoneyInputCtrl.text);
  }

  agreeAction() {
    if (serviceType == 2) {
      if (backMoneyInputCtrl.text.isEmpty) {
        ShowToast.normal("请输入退货金额");
        return;
      }
      if (double.tryParse(backMoneyInputCtrl.text) == null) {
        ShowToast.normal("请输入正确的退货金额");
        return;
      }
    }

    if (nameInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入收货人姓名");
      return;
    }
    if (addressInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入收货地址");
      return;
    }
    if (phoneInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入手机号码");
      return;
    }
    btnEnablue = false;
    simpleRequest(
      url: Urls.userLevelUpAfterSaleConfirm,
      params: {
        "id": aftersaleOrderData["id"],
        "returnAmount":
            serviceType == 2 ? double.tryParse(backMoneyInputCtrl.text) : 0,
        "uRecipient": nameInputCtrl.text,
        "uMobile": phoneInputCtrl.text,
        "deliveryAddress": addressInputCtrl.text,
      },
      success: (success, json) {
        if (success) {
          Get.find<MachineOrderListController>().loadData(index: 1);
          push(
              AppSuccessResult(
                contentTitle:
                    "${serviceType == 1 ? "换货" : "退货"}单已生成，等待买家${serviceType == 1 ? "寄回" : "退货"}",
                buttonTitles: const ["查看订单", "返回列表"],
                backPressed: () {
                  util.popToList();
                },
                onPressed: (index) {
                  if (index == 0) {
                    util.popToList(
                        page: const MachineOrderAftersale(),
                        binding: MachineOrderAftersaleBinding(),
                        arguments: {
                          "orderData": aftersaleOrderData,
                          "isMine": false
                        });
                  } else {
                    util.popToList();
                  }
                },
              ),
              Global.navigatorKey.currentContext!);
        }
      },
      after: () {
        btnEnablue = true;
      },
    );
  }

  @override
  void onInit() {
    aftersaleOrderData = datas["orderData"] ?? {};
    serviceType = aftersaleOrderData["serviceType"] ?? 1;
    productList = aftersaleOrderData["commodity"] ?? [];
    orderNum = 0;
    for (var e in productList) {
      orderNum += (e["num"] ?? 1) as int;
    }
    backMoneyNode.addListener(backMoneyNodeListener);
    backMoneyInputCtrl.addListener(backMoneyInputListener);
    super.onInit();
  }

  @override
  void onClose() {
    backMoneyNode.removeListener(backMoneyNodeListener);
    backMoneyInputCtrl.removeListener(backMoneyInputListener);
    backMoneyNode.dispose();
    nameInputCtrl.dispose();
    addressInputCtrl.dispose();
    phoneInputCtrl.dispose();
    backMoneyInputCtrl.dispose();

    super.onClose();
  }
}

class MachineAftersaleAgree extends GetView<MachineAftersaleAgreeController> {
  const MachineAftersaleAgree({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
            context, "生成${controller.serviceType == 1 ? "换货" : "退货"}单"),
        body: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 55.w + paddingSizeBottom(context),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                    bottom: paddingSizeBottom(context),
                  ),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(color: const Color(0x0D000000), blurRadius: 5.w)
                  ]),
                  child: sbhRow([
                    controller.serviceType == 1
                        ? gwb(0)
                        : GetX<MachineAftersaleAgreeController>(
                            builder: (_) {
                              return getRichText(
                                  "应退金额",
                                  "￥${priceFormat(controller.backMoneyStr)}",
                                  12,
                                  AppColor.text,
                                  15,
                                  AppColor.red,
                                  isBold2: true,
                                  h1: 1.3,
                                  h2: 1.3);
                            },
                          ),
                    GetX<MachineAftersaleAgreeController>(
                      builder: (controller) {
                        return CustomButton(
                          onPressed: () {
                            if (!controller.btnEnablue) {
                              return;
                            }
                            controller.util.myAlert(
                                "是否确定同意${controller.serviceType == 1 ? "换货" : "退货"}",
                                () {
                              controller.agreeAction();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 90.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.w),
                              color: AppColor.theme.withOpacity(
                                  controller.btnEnablue ? 1.0 : 0.5),
                            ),
                            child: getSimpleText("确认", 14, Colors.white),
                          ),
                        );
                      },
                    )
                  ], width: 375 - 15 * 2, height: 55),
                )),
            Positioned.fill(
                bottom: 55.w + paddingSizeBottom(context),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ghb(15),
                      machineInfoView(),
                      orderInfoView(),
                      ghb(15),
                      controller.serviceType == 2
                          ? backMoneyInputView()
                          : ghb(0),
                      ghb(controller.serviceType == 2 ? 15 : 0),
                      addressInputView(),
                      ghb(20),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget backMoneyInputView() {
    return Container(
      width: 345.w,
      height: 50.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
      child: sbhRow([
        getWidthText("退款金额", 14, AppColor.text3, 80, 1, textHeight: 1.3),
        centRow([
          GetX<MachineAftersaleAgreeController>(
            builder: (_) {
              return controller.editMoney
                  ? CustomInput(
                      width: (315 - 80 - 18 - 55 - 5).w,
                      heigth: 50.w,
                      textEditCtrl: controller.backMoneyInputCtrl,
                      textAlign: TextAlign.end,
                      focusNode: controller.backMoneyNode,
                      placeholder: "",
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColor.red,
                          height: 1.3,
                          fontWeight: AppDefault.fontBold),
                      placeholderStyle: TextStyle(
                          fontSize: 15.sp,
                          color: AppColor.assisText,
                          height: 1.3),
                    )
                  : getSimpleText(
                      "￥${priceFormat(controller.backMoneyInputCtrl.text.isEmpty ? 0 : controller.backMoneyInputCtrl.text)}",
                      15,
                      AppColor.red,
                      isBold: true);
            },
          ),
          gwb(5),
          CustomButton(
            onPressed: () {
              controller.editMoney = true;
              controller.backMoneyNode.requestFocus();
            },
            child: Center(
              child: SizedBox(
                height: 50.w,
                child: Center(
                  child: centRow([
                    Image.asset(
                      assetsName("machine/btn_edit"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                    gwb(3),
                    getSimpleText("修改金额", 12, AppColor.text2)
                  ]),
                ),
              ),
            ),
          )
        ])
      ], width: 315, height: 50),
    );
  }

  Widget addressInputView() {
    return Container(
      width: 345.w,
      padding: EdgeInsets.symmetric(vertical: 10.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
      child: Column(children: [
        ...List.generate(3, (index) {
          return sbhRow([
            getWidthText(
                index == 0
                    ? "收货人姓名"
                    : index == 1
                        ? "收货地址"
                        : "手机号码",
                14,
                AppColor.text3,
                80,
                1,
                textHeight: 1.3),
            CustomInput(
              width: (315 - 80 - 1).w,
              heigth: 45.w,
              keyboardType:
                  index == 2 ? TextInputType.phone : TextInputType.text,
              textEditCtrl: index == 0
                  ? controller.nameInputCtrl
                  : index == 1
                      ? controller.addressInputCtrl
                      : controller.phoneInputCtrl,
              textAlign: TextAlign.end,
              style:
                  TextStyle(fontSize: 12.sp, color: AppColor.text, height: 1.3),
              placeholderStyle: TextStyle(
                  fontSize: 12.sp, color: AppColor.assisText, height: 1.3),
              placeholder: index == 0
                  ? "请输入您的姓名"
                  : index == 1
                      ? "请输入您的收货地址"
                      : "请输入您的手机号码",
            ),
          ], width: 345 - 15 * 2, height: 45);
        }),
      ]),
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
          controller.util.orderDetailInfoCell("服务单号",
              t2: controller.aftersaleOrderData["serviceNo"] ?? "",
              type: 1,
              height: cellHeight),
          controller.util.orderDetailInfoCell("申请时间",
              t2: controller.aftersaleOrderData["addTime"] ?? "",
              type: 1,
              height: cellHeight),
          controller.util.orderDetailInfoCell("售后类型",
              t2: controller.serviceType == 1 ? "换货" : "退货",
              type: 1,
              height: cellHeight),
          controller.util.orderDetailInfoCell("申请原因",
              t2: controller.aftersaleOrderData["userReason"] ?? "",
              type: 1,
              height: cellHeight,
              maxLines: 10),
          ghb(cellHeight - 20),
          // (controller.aftersaleOrderData["serviceType"] ?? 1) == 2
          //     ? controller.util.orderDetailInfoCell("退款金额",
          //         rightWidget: getSimpleText(
          //             "￥${priceFormat(controller.aftersaleOrderData["price"] ?? 0)}",
          //             15,
          //             AppColor.red),
          //         type: 1,
          //         height: cellHeight,
          //         maxLines: 10)
          //     : ghb(0),
          ghb(5)
        ],
      ),
    );
  }
}
