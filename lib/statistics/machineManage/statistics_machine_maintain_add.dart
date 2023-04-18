import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_upload_imageview.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineManage/statistics_machine_maintain.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsMachineMaintainAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineMaintainAddController>(
        StatisticsMachineMaintainAddController());
  }
}

class StatisticsMachineMaintainAddController extends GetxController {
  final dynamic datas;
  StatisticsMachineMaintainAddController({this.datas});

  TextEditingController noInputCtrl = TextEditingController();
  // TextEditingController newNoInputCtrl = TextEditingController();
  TextEditingController descriptionInputCtrl = TextEditingController();

  List imageUrls = [];

  final _faultIndex = (-1).obs;
  int get faultIndex => _faultIndex.value;
  set faultIndex(v) => _faultIndex.value = v;

  final _faultPickIndex = 0.obs;
  int get faultPickIndex => _faultPickIndex.value;
  set faultPickIndex(v) => _faultPickIndex.value = v;

  final _submitEnable = true.obs;
  bool get submitEnable => _submitEnable.value;
  set submitEnable(v) => _submitEnable.value = v;

  List faultList = [
    {"id": 1, "name": "错误类型1"},
    {"id": 2, "name": "错误类型2"},
    {"id": 3, "name": "错误类型3"},
    {"id": 4, "name": "错误类型4"},
    {"id": 5, "name": "错误类型5"},
  ];

  submitAction() {
    if (noInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写设备号");
      return;
    }

    if (descriptionInputCtrl.text.isEmpty) {
      ShowToast.normal("请填写故障描述");
      return;
    }

    if (imageUrls.isEmpty) {
      ShowToast.normal("请上传故障凭证");
      return;
    }

    // if (faultIndex == -1) {
    //   ShowToast.normal("请选择故障类型");
    //   return;
    // }
    submitEnable = false;

    String imgStr = "";
    List.generate(imageUrls.length, (index) {
      imgStr += "${index != 0 ? "," : ""}${imageUrls[index]}";
    });

    Map<String, dynamic> params = {
      "oldTerminalNo": noInputCtrl.text,
      "cause": descriptionInputCtrl.text,
      "certificate": imgStr
    };

    simpleRequest(
      url: Urls.userMaintaineApply,
      params: params,
      success: (success, json) {
        if (success) {
          ShowToast.normal("提交成功");
          Get.find<StatisticsMachineMaintainController>().loadData();
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
  void onClose() {
    noInputCtrl.dispose();
    // newNoInputCtrl.dispose();
    descriptionInputCtrl.dispose();
    super.onClose();
  }
}

class StatisticsMachineMaintainAdd
    extends GetView<StatisticsMachineMaintainAddController> {
  const StatisticsMachineMaintainAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "维修设备"),
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
                  sbhRow([
                    centRow([
                      getWidthText("维修设备编号", 14, AppColor.text2, 90, 1),
                      CustomInput(
                        textEditCtrl: controller.noInputCtrl,
                        width: (315 - 90 - 18 - 30).w,
                        heigth: 46.w,
                        placeholder: "请输入故障设备编号",
                        style: TextStyle(fontSize: 14.w, color: AppColor.text),
                        placeholderStyle: TextStyle(
                            fontSize: 14.w, color: AppColor.assisText),
                      ),
                    ]),
                    kIsWeb
                        ? gwb(0)
                        : CustomButton(
                            onPressed: () {
                              toScanBarCode(((barCode) {
                                controller.noInputCtrl.text = barCode;
                              }));
                            },
                            child: SizedBox(
                              width: 18.w + 25.w,
                              height: 46.w,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  assetsName("machine/btn_scan_code"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                  ], width: 315, height: 46),
                  // gline(315, 0.5),
                  // sbhRow([
                  //   centRow([
                  //     getWidthText("新设备编号", 14, AppColor.text2, 90, 1),
                  //     CustomInput(
                  //       textEditCtrl: controller.newNoInputCtrl,
                  //       width: (315 - 90 - 18 - 30).w,
                  //       heigth: 46.w,
                  //       placeholder: "请输入更换的新设备编号",
                  //       style: TextStyle(fontSize: 14.w, color: AppColor.text),
                  //       placeholderStyle: TextStyle(
                  //           fontSize: 14.w, color: AppColor.assisText),
                  //     ),
                  //   ]),
                  //   kIsWeb
                  //       ? gwb(0)
                  //       : CustomButton(
                  //           onPressed: () {
                  //             toScanBarCode(((barCode) {
                  //               controller.newNoInputCtrl.text = barCode;
                  //             }));
                  //           },
                  //           child: SizedBox(
                  //             width: 18.w + 25.w,
                  //             height: 46.w,
                  //             child: Align(
                  //               alignment: Alignment.centerRight,
                  //               child: Image.asset(
                  //                 assetsName("machine/btn_scan_code"),
                  //                 width: 18.w,
                  //                 fit: BoxFit.fitWidth,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  // ], width: 315, height: 46),
                  // gline(315, 0.5),
                  // CustomButton(
                  //   onPressed: () {
                  //     showTypeSelectModel();
                  //   },
                  //   child: sbhRow([
                  //     centRow([
                  //       getWidthText("故障类型", 14, AppColor.text2, 80, 1),
                  //       GetX<StatisticsMachineMaintainAddController>(
                  //         builder: (_) {
                  //           return getWidthText(
                  //               controller.faultIndex < 0
                  //                   ? "请选择"
                  //                   : controller
                  //                           .faultList[controller.faultIndex]
                  //                       ["name"],
                  //               14,
                  //               controller.faultIndex < 0
                  //                   ? AppColor.assisText
                  //                   : AppColor.text,
                  //               315 - 80 - 30 - 18,
                  //               1);
                  //         },
                  //       )
                  //     ]),
                  //     Image.asset(
                  //       assetsName("statistics/icon_arrow_right_gray"),
                  //       width: 15.w,
                  //       fit: BoxFit.fitWidth,
                  //     )
                  //   ], width: 315, height: 44.5),
                  // ),
                  gline(315, 0.5),
                  ghb(10),
                  sbRow([
                    centRow([
                      getWidthText("故障类型", 14, AppColor.text2, 90, 1),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    CustomInput(
                      textEditCtrl: controller.descriptionInputCtrl,
                      width: (315 - 90).w,
                      heigth: 138.5.w,
                      placeholder: "描述一下设备故障问题吧...",
                      style: TextStyle(
                          fontSize: 14.w, color: AppColor.text, height: 1.5),
                      placeholderStyle: TextStyle(
                          fontSize: 14.w,
                          color: AppColor.assisText,
                          height: 1.5),
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
                      maxLines: 100,
                      // padding: EdgeInsets.only(top: 3.w),
                    ),
                  ], crossAxisAlignment: CrossAxisAlignment.start, width: 315),
                ],
              ),
            ),
            ghb(15),
            CustomUploadImageView(
              maxImgCount: 3,
              tipStr: "注：最多可上传3张，截图需包括设备损坏界面及设备编号",
              // uploadVideo: true,
              imageUpload: (imgs) {
                controller.imageUrls = imgs;
              },
            ),
            ghb(30),
            GetX<StatisticsMachineMaintainAddController>(
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
    double height = 230;
    Get.bottomSheet(Container(
      height: height.w,
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
                            controller.faultIndex = controller.faultPickIndex;
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
            height: height.w - 52.w - 1.w,
            child: CupertinoPicker.builder(
              scrollController: FixedExtentScrollController(
                  initialItem: controller.faultIndex),
              itemExtent: 40.w,
              childCount: controller.faultList.length,
              onSelectedItemChanged: (value) {
                controller.faultPickIndex = value;
              },
              itemBuilder: (context, index) {
                return Center(
                  child: GetX<StatisticsMachineMaintainAddController>(
                    builder: (_) {
                      return getSimpleText(controller.faultList[index]["name"],
                          15, AppColor.text,
                          fw: controller.faultIndex == index
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
