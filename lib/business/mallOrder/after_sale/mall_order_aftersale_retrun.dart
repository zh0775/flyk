import 'package:cxhighversion2/business/mallOrder/after_sale/mall_order_aftersale_order_list.dart';
import 'package:cxhighversion2/business/mallOrder/mall_order_status.page.dart';
import 'package:cxhighversion2/business/pointsMall/points_mall_page.dart';
import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_upload_imageview.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MallOrderAftersaleRetrunBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderAftersaleRetrunController>(
        MallOrderAftersaleRetrunController(datas: Get.arguments));
  }
}

class MallOrderAftersaleRetrunController extends GetxController {
  final dynamic datas;
  MallOrderAftersaleRetrunController({this.datas});

  final noInputCtrl = TextEditingController();
  final phoneInputCtrl = TextEditingController();

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  final _shipcompanyIdx = (-1).obs;
  int get shipcompanyIdx => _shipcompanyIdx.value;
  set shipcompanyIdx(v) => _shipcompanyIdx.value = v;

  final _realShipcompanyIdx = (-1).obs;
  int get realShipcompanyIdx => _realShipcompanyIdx.value;
  set realShipcompanyIdx(v) => _realShipcompanyIdx.value = v;

  List imageUrls = [];

  closeShipSelect() {
    Get.back();
    shipcompanyIdx = realShipcompanyIdx;
  }

  confirmShipSelect() {
    Get.back();
    realShipcompanyIdx = shipcompanyIdx;
  }

  submitAction() {
    if (realShipcompanyIdx < 0) {
      ShowToast.normal("请选择物流公司");
      return;
    }
    if (noInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入物流单号");
      return;
    }
    if (phoneInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入联系电话");
      return;
    }

    push(
        AppSuccessResult(
          title: "",
          success: true,
          contentTitle: "提交成功",
          orangeThame: true,
          buttonTitles: const ["查看列表", "返回订单"],
          backPressed: () {
            Get.find<MallOrderStatusPageController>().loadDetail();
            Get.until(
              (route) => route is GetPageRoute
                  ? route.binding is MallOrderStatusPageBinding ||
                          route.binding is MainPageBinding
                      ? true
                      : false
                  : false,
            );
          },
          onPressed: (index) {
            if (index == 0) {
              Get.offUntil(
                GetPageRoute(
                  page: () => const MallOrderAftersaleOrderList(),
                  binding: MallOrderAftersaleOrderListBinding(),
                ),
                (route) => route is GetPageRoute
                    ? route.binding is PointsMallPageBinding ||
                            route.binding is MainPageBinding
                        ? true
                        : false
                    : false,
              );
            } else {
              Get.find<MallOrderStatusPageController>().loadDetail();
              Get.until(
                (route) => route is GetPageRoute
                    ? route.binding is MallOrderStatusPageBinding ||
                            route.binding is MainPageBinding
                        ? true
                        : false
                    : false,
              );
            }
          },
        ),
        Global.navigatorKey.currentContext!);
  }

  Map orderData = {};
  Map productData = {};
  List shipcompanys = [];
  @override
  void onInit() {
    orderData = (datas ?? {})["order"] ?? {};
    productData = (datas ?? {})["product"] ?? {};
    shipcompanys = AppDefault().publicHomeData["logisticeListInfo"] ?? [];
    super.onInit();
  }

  @override
  void onClose() {
    noInputCtrl.dispose();
    phoneInputCtrl.dispose();
    super.onClose();
  }
}

class MallOrderAftersaleRetrun
    extends GetView<MallOrderAftersaleRetrunController> {
  const MallOrderAftersaleRetrun({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "填写退货物流"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ghb(15),
              gwb(375),
              Container(
                width: 345.w,
                decoration: getDefaultWhiteDec(radius: 8),
                child: Column(
                  children: [
                    CustomButton(
                      onPressed: () {
                        showShipCompanySelect();
                      },
                      child: sbhRow([
                        centRow([
                          getWidthText("物流公司", 14, AppColor.text3, 80, 1),
                          GetX<MallOrderAftersaleRetrunController>(
                            builder: (_) {
                              return getWidthText(
                                  controller.realShipcompanyIdx < 0
                                      ? "请选择"
                                      : controller.shipcompanys[
                                              controller.realShipcompanyIdx]
                                          ["logistics_Name"],
                                  14,
                                  controller.realShipcompanyIdx < 0
                                      ? AppColor.assisText
                                      : AppColor.text,
                                  315 - 80 - 30 - 18,
                                  1);
                            },
                          )
                        ]),
                        Image.asset(
                          assetsName("statistics/icon_arrow_right_gray"),
                          width: 15.w,
                          fit: BoxFit.fitWidth,
                        )
                      ], width: 315, height: 44.5),
                    ),
                    gline(315, 0.5),
                    sbhRow([
                      centRow([
                        getWidthText("物流单号", 14, AppColor.text3, 80, 1),
                        CustomInput(
                          textEditCtrl: controller.noInputCtrl,
                          width: (315 - 80 - 18 - 30).w,
                          heigth: 46.w,
                          placeholder: "请输入物流单号",
                          style:
                              TextStyle(fontSize: 14.w, color: AppColor.text),
                          placeholderStyle: TextStyle(
                              fontSize: 14.w, color: AppColor.assisText),
                        ),
                      ]),
                    ], width: 315, height: 46),
                    gline(315, 0.5),
                    sbhRow([
                      centRow([
                        getWidthText("联系电话", 14, AppColor.text3, 80, 1),
                        CustomInput(
                          textEditCtrl: controller.phoneInputCtrl,
                          width: (315 - 80 - 18 - 30).w,
                          heigth: 46.w,
                          placeholder: "请输入联系电话",
                          style:
                              TextStyle(fontSize: 14.w, color: AppColor.text),
                          keyboardType: TextInputType.phone,
                          placeholderStyle: TextStyle(
                              fontSize: 14.w, color: AppColor.assisText),
                        ),
                      ]),
                    ], width: 315, height: 46),
                  ],
                ),
              ),
              ghb(15),
              CustomUploadImageView(
                maxImgCount: 3,
                tipStr: "注：最多可上传3张图片",
                imageUpload: (imgs) {
                  controller.imageUrls = imgs;
                },
              ),
              ghb(30),
              GetX<MallOrderAftersaleRetrunController>(
                builder: (_) {
                  return getSubmitBtn("提交", () {
                    controller.submitAction();
                  },
                      width: 345,
                      height: 45,
                      color: AppColor.themeOrange,
                      enable: controller.submitEnable);
                },
              ),
              ghb(20)
            ],
          ),
        ),
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
                    return GetX<MallOrderAftersaleRetrunController>(
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
