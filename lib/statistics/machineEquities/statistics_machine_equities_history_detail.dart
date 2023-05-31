
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StatisticsMachineEquitiesHistoryDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesHistoryDetailController>(
        StatisticsMachineEquitiesHistoryDetailController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesHistoryDetailController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesHistoryDetailController({this.datas});

  Map mData = {};

  @override
  void onInit() {
    mData = (datas ?? {})["data"] ?? {};

    super.onInit();
  }
}

class StatisticsMachineEquitiesHistoryDetail
    extends GetView<StatisticsMachineEquitiesHistoryDetailController> {
  const StatisticsMachineEquitiesHistoryDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "详情"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            Container(
              margin: EdgeInsets.only(top: 15.w),
              width: 345.w,
              height: 120.w,
              decoration: getDefaultWhiteDec(radius: 4),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  sbhRow([
                    getWidthText("添加对象", 14, AppColor.textGrey5, 70.5, 1,
                        textHeight: 1.3),
                    SizedBox(
                      width: (345 - 15 * 2 - 70.5).w,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: centRow(
                            [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.w),
                                child: Image.asset(
                                  assetsName("common/default_head"),
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.cover,
                                ),

                                // CustomNetworkImage(
                                //   src: AppDefault().imageUrl +
                                //       (controller.mData["data"] ?? ""),
                                //   width: 24.w,
                                //   height: 24.w,
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                              gwb(9),
                              getSimpleText(
                                  "${controller.mData["suName"] ?? ""}(${controller.mData["suMobile"] ?? ""})",
                                  14,
                                  AppColor.text2),
                            ],
                          )),
                    ),
                  ], width: 345 - 15 * 2, height: 30),
                  sbhRow([
                    getWidthText("操作时间", 14, AppColor.textGrey5, 70.5, 1,
                        textHeight: 1.3),
                    getWidthText(controller.mData["applyTime"] ?? "", 14,
                        AppColor.text2, 345 - 15 * 2 - 70.5, 1,
                        textHeight: 1.3),
                  ], width: 345 - 15 * 2, height: 30),
                  sbhRow([
                    getWidthText("当前状态", 14, AppColor.textGrey5, 70.5, 1,
                        textHeight: 1.3),
                    getWidthText(
                        "已完成", 14, AppColor.text2, 345 - 15 * 2 - 70.5, 1,
                        textHeight: 1.3),
                  ], width: 345 - 15 * 2, height: 30)
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15.w),
              width: 345.w,
              decoration: getDefaultWhiteDec(radius: 4),
              child: Column(
                children: [
                  sbhRow([
                    getRichText(
                        "设备列表",
                        "(共${(controller.mData["detail"] ?? []).length}台)",
                        16,
                        AppColor.text,
                        12,
                        AppColor.textGrey5,
                        isBold: true),
                  ], width: 345 - 15 * 2, height: 45),
                  ghb(4.5),
                  ...List.generate((controller.mData["detail"] ?? []).length,
                      (index) {
                    Map data = controller.mData["detail"][index];
                    // data["tNo"] = "1928309182093812903819028391823901823";
                    data["tStatus"] = "正常";
                    // data["tbName"] = "立刷电签K300";
                    String sn = data["terminal_NO"] ?? "";
                    int overLength = 15;
                    if (sn.length > overLength) {
                      int star =
                          ((sn.length - (sn.length - overLength) - 4) / 2)
                              .round();
                      sn = sn.replaceRange(
                          star, star + sn.length - overLength, "****");
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.w),
                      child: sbRow([
                        centRow([
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.w),
                            child: Image.asset(
                              assetsName("common/default_machine"),
                              width: 45.w,
                              height: 45.w,
                              fit: BoxFit.fill,
                            ),
                          ),
                          gwb(7),
                          centClm([
                            sbRow([
                              getSimpleText(data["terninal_Name"] ?? "", 15,
                                  AppColor.text,
                                  isBold: true),
                              centRow([
                                Container(
                                  width: 7.5.w,
                                  height: 7.5.w,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF3AD3D2),
                                      borderRadius:
                                          BorderRadius.circular(7.5.w / 2)),
                                ),
                                gwb(5),
                                getSimpleText("${data["tStatus"] ?? ""}", 12,
                                    AppColor.text2)
                              ])
                            ], width: 315 - 45 - 7),
                            CustomButton(
                              onPressed: () {
                                showSnNoModel(
                                    Global.navigatorKey.currentContext!,
                                    data["tNo"] ?? "");
                              },
                              child: SizedBox(
                                height: 25.w,
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: getSimpleText(
                                        "设备编号：$sn", 12, AppColor.text3)),
                              ),
                            ),
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                        ]),
                      ], width: 315),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  showSnNoModel(BuildContext context, String sn) {
    showGeneralDialog(
      barrierLabel: "",
      barrierDismissible: true,
      context: context,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 345.w,
              height: 172.5.w,
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Image.asset(
                      assetsName(
                        "common/btn_model_close",
                      ),
                      width: 37.w,
                      height: 56.5.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: 345.w,
                    height: 116.w,
                    decoration: BoxDecoration(
                        color: AppColor.lineColor,
                        borderRadius: BorderRadius.circular(5.w)),
                    child: Column(
                      children: [
                        ghb(25),
                        getSimpleText("点击机具编号即可复制", 15, AppColor.textBlack,
                            isBold: true),
                        ghb(13.5),
                        CustomButton(
                          onPressed: () {
                            copyClipboard(sn);
                          },
                          child: Container(
                            width: 270.w,
                            height: 35.w,
                            decoration: getDefaultWhiteDec(),
                            child: Center(
                                child: getSimpleText(sn, 20, AppColor.textBlack,
                                    isBold: true)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
