import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

class MineFeedbackBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineFeedbackController>(MineFeedbackController());
  }
}

class MineFeedbackController extends GetxController {
  TextEditingController contentInputCtrl = TextEditingController();

  int countLength = 100;

  int typeIdx = -1;

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  final _realTypeIdx = (-1).obs;
  int get realTypeIdx => _realTypeIdx.value;
  set realTypeIdx(v) => _realTypeIdx.value = v;

  final _contentInputCount = (-1).obs;
  int get contentInputCount => _contentInputCount.value;
  set contentInputCount(v) => _contentInputCount.value = v;

  List typeList = [
    {"id": 1, "name": "使用卡顿"},
    {"id": 2, "name": "操作体验"},
    {"id": 3, "name": "界面审美"},
    {"id": 4, "name": "页面闪退"},
    {"id": 5, "name": "支付问题"},
    {"id": 6, "name": "商城问题"},
    {"id": 7, "name": "账号问题"},
    {"id": 8, "name": "其他意见"}
  ];

  sendFeedBackAction() {
    if (realTypeIdx < 0) {
      ShowToast.normal("请选择反馈类型");
      return;
    }
    if (contentInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写问题描述");
      return;
    }
    submitEnable = false;

    simpleRequest(
      url: Urls.userFeedback,
      params: {
        "title": typeList[realTypeIdx]["name"],
        "content": contentInputCtrl.text
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("感谢您的反馈，我们会尽快就您的问题进行改进");
          Future.delayed(const Duration(seconds: 1), () {
            popToUntil();
          });
        }
      },
      after: () {
        submitEnable = true;
      },
    );
  }

  countListener() {
    contentInputCount = contentInputCtrl.text.length;
  }

  // late AppImagePicker imagePicker;
  @override
  void onInit() {
    contentInputCtrl.addListener(countListener);
    // imagePicker = AppImagePicker(
    //   multiple: true,
    //   imgsCallback: (imgFiles) {
    //     imageList = imgFiles;
    //     // upLoadImg(uploadImageFile!);
    //     update([imageListBuildId]);
    //   },
    // );
    super.onInit();
  }

  @override
  void dispose() {
    contentInputCtrl.removeListener(countListener);
    contentInputCtrl.dispose();
    super.dispose();
  }
}

class MineFeedback extends GetView<MineFeedbackController> {
  const MineFeedback({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
            appBar: getDefaultAppBar(context, "意见反馈"),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                ghb(15),
                gwb(375),
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
                            getWidthText("反馈类型", 14, AppColor.text2, 80, 1),
                            GetX<MineFeedbackController>(
                              builder: (_) {
                                return getWidthText(
                                    controller.realTypeIdx < 0
                                        ? "请选择"
                                        : controller.typeList[
                                            controller.realTypeIdx]["name"],
                                    14,
                                    controller.realTypeIdx < 0
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
                      ghb(10),
                      sbRow([
                        centRow([
                          getWidthText("问题描述", 14, AppColor.text2, 80, 1),
                        ], crossAxisAlignment: CrossAxisAlignment.start),
                        Padding(
                          padding: EdgeInsets.only(top: 3.w),
                          child: CustomInput(
                            textEditCtrl: controller.contentInputCtrl,
                            width: (315 - 80).w,
                            heigth: 193.5.w,
                            placeholder: "描述一下所遇到的问题吧...",
                            style: TextStyle(
                                fontSize: 14.w,
                                color: AppColor.text,
                                height: 1.3),
                            placeholderStyle: TextStyle(
                                fontSize: 14.w, color: AppColor.assisText),
                            textAlignVertical: TextAlignVertical.top,
                            textAlign: TextAlign.start,
                            maxLines: 100,
                            maxLength: 100,
                          ),
                        ),
                      ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          width: 315),
                    ],
                  ),
                ),
                ghb(29),
                GetX<MineFeedbackController>(
                  builder: (_) {
                    return getSubmitBtn("提交", () {
                      controller.sendFeedBackAction();
                    },
                        width: 345,
                        height: 45,
                        fontSize: 15,
                        color: AppColor.theme,
                        enable: controller.submitEnable);
                  },
                ),
              ]),
            )));
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
                            controller.realTypeIdx = controller.typeIdx;
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
              scrollController:
                  FixedExtentScrollController(initialItem: controller.typeIdx),
              itemExtent: 40.w,
              childCount: controller.typeList.length,
              onSelectedItemChanged: (value) {
                controller.typeIdx = value;
              },
              itemBuilder: (context, index) {
                return Center(
                  child: GetX<MineFeedbackController>(
                    builder: (_) {
                      return getSimpleText(
                          controller.typeList[index]["name"], 15, AppColor.text,
                          fw: controller.realTypeIdx == index
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
