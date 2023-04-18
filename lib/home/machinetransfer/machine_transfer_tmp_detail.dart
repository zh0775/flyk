import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/src/size_extension.dart';

import 'package:get/get.dart';

class MachineTransferTmpDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MachineTransferTmpDetailController>(
        () => MachineTransferTmpDetailController());
  }
}

class MachineTransferTmpDetailController extends GetxController {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final tmpNameTextCtrl = TextEditingController();

  final activeCashTextCtrl = TextEditingController();
  final activeIntegralTextCtrl = TextEditingController();
  final standardsCashTextCtrl = TextEditingController();
  final standardsIntegralTextCtrl = TextEditingController();
  final againStandardsCashTextCtrl = TextEditingController();
  final againStandardsIntegralTextCtrl = TextEditingController();

  List sections = [false, false, false];

  void updateSections(List l) {
    sections = l;
    update();
  }

  @override
  void dispose() {
    tmpNameTextCtrl.dispose();
    activeCashTextCtrl.dispose();
    activeIntegralTextCtrl.dispose();
    standardsCashTextCtrl.dispose();
    standardsIntegralTextCtrl.dispose();
    againStandardsCashTextCtrl.dispose();
    againStandardsIntegralTextCtrl.dispose();
    super.dispose();
  }
}

class MachineTransferTmpDetail
    extends GetView<MachineTransferTmpDetailController> {
  final int? type; // 0: 不可编辑仅可查看 1:可编辑 2:新建
  final Map? tmpData;
  const MachineTransferTmpDetail({Key? key, this.tmpData, this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type != 0 && tmpData != null && tmpData!["name"].isNotEmpty) {
      controller.tmpNameTextCtrl.text = tmpData!["name"];
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
          backgroundColor: AppColor.pageBackgroundColor,
          appBar: getDefaultAppBar(context, "模版详情", action: [
            Visibility(
              visible: type != 0,
              child: CustomButton(
                onPressed: () {},
                child: SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: Center(
                    child: getSimpleText("保存", 14, const Color(0xFF1B1B1B)),
                  ),
                ),
              ),
            )
          ]),
          body: Stack(children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 250.w,
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Color(0xFFE0EEFF),
                        Color(0xFFF5F6F8),
                      ])),
                )),
            Positioned.fill(
                child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Visibility(
                    visible: type == 0,
                    child: centClm([
                      ghb(18),
                      getSimpleText("默认模版只能查看不可编辑", 13, AppColor.textBlack),
                      ghb(18),
                    ]),
                    replacement: ghb(16),
                  ),
                  Align(
                    child: Container(
                      constraints: BoxConstraints(
                          minWidth: 345.w,
                          maxWidth: 345.w,
                          minHeight: ScreenUtil().screenHeight -
                              kToolbarHeight -
                              (type == 0
                                  ? (18.w +
                                      18.w +
                                      calculateTextHeight(
                                          "默认模版只能查看不可编辑",
                                          13,
                                          FontWeight.normal,
                                          double.infinity,
                                          1,
                                          context,
                                          color: AppColor.textBlack))
                                  : 16.w) -
                              53.w),
                      decoration: getDefaultWhiteDec(),
                      child: Column(
                        children: [
                          ghb(30),
                          sbRow([
                            getSimpleText("模版名称", 16, AppColor.textGrey2,
                                isBold: true),
                          ], width: 345 - 15 * 2),
                          ghb(10),
                          Visibility(
                            visible: type != 0,
                            child: CustomInput(
                              textEditCtrl: controller.tmpNameTextCtrl,
                              width: (345 - 15 * 2).w,
                              heigth: 60.w,
                              placeholder: "点击填写模版名称",
                              placeholderStyle: TextStyle(
                                  fontSize: 18.sp,
                                  color: AppColor.textGrey,
                                  fontWeight: AppDefault.fontBold),
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: AppColor.textBlack,
                                  fontWeight: AppDefault.fontBold),
                            ),
                          ),
                          Visibility(
                            visible: type == 0,
                            child: sbhRow([
                              getSimpleText(
                                  tmpData != null && tmpData!["name"] != null
                                      ? tmpData!["name"]
                                      : "",
                                  18,
                                  AppColor.textBlack,
                                  isBold: true)
                            ], width: 345 - 15 * 2, height: 60),
                          ),
                          gline(345 - 15 * 2, 0.5),
                          ghb(15),
                          sbRow([
                            getSimpleText("创建时间", 16, const Color(0xFF808080)),
                            getSimpleText(
                                type == 2 ? "-.-.-" : tmpData!["createDate"],
                                16,
                                const Color(0xFF808080)),
                          ], width: 345 - 15 * 2),
                          ghb(35),
                          GetBuilder<MachineTransferTmpDetailController>(
                            init: controller,
                            builder: (controller) {
                              return Column(
                                children: controller.sections
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return e.value
                                      ? tmpChild(e.key, "", "")
                                      : const SizedBox();
                                }).toList(),
                              );
                            },
                          ),
                          ghb(type != 0 ? 109 : 0),
                          Visibility(
                              visible: type != 0,
                              child: CustomButton(
                                onPressed: () {
                                  ShowTmpChildSelected(context);
                                },
                                child: Container(
                                  width: 315.w,
                                  height: 50.w,
                                  margin: EdgeInsets.only(bottom: 26.w),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(5.w)),
                                  child: Center(
                                    child: centRow([
                                      Icon(
                                        Icons.add_rounded,
                                        size: 18.w,
                                        color: const Color(0xFF1B1B1B),
                                      ),
                                      gwb(5),
                                      getSimpleText(
                                          "添加其他类型", 14, const Color(0xFF1B1B1B),
                                          isBold: true),
                                    ]),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                  ghb(50),
                ],
              ),
            ))
          ])),
    );
  }

  Widget tmpChild(int childType, String t1, String t2) {
    if (t1.isNotEmpty && type != 0) {
      if (childType == 0) {
        controller.activeCashTextCtrl.text = t1;
      } else if (childType == 1) {
        controller.standardsCashTextCtrl.text = t1;
      } else if (childType == 2) {
        controller.activeCashTextCtrl.text = t1;
      }
    }
    if (t2.isNotEmpty && type != 0) {
      if (childType == 0) {
        controller.activeIntegralTextCtrl.text = t2;
      } else if (childType == 1) {
        controller.standardsIntegralTextCtrl.text = t2;
      } else if (childType == 2) {
        controller.againStandardsIntegralTextCtrl.text = t2;
      }
    }

    return centClm([
      sbRow([
        getSimpleText(
            childType == 0
                ? "激活"
                : childType == 1
                    ? "达标"
                    : "连续达标",
            16,
            const Color(0xFF454D74)),
      ], width: 345 - 15 * 2),
      ghb(15),
      Container(
        width: (345 - 15 * 2).w,
        height: 60.w,
        decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(5.w)),
        child: Center(
          child: sbRow([
            getSimpleText("奖励金返现", 16, const Color(0xFF4D4D4D), isBold: true),
            type == 0
                ? getSimpleText(t1, 16, AppColor.textBlack, isBold: true)
                : CustomInput(
                    width: (((345 - 15 * 2) - 21 * 2) / 2).w,
                    heigth: 60.w,
                    placeholder: "最高130元",
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    placeholderStyle: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.textGrey,
                        fontWeight: AppDefault.fontBold),
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.textBlack,
                        fontWeight: AppDefault.fontBold),
                    textEditCtrl: childType == 0
                        ? controller.activeCashTextCtrl
                        : childType == 1
                            ? controller.standardsCashTextCtrl
                            : controller.againStandardsCashTextCtrl,
                  )
          ], width: ((345 - 15 * 2) - 21 * 2)),
        ),
      ),
      ghb(5),
      Container(
        width: (345 - 15 * 2).w,
        height: 60.w,
        decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(5.w)),
        child: Center(
          child: sbRow([
            getSimpleText("积分", 16, const Color(0xFF4D4D4D), isBold: true),
            type == 0
                ? getSimpleText(t2, 16, AppColor.textBlack, isBold: true)
                : CustomInput(
                    width: (((345 - 15 * 2) - 21 * 2) / 2).w,
                    heigth: 60.w,
                    placeholder: "最高80",
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    placeholderStyle: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.textGrey,
                        fontWeight: AppDefault.fontBold),
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColor.textBlack,
                        fontWeight: AppDefault.fontBold),
                    textEditCtrl: childType == 0
                        ? controller.activeIntegralTextCtrl
                        : childType == 1
                            ? controller.standardsIntegralTextCtrl
                            : controller.againStandardsIntegralTextCtrl,
                  )
          ], width: ((345 - 15 * 2) - 21 * 2)),
        ),
      ),
      ghb(26),
    ]);
  }

  ShowTmpChildSelected(BuildContext context) {
    List l = controller.sections.map((e) => e).toList();

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sfctx, setSFState) {
            return SizedBox(
              width: 375.w,
              height: 463.5.w,
              child: Column(
                children: [
                  sbRow([
                    const SizedBox(),
                    CustomButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Icon(
                        Icons.highlight_off,
                        size: 37.w,
                        color: Colors.white,
                      ),
                    ),
                  ], width: 375 - 55.5 * 2),
                  sbRow([
                    const SizedBox(),
                    Container(
                      width: 1.5.w,
                      height: 20.w,
                      color: Colors.white,
                    ),
                  ], width: 375 - 73.5 * 2),
                  Container(
                    width: 315.w,
                    height: 335.5.w,
                    decoration: getDefaultWhiteDec(),
                    child: Column(
                      children: [
                        ghb(20),
                        sbRow([
                          Container(
                            width: 12.5.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                                color: AppColor.textBlack,
                                borderRadius: BorderRadius.circular(1.w)),
                          ),
                          getSimpleText("请选择下发奖励类型", 15, AppColor.textBlack,
                              isBold: true),
                          Container(
                            width: 12.5.w,
                            height: 2.w,
                            decoration: BoxDecoration(
                                color: AppColor.textBlack,
                                borderRadius: BorderRadius.circular(1.w)),
                          )
                        ], width: 187),
                        ghb(10),
                        getSimpleText(
                            "为您提供的类型，下发额度由自己填写", 11, AppColor.textGrey),
                        ghb(23),
                        ...l.asMap().entries.map((e) {
                          return Container(
                            width: 270.w,
                            height: 50.w,
                            margin: EdgeInsets.only(bottom: 3.w),
                            decoration: BoxDecoration(
                              color: e.value
                                  ? const Color(0xFFFFEEF0)
                                  : const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            child: Center(
                              child: sbhRow([
                                centRow([
                                  getSimpleText(
                                      e.key == 0
                                          ? "激活"
                                          : e.key == 1
                                              ? "达标"
                                              : "连续达标",
                                      16,
                                      AppColor.textBlack,
                                      isBold: true),
                                  getSimpleText(
                                    e.value ? "(已添加)" : "",
                                    13,
                                    AppColor.textGrey,
                                  ),
                                ]),
                                CustomButton(
                                  onPressed: () {
                                    setSFState(() {
                                      l[e.key] = !l[e.key];
                                    });
                                  },
                                  child: Image.asset(
                                    assetsName(
                                        "home/machinetransfer/${e.value ? "btn_section_sub" : "btn_section_add"}"),
                                    width: 22.w,
                                    height: 22.w,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ], width: 270 - 23 * 2),
                            ),
                          );
                        }).toList(),
                        ghb(19),
                        CustomButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            controller.updateSections(l);
                          },
                          child: Container(
                            width: 270.w,
                            height: 45.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22.5.w),
                                gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF4282EB),
                                      Color(0xFF5BA3F7),
                                    ])),
                            child: Center(
                              child: getSimpleText("确定添加", 15, Colors.white,
                                  isBold: true),
                            ),
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
      },
    );
  }
}
