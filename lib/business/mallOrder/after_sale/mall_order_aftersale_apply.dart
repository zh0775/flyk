import 'package:cxhighversion2/business/mallOrder/after_sale/mall_order_aftersale_order_list.dart';
import 'package:cxhighversion2/business/mallOrder/after_sale/mall_order_aftersale_retrun.dart';
import 'package:cxhighversion2/business/mallOrder/mall_order_status.page.dart';
import 'package:cxhighversion2/business/pointsMall/points_mall_page.dart';
import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_upload_imageview.dart';
import 'package:cxhighversion2/home/contactCustomerService/contact_order_list.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MallOrderAftersaleApplyBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderAftersaleApplyController>(
        MallOrderAftersaleApplyController(datas: Get.arguments));
  }
}

class MallOrderAftersaleApplyController extends GetxController {
  final dynamic datas;
  MallOrderAftersaleApplyController({this.datas});

  final descriptionInputCtrl = TextEditingController();

  List serviceTypeList = [];

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  final _serviceIndex = (-1).obs;
  int get serviceIndex => _serviceIndex.value;
  set serviceIndex(v) => _serviceIndex.value = v;

  final _realServiceIndex = (-1).obs;
  int get realServiceIndex => _realServiceIndex.value;
  set realServiceIndex(v) => _realServiceIndex.value = v;

  List imageUrls = [];

  submitAction() {
    if (realServiceIndex < 0) {
      ShowToast.normal("请选择服务类型");
      return;
    }

    if (descriptionInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写问题描述");
      return;
    }

    if (aftersaleType == 0) {
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
    } else if (aftersaleType == 1) {
      push(const MallOrderAftersaleRetrun(), null,
          binding: MallOrderAftersaleRetrunBinding(),
          arguments: {
            "product": productData,
            "order": orderData,
          });
    }
    return;

    if (imageUrls.isEmpty) {
      ShowToast.normal("请上传凭证");
      return;
    }

    String certificate = "";
    List.generate(imageUrls.length, (index) {
      certificate += "${index == 0 ? "" : ","}${imageUrls[index]}";
    });

    submitEnable = false;

    simpleRequest(
      url: Urls.userCustomerServiceApply,
      params: {
        "cause": descriptionInputCtrl.text,
        "certificate": certificate,
        "serviceType": serviceTypeList[realServiceIndex]["id"] is String
            ? int.tryParse(serviceTypeList[realServiceIndex]["id"]) ?? -1
            : serviceTypeList[realServiceIndex]["id"]
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("提交成功");
          Get.find<ContactOrderListController>().loadList();
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  int aftersaleType = 0;
  Map orderData = {};
  Map productData = {};
  @override
  void onInit() {
    aftersaleType = (datas ?? {})["type"] ?? 0;
    orderData = (datas ?? {})["order"] ?? {};
    productData = (datas ?? {})["product"] ?? {};
    serviceTypeList =
        (AppDefault().publicHomeData["appHelpRule"] ?? {})["serviceType"] ?? [];
    super.onInit();
  }

  @override
  void onClose() {
    descriptionInputCtrl.dispose();
    super.onClose();
  }
}

class MallOrderAftersaleApply
    extends GetView<MallOrderAftersaleApplyController> {
  const MallOrderAftersaleApply({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
            context, controller.aftersaleType == 0 ? "申请退款" : "申请退货退款"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            gwb(375),
            ghb(15),
            Container(
              width: 345.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w)),
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () {
                      showTypeSelectModel();
                    },
                    child: sbhRow([
                      centRow([
                        getWidthText("退款原因", 14, AppColor.text3, 80, 1),
                        GetX<MallOrderAftersaleApplyController>(
                          builder: (_) {
                            return getWidthText(
                                controller.realServiceIndex < 0
                                    ? "请选择"
                                    : controller.serviceTypeList[
                                        controller.realServiceIndex]["name"],
                                14,
                                controller.realServiceIndex < 0
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
                      getWidthText("退款金额", 14, AppColor.text3, 80, 1),
                      getSimpleText(
                          "${priceFormat(controller.productData["nowPrice"] ?? 0, savePoint: 0)}积分",
                          14,
                          AppColor.text)
                    ]),
                  ], width: 315, height: 46),
                  gline(315, 0.5),
                  ghb(10),
                  sbRow([
                    centRow([
                      getWidthText("退款说明", 14, AppColor.text3, 80, 1),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    CustomInput(
                      textEditCtrl: controller.descriptionInputCtrl,
                      width: (315 - 80).w,
                      heigth: 138.5.w,
                      placeholder: "描述一下所遇到的问题吧...",
                      style: TextStyle(
                          fontSize: 14.w, color: AppColor.text, height: 1.5),
                      placeholderStyle:
                          TextStyle(fontSize: 14.w, color: AppColor.assisText),
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
                      maxLines: 100,
                    ),
                  ], crossAxisAlignment: CrossAxisAlignment.start, width: 315),
                ],
              ),
            ),
            controller.aftersaleType == 1
                ? Container(
                    margin: EdgeInsets.only(top: 15.w),
                    width: 345.w,
                    alignment: Alignment.center,
                    decoration: getDefaultWhiteDec(radius: 8),
                    child: sbhRow([
                      getSimpleText("退货方式", 14, AppColor.text3),
                      getSimpleText("自寄退回", 14, AppColor.text2),
                    ], width: 315, height: 50),
                  )
                : ghb(0),
            ghb(15),
            CustomUploadImageView(
              maxImgCount: 3,
              tipStr: "注：最多可上传3张图片",
              imageUpload: (imgs) {
                controller.imageUrls = imgs;
              },
            ),
            ghb(30),
            GetX<MallOrderAftersaleApplyController>(
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
          ]),
        ),
      ),
    );
  }

  showTypeSelectModel() {
    Get.bottomSheet(Container(
      height: 255.w,
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
                          if (index == 1) {
                            controller.realServiceIndex =
                                controller.serviceIndex;
                          }
                          Get.back();
                        },
                        child: SizedBox(
                          width: 65.w,
                          height: 52.w,
                          child: Center(
                            child: getSimpleText(index == 0 ? "取消" : "确定", 14,
                                index == 0 ? AppColor.text3 : AppColor.text),
                          ),
                        ),
                      )),
              height: 52,
              width: 375),
          gline(375, 1),
          SizedBox(
            width: 375.w,
            height: 255.w - 52.w - 1.w,
            child: CupertinoPicker.builder(
              scrollController: FixedExtentScrollController(
                  initialItem: controller.serviceIndex),
              itemExtent: 40.w,
              childCount: controller.serviceTypeList.length,
              onSelectedItemChanged: (value) {
                controller.serviceIndex = value;
              },
              itemBuilder: (context, index) {
                return Center(
                  child: GetX<MallOrderAftersaleApplyController>(
                    builder: (_) {
                      return getSimpleText(
                          controller.serviceTypeList[index]["name"],
                          15,
                          AppColor.text,
                          fw: controller.serviceIndex == index
                              ? FontWeight.w500
                              : FontWeight.normal);
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    ));
  }
}
