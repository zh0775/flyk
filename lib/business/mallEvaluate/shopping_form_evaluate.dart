// 评论表单  发表评价

import 'package:cxhighversion2/business/mallEvaluate/mall_evaluate_page.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_upload_imageview.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EvaluateFormPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<EvaluateFormPageController>(
        EvaluateFormPageController(datas: Get.arguments));
  }
}

class EvaluateFormPageController extends GetxController {
  final dynamic datas;
  EvaluateFormPageController({this.datas});

  final _isCurrentStar = (-1).obs;
  get currentStar => _isCurrentStar.value;
  set currentStar(v) => _isCurrentStar.value = v;

  final descriptionInputCtrl = TextEditingController();

  List imageUrls = [];

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  submitAction() {
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

    simpleRequest(
      url: Urls.userCommentAdd,
      params: {
        "productID": datas['productID'], // 商品ID
        "orderID": datas['orderID'], // 订单ID
        "score": currentStar, // 分数
        "comment": descriptionInputCtrl.text, // 评论
        "images": certificate, // 图片
      },
      success: (success, json) {
        if (success) {
          Get.find<MallEvaluatePageController>().loadNotEvaluteList();
          Get.find<MallEvaluatePageController>().loadHasEvaluteList();
          ShowToast.normal("提交成功");
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
}

class EvaluateFormPage extends GetView<EvaluateFormPageController> {
  const EvaluateFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, '发表评价'),
      body: Container(
        width: 375.w,
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            evaluateFormBox(),
            ghb(15),
            evaluateWrapper(),
            ghb(15),
            evaluateSubmit(),
          ],
        ),
      ),
    );
  }

  // 评论表单
  Widget evaluateFormBox() {
    return GetBuilder<EvaluateFormPageController>(
      initState: (_) {},
      builder: (_) {
        return Container(
          child: Column(
            children: [
              Container(
                width: 375.w - 15.w * 2,
                padding: EdgeInsets.fromLTRB(9.w, 12.w, 9.w, 18.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Row(
                  children: [
                    CustomNetworkImage(
                      src: AppDefault().imageUrl +
                          (controller.datas["shopImg"] ?? ""),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    gwb(11.w),
                    SizedBox(
                      width: 345.w - 60.w - 11.w - 16.w,
                      height: 60.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          getSimpleText(controller.datas["shopName"] ?? '', 15,
                              const Color(0xFF333333)),
                          SizedBox(
                            child: starButton(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 五星评论
  Widget starButton() {
    return Row(
        children: List.generate(5, (index) {
      return GetBuilder<EvaluateFormPageController>(
        initState: (_) {},
        builder: (_) {
          return CustomButton(
            onPressed: () {
              controller.currentStar = index;
              controller.update();
            },
            child: Image.asset(
              index <= controller.currentStar
                  ? assetsName('business/icon_star')
                  : assetsName('business/icon_star_border'),
              width: 28.5,
              height: 27.5,
            ),
          );
        },
      );
    }));
  }

  // 表单提交信息

  Widget evaluateWrapper() {
    return Container(
      width: 375.w - 15.w * 2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      padding: EdgeInsets.fromLTRB(3.w, 11.w, 3.w, 11.w),
      child: Column(
        children: [
          sbRow([
            CustomInput(
              textEditCtrl: controller.descriptionInputCtrl,
              width: (315 - 80).w,
              heigth: 138.5.w,
              placeholder: "请说出您对商品的使用感受...",
              style: TextStyle(fontSize: 14.w, color: AppColor.text),
              placeholderStyle:
                  TextStyle(fontSize: 14.w, color: AppColor.assisText),
              textAlignVertical: TextAlignVertical.top,
              textAlign: TextAlign.start,
              maxLines: 100,
            ),
          ], crossAxisAlignment: CrossAxisAlignment.start, width: 315),
          CustomUploadImageView(
            maxImgCount: 3,
            tipStr: "注：最多可上传3张图片",
            imageUpload: (imgs) {
              controller.imageUrls = imgs;
            },
          ),
        ],
      ),
    );
  }

  Widget evaluateSubmit() {
    return Container(
      child: GetX<EvaluateFormPageController>(
        builder: (_) {
          return getSubmitBtn("确定", () {
            controller.submitAction();
          },
              width: 345,
              height: 45,
              color: AppColor.themeOrange,
              enable: controller.submitEnable);
        },
      ),
    );
  }
}
