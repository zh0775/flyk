import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_upload_imageview.dart';
import 'package:cxhighversion2/home/contactCustomerService/contact_order_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ContactAddOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ContactAddOrderController>(
        ContactAddOrderController(datas: Get.arguments));
  }
}

class ContactAddOrderController extends GetxController {
  final dynamic datas;
  ContactAddOrderController({this.datas});

  final descriptionInputCtrl = TextEditingController();
  final titleInputCtrl = TextEditingController();

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

    if (titleInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写工单标题");
      return;
    }

    if (descriptionInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写问题描述");
      return;
    }
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
        "serviceTitle": titleInputCtrl.text,
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

  @override
  void onInit() {
    serviceTypeList =
        (AppDefault().publicHomeData["appHelpRule"] ?? {})["serviceType"] ?? [];
    super.onInit();
  }

  @override
  void onClose() {
    titleInputCtrl.dispose();
    descriptionInputCtrl.dispose();
    super.onClose();
  }
}

class ContactAddOrder extends GetView<ContactAddOrderController> {
  const ContactAddOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "新建工单"),
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
                        getWidthText("服务类型", 14, AppColor.text2, 80, 1),
                        GetX<ContactAddOrderController>(
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
                      getWidthText("工单标题", 14, AppColor.text2, 80, 1),
                      CustomInput(
                        textEditCtrl: controller.titleInputCtrl,
                        width: (315 - 80 - 18 - 30).w,
                        heigth: 46.w,
                        placeholder: "请输入标题",
                        style: TextStyle(fontSize: 14.w, color: AppColor.text),
                        placeholderStyle: TextStyle(
                            fontSize: 14.w, color: AppColor.assisText),
                      ),
                    ]),
                  ], width: 315, height: 46),
                  gline(315, 0.5),
                  ghb(10),
                  sbRow([
                    centRow([
                      getWidthText("问题描述", 14, AppColor.text2, 80, 1),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    CustomInput(
                      textEditCtrl: controller.descriptionInputCtrl,
                      width: (315 - 80).w,
                      heigth: 138.5.w,
                      placeholder: "描述一下所遇到的问题吧...",
                      style: TextStyle(fontSize: 14.w, color: AppColor.text),
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
            ghb(15),
            CustomUploadImageView(
              maxImgCount: 3,
              tipStr: "注：最多可上传3张图片",
              imageUpload: (imgs) {
                controller.imageUrls = imgs;
              },
            ),
            ghb(30),
            GetX<ContactAddOrderController>(
              builder: (_) {
                return getSubmitBtn("提交", () {
                  controller.submitAction();
                },
                    width: 345,
                    height: 45,
                    color: AppColor.theme,
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
      height: 165.w,
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
            height: 165.w - 52.w - 1.w,
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
                  child: GetX<ContactAddOrderController>(
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
